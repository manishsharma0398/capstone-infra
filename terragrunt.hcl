# Root terragrunt.hcl (shared by all environments)

# Local values (shared defaults)
locals {
  project = "Capstone"
  owner   = "Manish"
  region  = "ap-south-2"

  common_tags = {
    Project = "Capstone"
    Owner   = "Manish"
    Managed = "Terraform"
  }
}

# Generate a backend config for every child
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket  = "capstone-community-connect-tf-state"
    key     = "${path_relative_to_include()}.tfstate"
    region  = "${local.region}"
    encrypt = true
  }
}
EOF
}

# Generate provider + versions (shared everywhere)
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = "~> 1.13.3"
}

provider "aws" {
  region = "${local.region}"
}
EOF
}

# Pass down shared inputs
inputs = {
  project     = local.project
  owner       = local.owner
  region      = local.region
  common_tags = local.common_tags
}
