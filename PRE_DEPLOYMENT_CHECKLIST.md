# Pre-Deployment Checklist

Use this checklist before deploying to production to ensure a smooth deployment.

## ✅ Pre-Deployment Checks

### 1. Code Quality

- [ ] All code follows Salesforce best practices
- [ ] Code passes ESLint checks (`npm run lint`)
- [ ] Code is formatted with Prettier (`npm run prettier`)
- [ ] No hardcoded IDs or credentials in code
- [ ] Error handling is implemented properly

### 2. Testing

- [ ] All Apex test classes pass locally
- [ ] Test coverage is at least 75% for new classes
- [ ] InterviewSequenceHelperTest passes
- [ ] InterviewTriggerHandlerTest passes
- [ ] LWC tests pass (`npm run test`)

### 3. Documentation

- [ ] Code comments are clear and up-to-date
- [ ] README updated if needed
- [ ] User documentation updated
- [ ] Deployment guide reviewed (PRODUCTION_DEPLOYMENT_GUIDE.md)

### 4. Environment Preparation

- [ ] Salesforce CLI installed and updated
- [ ] Authenticated to production org (ProductionCapstone)
- [ ] Target org verified (`sf org display`)
- [ ] Backup of current production metadata taken

### 5. Dependency Check

- [ ] All dependent components identified
- [ ] Required custom fields exist in production
  - [ ] Candidate**c.Highest_Level_Achieved**c
  - [ ] Interview**c.Interview_Type**c
  - [ ] Interview**c.Interview_Status**c
  - [ ] Interview**c.Candidate**c
- [ ] Required objects exist
  - [ ] Candidate\_\_c
  - [ ] Interview\_\_c

### 6. Security Review

- [ ] Permission sets updated
  - [ ] Recruiter_Dashboard_Access includes InterviewSequenceHelper
- [ ] Field-level security checked
- [ ] Sharing rules reviewed
- [ ] No security vulnerabilities introduced

### 7. Communication

- [ ] Stakeholders notified of deployment
- [ ] Deployment window scheduled
- [ ] Maintenance window communicated if needed
- [ ] Support team prepared for user questions

### 8. Dry Run

- [ ] Dry-run deployment executed successfully
  ```bash
  sf project deploy start --source-dir force-app --dry-run
  ```
- [ ] Dry-run results reviewed
- [ ] No validation errors or warnings

### 9. Rollback Plan

- [ ] Previous version backed up in git
- [ ] Rollback commands documented
- [ ] Rollback procedure tested in sandbox
- [ ] Team knows who to contact if rollback needed

### 10. Components Ready

- [ ] InterviewSequenceHelper.cls (new)
- [ ] InterviewSequenceHelperTest.cls (new)
- [ ] InterviewTriggerHandler.cls (new)
- [ ] InterviewTriggerHandlerTest.cls (new)
- [ ] InterviewTrigger.trigger (new)
- [ ] candidateRecordView LWC (updated)
- [ ] recruiterPortalHeader LWC (updated)
- [ ] portalHeaderNew LWC (updated)
- [ ] Recruiter_Dashboard_Access permission set (updated)

## ✅ During Deployment

- [ ] Execute deployment command
- [ ] Monitor deployment progress
- [ ] Review deployment logs for any warnings
- [ ] Deployment completes successfully

## ✅ Post-Deployment Validation

### 1. Technical Validation

- [ ] All components deployed successfully
- [ ] Run all tests in production
  ```bash
  sf apex run test --test-level RunLocalTests
  ```
- [ ] Verify test coverage meets minimum (75%)
- [ ] Check for any deployment warnings

### 2. Functional Testing

- [ ] Test Interview Sequencing
  - [ ] Open candidate with no interviews
  - [ ] Click "Schedule Interview"
  - [ ] Verify "Ci-First" is suggested
  - [ ] Complete the interview
  - [ ] Schedule another interview
  - [ ] Verify "Align-2nd" is suggested

- [ ] Test Highest Level Achieved Update
  - [ ] Create and complete an interview
  - [ ] Verify Candidate.Highest_Level_Achieved\_\_c updates
  - [ ] Test with multiple interview types

- [ ] Test Modal Functionality
  - [ ] Modal opens without errors
  - [ ] Current user name auto-populates
  - [ ] All fields are editable
  - [ ] Save works correctly
  - [ ] Cancel works correctly

### 3. User Acceptance

- [ ] Recruiter team tests the feature
- [ ] Sales managers validate dashboards still work
- [ ] No blocking issues reported
- [ ] User feedback collected

### 4. Monitoring

- [ ] Debug logs show no errors
- [ ] Interview records creating correctly
- [ ] Highest_Level_Achieved\_\_c updating properly
- [ ] No performance degradation
- [ ] Monitor for 24-48 hours

### 5. Documentation

- [ ] Update deployment history in PRODUCTION_DEPLOYMENT_GUIDE.md
- [ ] Document any issues encountered
- [ ] Update runbook if needed
- [ ] Notify team of successful deployment

## ✅ Cleanup

- [ ] Remove dry-run files if any
- [ ] Archive deployment logs
- [ ] Update project board/tickets
- [ ] Celebrate successful deployment! 🎉

---

## Emergency Contacts

| Role             | Name          | Contact                               |
| ---------------- | ------------- | ------------------------------------- |
| Technical Lead   | Cole Arnold   | TBD                                   |
| Project Manager  | Patrick Baker | pbmax4423@gmail.com                   |
| Salesforce Admin | Patrick Baker | patrickbakeradmin2@financialguide.com |

## Quick Rollback

If critical issues arise:

```bash
# Deactivate trigger immediately
sf apex execute -f emergency-deactivate-trigger.apex

# Or deploy previous version
git checkout HEAD~1 force-app/main/default/
sf project deploy start --source-dir force-app
```

---

**Date Prepared:** 2026-01-08  
**Prepared By:** Copilot Agent  
**Version:** 1.0
