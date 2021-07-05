# Main
# S3 bucket, IAM role, Lamda function for 
# file destribution infrastructure

provider "aws" {
  region = var.region
}

module "s3_bucket" {
  source = "./modules/s3_bucket"

  s3_bucket_files_name   = var.s3_bucket_files_name
  s3_bucket_sources_name = var.s3_bucket_sources_name
  source_code_zip        = var.source_code_zip
  tag_resource           = var.tag_resource
}

module "iam" {
  source = "./modules/iam"

  iam_role_name        = var.iam_role_name
  iam_role_inline_name = var.iam_role_inline_name
}

module "lambda" {
  source = "./modules/lambda"

  lambda_function_name    = var.lambda_function_name
  s3_bucket_sources_name  = var.s3_bucket_sources_name
  lambda_payload_filename = var.source_code_zip
  hatchery_iam_role_arn   = module.iam.hatchery_iam_role_arn
  lambda_function_handler = var.lambda_function_handler

  depends_on = [module.iam, module.s3_bucket]
}
