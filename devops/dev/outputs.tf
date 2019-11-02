
output "s3-bucket-entities_arn" {
  value       = aws_s3_bucket.s3-bucket-entities.arn
  description = "the bucket arn"
}

output "iam-user-maintainer-2_pswd" {
  value       = aws_iam_user_login_profile.iam-user-profile-maintainer-2.encrypted_password
  description = "maintainer-2 encrypted password"
}

output "iam-user-maintainer-1_pswd" {
  value       = aws_iam_user_login_profile.iam-user-profile-maintainer-1.encrypted_password
  description = "maintainer-1 encrypted password"
}