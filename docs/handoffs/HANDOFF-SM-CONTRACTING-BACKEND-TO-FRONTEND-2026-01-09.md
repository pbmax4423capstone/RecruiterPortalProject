# Handoff: Sales Manager Contracting Kanban - Backend to Frontend

**From:** Patrick's Agent  
**To:** Cole's Agent  
**Date:** 2026-01-09  
**Task:** #006 → #008 (Backend Apex complete, ready for LWC implementation)

---

## Work Completed ✅

### Apex Controller Methods Added

Added 4 new methods to `CandidatesInContractingController.cls`:

#### 1. `getALCDataForSalesManager(String salesManagerFilter)`
**Purpose:** Main data provider for Sales Manager Contracting Kanban component  
**Parameters:**
- `salesManagerFilter` - Sales Manager name or "All Sales Managers"
- Defaults to `getCurrentUserSalesManagerName()` if blank

**Returns:** `ALCDataResponse` containing:
- `alcsByStage` - Map of stage API values to CandidateWrapper lists
- `stageConfigs` - Map of stage configurations (Career only)
- `recordTypeCounts` - Map with Career count only

**Key Features:**
- ✅ Hard-coded to Career record type: `WHERE RecordType.DeveloperName = 'Career'`
- ✅ Filters by `Candidate__r.Sales_Manager__c = :salesManagerFilter`
- ✅ Supports "All Sales Managers" option (no filter applied)
- ✅ Uses same stage configuration system as original component
- ✅ Respects `with sharing` - record-level security enforced

**Query Structure:**
```apex
WHERE RecordType.DeveloperName = 'Career'
AND Stage__c IN :validStages // From ALC_Stage_Config__mdt where Record_Type = 'Career'
AND Candidate__r.Sales_Manager__c = :salesManagerFilter // Unless "All Sales Managers"
ORDER BY LastModifiedDate DESC
```

#### 2. `getCurrentUserSalesManagerName()`
**Purpose:** Returns logged-in user's full name for default filtering  
**Returns:** `String` - Current user's name from `UserInfo.getName()`  
**Cacheable:** Yes (`@AuraEnabled(cacheable=true)`)

#### 3. `getSalesManagerOptions()`
**Purpose:** Provides dropdown options for Sales Manager filter  
**Returns:** `List<String>` with "All Sales Managers" first, then distinct Sales Manager values  
**Query:** Groups by `Candidate__r.Sales_Manager__c` from Career ALC records  
**Cacheable:** Yes

#### 4. `canViewAllSalesManagers()`
**Purpose:** Determines if current user can view dropdown (Director/Admin)  
**Returns:** `Boolean` - true if profile contains "Director", "System Administrator", or "Admin"  
**Cacheable:** Yes  
**Default on Error:** false (safe fallback)

---

## Test Coverage ✅

**Test Class:** `CandidatesInContractingControllerTest.cls`  
**Results:** 28/28 tests passing (100%)

### New Test Methods Added:
1. `testGetALCDataForSalesManager_FilterBySpecificManager` - Verifies filtering by specific Sales Manager
2. `testGetALCDataForSalesManager_FilterByAllSalesManagers` - Verifies "All" option shows all records
3. `testGetALCDataForSalesManager_DefaultToCurrentUser` - Verifies null param defaults to current user
4. `testGetALCDataForSalesManager_OnlyCareerStages` - Verifies only Career record type returned
5. `testGetCurrentUserSalesManagerName` - Verifies current user name returned
6. `testGetSalesManagerOptions` - Verifies dropdown options structure
7. `testCanViewAllSalesManagers_StandardUser` - Verifies profile detection
8. `testGetALCDataForSalesManager_NoRecords` - Handles no results gracefully
9. `testGetALCDataForSalesManager_StageConfiguration` - Verifies stage config structure

### Test Data:
- 20 test candidates with 3 Sales Managers:
  - Tim Denton (candidates 0-9) - 5 Career ALCs
  - Elizabeth Kagele (candidates 10-14) - 2 Career ALCs
  - Son Le (candidates 15-19) - 1 Career ALC
- Multiple record types: Broker, Career, NRF, Registration
- Multiple agencies: A157, A007

---

## Deployment Status ✅

**Deployed To:** ProductionCapstone  
**Deploy ID:** 0AfVo000000tEjtKAE  
**Status:** Succeeded  
**Test Coverage:** 28/28 passing

**Files Deployed:**
- `CandidatesInContractingController.cls`
- `CandidatesInContractingController.cls-meta.xml`
- `CandidatesInContractingControllerTest.cls`
- `CandidatesInContractingControllerTest.cls-meta.xml`

---

## Next Steps for Cole's Agent 🚀

### Task #008: Create salesManagerContractingKanban LWC Component

#### Component Requirements:

1. **Clone Source:** `candidatesInContracting` component
2. **New Component Name:** `salesManagerContractingKanban`
3. **Location:** `force-app/main/default/lwc/salesManagerContractingKanban/`

#### Wire Adapters Needed:

```javascript
@wire(getALCDataForSalesManager, { 
    salesManagerFilter: '$selectedSalesManager'
})
wiredALCData(result) { ... }

@wire(canViewAllSalesManagers)
wiredCanViewAll({ error, data }) { ... }

@wire(getCurrentUserSalesManagerName)
wiredCurrentUser({ error, data }) { ... }

@wire(getSalesManagerOptions)
wiredSalesManagers({ error, data }) { ... }
```

#### Key Implementation Details:

**1. localStorage for Filter Persistence:**
- Key: `smContractingKanban_salesManagerFilter`
- Save on filter change
- Load on component init
- Default behavior:
  - If `canViewAllSalesManagers` is true → default to "All Sales Managers"
  - If false → default to current user's name

**2. Sales Manager Dropdown:**
- Only visible if `canViewAllSalesManagers` returns true
- Dropdown options from `getSalesManagerOptions`
- Selected value controls `selectedSalesManager` property
- On change: save to localStorage, refresh data

**3. UI Simplifications:**
```javascript
// REMOVE from original component:
- Record type tabs (Broker, Career, NRF, etc.)
- Agency filter toggle
- Agency-specific logic

// KEEP from original component:
- Drag-and-drop functionality (uses existing updateCandidateStage method)
- Stage columns (filtered to Career stages only)
- Candidate cards
- Refresh button
- Loading spinner
```

**4. Stage Columns:**
Display same active workflow stages as original component, but filtered to Career record type only. The `getALCDataForSalesManager` method returns stage configs with Career stages pre-filtered.

**5. Component Metadata (.js-meta.xml):**
```xml
<targets>
    <target>lightning__RecordPage</target>
    <target>lightning__AppPage</target>
    <target>lightning__HomePage</target>
</targets>
```

---

## API Reference

### Method Signatures for LWC Import:

```javascript
import getALCDataForSalesManager from '@salesforce/apex/CandidatesInContractingController.getALCDataForSalesManager';
import getCurrentUserSalesManagerName from '@salesforce/apex/CandidatesInContractingController.getCurrentUserSalesManagerName';
import getSalesManagerOptions from '@salesforce/apex/CandidatesInContractingController.getSalesManagerOptions';
import canViewAllSalesManagers from '@salesforce/apex/CandidatesInContractingController.canViewAllSalesManagers';
import updateCandidateStage from '@salesforce/apex/CandidatesInContractingController.updateCandidateStage'; // Existing method for drag-and-drop
```

### ALCDataResponse Structure:

```javascript
{
    alcsByStage: {
        "Sent To Compliance": [
            {
                alcId: "a0X...",
                alcName: "ALC-12345",
                candidateId: "a02...",
                candidateName: "John Doe",
                salesManager: "Tim Denton",
                alcStage: "Sent To Compliance",
                lastStageChange: "2026-01-09T10:30:00.000Z",
                recordTypeName: "Career",
                agency: "A157"
            }
        ],
        "Pending SM": [ ... ],
        // ... more stages
    },
    stageConfigs: {
        "Career": [
            {
                recordType: "Career",
                stageApiValue: "Sent To Compliance",
                stageDisplayLabel: "Sent To Compliance",
                sortOrder: 1,
                columnColor: "#0070d2"
            },
            // ... more stages
        ]
    },
    recordTypeCounts: {
        "Career": 23
    }
}
```

---

## Important Notes ⚠️

### localStorage Key Format:
**Key:** `smContractingKanban_salesManagerFilter`  
**Why:** Matches existing pattern (like `agencyFilter` in original component)

### Default Behavior for Directors/Admins:
- **canViewAllSalesManagers = true:** Default to "All Sales Managers"
- **canViewAllSalesManagers = false:** Default to current user's name
- **Reason:** Directors need oversight view by default, Sales Managers see only their data

### Stage Columns:
The original component displays stages from `ALC_Stage_Config__mdt` where `Is_Active__c = true`. The new method already filters to Career record type stages, so no additional filtering needed in LWC.

### Drag-and-Drop:
Use existing `updateCandidateStage(alcId, newStage)` method - it works for all record types including Career.

---

## Testing Checklist for Frontend

### Jest Unit Tests (Task #009):
- [ ] Component renders with Career records only
- [ ] localStorage saves filter preference
- [ ] localStorage loads filter preference on init
- [ ] Director toggle shows dropdown when `canViewAllSalesManagers` is true
- [ ] Sales Manager user doesn't see dropdown when `canViewAllSalesManagers` is false
- [ ] Dropdown change triggers data refresh
- [ ] Drag-and-drop updates stage
- [ ] Error states display correctly
- [ ] Loading spinner shows during data fetch

### Integration Tests - ProdTest Sandbox (Task #010):
- [ ] Deploy to `choujifan90@gmail.com.prodtest`
- [ ] Test as Sales Manager user (profile without "Director")
  - [ ] Should see only their Career candidates
  - [ ] No dropdown visible
  - [ ] Default filter = their name
- [ ] Test as Director user (profile contains "Director")
  - [ ] Should see dropdown with all managers
  - [ ] Default selection = "All Sales Managers"
  - [ ] Can switch between managers
- [ ] localStorage persists across page refreshes
- [ ] Same stage columns as original Kanban (no terminal stages)
- [ ] Drag-and-drop updates ALC stage correctly

---

## Files Modified

### Apex:
- ✅ `force-app/main/default/classes/CandidatesInContractingController.cls`
- ✅ `force-app/main/default/classes/CandidatesInContractingControllerTest.cls`

### LWC (To Be Created by Cole's Agent):
- [ ] `force-app/main/default/lwc/salesManagerContractingKanban/salesManagerContractingKanban.js`
- [ ] `force-app/main/default/lwc/salesManagerContractingKanban/salesManagerContractingKanban.html`
- [ ] `force-app/main/default/lwc/salesManagerContractingKanban/salesManagerContractingKanban.css`
- [ ] `force-app/main/default/lwc/salesManagerContractingKanban/salesManagerContractingKanban.js-meta.xml`
- [ ] `force-app/main/default/lwc/salesManagerContractingKanban/__tests__/salesManagerContractingKanban.test.js`

---

## Reference Components

### For Pattern Reference:
1. **candidatesInContracting** - Source component to clone
   - Path: `force-app/main/default/lwc/candidatesInContracting/`
   - Has: Record type tabs, agency filter, drag-and-drop
   
2. **portalHeaderNew** - Dark mode publisher pattern
   - Shows how to use Lightning Message Service
   
3. **recruitingDirectorDashboard** - Sales Manager dropdown pattern
   - Shows how to implement manager filter dropdown

---

## Questions or Issues?

If you encounter any issues with:
- **Apex methods:** Review this handoff document or test class examples
- **Data structure:** See "ALCDataResponse Structure" section
- **Profile detection:** Test `canViewAllSalesManagers` in browser console
- **localStorage:** Key is `smContractingKanban_salesManagerFilter`

**Contact:** Patrick Baker or create a note in WORK_COORDINATION.md

---

## Success Criteria ✅

Frontend implementation is complete when:
1. ✅ Component cloned from `candidatesInContracting`
2. ✅ Wired to all 4 new Apex methods
3. ✅ localStorage implemented with correct key
4. ✅ Director/Admin dropdown conditionally visible
5. ✅ Default behavior matches spec (All for Directors, User for Sales Managers)
6. ✅ Only Career stages displayed
7. ✅ Drag-and-drop working
8. ✅ Jest tests passing with ≥80% coverage
9. ✅ Tested in ProdTest sandbox
10. ✅ Ready for production deployment

---

**Handoff Status:** ✅ READY FOR FRONTEND IMPLEMENTATION

**Last Updated:** 2026-01-09  
**Agent:** Patrick's Agent  
**Task Board:** See SHARED_PLANNING.md tasks #007, #008, #009, #010, #011
