terraform {
  required_providers {
    contabo = {
      source  = "contabo/contabo"
      version = "~> 0.1.23"
    }
  }
  backend "s3" {
    bucket = "nilstrieb-states"
    key = "contabo-terraform.tfstate"
    region = "eu-central-1"
  }
}
