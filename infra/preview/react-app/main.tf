terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "kalabanga-iac-bucket"
    key            = "preview/react-app-runner/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "infrastructure-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-north-1"
}

# IAM Policy for Terraform Backend Access
resource "aws_iam_policy" "preview_react_app_infrastructure_policy" {
  name        = "ProjectPreviewReactAppInfrastructurePolicy"
  description = "Policy for Terraform backend access to S3, DynamoDB, and KMS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BackendAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::kalabanga-iac-bucket",
          "arn:aws:s3:::kalabanga-iac-bucket/preview/react-app-runner/*"
        ]
      },
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:eu-north-1:*:table/infrastructure-locks"
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "arn:aws:kms:eu-north-1:*:alias/iac-key"
      }
    ]
  })
}



# IAM Role for Preview React App Deployment
resource "aws_iam_role" "preview_react_app_deploy" {
  name = "ProjectPreviewReactAppDeploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository_owner}/preview-app-react:*"
          }
        }
      }
    ]
  })
}

# Attach policies to the role
resource "aws_iam_role_policy_attachment" "preview_react_app_infrastructure_policy_attachment" {
  role       = aws_iam_role.preview_react_app_deploy.name
  policy_arn = aws_iam_policy.preview_react_app_infrastructure_policy.arn
}


