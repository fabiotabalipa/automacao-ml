data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/start_ec2.py"
  output_path = "${path.module}/lambda/start_ec2.py.zip"
}

resource "aws_lambda_function" "start_ec2" {
  function_name = "tf_start_ec2_instance"
  role = aws_iam_role.service_lambda.arn
	filename = data.archive_file.lambda.output_path
	source_code_hash = filebase64sha256(data.archive_file.lambda.output_path)
  handler = "start_ec2.lambda_handler"
  runtime = "python3.8"
	memory_size = 128
	timeout = 600
  environment {
    variables = {
      "TEAM_PASS" = var.team_pass
			"EC2_REGION" = var.region,
			"EC2_INSTANCE_ID" = aws_instance.jupyter_lab.id
    }
  }
	depends_on = [ 
		aws_iam_role.service_lambda,
		aws_instance.jupyter_lab
	]
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_ec2.arn
  principal = "apigateway.amazonaws.com"
	depends_on = [ 
		aws_lambda_function.start_ec2
	]
}
