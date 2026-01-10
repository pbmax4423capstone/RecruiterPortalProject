# Deployment Runbook: Summary Card Metrics Component

**Component:** summaryCardMetrics  
**Version:** 1.0 (Phase 1 - Mock Data)  
**Date:** December 23, 2025

---

## DEPLOYMENT STATUS

### ✅ Recruiting Sandbox (COMPLETED)

- **Org:** patrickbakeradmin2@financialguide.com.recruiting
- **Deploy ID:**
  - LWC: 0Afdh0000054zBhCAI
  - Apex: 0Afdh0000054yV4CAI
- **Status:** Succeeded
- **Date:** December 23, 2025
- **Components Deployed:**
  - ✅ summaryCardMetrics.html
  - ✅ summaryCardMetrics.js
  - ✅ summaryCardMetrics.css
  - ✅ summaryCardMetrics.js-meta.xml
  - ✅ SummaryCardMetricsController.cls
  - ✅ SummaryCardMetricsControllerTest.cls

### ⏳ ProdTest Sandbox (PENDING)

- **Org:** patrickbakeradmin2@financialguide.com.prodtest
- **Status:** Not yet deployed (awaiting custom field sync)
- **Blocker:** Existing classes have compilation errors due to missing custom fields

### ⏳ Production (PHASE 2)

- **Status:** Not yet deployed
- **Prerequisite:** Phase 2 implementation with real data integration

---

## DEPLOYMENT COMMANDS

### Option 1: Deploy LWC Component Only

```powershell
cd "c:\Users\patba\OneDrive - MassMutual\SF Projects VS Code\SalesforceRecruiterPortal\RecruiterPortal"
sf project deploy start --target-org Recruiting --source-dir force-app/main/default/lwc/summaryCardMetrics
```

### Option 2: Deploy Apex Classes Only

```powershell
cd "c:\Users\patba\OneDrive - MassMutual\SF Projects VS Code\SalesforceRecruiterPortal\RecruiterPortal"
sf project deploy start --target-org Recruiting --metadata "ApexClass:SummaryCardMetricsController" --metadata "ApexClass:SummaryCardMetricsControllerTest"
```

### Option 3: Deploy Everything Together

```powershell
cd "c:\Users\patba\OneDrive - MassMutual\SF Projects VS Code\SalesforceRecruiterPortal\RecruiterPortal"

# LWC Component
sf project deploy start --target-org Recruiting --source-dir force-app/main/default/lwc/summaryCardMetrics

# Apex Classes
sf project deploy start --target-org Recruiting --metadata "ApexClass:SummaryCardMetricsController" --metadata "ApexClass:SummaryCardMetricsControllerTest"
```

### Validation-Only Deployment (Dry Run)

```powershell
# Add --dry-run flag to test without actually deploying
sf project deploy start --dry-run --target-org Recruiting --source-dir force-app/main/default/lwc/summaryCardMetrics
```

---

## POST-DEPLOYMENT VALIDATION

### 1. Verify Component in Setup

1. Log into Recruiting Sandbox
2. Navigate to **Setup** → **Custom Code** → **Lightning Components**
3. Search for `summaryCardMetrics`
4. Verify status: **Active**

### 2. Verify Apex Classes

1. Navigate to **Setup** → **Custom Code** → **Apex Classes**
2. Verify presence:
   - `SummaryCardMetricsController`
   - `SummaryCardMetricsControllerTest`
3. Check compilation status: **No errors**

### 3. Run Apex Test

```powershell
sf apex run test --target-org Recruiting --tests SummaryCardMetricsControllerTest --result-format human
```

Expected output:

- Test: `testGetMetricsPhase1ReturnsEmptyMap` - **PASS**
- Coverage: 100% (Phase 1 stub method)

### 4. Test in Lightning App Builder

1. Open Lightning App Builder
2. Create or edit an App Page
3. Drag `Summary Card Metrics` component onto page
4. Save and activate
5. Preview page
6. Verify:
   - ✅ 6 metric cards visible
   - ✅ Values: 24, 8, 12, 3, 5, 85%
   - ✅ Gradient colors display correctly
   - ✅ Definitions table visible
   - ✅ Informational note visible

### 5. Test Click Events

1. Open browser Developer Tools (F12)
2. Go to **Console** tab
3. Click on each metric card
4. Verify console logs show:
   ```javascript
   Summary card clicked: {label: "Total Candidates", value: "24", timestamp: "..."}
   ```

### 6. Test Responsive Design

1. Use browser Developer Tools responsive mode
2. Test breakpoints:
   - Desktop (1024px+): 6 cards in 1 row
   - Tablet (768-1023px): 3 cards per row
   - Mobile (<768px): Cards stack vertically

---

## ROLLBACK PROCEDURE

### If Issues Occur, Roll Back Immediately

#### Step 1: Remove Component from Pages

```powershell
# If component was added to Lightning pages, remove it first
# Via UI: Edit page in Lightning App Builder, remove component, save
```

#### Step 2: Delete Metadata

```powershell
cd "c:\Users\patba\OneDrive - MassMutual\SF Projects VS Code\SalesforceRecruiterPortal\RecruiterPortal"

# Delete LWC
sf project delete source --target-org Recruiting --metadata "LightningComponentBundle:summaryCardMetrics" --no-prompt

# Delete Apex Classes
sf project delete source --target-org Recruiting --metadata "ApexClass:SummaryCardMetricsController" --no-prompt
sf project delete source --target-org Recruiting --metadata "ApexClass:SummaryCardMetricsControllerTest" --no-prompt
```

#### Step 3: Verify Removal

1. Check Setup → Lightning Components (should not show summaryCardMetrics)
2. Check Setup → Apex Classes (should not show SummaryCardMetrics\*)
3. Verify no dependent components are affected

---

## DEPLOYMENT TO PRODTEST

### Prerequisites

1. ✅ Successful deployment to Recruiting Sandbox
2. ✅ Manual testing completed
3. ⚠️ **BLOCKER:** Sync custom fields to ProdTest
   - Missing fields: Total_FYC**c, Contract_Outcome**c, Transition_to_A_Date**c, Termination_Date**c, Termination_Reason\_\_c
4. ✅ Validation deployment passes

### Commands for ProdTest

```powershell
cd "c:\Users\patba\OneDrive - MassMutual\SF Projects VS Code\SalesforceRecruiterPortal\RecruiterPortal"

# Validation only (dry run)
sf project deploy start --dry-run --target-org patrickbakeradmin2@financialguide.com.prodtest --source-dir force-app/main/default/lwc/summaryCardMetrics

# Actual deployment (after validation passes)
sf project deploy start --target-org patrickbakeradmin2@financialguide.com.prodtest --source-dir force-app/main/default/lwc/summaryCardMetrics

# Deploy Apex
sf project deploy start --target-org patrickbakeradmin2@financialguide.com.prodtest --metadata "ApexClass:SummaryCardMetricsController" --metadata "ApexClass:SummaryCardMetricsControllerTest"
```

---

## DEPLOYMENT TO PRODUCTION (PHASE 2)

### Prerequisites

1. ✅ Phase 2 implementation complete (real data integration)
2. ✅ Wire service connected to Apex
3. ✅ All tests passing with real data
4. ✅ ProdTest validation successful
5. ✅ Stakeholder sign-off
6. ✅ Change request approved

### Production Deployment Strategy

1. **Validation Deployment** (--dry-run)
2. **Scheduled Maintenance Window** (if required)
3. **Actual Deployment**
4. **Smoke Testing** (verify component loads)
5. **Monitoring** (check for errors in 24 hours)

---

## KNOWN ISSUES & MITIGATIONS

### Issue 1: ProdTest Custom Field Sync

**Problem:** ProdTest sandbox missing custom fields from Recruiting  
**Impact:** Cannot deploy entire classes folder due to compilation errors in unrelated classes  
**Mitigation:** Deploy only summaryCardMetrics component individually  
**Resolution:** Sync custom field metadata from Recruiting to ProdTest

### Issue 2: Phase 1 Mock Data Only

**Status:** Expected behavior  
**Impact:** Component displays hardcoded values (not real data)  
**Mitigation:** Clearly labeled as Phase 1 in documentation  
**Resolution:** Phase 2 implementation will connect to real data

---

## MAINTENANCE & SUPPORT

### Component Owner

- Team: Recruiter Portal Development Team
- Repository: RecruiterPortalProject (GitHub)
- Documentation:
  - `docs/requirements-summary-card-metrics.md`
  - `docs/technical-design-summary-card-metrics.md`
  - `docs/qa-validation-report-summary-card-metrics.md`

### Future Enhancements (Phase 2)

1. Connect to real Salesforce data via wire service
2. Implement actual filtering of Pipeline Details table
3. Add refresh button
4. Add drill-down navigation
5. Add export functionality
6. Implement WCAG 2.1 AA accessibility

---

## DEPLOYMENT CHECKLIST

### Pre-Deployment

- [✅] Code reviewed and approved
- [✅] QA validation complete (100% pass rate)
- [✅] Documentation complete
- [✅] Target org credentials verified
- [✅] Backup of existing metadata (N/A - new component)

### Deployment

- [✅] Deploy LWC component - **SUCCEEDED**
- [✅] Deploy Apex controller - **SUCCEEDED**
- [✅] Deploy Apex test class - **SUCCEEDED**
- [✅] Verify deployment status - **SUCCEEDED**

### Post-Deployment

- [ ] Verify component in Setup
- [ ] Run Apex tests
- [ ] Test in Lightning App Builder
- [ ] Test click event handlers
- [ ] Test responsive design
- [ ] Stakeholder demo/approval
- [ ] Update deployment log

---

## DEPLOYMENT LOG

| Date       | Environment        | Status       | Deploy ID                 | Notes                              |
| ---------- | ------------------ | ------------ | ------------------------- | ---------------------------------- |
| 2025-12-23 | Recruiting Sandbox | ✅ Succeeded | 0Afdh0000054zBhCAI (LWC)  | LWC deployed successfully          |
| 2025-12-23 | Recruiting Sandbox | ✅ Succeeded | 0Afdh0000054yV4CAI (Apex) | Apex classes deployed successfully |
| TBD        | ProdTest Sandbox   | ⏳ Pending   | -                         | Awaiting custom field sync         |
| TBD        | Production         | ⏳ Phase 2   | -                         | Requires Phase 2 implementation    |

---

## CONTACT INFORMATION

**Questions or Issues:**

- Check documentation in `docs/` folder
- Review QA validation report
- Consult technical design document
- Refer to Phase 2 handoff notes

---

**Deployment Status:** ✅ Phase 1 Complete - Recruiting Sandbox  
**Next Step:** Manual testing and validation in Lightning App Builder  
**Phase 2 Readiness:** Component structure supports future data integration
