# IAM role output

output "hatchery_iam_role_arn" {
  value = aws_iam_role.hatchery_iam_role.arn
}
