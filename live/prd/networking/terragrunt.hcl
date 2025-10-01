include "root" {
  path = find_in_parent_folders()
}

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders())
  env         = "prd"
}

terraform {
  source = "../../../modules/networking"
}

# Just declare dependency, no outputs needed
dependency "foundations" {
  config_path  = "../../foundations"
  skip_outputs = true
}

inputs = {
  environment_slug = "${local.env}"
  cidr_block       = "192.168.0.0/16"
  azs              = ["ap-south-2a", "ap-south-2b", "ap-south-2c"]
  public_subnets   = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  private_subnets  = ["192.168.11.0/24", "192.168.12.0/24", "192.168.13.0/24"]

  tags = {
    Project     = "Capstone"
    Environment = "${local.env}"
    Owner       = "Manish"
    Role        = "Terraform-State"
    ManagedBy   = "Terraform"
  }
}