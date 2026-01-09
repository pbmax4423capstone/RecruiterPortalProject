# Candidate Activity History Enhancement Plan

## Overview
Fix the New Task/New Call buttons not appearing and implement auto-refresh functionality while removing the manual Refresh button.

---

## 🔍 Root Cause Analysis

### Why Buttons Aren't Showing
**Issue:** Component changes were made but **NOT deployed** to ProductionCapstone org.

**Evidence:**
- Terminal history shows no deployment of `candidateActivityHistory` component
- Code changes are in local files only
- Component needs to be pushed to the org for buttons to appear

---

## 📋 Implementation Plan

### Phase 1: Deploy Current Changes ✅
**Objective:** Deploy the component with New Task and New Call buttons

**Actions:**
1. Deploy the entire `candidateActivityHistory` component to ProductionCapstone
2. Verify buttons appear on Candidate record page
3. Test button functionality (create task and call)

**Command:**
```bash
sf project deploy start --source-dir "force-app\main\default\lwc\candidateActivityHistory" --target-org ProductionCapstone --wait 15
```

**Expected Result:** Buttons appear in component header

---

### Phase 2: Remove Refresh Button ❌
**Objective:** Remove manual refresh button from UI

**Actions:**
1. Remove refresh button from HTML template
2. Remove `handleRefresh()` method from JavaScript
3. Update CSS to remove refresh button styles
4. Keep `refreshApex` import for auto-refresh

**Files to Modify:**
- `candidateActivityHistory.html` - Remove refresh button element
- `candidateActivityHistory.js` - Remove `handleRefresh()` method
- `candidateActivityHistory.css` - Remove `.refresh-btn` styles

---

### Phase 3: Implement Auto-Refresh ⚡
**Objective:** Automatically refresh activity data every 30 seconds

**Pattern to Follow:** Based on `candidateRecordView` component (lines 71-73)

**Implementation Details:**

#### A. Add Lifecycle Management
```javascript
refreshInterval;  // Add property to store interval ID

connectedCallback() {
    // Set up auto-refresh every 30 seconds
    this.refreshInterval = setInterval(() => {
        refreshApex(this.wiredActivitiesResult);
    }, 30000); // 30 seconds
}

disconnectedCallback() {
    // Clear interval when component is destroyed
    if (this.refreshInterval) {
        clearInterval(this.refreshInterval);
    }
}
```

#### B. Refresh After Creating Task/Call
Add refresh logic after navigation to ensure data updates when user returns:
```javascript
handleNewTask() {
    this[NavigationMixin.Navigate]({
        type: 'standard__objectPage',
        attributes: {
            objectApiName: 'Task',
            actionName: 'new'
        },
        state: {
            defaultFieldValues: `WhatId=${this.recordId}`,
            nooverride: '1'
        }
    });
    // Refresh after a short delay to catch new tasks
    setTimeout(() => {
        refreshApex(this.wiredActivitiesResult);
    }, 2000);
}
```

**Refresh Interval Rationale:**
- **30 seconds** is appropriate for activity history
- Not as critical as notes (which use 5 seconds in candidateRecordView)
- Balances freshness with API call efficiency
- Prevents excessive server load

---

### Phase 4: Deploy Final Version 🚀
**Objective:** Deploy auto-refresh implementation

**Actions:**
1. Deploy updated component
2. Test auto-refresh functionality
3. Verify no console errors
4. Test button functionality still works
5. Verify component loads without refresh button

**Command:**
```bash
sf project deploy start --source-dir "force-app\main\default\lwc\candidateActivityHistory" --target-org ProductionCapstone --wait 15
```

---

## 🧪 Testing Checklist

### Pre-Deployment Testing
- [ ] Code compiles without errors
- [ ] ESLint passes: `npm run lint`
- [ ] Prettier formatting: `npm run prettier`

### Post-Deployment Testing (Phase 1)
- [ ] Navigate to any Candidate record page
- [ ] Verify component appears
- [ ] **Verify "New Task" button is visible**
- [ ] **Verify "New Call" button is visible**
- [ ] Click "New Task" - opens Task creation form with Candidate linked
- [ ] Click "New Call" - opens Event creation form with Candidate linked
- [ ] Cancel/complete forms and return to record

### Post-Deployment Testing (Phase 4)
- [ ] Navigate to Candidate record page
- [ ] Verify NO refresh button present
- [ ] Verify "New Task" and "New Call" buttons still visible
- [ ] Create a new Task via button
- [ ] Wait 30 seconds - verify task appears in activity list
- [ ] Create a new Event/Call via button
- [ ] Wait 30 seconds - verify call appears in activity list
- [ ] Open browser console - verify no errors
- [ ] Navigate away and back - verify component cleans up interval

---

## 🎯 Success Criteria

✅ **Deployment Success:**
- Component deployed to ProductionCapstone without errors
- All test results pass

✅ **UI Success:**
- "New Task" button visible and functional
- "New Call" button visible and functional
- NO manual refresh button present
- Buttons styled consistently with Capstone Navy/Blue theme

✅ **Functionality Success:**
- Auto-refresh runs every 30 seconds
- New activities appear automatically
- Component properly cleans up interval on unmount
- No performance issues or console errors

✅ **User Experience:**
- Users can create tasks and calls directly from component
- Activity list stays current without manual interaction
- Smooth, professional user experience

---

## 📝 Implementation Notes

### Why Initial Deployment Failed to Show Buttons
1. **Code was updated locally** ✅
2. **Code was NOT deployed to org** ❌
3. Result: Salesforce org still has old version without buttons

### Auto-Refresh Best Practices
- **Use `setInterval`** for periodic refresh
- **Always cleanup** in `disconnectedCallback()`
- **Store interval ID** as instance property
- **Use `refreshApex()`** with wired result
- **Choose appropriate interval** (30s for activities, 5s for critical data)

### Navigation Best Practices
- **Use `NavigationMixin`** for all navigation
- **Pre-populate fields** with `defaultFieldValues`
- **Use `WhatId`** to link to Candidate (custom object)
- **Use `WhoId`** for Lead/Contact (if needed in future)

---

## 🚀 Deployment Order

1. **Deploy Phase 1** → Test buttons appear
2. **Modify code for Phases 2 & 3** → Remove refresh, add auto-refresh
3. **Deploy Phase 4** → Test final version
4. **Mark complete** in SHARED_PLANNING.md

---

## 📂 Files to be Modified

### Phase 1 (Deployment Only)
- No code changes, just deploy existing files

### Phases 2-3 (Code Changes)
1. **candidateActivityHistory.js**
   - Remove `handleRefresh()` method
   - Add `refreshInterval` property
   - Add `connectedCallback()` with setInterval
   - Add `disconnectedCallback()` with clearInterval
   - Update `handleNewTask()` with refresh trigger
   - Update `handleNewCall()` with refresh trigger

2. **candidateActivityHistory.html**
   - Remove refresh button element
   - Keep New Task and New Call buttons

3. **candidateActivityHistory.css**
   - Remove `.refresh-btn` styles
   - Keep `.action-btn` styles
   - Verify `.header-actions` flexbox layout

---

## ⚠️ Potential Issues & Mitigation

### Issue 1: Interval Memory Leak
**Risk:** If `disconnectedCallback` doesn't fire, interval keeps running
**Mitigation:** Always store interval ID and clear it properly

### Issue 2: Excessive API Calls
**Risk:** 30-second interval might cause too many calls with many users
**Mitigation:** 30s is reasonable; can adjust to 60s if needed

### Issue 3: Navigation Doesn't Trigger Refresh
**Risk:** New task/call might not appear even after creation
**Mitigation:** Added 2-second delayed refresh after navigation

---

## ✅ Approval Required

**Please review this plan and confirm:**
1. ✅ Deploy current code first to test buttons?
2. ✅ Auto-refresh interval of 30 seconds acceptable?
3. ✅ Remove manual refresh button completely?
4. ✅ Ready to proceed with implementation?

Once approved, I will execute all phases sequentially.

---

**Created:** January 9, 2026  
**Component:** candidateActivityHistory  
**Target Org:** ProductionCapstone  
**Status:** Awaiting Approval
