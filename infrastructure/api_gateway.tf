resource "aws_api_gateway_rest_api" "start_jupyter_lab" {
	name = "jupyter-lab"
	endpoint_configuration {
		types = ["EDGE"]
  }
}

resource "aws_api_gateway_rest_api_policy" "custom_ips" {
  rest_api_id = aws_api_gateway_rest_api.start_jupyter_lab.id
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
		aws_api_gateway_rest_api.start_jupyter_lab
	]
}

resource "aws_api_gateway_resource" "start" {
	path_part = "start"
  rest_api_id = aws_api_gateway_rest_api.start_jupyter_lab.id
  parent_id = aws_api_gateway_rest_api.start_jupyter_lab.root_resource_id
	depends_on = [ 
		aws_api_gateway_rest_api.start_jupyter_lab
	]
}

resource "aws_api_gateway_method" "get_start" {
  rest_api_id = aws_api_gateway_rest_api.start_jupyter_lab.id
  resource_id = aws_api_gateway_resource.start.id
  http_method = "GET"
  authorization = "NONE"
	depends_on = [ 
		aws_api_gateway_rest_api.start_jupyter_lab,
		aws_api_gateway_resource.start
	]
}

resource "aws_api_gateway_integration" "api_gateway_lambda" {
  rest_api_id = aws_api_gateway_rest_api.start_jupyter_lab.id
  resource_id = aws_api_gateway_resource.start.id
  http_method = aws_api_gateway_method.get_start.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.start_ec2.invoke_arn
	depends_on = [ 
		aws_api_gateway_rest_api.start_jupyter_lab,
		aws_api_gateway_resource.start,
		aws_api_gateway_method.get_start,
		aws_lambda_function.start_ec2
	]
}

resource "aws_api_gateway_deployment" "api_gateway_lambda_deploy" {
  rest_api_id = aws_api_gateway_rest_api.start_jupyter_lab.id
  stage_name  = "v1"
	depends_on = [ 
		aws_api_gateway_rest_api.start_jupyter_lab,
		aws_api_gateway_integration.api_gateway_lambda,
		aws_api_gateway_rest_api_policy.custom_ips
	]
}
