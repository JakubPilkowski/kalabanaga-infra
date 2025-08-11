#!/bin/bash

# Script to set up git hooks for the kalabanga-iac repository
# This script creates the necessary git hooks locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${NC}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

echo "🔧 Setting up git hooks for kalabanga-iac repository..."
echo ""

# Get the repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Check if we're in a git repository
if [ ! -d "$REPO_ROOT/.git" ]; then
    print_error "This script must be run from within a git repository!"
    exit 1
fi

# Create hooks directory if it doesn't exist
HOOKS_DIR="$REPO_ROOT/.git/hooks"
mkdir -p "$HOOKS_DIR"

print_info "Creating pre-commit hook..."

# Create the pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash

# Git pre-commit hook to validate S3 bucket keys in main.tf files
# This hook prevents commits with invalid S3 bucket key patterns

set -e

echo "🔍 Running S3 bucket key validation..."

# Get the directory where this script is located (git hooks directory)
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the repository root directory
REPO_ROOT="$(cd "$HOOK_DIR/../.." && pwd)"

# Run the validation script
if [ -f "$REPO_ROOT/scripts/validate-s3-keys.sh" ]; then
    "$REPO_ROOT/scripts/validate-s3-keys.sh"
    
    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ S3 bucket key validation failed!"
        echo "Please fix the validation errors before committing."
        echo ""
        echo "To skip this validation (not recommended), use:"
        echo "  git commit --no-verify"
        exit 1
    fi
    
    echo ""
    echo "✅ S3 bucket key validation passed!"
else
    echo "⚠️  Warning: S3 validation script not found at $REPO_ROOT/scripts/validate-s3-keys.sh"
    echo "Skipping S3 key validation..."
fi

exit 0
EOF

# Make the hook executable
chmod +x "$HOOKS_DIR/pre-commit"

print_success "Pre-commit hook created successfully!"

echo ""
print_info "Git hooks setup complete! 🎉"
echo ""
print_info "The pre-commit hook will now automatically validate S3 bucket keys"
print_info "before each commit to ensure they follow the pattern: */*-runner/terraform.tfstate"
echo ""
print_info "To test the hook, try making a commit:"
print_info "  git add . && git commit -m 'Test commit'"
echo ""
print_info "If you need to skip validation for a specific commit (not recommended):"
print_info "  git commit --no-verify -m 'Skip validation'"
