#!/bin/bash

# Script to deploy all Terraform projects in the infra directory
# Usage: ./scripts/deploy-all-terraform.sh

set -e

echo "Starting deployment of all Terraform projects..."

# Find all directories containing .tf files in the infra directory
TERRAFORM_DIRS=$(find infra -name "*.tf" -type f | xargs -n1 dirname | sort -u)

if [ -z "$TERRAFORM_DIRS" ]; then
    echo "No Terraform directories found in infra folder"
    exit 0
fi

echo "Found Terraform directories:"
echo "$TERRAFORM_DIRS"
echo ""

for dir in $TERRAFORM_DIRS; do
    if [ -d "$dir" ]; then
        echo "=========================================="
        echo "Deploying: $dir"
        echo "=========================================="
        
        cd "$dir"
        
        echo "Initializing Terraform..."
        terraform init -input=false
        
        echo "Planning Terraform changes..."
        terraform plan -input=false
        
        echo "Applying Terraform changes..."
        terraform apply -input=false -auto-approve
        
        echo "Deployment completed for $dir"
        echo ""
        cd -
    else
        echo "Warning: Directory $dir does not exist, skipping..."
    fi
done

echo "=========================================="
echo "All Terraform deployments completed!"
echo "=========================================="
