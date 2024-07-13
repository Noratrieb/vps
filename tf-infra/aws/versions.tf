terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.35.0"
    }
  }
  backend "s3" {
    bucket = "nilstrieb-states"
    key = "aws-terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}
