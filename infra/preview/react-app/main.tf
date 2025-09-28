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
    key            = "preview/react-app-runner/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "PLACEHOLDER_DYNAMODB_TABLE"
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

  policy = jsonencode(
    {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudfrontConfiguration",
      "Effect": "Allow",
      "Action": [
        "cloudfront:GetDistribution",
        "cloudfront:GetOriginAccessControl",
        "cloudfront:ListTagsForResource"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamodbConfiguration",
      "Effect": "Allow",
      "Action": [
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ElasticloadbalancingConfiguration",
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTags"
      ],
      "Resource": "*"
    },
    {
      "Sid": "S3Configuration",
      "Effect": "Allow",
      "Action": [
        "s3:GetAccelerateConfiguration",
        "s3:GetBucketAcl",
        "s3:GetBucketCORS",
        "s3:GetBucketLogging",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetBucketOwnershipControls",
        "s3:GetBucketPolicy",
        "s3:GetBucketPublicAccessBlock",
        "s3:GetBucketRequestPayment",
        "s3:GetBucketTagging",
        "s3:GetBucketVersioning",
        "s3:GetBucketWebsite",
        "s3:GetEncryptionConfiguration",
        "s3:GetLifecycleConfiguration",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Resource": "*"
    },
    {
      "Sid": "StsConfiguration",
      "Effect": "Allow",
      "Action": [
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Wafv2Configuration",
      "Effect": "Allow",
      "Action": [
        "wafv2:GetWebACL",
        "wafv2:ListTagsForResource"
      ],
      "Resource": "*"
    }
  ]
} 
  )
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


