variable "credentials_profile" {
	type = string
	description = "Perfil de credenciais da AWS"
}

variable "region" {
	type = string
	description = "Região dos recursos"
}

variable "key_name" {
	type = string
	description = "Par de chaves para acesso SSH"
}

variable "identity_file_path" {
	type = string
	description = "Caminho para o arquivo com SSH private key"
}

variable "allowed_ips" {
	type = list(string)
	description = "IPs allowed to access ML Playground"
}

variable "instance_type" {
	type = string
	default = "t2.micro"
	description = "Default EC2 instance type for SageMaker"
}
