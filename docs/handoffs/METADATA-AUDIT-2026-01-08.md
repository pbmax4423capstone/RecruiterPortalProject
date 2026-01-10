# Custom Metadata Audit - ALC Stage Configuration

**Date:** 2026-01-08  
**Agent:** Research Agent  
**Handoff To:** Metadata Specialist Agent

## Audit Summary

Audited all 37 ALC_Stage_Config custom metadata records to identify incorrectly inactive stages.

### Findings

**CRITICAL ISSUE IDENTIFIED:** NRF Stage 07 "Request FieldNet/CoverPath Access" is marked `Is_Active__c = false` but is NOT a terminal stage. It is a workflow stage (Sort Order 7) that should be active.

## Complete Metadata Audit Table

### Broker Record Type (9 stages)

| Sort | Stage API Value                   | Stage Label                       | Is_Active    | Color   | Type         |
| ---- | --------------------------------- | --------------------------------- | ------------ | ------- | ------------ |
| 1    | Initial Form Sent                 | Initial Form Sent                 | ✅ true      | #1589EE | Workflow     |
| 2    | MM_ONX_Sent                       | MM ONX sent                       | ✅ true      | #0D47A1 | Workflow     |
| 3    | Background Check                  | Background Check                  | ✅ true      | #9C27B0 | Workflow     |
| 4    | CORP- ECQ Request                 | CORP- ECQ Request                 | ✅ true      | #E83A86 | Workflow     |
| 5    | Submit to HO                      | Submit to HO                      | ✅ true      | #009688 | Workflow     |
| 6    | AA Received                       | AA Received                       | ✅ true      | #E37C06 | Workflow     |
| 7    | Request FieldNet/CoverPath Access | Request FieldNet/CoverPath Access | ✅ true      | #673AB7 | Workflow     |
| 8    | **COMPLETE**                      | **COMPLETE**                      | ❌ **false** | #4CAF50 | **Terminal** |
| 9    | **CANCELED**                      | **CANCELED**                      | ❌ **false** | #F44336 | **Terminal** |

**Broker Summary:**

- Total stages: 9
- Active workflow stages: 7
- Terminal stages (inactive): 2 (COMPLETE, CANCELED)
- Issues: ✅ None - correctly configured

---

### Career Record Type (12 stages)

| Sort | Stage API Value                   | Stage Label                       | Is_Active    | Color   | Type         |
| ---- | --------------------------------- | --------------------------------- | ------------ | ------- | ------------ |
| 1    | Initial Form Sent                 | Initial Form Sent                 | ✅ true      | #1589EE | Workflow     |
| 2    | MM_ONX_Sent                       | MM ONX sent                       | ✅ true      | #0D47A1 | Workflow     |
| 3    | In Background                     | In Background                     | ✅ true      | #9C27B0 | Workflow     |
| 4    | Post Background - Pending Rachyll | Post Background - Pending Rachyll | ✅ true      | #E83A86 | Workflow     |
| 5    | Sent To Compliance                | Sent To Compliance                | ✅ true      | #FF5722 | Workflow     |
| 6    | Pending SM                        | Pending SM                        | ✅ true      | #FF9800 | Workflow     |
| 7    | Contract Codes (A/B) & DocuSign   | Contract Codes (A/B) & DocuSign   | ✅ true      | #673AB7 | Workflow     |
| 8    | Submit to HO                      | Submit to HO                      | ✅ true      | #009688 | Workflow     |
| 9    | AA Received                       | AA Received                       | ✅ true      | #E37C06 | Workflow     |
| 10   | **Candidate Complete**            | **Candidate Complete**            | ❌ **false** | #4CAF50 | **Terminal** |
| 11   | **TERMINATED**                    | **TERMINATED**                    | ❌ **false** | #9E9E9E | **Terminal** |
| 12   | **CANCELED**                      | **CANCELED**                      | ❌ **false** | #F44336 | **Terminal** |

**Career Summary:**

- Total stages: 12
- Active workflow stages: 9
- Terminal stages (inactive): 3 (Candidate Complete, TERMINATED, CANCELED)
- Issues: ✅ None - correctly configured

---

### NRF Record Type (8 stages)

| Sort | Stage API Value                       | Stage Label                           | Is_Active    | Color   | Type                                |
| ---- | ------------------------------------- | ------------------------------------- | ------------ | ------- | ----------------------------------- |
| 1    | Initial Form Sent                     | Initial Form Sent                     | ✅ true      | #1589EE | Workflow                            |
| 2    | Receive NRF Info                      | Receive NRF Info                      | ✅ true      | #0D47A1 | Workflow                            |
| 3    | Request AE                            | Request AE                            | ✅ true      | #9C27B0 | Workflow                            |
| 4    | Step 1 Email                          | Step 1 Email                          | ✅ true      | #E83A86 | Workflow                            |
| 5    | NRF BIG Review                        | NRF BIG Review                        | ✅ true      | #FF5722 | Workflow                            |
| 6    | Fingerprinting                        | Fingerprinting                        | ✅ true      | #FF9800 | Workflow                            |
| 7    | **Request FieldNet/CoverPath Access** | **Request FieldNet/CoverPath Access** | ⚠️ **false** | #673AB7 | **❌ WORKFLOW (SHOULD BE ACTIVE!)** |
| 8    | **COMPLETE**                          | **COMPLETE**                          | ❌ **false** | #4CAF50 | **Terminal**                        |

**NRF Summary:**

- Total stages: 8
- Active workflow stages: 6 (should be 7)
- Terminal stages (inactive): 1 (COMPLETE)
- **⚠️ CRITICAL ISSUE:** Stage 07 "Request FieldNet/CoverPath Access" is incorrectly marked inactive - it's a workflow stage, not terminal!

---

### Registration Record Type (8 stages)

| Sort | Stage API Value                        | Stage Label                            | Is_Active    | Color   | Type         |
| ---- | -------------------------------------- | -------------------------------------- | ------------ | ------- | ------------ |
| 1    | Pending Instructions                   | Pending Instructions                   | ✅ true      | #1589EE | Workflow     |
| 2    | Pending Scheduling Zoom                | Pending Scheduling Zoom                | ✅ true      | #0D47A1 | Workflow     |
| 3    | Complete U4                            | Complete U4                            | ✅ true      | #9C27B0 | Workflow     |
| 4    | Follow Up with Agent                   | Follow Up with Agent                   | ✅ true      | #E83A86 | Workflow     |
| 5    | Background Check (if 6 months or more) | Background Check (if 6 months or more) | ✅ true      | #FF5722 | Workflow     |
| 6    | Submit to HO                           | Submit to HO                           | ✅ true      | #009688 | Workflow     |
| 7    | **Received Approval Letter**           | **Received Approval Letter**           | ❌ **false** | #4CAF50 | **Terminal** |
| 8    | **CANCELED**                           | **CANCELED**                           | ❌ **false** | #F44336 | **Terminal** |

**Registration Summary:**

- Total stages: 8
- Active workflow stages: 6
- Terminal stages (inactive): 2 (Received Approval Letter, CANCELED)
- Issues: ✅ None - correctly configured

---

## Overall Summary

**Total Stages Across All Record Types:** 37

**Terminal Stages (correctly inactive):** 8

- Broker: COMPLETE, CANCELED
- Career: Candidate Complete, TERMINATED, CANCELED
- NRF: COMPLETE
- Registration: Received Approval Letter, CANCELED

**Workflow Stages (should be active):** 29

- Currently active: 28
- **Incorrectly inactive: 1** ⚠️

---

## Issues Requiring Fix

### ⚠️ Issue #1: NRF Stage 07 Incorrectly Inactive

**File:** `ALC_Stage_Config.NRF_Stage_07.md-meta.xml`  
**Current Value:** `Is_Active__c = false`  
**Required Value:** `Is_Active__c = true`  
**Reason:** This is a workflow stage "Request FieldNet/CoverPath Access" (Sort Order 7) that comes BEFORE the terminal stage COMPLETE (Sort Order 8). It should be active.

---

## Expected Count Impact

After fixing NRF Stage 07, the component should display:

- **Broker:** All active records excluding COMPLETE and CANCELED stages
- **Career:** All active records excluding Candidate Complete, TERMINATED, and CANCELED stages
- **NRF:** All active records INCLUDING "Request FieldNet/CoverPath Access" but excluding COMPLETE stage
- **Registration:** All active records excluding Received Approval Letter and CANCELED stages

**User's Expected Counts:**

- Broker: 61
- Career: 23
- NRF: 21
- Registration: 12

The missing NRF Stage 07 may explain why counts are lower than expected.

---

## Next Steps for Metadata Specialist Agent

1. **Fix NRF_Stage_07:** Change `Is_Active__c` from `false` to `true`
2. **Verify No Other Issues:** Double-check that all terminal stages remain inactive
3. **Create Fix Summary:** Document the change in METADATA-FIXES-2026-01-08.md
4. **Prepare for Deployment:** List modified file for deployment

---

## Files Referenced

All 37 files in: `force-app/main/default/customMetadata/ALC_Stage_Config.*.md-meta.xml`

**Priority Fix:**

- `force-app/main/default/customMetadata/ALC_Stage_Config.NRF_Stage_07.md-meta.xml`

---

**Handoff Complete - Ready for Metadata Specialist Agent**
