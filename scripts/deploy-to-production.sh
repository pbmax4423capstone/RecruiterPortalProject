#!/bin/bash
#
# Production Deployment Script for Interview Scheduling Enhancement
# 
# This script deploys the intelligent interview scheduling features to production.
# It includes safety checks, dry-run options, and validation steps.
#
# Usage:
#   ./scripts/deploy-to-production.sh [--dry-run] [--skip-tests]
#

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse command line arguments
DRY_RUN=false
SKIP_TESTS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --skip-tests)
      SKIP_TESTS=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--dry-run] [--skip-tests]"
      exit 1
      ;;
  esac
done

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_info "Starting Production Deployment Script..."
echo ""

# 1. Check prerequisites
print_info "Step 1: Checking prerequisites..."

if ! command_exists sf; then
    print_error "Salesforce CLI (sf) is not installed!"
    print_error "Please install it from: https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm"
    exit 1
fi

print_info "✓ Salesforce CLI is installed: $(sf --version | head -1)"

# Check if authenticated
if ! sf org list >/dev/null 2>&1; then
    print_error "No Salesforce orgs authenticated!"
    print_error "Please authenticate with: sf org login web --alias ProductionCapstone"
    exit 1
fi

print_info "✓ Salesforce orgs authenticated"

# Check target org
TARGET_ORG=$(sf config get target-org --json 2>/dev/null | grep -o '"value":"[^"]*"' | cut -d'"' -f4 || echo "")

if [ -z "$TARGET_ORG" ]; then
    print_warning "No default target org set"
    print_info "Setting ProductionCapstone as target org..."
    sf config set target-org=ProductionCapstone
    TARGET_ORG="ProductionCapstone"
fi

print_info "✓ Target org: $TARGET_ORG"

# Confirm deployment to production
if [ "$DRY_RUN" = false ]; then
    echo ""
    print_warning "You are about to deploy to production: $TARGET_ORG"
    read -p "Are you sure you want to continue? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        print_info "Deployment cancelled by user"
        exit 0
    fi
fi

echo ""
print_info "Step 2: Validating repository..."

# Check we're in the right directory
if [ ! -f "sfdx-project.json" ]; then
    print_error "Not in a Salesforce DX project directory!"
    print_error "Please run this script from the project root"
    exit 1
fi

print_info "✓ Repository validated"

echo ""
print_info "Step 3: Running pre-deployment checks..."

# Run linter
if command_exists npm; then
    print_info "Running linter..."
    npm run lint || {
        print_warning "Linting found issues. Review and fix before deploying."
        read -p "Continue anyway? (yes/no): " CONTINUE
        if [ "$CONTINUE" != "yes" ]; then
            exit 1
        fi
    }
    print_info "✓ Linting completed"
else
    print_warning "npm not found, skipping linting"
fi

echo ""
print_info "Step 4: Preparing deployment..."

# Create deployment package - key components for interview scheduling enhancement
DEPLOY_SOURCES=(
    "force-app/main/default/classes/InterviewSequenceHelper.cls"
    "force-app/main/default/classes/InterviewSequenceHelper.cls-meta.xml"
    "force-app/main/default/classes/InterviewSequenceHelperTest.cls"
    "force-app/main/default/classes/InterviewSequenceHelperTest.cls-meta.xml"
    "force-app/main/default/classes/InterviewTriggerHandler.cls"
    "force-app/main/default/classes/InterviewTriggerHandler.cls-meta.xml"
    "force-app/main/default/classes/InterviewTriggerHandlerTest.cls"
    "force-app/main/default/classes/InterviewTriggerHandlerTest.cls-meta.xml"
    "force-app/main/default/triggers/InterviewTrigger.trigger"
    "force-app/main/default/triggers/InterviewTrigger.trigger-meta.xml"
    "force-app/main/default/lwc/candidateRecordView"
    "force-app/main/default/lwc/recruiterPortalHeader"
    "force-app/main/default/lwc/portalHeaderNew"
    "force-app/main/default/permissionsets/Recruiter_Dashboard_Access.permissionset-meta.xml"
)

# Check all files exist
for SOURCE in "${DEPLOY_SOURCES[@]}"; do
    if [ ! -e "$SOURCE" ]; then
        print_error "Missing source file: $SOURCE"
        exit 1
    fi
done

print_info "✓ All deployment sources validated"

echo ""
if [ "$DRY_RUN" = true ]; then
    print_info "Step 5: Running dry-run deployment..."
    
    # Build source-dir arguments
    SOURCE_DIRS=""
    for SOURCE in "${DEPLOY_SOURCES[@]}"; do
        # Only add directories for --source-dir
        if [ -d "$SOURCE" ]; then
            SOURCE_DIRS="$SOURCE_DIRS --source-dir $SOURCE"
        fi
    done
    
    # For simplicity, deploy entire force-app in dry-run
    print_info "Executing: sf project deploy start --source-dir force-app --dry-run"
    sf project deploy start --source-dir force-app --dry-run
    
    print_info "✓ Dry-run completed successfully"
    echo ""
    print_info "Dry-run completed. Review the output above."
    print_info "To deploy for real, run: $0"
else
    print_info "Step 5: Deploying to production..."
    
    # Deploy all components
    print_info "Executing: sf project deploy start --source-dir force-app"
    sf project deploy start --source-dir force-app
    
    print_info "✓ Deployment completed successfully"
fi

# Run tests if not skipped
if [ "$SKIP_TESTS" = false ] && [ "$DRY_RUN" = false ]; then
    echo ""
    print_info "Step 6: Running tests..."
    
    print_info "Running local tests..."
    sf apex run test --test-level RunLocalTests --output-dir test-results --result-format human
    
    # Check test results
    if [ $? -eq 0 ]; then
        print_info "✓ All tests passed"
    else
        print_error "Some tests failed! Check test-results directory for details"
        exit 1
    fi
else
    print_warning "Skipping test execution"
fi

echo ""
print_info "Step 7: Post-deployment validation..."

# Verify components deployed
print_info "Verifying Apex classes..."
sf apex list class --json | grep -q "InterviewSequenceHelper" && \
    print_info "✓ InterviewSequenceHelper deployed" || \
    print_warning "⚠ InterviewSequenceHelper not found"

sf apex list class --json | grep -q "InterviewTriggerHandler" && \
    print_info "✓ InterviewTriggerHandler deployed" || \
    print_warning "⚠ InterviewTriggerHandler not found"

echo ""
print_info "═══════════════════════════════════════════════"
print_info "          DEPLOYMENT COMPLETED!                "
print_info "═══════════════════════════════════════════════"
echo ""

if [ "$DRY_RUN" = false ]; then
    print_info "Next steps:"
    echo "  1. Test Interview scheduling modal in production"
    echo "  2. Verify Highest_Level_Achieved__c auto-updates"
    echo "  3. Check with recruiters that everything works"
    echo "  4. Monitor debug logs for any errors"
    echo ""
    print_info "See PRODUCTION_DEPLOYMENT_GUIDE.md for detailed validation steps"
else
    print_info "This was a dry-run. No changes were made to production."
    print_info "Run without --dry-run to deploy for real."
fi

echo ""
print_info "Deployment log saved to: deployment-$(date +%Y%m%d-%H%M%S).log"

# Save deployment record
echo "Deployment completed at $(date)" >> "deployment-$(date +%Y%m%d-%H%M%S).log"
