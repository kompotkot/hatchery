# S3 bucket main

# Bucket for files
resource "aws_s3_bucket" "hatchery_s3_bucket_files" {
  acl    = "private"
  bucket = var.s3_bucket_files_name

  tags = {
    Name     = var.s3_bucket_files_name
    Resource = var.tag_resource
    Access   = "private"
  }
}

resource "aws_s3_bucket_object" "hatchery_s3_bucket_files_object" {
  bucket = aws_s3_bucket.hatchery_s3_bucket_files.id
  key    = "bugout-git-habr-post.png"
  source = "modules/s3_bucket/files/bugout-git-habr-post.png"
}

# Bucket for lambda source code
resource "aws_s3_bucket" "hatchery_s3_bucket_sources" {
  acl    = "private"
  bucket = var.s3_bucket_sources_name

  tags = {
    Name     = var.s3_bucket_sources_name
    Resource = var.tag_resource
    Access   = "private"
  }
}

resource "aws_s3_bucket_object" "hatchery_s3_bucket_sources_object" {
  bucket = aws_s3_bucket.hatchery_s3_bucket_sources.id
  key    = var.source_code_zip
  source = "modules/s3_bucket/files/${var.source_code_zip}"
}
