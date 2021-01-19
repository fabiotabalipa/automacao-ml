data "aws_subnet_ids" "default" {
  vpc_id = var.default_vpc_id
}

data "aws_subnet" "default" {
  for_each = data.aws_subnet_ids.default.ids
  id = each.value
	depends_on = [ 
		data.aws_subnet_ids.default
	]
}

resource "aws_security_group" "custom_ips" {
  name = "tf_ml_playground_custom_ips"
  description = "Allow custom IPs to access ML Playground"
  vpc_id = var.default_vpc_id
  ingress {
			description = "HTTPS from custom IPs"
			from_port   = 443
			to_port     = 443
			protocol    = "tcp"
			cidr_blocks = var.allowed_ips
	}
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
