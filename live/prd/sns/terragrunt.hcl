# live\prd\sns\terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders())
  env         = "prd"
}

terraform {
  source = "../../../modules/sns"
}

inputs = {
  environment_slug = "${local.env}"
  sns_name         = "user-notifications"

  tags = {
    Project     = "Capstone"
    Environment = "${local.env}"
    Owner       = "Manish"
    Role        = "Terraform-State"
    ManagedBy   = "Terraform"
  }
}