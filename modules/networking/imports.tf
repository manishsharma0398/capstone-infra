data "terraform_remote_state" "notifications_lambda" {
  backend = "s3"

  config = {
    bucket = "capstone-community-connect-tf-state"
    key    = "lambda/capstone-notifications/${var.environment_slug}.tfstate"
    region = "${var.lambda_region}"
  }
}
