provider "aws" {
  region = var.region
}

# IAM Role
resource "aws_iam_role" "iam_role_lambda" {
  name               = var.iam_role_name
  assume_role_policy = file("files/iam_role_lambda_policy.json")

  inline_policy {
    name   = var.iam_role_inline_policy_name
    policy = file("files/iam_role_lambda_inline_policy.json")
  }
}

# Lambda Edge
resource "aws_lambda_function" "lambda_hatchery_files_access" {
  filename      = var.lambda_payload_filename
  function_name = var.lambda_name
  role          = aws_iam_role.iam_role_lambda.arn
  handler       = var.lambda_handler_function

  # TODO(kompotkot): Upload code to S3 or somewere
  source_code_hash = filebase64sha256(var.lambda_payload_filename)

  runtime = "python3.8"

  environment {
    variables = {
      password = "123456"
    }
  }
}
