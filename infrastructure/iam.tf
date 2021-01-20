resource "aws_iam_role" "service_ec2" {
	name_prefix = "tf_ec2_"
  assume_role_policy = jsonencode(
		{
			Version = "2012-10-17"
			Statement = [
				{
					Action = "sts:AssumeRole"
					Principal = {
						Service = "ec2.amazonaws.com"
					}
					Effect = "Allow"
				}
			]
		}
	)
}

resource "aws_iam_instance_profile" "service_ec2" {
	name_prefix = "tf_ec2_"
	role = aws_iam_role.service_ec2.name
	depends_on = [ 
		aws_iam_role.service_ec2
	]
}

resource "aws_iam_policy" "ec2_stop_instance" {
	name_prefix = "tf_ec2_stop_instance_"
	policy = jsonencode(
		{
			"Version": "2012-10-17",
			"Statement": [
				{
						"Effect": "Allow",
						"Action": [
							"ec2:StopInstances"
						],
						"Resource": [
								aws_instance.jupyter_lab.arn
						]
				}
			]
		}
	)
	depends_on = [ 
		aws_instance.jupyter_lab
	]
}

resource "aws_iam_role_policy_attachment" "ec2_stop_instance" {
  role = aws_iam_role.service_ec2.name
  policy_arn = aws_iam_policy.ec2_stop_instance.arn
	depends_on = [ 
		aws_iam_role.service_ec2,
		aws_iam_policy.ec2_stop_instance
	]
}

resource "aws_iam_role" "service_lambda" {
	name_prefix = "tf_lambda_"
  assume_role_policy = jsonencode(
		{
			Version = "2012-10-17"
			Statement = [
				{
					Action = "sts:AssumeRole"
					Principal = {
						Service = "lambda.amazonaws.com"
					}
					Effect = "Allow"
				}
			]
		}
	)
}

resource "aws_iam_policy" "ec2_start_instance" {
	name_prefix = "tf_lambda_ec2_start_instance_"
	policy = jsonencode(
		{
			"Version": "2012-10-17",
			"Statement": [
				{
						"Effect": "Allow",
						"Action": [
							"ec2:StartInstances"
						],
						"Resource": [
								aws_instance.jupyter_lab.arn
						]
				},
				{
						"Effect": "Allow",
						"Action": [
							"ec2:DescribeInstances"
						],
						"Resource": "*"
				}
			]
		}
	)
	depends_on = [ 
		aws_instance.jupyter_lab
	]
}

resource "aws_iam_role_policy_attachment" "ec2_start_instance" {
  role = aws_iam_role.service_lambda.name
  policy_arn = aws_iam_policy.ec2_start_instance.arn
	depends_on = [ 
		aws_iam_role.service_lambda,
		aws_iam_policy.ec2_start_instance
	]
}
