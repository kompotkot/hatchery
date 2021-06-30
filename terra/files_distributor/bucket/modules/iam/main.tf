# IAM role main

resource "aws_iam_role" "hatchery_iam_role" {
  name               = var.iam_role_name
  assume_role_policy = file("modules/iam/files/iam_role_lambda_policy.json")

  inline_policy {
    name   = var.iam_role_inline_name
    policy = file("modules/iam/files/iam_role_lambda_inline_policy.json")
  }
}
