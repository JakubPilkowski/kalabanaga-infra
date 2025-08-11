#!/bin/bash

# S3 Bucket Key Validation Script
# This script validates that all main.tf files have S3 bucket keys following the pattern: */*-runner/terraform.tfstate
# It also checks for duplicate keys to prevent state file conflicts

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

print_info() {
    echo -e "${NC}ℹ️  $1${NC}"
}

# Expected pattern: */*-runner/terraform.tfstate
EXPECTED_PATTERN="^[^/]+/[^/]+-runner/terraform\.tfstate$"

echo "🔍 Validating S3 bucket keys in main.tf files..."
echo "Expected pattern: */*-runner/terraform.tfstate"
echo ""

# Find all main.tf files
MAIN_TF_FILES=$(find . -name "main.tf" -type f)

if [ -z "$MAIN_TF_FILES" ]; then
    print_error "No main.tf files found!"
    exit 1
fi

# Arrays to store keys and file paths
declare -a s3_keys
declare -a file_paths
declare -a valid_files
declare -a invalid_files

# Check each main.tf file
for file in $MAIN_TF_FILES; do
    print_info "Checking: $file"
    
    # Extract S3 bucket key from backend configuration
    s3_key=$(grep -A 5 "backend \"s3\"" "$file" | grep "key" | sed 's/.*key[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/' | tr -d ' ')
    
    if [ -z "$s3_key" ]; then
        print_error "No S3 bucket key found in $file"
        invalid_files+=("$file")
        continue
    fi
    
    # Check if key follows the expected pattern
    if [[ $s3_key =~ $EXPECTED_PATTERN ]]; then
        print_success "Valid key: $s3_key"
        valid_files+=("$file")
        s3_keys+=("$s3_key")
        file_paths+=("$file")
    else
        print_error "Invalid key pattern in $file: $s3_key"
        print_error "Expected pattern: */*-runner/terraform.tfstate"
        invalid_files+=("$file")
    fi
    
    echo ""
done

# Check for duplicate keys
echo "🔍 Checking for duplicate S3 bucket keys..."
duplicates_found=false

for i in "${!s3_keys[@]}"; do
    for j in "${!s3_keys[@]}"; do
        if [ $i -ne $j ] && [ "${s3_keys[$i]}" = "${s3_keys[$j]}" ]; then
            print_error "Duplicate S3 bucket key found:"
            print_error "  Key: ${s3_keys[$i]}"
            print_error "  File 1: ${file_paths[$i]}"
            print_error "  File 2: ${file_paths[$j]}"
            duplicates_found=true
        fi
    done
done

if [ "$duplicates_found" = false ]; then
    print_success "No duplicate S3 bucket keys found"
fi

echo ""

# Summary
echo "📊 Validation Summary:"
echo "======================"

if [ ${#valid_files[@]} -gt 0 ]; then
    print_success "Valid files (${#valid_files[@]}):"
    for file in "${valid_files[@]}"; do
        echo "  ✅ $file"
    done
fi

if [ ${#invalid_files[@]} -gt 0 ]; then
    print_error "Invalid files (${#invalid_files[@]}):"
    for file in "${invalid_files[@]}"; do
        echo "  ❌ $file"
    done
fi

echo ""

# Exit with error if any invalid files or duplicates found
if [ ${#invalid_files[@]} -gt 0 ] || [ "$duplicates_found" = true ]; then
    print_error "Validation failed! Please fix the issues above."
    exit 1
else
    print_success "All S3 bucket keys are valid and unique! 🎉"
    exit 0
fi
