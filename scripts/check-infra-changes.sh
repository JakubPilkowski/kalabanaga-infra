#!/bin/bash

# Script to check if there are changes in the infra folder
# Used in CI/CD to determine if deployment is needed

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

echo "🔍 Checking for infrastructure changes..."

# Get the base commit for comparison
# In GitHub Actions, we can compare with the previous commit
if [ "$GITHUB_EVENT_NAME" = "push" ]; then
    # For push events, compare with the previous commit
    BASE_COMMIT="$GITHUB_SHA~1"
    CURRENT_COMMIT="$GITHUB_SHA"
elif [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
    # For PR events, compare with the base branch
    BASE_COMMIT="$GITHUB_BASE_REF"
    CURRENT_COMMIT="$GITHUB_HEAD_REF"
else
    # Fallback: compare with main branch
    BASE_COMMIT="origin/main"
    CURRENT_COMMIT="HEAD"
fi

# Check if this is the first commit
FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD | head -1)
if [ "$CURRENT_COMMIT" = "$FIRST_COMMIT" ] || [ "$(git rev-parse "$CURRENT_COMMIT")" = "$FIRST_COMMIT" ]; then
    print_info "This is the first commit - treating as infrastructure changes"
    print_success "Infrastructure changes detected! (first commit)"
    echo "Changed files:"
    echo "  - All files in initial commit"
    echo ""
    
    # Set environment variables for GitHub Actions
    if [ -n "$GITHUB_ENV" ]; then
        echo "DEPLOY_NEEDED=true" >> $GITHUB_ENV
        echo "INFRA_CHANGES<<EOF" >> $GITHUB_ENV
        echo "First commit - all files" >> $GITHUB_ENV
        echo "EOF" >> $GITHUB_ENV
    fi
    
    print_info "Deployment will proceed"
    exit 0
fi

echo "Comparing changes between $BASE_COMMIT and $CURRENT_COMMIT"

# Check if there are changes in the infra folder, package.json, or .deploy.yml
CHANGES=$(git diff --name-only "$BASE_COMMIT" "$CURRENT_COMMIT" | grep -E "^(infra/|package\.json|\.github/workflows/\.deploy\.yml)" || true)

if [ -z "$CHANGES" ]; then
    print_info "No changes detected in infra folder, package.json, or .deploy.yml"
    print_info "Skipping deployment"
    if [ -n "$GITHUB_ENV" ]; then
        echo "DEPLOY_NEEDED=false" >> $GITHUB_ENV
        echo "INFRA_CHANGES=" >> $GITHUB_ENV
    fi
    exit 0
else
    print_success "Infrastructure or workflow changes detected!"
    echo "Changed files:"
    echo "$CHANGES" | sed 's/^/  - /'
    echo ""
    
    # Set environment variables for GitHub Actions
    if [ -n "$GITHUB_ENV" ]; then
        echo "DEPLOY_NEEDED=true" >> $GITHUB_ENV
        echo "INFRA_CHANGES<<EOF" >> $GITHUB_ENV
        echo "$CHANGES" >> $GITHUB_ENV
        echo "EOF" >> $GITHUB_ENV
    fi
    
    print_info "Deployment will proceed"
    exit 0
fi
