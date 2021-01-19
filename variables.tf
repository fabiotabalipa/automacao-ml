variable "default_vpc_id" {
	type = string
	description = "Default VPC id"
}

variable "allowed_ips" {
	type = list(string)
	description = "IPs allowed to access ML Playground"
}

variable "instance_type" {
	type = string
	default = "ml.t2.2xlarge"
	description = "Default EC2 instance type for SageMaker"
}