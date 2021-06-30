# File destribution infrastructure

provider "aws" {
  region = var.region
}

module "s3_bucket" {
  source = "./modules/s3_bucket"

  s3_bucket_name = var.s3_bucket_name
  tag_resource   = var.tag_resource
}

module "iam" {
  source = "./modules/iam"

  iam_role_name        = var.iam_role_name
  iam_role_inline_name = var.iam_role_inline_name
}

module "lambda" {
  source = "./modules/lambda"

  lambda_function_name    = var.lambda_function_name
  hatchery_iam_role_arn   = module.iam.hatchery_iam_role_arn
  lambda_function_handler = var.lambda_function_handler
}
