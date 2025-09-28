# S3 bucket for state
resource "aws_s3_bucket" "tf_state" {
  bucket = "capstone-community-connect-tf-state"

  tags = {
    Project     = "Capstone"
    Environment = "Infra"
    Owner       = "Manish"
    Role        = "Terraform-State"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "versioning_tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Attach Terraform S3 policy to the infra group
resource "aws_iam_group_policy" "terraform_s3_state_access" {
  name  = "TerraformS3StateAccess"
  group = "capstone-project-infra"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowListBucket"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::capstone-community-connect-tf-state"
        Condition = {
          StringLike = {
            "s3:prefix" = "foundation/*"
          }
        }
      },
      {
        Sid      = "AllowStateObjectAccess"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "arn:aws:s3:::capstone-community-connect-tf-state/foundation/*"
      },
      {
        Sid      = "AllowLockFileManagement"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "arn:aws:s3:::capstone-community-connect-tf-state/foundation/*.tflock"
      }
    ]
  })
}
