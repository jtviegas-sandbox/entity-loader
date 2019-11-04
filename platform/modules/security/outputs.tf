
output "iam-user-maintainer-2_pswd" {
  value       = aws_iam_user_login_profile.maintainer-2.encrypted_password
  description = "maintainer-2 encrypted password"
}

output "iam-user-maintainer-1_pswd" {
  value       = aws_iam_user_login_profile.maintainer-1.encrypted_password
  description = "maintainer-1 encrypted password"
}

output "iam-role-maintainer_arn" {
  value       = aws_iam_role.iam-role-maintainer.arn
  description = "role arn for store maintainenance"
}

