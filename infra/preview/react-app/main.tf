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
    key            = "preview/react-app-runner/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = var.dynamodb_table_name
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
          "arn:aws:s3:::${var.infrastructure_s3_bucket_name}",
          "arn:aws:s3:::${var.infrastructure_s3_bucket_name}/preview/react-app/*"
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

# IAM Policy for React App Deployment (S3 and CloudFront)
resource "aws_iam_policy" "preview_react_app_deploy_policy" {
  name        = "ProjectPreviewReactAppDeployPolicy"
  description = "Policy for React app deployment to S3 and CloudFront"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketCreation"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketVersioning",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketPolicy",
          "s3:PutBucketCors",
          "s3:PutBucketWebsite",
          "s3:PutBucketAcl",
          "s3:PutBucketTagging",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketPolicy",
          "s3:GetBucketCors",
          "s3:GetBucketWebsite",
          "s3:GetBucketAcl",
          "s3:GetBucketTagging",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketLogging",
          "s3:GetLifecycleConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:PutReplicationConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:PutEncryptionConfiguration",
          "s3:GetBucketOwnershipControls",
          "s3:PutBucketOwnershipControls",
          "s3:GetBucketObjectLockConfiguration"
        ]
        Resource = "arn:aws:s3:::preview-react-app-bucket"
      },
      {
        Sid    = "S3AppDeployment"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "arn:aws:s3:::preview-react-app-bucket",
          "arn:aws:s3:::preview-react-app-bucket/*"
        ]
      },
      {
        Sid    = "CloudFrontDistributionManagement"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateDistribution",
          "cloudfront:GetDistribution",
          "cloudfront:UpdateDistribution",
          "cloudfront:DeleteDistribution",
          "cloudfront:ListDistributions",
          "cloudfront:GetDistributionConfig",
          "cloudfront:TagResource",
          "cloudfront:ListTagsForResource",
        ]
        Resource = "arn:aws:cloudfront::*:distribution/*"
        # Condition = {
        #   StringEquals = {
        #     "aws:ResourceTag/Name"        = "kalabanga-preview-react-app"
        #     "aws:ResourceTag/Environment" = "preview"
        #     "aws:ResourceTag/Project"     = "preview-react-app"
        #     "aws:ResourceTag/Owner"       = "kalabanga"
        #   }
        # }
      },
      {
        Sid    = "CloudFrontOriginAccessControl"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateOriginAccessControl",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:UpdateOriginAccessControl",
          "cloudfront:DeleteOriginAccessControl",
          "cloudfront:ListOriginAccessControls"
        ]
        Resource = "*"
      },
      {
        Sid    = "WAFv2WebACLManagement"
        Effect = "Allow"
        Action = [
          "wafv2:CreateWebACL",
          "wafv2:GetWebACL",
          "wafv2:UpdateWebACL",
          "wafv2:DeleteWebACL",
          "wafv2:ListWebACLs",
          "wafv2:TagResource",
          "wafv2:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudFrontInvalidation"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations"
        ]
        Resource = "arn:aws:cloudfront::*:distribution/*"
        # Condition = {
        #   StringEquals = {
        #     "aws:ResourceTag/Name"        = "kalabanga-preview-react-app"
        #     "aws:ResourceTag/Environment" = "preview"
        #     "aws:ResourceTag/Project"     = "preview-react-app"
        #     "aws:ResourceTag/Owner"       = "kalabanga"
        #   }
        # }
      }
    ]
  })
}

# Attach policies to the role
resource "aws_iam_role_policy_attachment" "preview_react_app_infrastructure_policy_attachment" {
  role       = aws_iam_role.preview_react_app_deploy.name
  policy_arn = aws_iam_policy.preview_react_app_infrastructure_policy.arn
}

resource "aws_iam_role_policy_attachment" "preview_react_app_deploy_policy_attachment" {
  role       = aws_iam_role.preview_react_app_deploy.name
  policy_arn = aws_iam_policy.preview_react_app_deploy_policy.arn
}


