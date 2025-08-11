# Outputs
output "role_arn" {
  description = "ARN of the PreviewServerDeploy role"
  value       = aws_iam_role.preview_server_deploy.arn
}

output "role_name" {
  description = "Name of the PreviewServerDeploy role"
  value       = aws_iam_role.preview_server_deploy.name
}

output "infrastructure_policy_arn" {
  description = "ARN of the PreviewServerInfrastructurePolicy"
  value       = aws_iam_policy.preview_server_infrastructure_policy.arn
}

output "deploy_policy_arn" {
  description = "ARN of the PreviewServerDeployPolicy"
  value       = aws_iam_policy.preview_server_deploy_policy.arn
}
