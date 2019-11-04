
output "s3-bucket-entities_arn" {
  value       = aws_s3_bucket.store-entities.arn
  description = "the bucket arn"
}

output "s3-bucket-entities_id" {
  value       = aws_s3_bucket.store-entities.id
  description = "the bucket id"
}
