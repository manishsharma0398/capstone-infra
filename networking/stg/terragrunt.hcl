include "root" {
  path = find_in_parent_folders()
}

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders())
  env         = "stg"
}

terraform {
  source = "..//resources"
}

inputs = {
  environment_slug   = "${local.env}"
  cidr_block     = "10.0.0.0/16"
  azs            = ["ap-south-2a", "ap-south-2b", "ap-south-2c"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  tags = {
    Project = "Capstone"
    Owner   = "Manish"
    Env     = "stg"
  }
}