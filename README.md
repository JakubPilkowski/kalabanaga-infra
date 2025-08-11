# Kalabanga Infrastructure as Code (IaC)

This repository contains Terraform configurations for managing the Kalabanga project infrastructure across different environments.

## 🏗️ Project Structure

```
kalabanga-iac/
├── infra/
│   └── preview/
│       ├── next-app/          # Next.js application infrastructure
│       ├── react-app/         # React application infrastructure
│       └── server-app/        # Server application infrastructure
├── scripts/
│   ├── deploy-all-terraform.sh    # Deploy all Terraform projects
│   ├── validate-s3-keys.sh        # Validate S3 bucket key patterns
│   └── setup-git-hooks.sh         # Set up local git hooks
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured
- Bash shell

### Initial Setup

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   cd kalabanga-iac
   ```

2. **Set up git hooks (required for development):**

   ```bash
   ./scripts/setup-git-hooks.sh
   ```

3. **Deploy all infrastructure:**
   ```bash
   ./scripts/deploy-all-terraform.sh
   ```

## 🔒 S3 Bucket Key Validation

This repository includes automatic validation to ensure all S3 bucket keys follow the required pattern: `*/*-runner/terraform.tfstate`

### Required Pattern

All S3 bucket keys in the `backend "s3"` configuration must follow this exact pattern:

```
{environment}/{app-name}-runner/terraform.tfstate
```

### Examples of Valid Keys

- `preview/server-app-runner/terraform.tfstate`
- `preview/next-app-runner/terraform.tfstate`
- `preview/react-app-runner/terraform.tfstate`
- `staging/api-runner/terraform.tfstate`
- `production/web-runner/terraform.tfstate`

### Examples of Invalid Keys (Will Cause Validation Errors)

- `preview/server-app/terraform.tfstate` (missing `-runner`)
- `preview/server-app-runner/state.tf` (wrong filename)
- `server-app-runner/terraform.tfstate` (missing environment prefix)
- `preview/server-app-runner/terraform.tfstate.backup` (wrong extension)

## 🛠️ Development

### Release Process

This repository uses **Semantic Release** for automatic versioning and changelog generation. The process is fully automated in CI/CD.

#### Commit Message Format

Use conventional commit messages to trigger automatic releases:

```bash
feat: add new feature          # → Minor version bump (1.0.0 → 1.1.0)
fix: resolve bug              # → Patch version bump (1.0.0 → 1.0.1)
feat!: breaking change        # → Major version bump (1.0.0 → 2.0.0)
docs: update documentation    # → Patch version bump
chore: maintenance tasks      # → Patch version bump
```

#### Automatic Release Process

1. **Push to main branch** with conventional commit messages
2. **CI/CD detects changes** in `infra/` folder
3. **Semantic Release analyzes** commit messages
4. **Automatic version bump** based on commit types
5. **Changelog generation** and GitHub release creation
6. **Terraform deployment** (only if infrastructure changes detected)

#### Pre-release Versions

For alpha/beta/rc versions, use:

```bash
feat: add new feature (alpha)
fix: resolve bug (beta)
feat!: breaking change (rc)
```

### Git Hooks

The repository uses git hooks to automatically validate S3 bucket keys before each commit. This prevents accidental commits with invalid patterns that could cause infrastructure issues.

**Setup (run once after cloning):**

```bash
./scripts/setup-git-hooks.sh
```

**Manual validation:**

```bash
./scripts/validate-s3-keys.sh
```

**Skip validation (not recommended):**

```bash
git commit --no-verify -m "Skip validation"
```

### Adding New Infrastructure

When creating new Terraform configurations:

1. **Create a new directory** in the appropriate environment folder:

   ```bash
   mkdir -p infra/preview/new-app
   ```

2. **Create main.tf** with the correct S3 bucket key pattern:

   ```hcl
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
       key            = "preview/new-app-runner/terraform.tfstate"  # ✅ Correct pattern
       region         = "eu-north-1"
       dynamodb_table = var.dynamodb_table_name
       encrypt        = true
     }
   }
   ```

3. **Test the validation:**

   ```bash
   ./scripts/validate-s3-keys.sh
   ```

4. **Commit your changes** (validation will run automatically):
   ```bash
   git add .
   git commit -m "Add new-app infrastructure"
   ```

### Deployment

#### Deploy All Projects

```bash
./scripts/deploy-all-terraform.sh
```

#### Deploy Individual Project

```bash
cd infra/preview/server-app
terraform init
terraform plan
terraform apply
```

## 📋 Available Scripts

| Script                            | Description                               |
| --------------------------------- | ----------------------------------------- |
| `scripts/setup-git-hooks.sh`      | Set up local git hooks for validation     |
| `scripts/validate-s3-keys.sh`     | Validate S3 bucket key patterns manually  |
| `scripts/check-infra-changes.sh`  | Check for infrastructure changes in CI/CD |
| `scripts/deploy-all-terraform.sh` | Deploy all Terraform projects             |

## 🔧 Infrastructure Components

### Preview Environment

#### Next.js App (`infra/preview/next-app/`)

- CloudFront distribution
- ECS service for Next.js application
- Application Load Balancer integration
- ECR repository access

#### React App (`infra/preview/react-app/`)

- S3 bucket for static hosting
- CloudFront distribution
- WAF web ACL
- Origin access control

#### Server App (`infra/preview/server-app/`)

- ECS service for server application
- Application Load Balancer integration
- ECR repository access
- CloudWatch logs

## 🚨 Important Notes

### S3 Bucket Key Validation

- **Never skip the validation** unless absolutely necessary
- The validation prevents state file conflicts and infrastructure issues
- All new main.tf files must follow the pattern: `*/*-runner/terraform.tfstate`

### State Management

- Each application has its own state file to prevent conflicts
- State files are stored in S3 with DynamoDB locking
- Never manually modify state files

### Security

- All infrastructure uses encrypted S3 buckets
- IAM roles follow the principle of least privilege
- OIDC authentication for GitHub Actions

## 🐛 Troubleshooting

### Validation Errors

If you get validation errors:

1. **Check the S3 bucket key pattern** in your main.tf file
2. **Ensure the key follows**: `{environment}/{app-name}-runner/terraform.tfstate`
3. **Check for duplicate keys** across all main.tf files
4. **Run manual validation**: `./scripts/validate-s3-keys.sh`

### Git Hook Issues

If git hooks aren't working:

1. **Re-run the setup**: `./scripts/setup-git-hooks.sh`
2. **Check permissions**: `ls -la .git/hooks/`
3. **Verify the hook exists**: `cat .git/hooks/pre-commit`

### Deployment Issues

If deployment fails:

1. **Check AWS credentials**: `aws sts get-caller-identity`
2. **Verify Terraform version**: `terraform version`
3. **Check S3 bucket access**: Ensure the bucket exists and is accessible
4. **Review IAM permissions**: Ensure your AWS user/role has necessary permissions

## 📞 Support

For issues related to:

- **Infrastructure**: Check the Terraform documentation and AWS console
- **Validation**: Review the validation script output and this README
- **Deployment**: Check AWS CloudTrail and Terraform logs

## 📄 License

This project is proprietary to Kalabanga.
