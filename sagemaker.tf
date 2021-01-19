resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "stop_on_idle" {
	name = "stop-idle-instance-40min"
	on_start = base64encode(<<-EOT
  	#!/bin/bash

		set -e

		# PARAMETERS
		IDLE_TIME=2400

		echo "Fetching the autostop script"
		wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py

		echo "Starting the SageMaker autostop script in cron"

		(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/python $PWD/autostop.py --time $IDLE_TIME --ignore-connections") | crontab -
  EOT
	)
}

resource "aws_sagemaker_notebook_instance" "ml_playground" {
  name = "ml-playground"
  role_arn = aws_iam_role.service_sagemaker.arn
  instance_type = "ml.p2.xlarge"
	volume_size = 80
	subnet_id = [for s in data.aws_subnet.default : s.id][0]
	security_groups = [ aws_security_group.custom_ips.id ]
	direct_internet_access = "Enabled"
	lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.stop_on_idle.name
	depends_on = [ 
		aws_iam_role.service_sagemaker,
		aws_security_group.custom_ips,
		aws_sagemaker_notebook_instance_lifecycle_configuration.stop_on_idle
	]
}
