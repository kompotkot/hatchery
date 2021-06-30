# Lambda functions main

resource "aws_lambda_function" "hatchery_lambda_function" {
  filename = "lambda_function.zip"
  #   s3_bucket     = var.s3_sources_name
  #   s3_key = var.lambda_payload_filename
  function_name = var.lambda_function_name
  role          = var.hatchery_iam_role_arn
  handler       = var.lambda_function_handler

  source_code_hash = filebase64sha256("lambda_function.zip")

  runtime = "python3.8"
  publish = true
}
