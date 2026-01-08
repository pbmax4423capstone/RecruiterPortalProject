# Production Deployment Guide

## Overview

This document provides step-by-step instructions for deploying the Interview Scheduling Enhancement to production.

## Prerequisites

1. **Salesforce CLI installed and authenticated**

   ```bash
   sf --version  # Verify CLI is installed
   sf org list   # Verify orgs are authenticated
   ```

2. **Production org should be set as default**

   ```bash
   sf config set target-org=ProductionCapstone
   ```

3. **Verify you have deployment permissions** in the production org

## Components to Deploy

Based on the intelligent interview scheduling enhancement (commit c93b0f7), the following components need to be deployed:

### 1. Apex Classes

- `InterviewSequenceHelper.cls` - New helper class for interview logic
- `InterviewSequenceHelperTest.cls` - Test class for InterviewSequenceHelper
- `InterviewTriggerHandler.cls` - Handler class for Interview trigger
- `InterviewTriggerHandlerTest.cls` - Test class for InterviewTriggerHandler

### 2. Triggers

- `InterviewTrigger.trigger` - Trigger to update Candidate.Highest_Level_Achieved\_\_c

### 3. Lightning Web Components (LWCs)

- `candidateRecordView` - Enhanced with auto-refresh functionality
- `recruiterPortalHeader` - Enhanced with context-aware interview suggestions
- `portalHeaderNew` - Updated for modal functionality

### 4. Permission Sets

- `Recruiter_Dashboard_Access.permissionset-meta.xml` - Updated with InterviewSequenceHelper access

### 5. Layouts

- `Interview__c-Interview Layout.layout-meta.xml` - Removed Conducted_By\_\_c field

### 6. Object Metadata

- `Interview__c` - Interview object with updated picklist values
- `Candidate__c` - Candidate object with Highest_Level_Achieved\_\_c field

## Deployment Steps

### Option 1: Deploy All Components Together (Recommended)

Deploy the entire force-app directory to ensure all dependencies are included:

```bash
sf project deploy start --source-dir force-app --dry-run
```

Review the dry-run results, then deploy:

```bash
sf project deploy start --source-dir force-app
```

### Option 2: Deploy Components Incrementally

If you prefer to deploy specific components, follow this order:

#### Step 1: Deploy Apex Classes and Triggers

```bash
# Deploy InterviewSequenceHelper class
sf project deploy start --source-dir "force-app/main/default/classes/InterviewSequenceHelper.cls" \
                        --source-dir "force-app/main/default/classes/InterviewSequenceHelper.cls-meta.xml"

# Deploy InterviewTriggerHandler class
sf project deploy start --source-dir "force-app/main/default/classes/InterviewTriggerHandler.cls" \
                        --source-dir "force-app/main/default/classes/InterviewTriggerHandler.cls-meta.xml"

# Deploy InterviewTrigger
sf project deploy start --source-dir "force-app/main/default/triggers/InterviewTrigger.trigger" \
                        --source-dir "force-app/main/default/triggers/InterviewTrigger.trigger-meta.xml"

# Deploy test classes
sf project deploy start --source-dir "force-app/main/default/classes/InterviewSequenceHelperTest.cls" \
                        --source-dir "force-app/main/default/classes/InterviewSequenceHelperTest.cls-meta.xml"

sf project deploy start --source-dir "force-app/main/default/classes/InterviewTriggerHandlerTest.cls" \
                        --source-dir "force-app/main/default/classes/InterviewTriggerHandlerTest.cls-meta.xml"
```

#### Step 2: Deploy LWCs

```bash
# Deploy candidateRecordView
sf project deploy start --source-dir "force-app/main/default/lwc/candidateRecordView"

# Deploy recruiterPortalHeader
sf project deploy start --source-dir "force-app/main/default/lwc/recruiterPortalHeader"

# Deploy portalHeaderNew
sf project deploy start --source-dir "force-app/main/default/lwc/portalHeaderNew"
```

#### Step 3: Deploy Permission Sets

```bash
sf project deploy start --source-dir "force-app/main/default/permissionsets/Recruiter_Dashboard_Access.permissionset-meta.xml"
```

#### Step 4: Deploy Object Metadata and Layouts

```bash
# Deploy Interview layout
sf project deploy start --source-dir "force-app/main/default/layouts/Interview__c-Interview Layout.layout-meta.xml"

# Deploy Interview object metadata if needed
sf project deploy start --source-dir "force-app/main/default/objects/Interview__c"
```

### Option 3: Deploy Using Manifest File

Create a package.xml manifest file and deploy:

```bash
sf project deploy start --manifest manifest/package.xml
```

## Post-Deployment Validation

### 1. Run All Tests

```bash
sf apex run test --test-level RunLocalTests --output-dir test-results --result-format human
```

Ensure all tests pass with at least 75% code coverage.

### 2. Verify Components

#### Verify Apex Classes

```bash
sf apex list class --json | grep -E "InterviewSequenceHelper|InterviewTriggerHandler"
```

#### Verify Trigger

- Navigate to Setup > Apex Triggers
- Confirm `InterviewTrigger` is active on Interview\_\_c object

#### Verify LWCs

- Navigate to a Candidate record page
- Verify the Schedule Interview modal shows correct suggestions
- Test creating a new interview with auto-populated fields

#### Verify Permission Set

- Navigate to Setup > Permission Sets > Recruiter Dashboard Access
- Confirm `InterviewSequenceHelper` class is included in Apex Class Access

### 3. Functional Testing

Test the following scenarios in production:

1. **Interview Sequencing**
   - Open a candidate record with no completed interviews
   - Click "Schedule Interview" - should suggest "Ci-First"
   - Complete a Ci-First interview
   - Click "Schedule Interview" again - should suggest "Align-2nd"

2. **Highest Level Achieved Update**
   - Create and complete interviews for a candidate
   - Verify `Highest_Level_Achieved__c` field updates automatically on the Candidate record

3. **Modal Functionality**
   - Verify the Schedule Interview modal opens correctly
   - Check that conductor name auto-populates with current user
   - Verify all fields are editable and save properly

## Rollback Plan

If issues are encountered, rollback using these steps:

### Rollback Apex Classes and Triggers

```bash
# Get previous version from source control
git checkout HEAD~1 force-app/main/default/classes/InterviewSequenceHelper*
git checkout HEAD~1 force-app/main/default/classes/InterviewTriggerHandler*
git checkout HEAD~1 force-app/main/default/triggers/InterviewTrigger*

# Deploy previous version
sf project deploy start --source-dir force-app/main/default/classes --source-dir force-app/main/default/triggers
```

### Deactivate Trigger (Emergency)

```apex
// Execute in Anonymous Apex
MetadataTrigger mt = [SELECT Id FROM MetadataTrigger WHERE DeveloperName = 'InterviewTrigger' LIMIT 1];
mt.Status = 'Inactive';
update mt;
```

## Monitoring

After deployment, monitor:

1. **Debug Logs** - Watch for any errors in Interview trigger execution
2. **Interview Records** - Verify Highest_Level_Achieved\_\_c is updating correctly
3. **User Feedback** - Check with recruiters that modals work as expected

## Troubleshooting

### Common Issues

**Issue**: Test failures during deployment
**Solution**: Review test error messages and ensure test data setup is correct

**Issue**: Permission errors when users try to schedule interviews
**Solution**: Verify Recruiter_Dashboard_Access permission set is assigned to users

**Issue**: Modal doesn't open or shows errors
**Solution**: Check browser console for JavaScript errors, verify LWC deployment

## Support Contacts

- **Technical Issues**: Cole Arnold, Patrick Baker
- **Business Questions**: Sales Manager Team
- **Salesforce Admin**: patrickbakeradmin2@financialguide.com

## Deployment Checklist

- [ ] Verify Salesforce CLI authenticated to production
- [ ] Run dry-run deployment
- [ ] Review dry-run results
- [ ] Execute deployment
- [ ] Run all tests (ensure 75%+ coverage)
- [ ] Verify components deployed successfully
- [ ] Perform functional testing
- [ ] Monitor for 24 hours post-deployment
- [ ] Document any issues encountered
- [ ] Notify team of successful deployment

## Deployment History

| Date | Deployed By | Components                       | Status  | Notes              |
| ---- | ----------- | -------------------------------- | ------- | ------------------ |
| TBD  | TBD         | Interview Scheduling Enhancement | Pending | Initial deployment |

---

_Document Version: 1.0_
_Last Updated: 2026-01-08_
