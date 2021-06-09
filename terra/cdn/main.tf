provider "aws" {
  region = var.region
}

# S3 bucket
resource "aws_s3_bucket" "s3_hatchery_files" {
  bucket = var.s3_name
  acl    = var.s3_acl

  tags = {
    Name     = var.s3_name
    Resource = var.tag_resource
    Access   = "private"
  }
}

# Upload test file
resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.s3_hatchery_files.id
  key    = "bugout-git-habr-post.png"
  source = "files/bugout-git-habr-post.png"
}

# CloudFront
resource "aws_cloudfront_origin_access_identity" "access_identity_hatchery" {
  comment = "access-identity-hatchery-files"
}

resource "aws_cloudfront_distribution" "cdn_hatchery_s3_files" {
  origin {
    domain_name = aws_s3_bucket.s3_hatchery_files.bucket_regional_domain_name
    origin_id   = var.cdn_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.access_identity_hatchery.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = var.cdn_comment

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.cdn_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = var.cdn_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Resource = var.tag_resource
  }
}

# Update S3 Policy
data "aws_iam_policy_document" "s3_hatchery_files_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_hatchery_files.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.access_identity_hatchery.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_hatchery_files_policy" {
  bucket = aws_s3_bucket.s3_hatchery_files.id
  policy = data.aws_iam_policy_document.s3_hatchery_files_policy_document.json
}
