# S3 bucket main

resource "aws_s3_bucket" "hatchery_s3_bucket" {
  acl    = "private"
  bucket = var.s3_bucket_name

  tags = {
    Name     = var.s3_bucket_name
    Resource = var.tag_resource
    Access   = "private"
  }
}

resource "aws_s3_bucket_object" "hatchery_s3_bucket_object" {
  bucket = aws_s3_bucket.hatchery_s3_bucket.id
  key    = "bugout-git-habr-post.png"
  source = "modules/bucket/files/bugout-git-habr-post.png"
}

