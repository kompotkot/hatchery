# Predifined variables for resources

# Common
variable "region" {
  description = "The region that the machine should be created in"
  default     = "us-east-1"
}

# IAM Role
variable "iam_role_name" {
  default = "iam_role_lambda"
}

variable "iam_role_inline_policy_name" {
  default = "iam_role_lambda_inline_policy"
}

# Lambda Edge
variable "lambda_name" {
  default = "lambda_hatchery_files_access"
}

variable "lambda_handler_function" {
  description = "Function name of lambda handler"
  default     = "lambda_handler"
}

variable "lambda_payload_filename" {
  description = "Name of ZIP file we upload"
  default     = "lambda_function.zip"
}
