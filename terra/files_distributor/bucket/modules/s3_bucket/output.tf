# S3 bucket output

output "hatchery_s3_bucket_id" {
  value = aws_s3_bucket.hatchery_s3_bucket.id
}
