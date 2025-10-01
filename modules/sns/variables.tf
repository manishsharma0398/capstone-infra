variable "sns_name" {
  description = "SNS name"
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "Default AWS region"
  default     = "ap-south-2"
}

variable "environment_slug" {
  description = "Environment short name (stg, prd, data)"
  type        = string
}
