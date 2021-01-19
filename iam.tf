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

resource "aws_iam_role" "service_sagemaker" {
	name_prefix = "tf_sagemaker_"
  assume_role_policy = jsonencode(
		{
			Version = "2012-10-17"
			Statement = [
				{
					Action = "sts:AssumeRole"
					Principal = {
						Service = "sagemaker.amazonaws.com"
					}
					Effect = "Allow"
				}
			]
		}
	)
}

resource "aws_iam_policy" "lambda_notebook" {
	name_prefix = "tf_sagemaker_"
	policy = jsonencode(
		{
			"Version": "2012-10-17",
			"Statement": [
				{
						"Effect": "Allow",
						"Action": [
							"ec2:DescribeNetworkInterfaces",
							"ec2:DescribeVpcs",
							"kms:ListAliases",
							"iam:ListRoles",
							"ec2:DescribeSubnets",
							"ec2:DescribeSecurityGroups",
							"ec2:CreateNetworkInterface",
							"iam:CreatePolicy",
							"ec2:DeleteNetworkInterface",
							"iam:CreateRole",
							"iam:AttachRolePolicy",
							"sagemaker:StartNotebookInstance"
						],
						"Resource": [
								aws_sagemaker_notebook_instance.ml_playground.arn
						]
				}
			]
		}
	)
	depends_on = [ 
		aws_sagemaker_notebook_instance.ml_playground
	]
}


resource "aws_iam_policy" "sagemaker_notebook" {
	name_prefix = "tf_sagemaker_"
	policy = jsonencode(
		{
			"Version": "2012-10-17",
			"Statement": [
				{
						"Effect": "Allow",
						"Action": [
							"sagemaker:StopNotebookInstance",
							"sagemaker:DescribeNotebookInstance"
						],
						"Resource": [
								aws_sagemaker_notebook_instance.ml_playground.arn
						]
				}
			]
		}
	)
	depends_on = [ 
		aws_sagemaker_notebook_instance.ml_playground 
	]
}

resource "aws_iam_role_policy_attachment" "lambda_notebook" {
  role = aws_iam_role.service_lambda.name
  policy_arn = aws_iam_policy.lambda_notebook.arn
	depends_on = [ 
		aws_iam_role.service_lambda,
		aws_iam_policy.lambda_notebook
	]
}

resource "aws_iam_role_policy_attachment" "sagemaker_notebook" {
  role = aws_iam_role.service_sagemaker.name
  policy_arn = aws_iam_policy.sagemaker_notebook.arn
	depends_on = [ 
		aws_iam_role.service_sagemaker,
		aws_iam_policy.sagemaker_notebook
	]
}
