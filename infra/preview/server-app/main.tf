terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = var.infrastructure_s3_bucket_name
    key            = "preview/server-app-runner/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = var.dynamodb_table_name
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-north-1"
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ProjectPreviewServerAppEcsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "ProjectPreviewServerAppEcsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Terraform Backend Access
resource "aws_iam_policy" "preview_server_infrastructure_policy" {
  name        = "ProjectPreviewServerInfrastructurePolicy"
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
          "arn:aws:s3:::${var.infrastructure_s3_bucket_name}",
          "arn:aws:s3:::${var.infrastructure_s3_bucket_name}/preview/server-app/*"
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
        Resource = "arn:aws:dynamodb:eu-north-1:*:table/${var.dynamodb_table_name}"
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "arn:aws:kms:eu-north-1:*:alias/${var.kms_key_alias}"
      }
    ]
  })
}

# IAM Role for Preview Server Deployment
resource "aws_iam_role" "preview_server_deploy" {
  name = "ProjectPreviewServerAppDeploy"

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
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository_owner}/preview-app-server:*"
          }
        }
      }
    ]
  })
}

# IAM Policy for Preview Server Deployment
resource "aws_iam_policy" "preview_server_deploy_policy" {
  name        = "ProjectPreviewServerDeployPolicy"
  description = "Policy for Preview Server deployment and infrastructure management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRManagement"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "arn:aws:ecr:eu-north-1:${var.aws_account_id}:repository/${var.ecr_repository_name}"
      },
      {
        Sid    = "ECSManagement"
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:CreateService",
          "ecs:DeleteService"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Name"        = "preview-server-app"
            "aws:ResourceTag/Environment" = "preview"
            "aws:ResourceTag/Project"     = "preview-server"
            "aws:ResourceTag/Owner"       = var.resource_owner_tag
          }
        }
      },
      {
        Sid    = "ALBManagement"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:CreateListenerRule",
          "elasticloadbalancing:ModifyListenerRule",
          "elasticloadbalancing:DeleteListenerRule",
          "elasticloadbalancing:DescribeRules"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Name"        = "preview-next-app"
            "aws:ResourceTag/Environment" = "preview"
            "aws:ResourceTag/Project"     = "preview-next-app"
            "aws:ResourceTag/Owner"       = var.resource_owner_tag
          }
        }
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:eu-north-1:${var.aws_account_id}:log-group:preview/server-app:*"
      },
      {
        Sid    = "IAMPassRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_task_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ]
      }
    ]
  })
}

# Attach policies to the role
resource "aws_iam_role_policy_attachment" "preview_server_infrastructure_policy_attachment" {
  role       = aws_iam_role.preview_server_deploy.name
  policy_arn = aws_iam_policy.preview_server_infrastructure_policy.arn
}

resource "aws_iam_role_policy_attachment" "preview_server_deploy_policy_attachment" {
  role       = aws_iam_role.preview_server_deploy.name
  policy_arn = aws_iam_policy.preview_server_deploy_policy.arn
}
