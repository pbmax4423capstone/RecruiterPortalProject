# Quick Deployment Commands

## Fast Deploy - All Components

```bash
# Full deployment to production (default org)
sf project deploy start --source-dir force-app

# Dry run first (recommended)
sf project deploy start --source-dir force-app --dry-run
```

## Deploy Using Manifest File

```bash
# Deploy interview scheduling enhancement using manifest
sf project deploy start --manifest manifest/package-interview-scheduling-enhancement.xml

# Dry run with manifest
sf project deploy start --manifest manifest/package-interview-scheduling-enhancement.xml --dry-run
```

## Deploy Using Script

```bash
# Dry run deployment
./scripts/deploy-to-production.sh --dry-run

# Full deployment
./scripts/deploy-to-production.sh

# Skip tests (not recommended for production)
./scripts/deploy-to-production.sh --skip-tests
```

## Deploy Individual Components

### Apex Classes

```bash
sf project deploy start \
  --source-dir force-app/main/default/classes/InterviewSequenceHelper.cls \
  --source-dir force-app/main/default/classes/InterviewSequenceHelper.cls-meta.xml \
  --source-dir force-app/main/default/classes/InterviewSequenceHelperTest.cls \
  --source-dir force-app/main/default/classes/InterviewSequenceHelperTest.cls-meta.xml
```

### Triggers

```bash
sf project deploy start \
  --source-dir force-app/main/default/triggers/InterviewTrigger.trigger \
  --source-dir force-app/main/default/triggers/InterviewTrigger.trigger-meta.xml
```

### LWCs

```bash
sf project deploy start \
  --source-dir force-app/main/default/lwc/candidateRecordView \
  --source-dir force-app/main/default/lwc/recruiterPortalHeader \
  --source-dir force-app/main/default/lwc/portalHeaderNew
```

### Permission Sets

```bash
sf project deploy start \
  --source-dir force-app/main/default/permissionsets/Recruiter_Dashboard_Access.permissionset-meta.xml
```

## Run Tests After Deployment

```bash
# Run all local tests
sf apex run test --test-level RunLocalTests --output-dir test-results --result-format human

# Run specific test classes
sf apex run test --tests InterviewSequenceHelperTest InterviewTriggerHandlerTest --result-format human

# Run tests with code coverage
sf apex run test --test-level RunLocalTests --code-coverage --result-format human
```

## Verify Deployment

```bash
# List Apex classes to verify deployment
sf apex list class --json | grep -E "InterviewSequenceHelper|InterviewTriggerHandler"

# Check org info
sf org display

# Get recent deployment status
sf project deploy report
```

## Rollback Commands

```bash
# Retrieve previous version from org
sf project retrieve start --source-dir force-app/main/default/classes/InterviewSequenceHelper.cls

# Or checkout from git and redeploy
git checkout HEAD~1 force-app/main/default/classes/InterviewSequenceHelper*
sf project deploy start --source-dir force-app/main/default/classes
```

## Deploy to Sandbox (ProdTest)

```bash
# Full deployment to sandbox
sf project deploy start --source-dir force-app --target-org ProdTest

# Using manifest to sandbox
sf project deploy start --manifest manifest/package-interview-scheduling-enhancement.xml --target-org ProdTest
```

## Set Target Org

```bash
# Set production as default
sf config set target-org=ProductionCapstone

# Set sandbox as default
sf config set target-org=ProdTest

# View current configuration
sf config list
```

## Authentication Commands (if needed)

```bash
# Login to production
sf org login web --alias ProductionCapstone --instance-url https://login.salesforce.com

# Login to sandbox
sf org login web --alias ProdTest --instance-url https://test.salesforce.com

# List authenticated orgs
sf org list
```

---

**For complete deployment guide with validation steps, see:** [PRODUCTION_DEPLOYMENT_GUIDE.md](./PRODUCTION_DEPLOYMENT_GUIDE.md)
