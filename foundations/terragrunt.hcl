# foundations/terragrunt.hcl

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../modules/foundations"
}

inputs = {
  tf_state_bucket_name       = "capstone-community-connect-tf-state"
  terraform_infra_group_name = "capstone-project-infra"
    
  tags = {
    Project     = "Capstone"
    Environment = "Infra"
    Owner       = "Manish"
    Role        = "Terraform-State"
    ManagedBy   = "Terraform"
  }
}
