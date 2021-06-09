# Predifined variables for resources

# Common
variable "region" {
  description = "The region that the machine should be created in"
  default     = "us-east-1"
}

variable "tag_resource" {
  default = "hatchery"
}

# S3 bucket
variable "s3_name" {
  default = "hatchery-files"
}

variable "s3_acl" {
  description = "Access policy"
  default     = "private"
}

# CloudFront
variable "cdn_origin_id" {
  description = "Origin ID for CDN, could be anything"
  default     = "org_id_hatchery_files"
}

variable "cdn_comment" {
  default     = "CloudFront for S3 bucket with files"
}

variable "cdn_price_class" {
    default = "PriceClass_100"
}
