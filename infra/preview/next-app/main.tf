terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "PLACEHOLDER_S3_BUCKET"
    key            = "preview/next-app-runner/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "PLACEHOLDER_DYNAMODB_TABLE"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-north-1"
}

# IAM Policy for Terraform Backend Access
resource "aws_iam_policy" "preview_next_app_infrastructure_policy" {
  name        = "ProjectPreviewNextAppInfrastructurePolicy"
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
          "arn:aws:s3:::${var.infrastructure_s3_bucket_name}/preview/next-app/*"
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

# IAM Role for Preview Next App Deployment
resource "aws_iam_role" "preview_next_app_deploy" {
  name = "ProjectPreviewNextAppDeploy"

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
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository_owner}/preview-app-next:*"
          }
        }
      }
    ]
  })
}

# IAM Policy for Next App Deployment
resource "aws_iam_policy" "preview_next_app_deploy_policy" {
  name        = "ProjectPreviewNextAppDeployPolicy"
  description = "Policy for Next app deployment and infrastructure management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudFrontDistributionManagement"
        Effect = "Allow"
        Action = [
          "cloudfront:GetDistribution",
          "cloudfront:UpdateDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:TagResource",
          "cloudfront:ListTagsForResource",
          "cloudfront:CreateInvalidation"
        ]
        Resource = "arn:aws:cloudfront::*:distribution/*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Name"        = "kalabanga-preview-next-app"
            "aws:ResourceTag/Environment" = "preview"
            "aws:ResourceTag/Project"     = "preview-next-app"
            "aws:ResourceTag/Owner"       = var.resource_owner_tag
          }
        }
      },
      {
        Sid    = "CloudFrontOriginRequestPolicy"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateOriginRequestPolicy",
          "cloudfront:GetOriginRequestPolicy",
          "cloudfront:UpdateOriginRequestPolicy",
          "cloudfront:DeleteOriginRequestPolicy",
          "cloudfront:ListOriginRequestPolicies"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudFrontFunctionManagement"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateFunction",
          "cloudfront:GetFunction",
          "cloudfront:UpdateFunction",
          "cloudfront:DeleteFunction",
          "cloudfront:ListFunctions",
          "cloudfront:PublishFunction",
          "cloudfront:TagResource",
          "cloudfront:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "ALBManagement"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTargetGroupAttributes"
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
        # Resource = "arn:aws:ecr:eu-north-1:${var.aws_account_id}:repository/${var.ecr_repository_name}"
        Resource = "*"
      },
      {
        Sid    = "ECSManagement"
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "*"
        # Condition = {
        #   StringEquals = {
        #     "aws:ResourceTag/Name"        = "preview-next-app"
        #     "aws:ResourceTag/Environment" = "preview"
        #     "aws:ResourceTag/Project"     = "preview-next-app"
        #     "aws:ResourceTag/Owner"       = var.resource_owner_tag
        #   }
        # }
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
        Resource = "arn:aws:logs:eu-north-1:${var.aws_account_id}:log-group:preview/next-app:*"
      },
      {
        Sid    = "CloudFrontDataAccess"
        Effect = "Allow"
        Action = [
          "cloudfront:GetDistribution",
          "cloudfront:ListDistributions",
          "cloudfront:CreateInvalidation"
        ]
        Resource = "*"
      },
      {
        Sid    = "ELBv2DataAccess"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTargetGroupAttributes"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3Management"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy"
        ]
        Resource = "*",
      },
       {
        Sid    = "EC2Configuration"
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcs",
          "ec2:RevokeSecurityGroupEgress"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policies to the role
resource "aws_iam_role_policy_attachment" "preview_next_app_infrastructure_policy_attachment" {
  role       = aws_iam_role.preview_next_app_deploy.name
  policy_arn = aws_iam_policy.preview_next_app_infrastructure_policy.arn
}

resource "aws_iam_role_policy_attachment" "preview_next_app_deploy_policy_attachment" {
  role       = aws_iam_role.preview_next_app_deploy.name
  policy_arn = aws_iam_policy.preview_next_app_deploy_policy.arn
}