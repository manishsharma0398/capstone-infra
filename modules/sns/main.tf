locals {
  full_name = "${var.sns_name}-${var.environment_slug}-${var.aws_region}"
}

resource "aws_sns_topic" "new_user_creation" {
  name = local.full_name

  tags = merge(var.tags, {
    Name     = var.sns_name
    FullName = local.full_name
  })
}
