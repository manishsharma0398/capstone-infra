# live/data/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders())
  env         = "Data"
}

terraform {
  source = "../../modules/data"
}

inputs = {
  environment_slug = "${local.env}"
  cidr_block       = "172.0.0.0/16"
  azs              = ["ap-south-2a", "ap-south-2b", "ap-south-2c"]
  private_subnets  = ["172.0.11.0/24", "172.0.12.0/24", "172.0.13.0/24"]

  tags = {
    Project     = "Capstone"
    Environment = "${local.env}"
    Owner       = "Manish"
    Role        = "Terraform-State"
    ManagedBy   = "Terraform"
  }
}