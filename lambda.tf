data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/main.py"
  output_path = "${path.module}/lambda/main.py.zip"
}

resource "aws_lambda_function" "wake_up_ml_playground" {
  function_name = "wake_up_ml_playground"
  role = aws_iam_role.service_lambda.arn
	filename = data.archive_file.lambda.output_path
	source_code_hash = filebase64sha256(data.archive_file.lambda.output_path)
  handler = "main.lambda_handler"
  runtime = "python3.8"
	memory_size = 128
	timeout = 60
  environment {
    variables = {
			"SAGEMAKER_INSTANCE_NAME" = aws_sagemaker_notebook_instance.ml_playground.name,
			"SAGEMAKER_URL" = aws_sagemaker_notebook_instance.ml_playground.url
    }
  }
	depends_on = [ 
		aws_iam_role.service_lambda,
		aws_sagemaker_notebook_instance.ml_playground
	]
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.wake_up_ml_playground.arn
  principal = "apigateway.amazonaws.com"
	depends_on = [ 
		aws_lambda_function.wake_up_ml_playground
	]
}
