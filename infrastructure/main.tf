terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.23.0"
    }
  }
}

provider "aws" {
  profile = var.credentials_profile
	region = var.region
}
