variable "default_vpc_id" {
	type = string
	description = "Default VPC id"
}

variable "allowed_ips" {
	type = list(string)
	description = "IPs allowed to access ML Playground"
}
