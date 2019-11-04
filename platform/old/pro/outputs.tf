
output "iam-user-maintainer-2_pswd" {
  value       = module.security.iam-user-maintainer-2_pswd
  description = "maintainer-2 encrypted password"
}

output "iam-user-maintainer-1_pswd" {
  value       = module.security.iam-user-maintainer-1_pswd
  description = "maintainer-1 encrypted password"
}

output "s3-bucket-entities_arn" {
  value       = module.services.s3-bucket-entities_arn
  description = "the bucket arn"
}
