# Lambda functions output

output "hatchery_lambda_arn" {
  value = aws_lambda_function.hatchery_lambda_function.arn
}
