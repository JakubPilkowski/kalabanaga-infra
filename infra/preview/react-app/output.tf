# Outputs
output "role_arn" {
  description = "ARN of the PreviewReactAppDeploy role"
  value       = aws_iam_role.preview_react_app_deploy.arn
}

output "role_name" {
  description = "Name of the PreviewReactAppDeploy role"
  value       = aws_iam_role.preview_react_app_deploy.name
}
