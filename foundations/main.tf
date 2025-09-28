terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"

  backend "s3" {
    bucket       = "capstone-community-connect-tf-state"
    key          = "foundations/terraform.tfstate"
    region       = "ap-south-2"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region  = "ap-south-2"
  profile = "capstone-infra"
}
