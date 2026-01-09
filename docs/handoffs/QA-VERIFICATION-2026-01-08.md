# QA Verification Report - Candidates in Contracting Component
**Date:** 2026-01-08  
**Agent:** QA Agent  
**Previous Agent:** Deployment Agent  
**Status:** ⚠️ ISSUES FOUND

---

## Deployment Verification

✅ **Metadata Deployment:** Successful (Deploy ID: 0AfVo000000tBHNKA2)
✅ **NRF Stage 07 Activated:** Confirmed in Custom Metadata

---

## Production Data Analysis

### Actual Record Counts (Excluding Terminal Stages)

| Record Type | Actual Count | Expected Count | Status |
|-------------|--------------|----------------|--------|
| Broker | 12 | 61 | ❌ 49 missing |
| Career | 26 | 23 | ⚠️ 3 extra |
| NRF | 0 | 21 | ❌ 21 missing |
| Registration | 2 | 12 | ❌ 10 missing |

---

## Critical Issues Discovered

### Issue #1: Data Quality - Stage Values Don't Match Metadata ⚠️⚠️⚠️

**Problem:** ALC records have stage values that don't exist in Custom Metadata configuration.

**Broker Record Type - Actual Stages in Data:**
```
✅ Pending SM (1 record) - matches metadata
✅ Submit to HO (1 record) - matches metadata
❌ Candidate Complete (3 records) - THIS IS A CAREER STAGE!
❌ Received Approval Letter (22 records) - THIS IS A REGISTRATION STAGE!
❌ CANCELED (1 record) - terminal stage
❌ CANCELLED (10 records) - terminal stage (spelling variation)
❌ Create Card in Capstone ALC Trackers (7 records) - NOT IN METADATA!
⚠️ MM Onyx Sent (1 record) - metadata has "MM_ONX_Sent" (underscore)
❌ Post Background - Pending SM/Rachyll (2 records) - NOT IN METADATA!
```

**Career Record Type - Actual Stages in Data:**
```
✅ Initial Form Sent (2 records) - matches metadata
✅ MM_ONX_Sent (2 records) - matches metadata
✅ Post Background - Pending Rachyll (15 records) - matches metadata
✅ Pending SM (3 records) - matches metadata
✅ Contract Codes (A/B) & DocuSign (3 records) - matches metadata
❌ Candidate Complete (50 records) - terminal stage
❌ CANCELED (95 records) - terminal stage
❌ To do (1 record) - NOT IN METADATA!
```

**Registration Record Type - Actual Stages in Data:**
```
✅ Follow Up with Agent (1 record) - matches metadata
✅ Background Check (if 6 months or more) (1 record) - matches metadata
```

**NRF Record Type:**
```
❌ NO RECORDS FOUND - Expected 21 records
```

---

### Issue #2: Record Type Misassignment 🚨

**Critical:** Many Broker records have stage values from OTHER record types:
- 22 Broker records in "Received Approval Letter" (Registration terminal stage)
- 3 Broker records in "Candidate Complete" (Career terminal stage)

**Root Causes:**
1. Records may have been manually edited with wrong stage values
2. Records may have wrong Record Type assignment
3. Picklist values may not be restricted by Record Type
4. Data migration may have mixed stage values

---

### Issue #3: Stage Value Variations

**Found multiple spelling/format variations:**
- "CANCELED" vs "CANCELLED" (both appear in data)
- "MM Onyx Sent" vs "MM_ONX_Sent" (underscore vs space)
- "Post Background - Pending SM/Rachyll" vs "Post Background - Pending Rachyll"

---

### Issue #4: Undocumented Stages

**Stages in data but NOT in Custom Metadata:**
- "Create Card in Capstone ALC Trackers" (7 Broker records)
- "Post Background - Pending SM/Rachyll" (2 Broker records)  
- "To do" (1 Career record)

These records will be excluded from the component because their stages aren't in `validStages` set.

---

## Component Impact Analysis

### What the Component Will Show

Based on current Custom Metadata + actual data:

**Broker Tab:**
- Will show: 2 records (Pending SM + Submit to HO)
- Won't show: 46 records (wrong stages, terminal stages, or not in metadata)
- **Tab will show: "Broker (2)"** not "Broker (61)"

**Career Tab:**
- Will show: 25 records (excluding 50 Candidate Complete + 95 CANCELED + 1 To do)
- **Tab will show: "Career (25)"** close to expected 23

**NRF Tab:**
- Will show: 0 records (no NRF records exist in data)
- **Tab will show: "NRF (0)"** not "NRF (21)"

**Registration Tab:**
- Will show: 2 records
- **Tab will show: "Registration (2)"** not "Registration (12)"

---

## Root Cause Analysis

### Why Counts Don't Match Reference View

The reference Kanban view likely:
1. **Uses different stage filtering** - May show ALL stages or use different picklist values
2. **Has different Record Type scope** - May be querying different records
3. **Uses historical data** - May include archived or deleted records
4. **Has custom logic** - May group stages differently

### Data Integrity Issues

The ALC object has significant data quality problems:
1. **No Record Type + Stage validation** - Records can have any stage value regardless of Record Type
2. **Manual data entry errors** - Stage values don't match metadata configuration
3. **Missing picklist dependencies** - Stage picklist not controlled by Record Type
4. **Legacy data** - Old stage values still in use

---

## Recommended Actions

### Immediate (Critical)

1. **Verify Reference View Configuration**
   - Ask user which view they're using as reference
   - Check that view's filters and stage values
   - Determine if reference counts include terminal stages

2. **Data Quality Fix Required**
   - Run data audit to identify all records with invalid stage values
   - Create picklist value dependencies: Record Type → Stage__c
   - Clean up data: fix Record Types or stage values
   - Standardize spelling (CANCELED vs CANCELLED)

3. **Custom Metadata Alignment**
   - Add missing stages to Custom Metadata if they're valid workflow stages
   - Or mark existing records' stages as invalid and fix them

### Short Term

1. **Query Production to Match Reference**
   ```sql
   -- Run this query in the reference view's context
   SELECT RecordType.DeveloperName, Stage__c, COUNT(Id) 
   FROM ALC__c 
   WHERE [same filters as reference view]
   GROUP BY RecordType.DeveloperName, Stage__c
   ```

2. **Update Custom Metadata**
   - If "Create Card in Capstone ALC Trackers" is valid, add to metadata
   - If "MM Onyx Sent" is correct, update metadata from "MM_ONX_Sent"
   - Add any other valid stages found in data

3. **Fix Data**
   - Bulk update Broker records in "Received Approval Letter" to correct Record Type or stage
   - Fix "MM Onyx Sent" → "MM_ONX_Sent" (or vice versa)
   - Resolve CANCELED vs CANCELLED spelling

---

## Questions for User

1. **Which Kanban view are you using as reference?**
   - What's the exact API name or URL?
   - Can you export its configuration?

2. **Are the stage values in Custom Metadata correct?**
   - Is "MM_ONX_Sent" correct or should it be "MM Onyx Sent"?
   - Should "Create Card in Capstone ALC Trackers" be a valid stage?

3. **What about Record Type assignment?**
   - Are Broker records supposed to have "Received Approval Letter" stage?
   - Or are these records assigned to wrong Record Type?

4. **Terminal stage handling:**
   - Does reference view show CANCELED/CANCELLED records?
   - Should we standardize on one spelling?

5. **Where are the NRF and missing Registration records?**
   - Do they exist in production?
   - Are they filtered out by some criteria?

---

## Current Status

⚠️ **Component is working correctly based on Custom Metadata configuration**

❌ **But production data doesn't match the metadata**

**Next Steps:**
1. User clarifies reference view and data expectations
2. Fix data quality issues (Record Types, stage values)
3. Update Custom Metadata to match valid production stage values
4. Re-test after data fixes applied

---

**QA Verification Complete - Issues Documented**

**Handoff To:** User for clarification and data quality decisions
