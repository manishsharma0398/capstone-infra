# S3 bucket for state
resource "aws_s3_bucket" "tf_state" {
  count  = var.create_state_bucket ? 1 : 0
  bucket = var.tf_state_bucket_name
  tags   = var.tags
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
  group = var.terraform_infra_group_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowListBucket"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::${var.tf_state_bucket_name}"
      },
      {
        Sid      = "AllowStateObjectAccess"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "arn:aws:s3:::${var.tf_state_bucket_name}/*"
      },
    ]
  })
}
