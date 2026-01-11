# Sales Manager Activity Filtering Fix

**Date:** January 10, 2026  
**Component:** salesManagerActivity LWC  
**Issue:** Modal displays full list instead of filtered list when Sales Manager filter is active

## Problem Description

When filtering by a specific Sales Manager on the Unified Recruiting Dashboard:
- The onboarding card displayed the **correct count** for the filtered Sales Manager
- However, clicking the card opened a modal showing **ALL candidates onboarding**, not just those for the filtered Sales Manager
- Same issue occurred with the "In Contracting" card

## Root Cause

In the `salesManagerActivity.js` component, two methods were hardcoding the Sales Manager filter parameter:

1. **`openAllContractingModal()`** (line 255)
2. **`openAllOnboardingModal()`** (line 266)

Both methods were passing `salesManager: 'All Sales Managers'` instead of using the current filter value from `this.currentSalesManagerFilter`.

## Solution

Updated both methods to respect the current Sales Manager filter:

### Before:
```javascript
const candidates = await getCandidatesInContracting({
    salesManager: 'All Sales Managers'  // ❌ Hardcoded
});
```

### After:
```javascript
const candidates = await getCandidatesInContracting({
    salesManager: this.currentSalesManagerFilter  // ✅ Uses current filter
});
```

## Files Modified

- [salesManagerActivity.js](force-app/main/default/lwc/salesManagerActivity/salesManagerActivity.js)
  - Line 255: `openAllContractingModal()` - Changed to use `this.currentSalesManagerFilter`
  - Line 280: `openAllOnboardingModal()` - Changed to use `this.currentSalesManagerFilter`

## Testing

1. Navigate to Unified Recruiting Dashboard
2. Select a specific Sales Manager (e.g., "Tim Denton")
3. Click on the "Onboarding" card
4. **Expected:** Modal shows only candidates for Tim Denton
5. **Actual:** ✅ Modal now correctly filters by selected Sales Manager
6. Click on the "In Contracting" card
7. **Expected:** Modal shows only candidates in contracting for Tim Denton
8. **Actual:** ✅ Modal now correctly filters by selected Sales Manager

## Deployment

```bash
sf project deploy start --source-dir "force-app/main/default/lwc/salesManagerActivity" --target-org ProductionCapstone
```

**Deploy ID:** 0AfVo000000tNtdKAE  
**Status:** Succeeded  
**Target Org:** ProductionCapstone (patrickbakeradmin2@financialguide.com)

## Notes

- The summary cards correctly calculated filtered counts because they used `calculateSummaryMetrics()` which aggregates from the already-filtered `activityData`
- The modals were making separate Apex calls and needed to pass the filter parameter
- Similar methods like `openInterviewModal()` were already correctly using `this.currentManagerName` for individual Sales Manager clicks from the table
- The "All" modal methods needed to use the global filter

## Related Components

- **salesManagerActivity** - Fixed component
- **SalesManagerActivityController.cls** - Apex controller (no changes needed)
- **UnifiedDashboard** - Parent dashboard that publishes filter changes
- **DashboardFilterChannel__c** - Lightning Message Service channel for filter coordination

## Impact

✅ Users can now properly drill down into filtered data  
✅ Improves usability and data accuracy  
✅ Consistent filtering behavior across all cards  
✅ No breaking changes to existing functionality
