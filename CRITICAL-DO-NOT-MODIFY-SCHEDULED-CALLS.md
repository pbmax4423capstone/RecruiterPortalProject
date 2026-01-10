# ⚠️ CRITICAL: SCHEDULED CALLS MODAL - DO NOT MODIFY ⚠️

## ISSUE RE-FIXED: December 10, 2025 18:23 MST

### Problem (AGAIN)

The scheduled calls modal was showing EMAILS in the past due calls list.

**ROOT CAUSE**: The local file had the correct `TaskSubtype = 'Call'` filter, but the DEPLOYED VERSION in ProdTest org still had the old broken filter using Subject LIKE.

### Evidence

Apex Execute Anonymous test showed the deployed query was:

```apex
WHERE OwnerId = '...' AND IsClosed = false
AND (Subject LIKE '%Call%' OR Subject LIKE '%call%' OR Subject LIKE '%Phone%' OR Subject LIKE '%phone%')
AND ActivityDate < TODAY
```

This returned **34 tasks** including 20+ emails with TaskSubtype='Email'.

### Solution

RE-DEPLOYED `RecruiterDashboardController.cls` with correct filter:

```apex
AND TaskSubtype = 'Call'
```

**Deploy ID**: 0Afdm000006rBt7CAE (December 10, 2025 18:23 MST)

### Verification

After redeployment, same test returned **3 tasks** (only calls, no emails).

## 🚨 CRITICAL RULES - NEVER VIOLATE THESE 🚨

### Rule #1: Scheduled Calls Modal Filter

**LOCATION**: `RecruiterDashboardController.cls` - Method: `getCurrentUserCallDetails()`

**CORRECT FILTER** (Line ~1177):

```apex
'AND TaskSubtype = \'Call\' ' +
```

**❌ NEVER USE THESE**:

```apex
'AND (Subject LIKE \'%Call%\' OR Subject LIKE \'%call%\') ' +  // WRONG - includes emails!
'AND (TaskSubtype = \'Call\' OR Type = \'Call\') ' +  // WRONG - too broad!
```

### Rule #2: Components That Use This Method

The following components depend on `getCurrentUserCallDetails()`:

1. **scheduledCallsModal** (`scheduledCallsModal.js`)
   - Shows scheduled calls for today
   - Shows past due calls
   - MUST ONLY show calls with TaskSubtype = 'Call'
   - MUST NOT show emails or other task types

### Rule #3: When Working on Other Components

**IF YOU ARE WORKING ON:**

- Email components
- Task management
- Any other dashboard feature
- ANY component that is NOT scheduledCallsModal

**THEN:**

- ✅ DO: Make your changes to your specific component
- ❌ DO NOT: Touch `getCurrentUserCallDetails()` method
- ❌ DO NOT: Modify any filters in `RecruiterDashboardController.cls` related to calls
- ❌ DO NOT: Add `OR Type = 'Call'` to any call filtering logic

### Rule #4: Testing Requirements

Before deploying ANY changes to `RecruiterDashboardController.cls`:

1. Open the scheduled calls modal
2. Verify it shows ONLY calls (TaskSubtype = 'Call')
3. Verify past due section does NOT show emails
4. Verify scheduled section does NOT show emails

## Why TaskSubtype = 'Call' is the ONLY Correct Filter

### Salesforce Task Object Fields

- **TaskSubtype**: The specific type of task ('Call', 'Email', etc.) - THIS IS WHAT WE FILTER ON
- **Type**: A broader categorization field that can have overlapping values

### Why OR Type = 'Call' Breaks Things

- Emails can have Type = 'Email' which passes through OR filters
- Other task types can have Type values that overlap
- TaskSubtype is the precise field that indicates ONLY call tasks

## Component Dependencies

### scheduledCallsModal Component

**File**: `force-app/main/default/lwc/scheduledCallsModal/scheduledCallsModal.js`

**Lines 188-191**:

```javascript
const [scheduledData, pastDueData] = await Promise.all([
  getCurrentUserCallDetails({ callType: "scheduled" }),
  getCurrentUserCallDetails({ callType: "pastdue" })
]);
```

**Purpose**:

- Displays calls scheduled for today
- Displays calls that are past due
- Users interact with these calls to complete them or schedule follow-ups

**Why This Breaks**:
If emails show up in this modal:

- Users can't distinguish between calls and emails
- Call metrics become inaccurate
- Follow-up scheduling breaks
- User experience is confusing

## History of This Issue

### December 10, 2025

- **Incident**: Scheduled calls modal showing emails in past due section
- **Root Cause**: Filter was changed to `AND (TaskSubtype = 'Call' OR Type = 'Call')`
- **Impact**: Users saw emails mixed with calls
- **Resolution**: Removed `OR Type = 'Call'` from filter
- **Prevention**: Created this documentation

## Contact

If you need to modify call-related functionality:

1. Read this entire document
2. Test with scheduledCallsModal component
3. Verify no emails appear in the modal
4. Document your changes

---

## ⚠️ FINAL WARNING ⚠️

**DO NOT modify `getCurrentUserCallDetails()` without:**

1. Reading this entire document
2. Testing scheduledCallsModal component
3. Verifying the filter is EXACTLY `AND TaskSubtype = 'Call'`
4. Updating this documentation if changes are needed

**This component is critical to recruiter workflow. Breaking it impacts all users.**
