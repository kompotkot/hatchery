# Main variables

variable "region" {
  description = "The region that the machine should be created in"
  default     = "us-east-1"
}
variable "tag_resource" {
  description = "Resource common tag"
  default     = "hatchery"
}

# S3 bucket
variable "s3_bucket_files_name" {
  default = "hatchery-files"
}
variable "s3_bucket_sources_name" {
  default = "hatchery-sources"
}
variable "source_code_zip" {
  default = "lambda_function.zip"
}

# IAM role
variable "iam_role_name" {
  description = "Policy name"
  default     = "hatchery_iam_role_lambda"
}
variable "iam_role_inline_name" {
  description = "Inpine policy name"
  default     = "hatchery_iam_role_lambda_inline"
}

# Lambda function
variable "lambda_function_name" {
  default = "lambda_hatchery_files_access"
}
variable "lambda_function_handler" {
  description = "Function name of lambda handler"
  default     = "lambda_function.lambda_handler"
}
