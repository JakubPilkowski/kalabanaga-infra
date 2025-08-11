# Outputs
output "role_arn" {
  description = "ARN of the PreviewNextAppDeploy role"
  value       = aws_iam_role.preview_next_app_deploy.arn
}

output "role_name" {
  description = "Name of the PreviewNextAppDeploy role"
  value       = aws_iam_role.preview_next_app_deploy.name
}

output "infrastructure_policy_arn" {
  description = "ARN of the PreviewNextAppInfrastructurePolicy"
  value       = aws_iam_policy.preview_next_app_infrastructure_policy.arn
}

output "deploy_policy_arn" {
  description = "ARN of the PreviewNextAppDeployPolicy"
  value       = aws_iam_policy.preview_next_app_deploy_policy.arn
}
