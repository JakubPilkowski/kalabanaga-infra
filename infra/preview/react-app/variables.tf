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
  default     = "preview-react-app"
}
variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository"
  type        = string
}