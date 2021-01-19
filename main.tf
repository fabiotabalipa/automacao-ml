terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.23.0"
    }
  }
}

provider "aws" {
  profile = "fabiotabalipa"
	region = "us-east-2"
}
