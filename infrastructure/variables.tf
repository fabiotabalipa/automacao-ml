variable "credentials_profile" {
	type = string
	description = "Perfil de credenciais da AWS"
}

variable "region" {
	type = string
	description = "Região dos recursos"
}

variable "instance_type" {
	type = string
	default = "t2.micro"
	description = "EC2 instance type"
}

variable "ami" {
	type = string
	description = "AMI for EC2 instance"
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
	description = "IPs allowed to ssh EC2 instance"
}

variable "team_pass" {
	type = string
	description = "Password to allow access to Jupyter Lab"
	sensitive = true
}

variable "github_repo_name" {
	type = string
	description = "Name from github repository"
}

variable "github_user_name" {
	type = string
	description = "Username from github"
}

variable "github_access_token" {
	type = string
	description = "Access token from github"
	sensitive = true
}