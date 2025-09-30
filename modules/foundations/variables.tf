variable "tf_state_bucket_name" {
  type = string
}

variable "terraform_infra_group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
