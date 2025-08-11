variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "preview-server-app"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "github_repository_owner" {
  description = "GitHub repository owner (username or organization)"
  type        = string
}

variable "infrastructure_s3_bucket_name" {
  description = "S3 bucket name for Terraform state storage"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
}

variable "kms_key_alias" {
  description = "KMS key alias for encryption"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "resource_owner_tag" {
  description = "Resource owner tag value"
  type        = string
}
