resource "aws_api_gateway_rest_api" "wake_up_ml_playground" {
	name = "ml-playground"
	endpoint_configuration {
		types = ["EDGE"]
  }
}

resource "aws_api_gateway_rest_api_policy" "custom_ips" {
  rest_api_id = aws_api_gateway_rest_api.wake_up_ml_playground.id
  policy = jsonencode(
		{
			Version = "2012-10-17",
			Statement = [
			{
					Effect = "Allow",
					Principal = "*",
					Action = "execute-api:Invoke",
					Resource = "execute-api:/*/*/*"
					Condition = {
						"IpAddress": {
							"aws:SourceIp": var.allowed_ips
						}
					}
			}
    ]
		}
	)
	depends_on = [ 
		aws_api_gateway_rest_api.wake_up_ml_playground
	]
}

resource "aws_api_gateway_resource" "wake_up" {
	path_part = "wake-up"
  rest_api_id = aws_api_gateway_rest_api.wake_up_ml_playground.id
  parent_id = aws_api_gateway_rest_api.wake_up_ml_playground.root_resource_id
	depends_on = [ 
		aws_api_gateway_rest_api.wake_up_ml_playground
	]
}

resource "aws_api_gateway_method" "get_wake_up" {
  rest_api_id = aws_api_gateway_rest_api.wake_up_ml_playground.id
  resource_id = aws_api_gateway_resource.wake_up.id
  http_method = "GET"
  authorization = "NONE"
	depends_on = [ 
		aws_api_gateway_rest_api.wake_up_ml_playground,
		aws_api_gateway_resource.wake_up
	]
}

resource "aws_api_gateway_integration" "api_gateway_lambda" {
  rest_api_id = aws_api_gateway_rest_api.wake_up_ml_playground.id
  resource_id = aws_api_gateway_resource.wake_up.id
  http_method = aws_api_gateway_method.get_wake_up.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.wake_up_ml_playground.invoke_arn
	depends_on = [ 
		aws_api_gateway_rest_api.wake_up_ml_playground,
		aws_api_gateway_resource.wake_up,
		aws_api_gateway_method.get_wake_up,
		aws_lambda_function.wake_up_ml_playground
	]
}

resource "aws_api_gateway_deployment" "api_gateway_lambda_deploy" {
  rest_api_id = aws_api_gateway_rest_api.wake_up_ml_playground.id
  stage_name  = "v1"
	depends_on = [ 
		aws_api_gateway_rest_api.wake_up_ml_playground,
		aws_api_gateway_integration.api_gateway_lambda,
		aws_api_gateway_rest_api_policy.custom_ips
	]
}
