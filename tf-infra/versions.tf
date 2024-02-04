terraform {
  required_providers {
    contabo = {
      source  = "contabo/contabo"
      version = "~> 0.1.23"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.35.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}
