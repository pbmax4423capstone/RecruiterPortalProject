# Sales Manager Qualification Dashboard - Technical Specification

**Date:** 2026-01-08  
**Project:** Contract B Agent Qualification Tracking System  
**Task ID:** #002, #003, #004, #005  
**Status:** 🔵 In Progress - Research Phase

---

## 📋 Project Overview

Build a Sales Manager qualification dashboard showing Contract B agent progress toward contract requirements (5 opportunities submitted + $2,500 FYC from won opportunities) and Contract A agent YTD metrics. Dashboard has role-based views: Sales Managers see only their unit, Directors and System Admins see global view with unit selector dropdown.

---

## 🎯 Business Requirements

### Contract B Qualification Criteria
- **FYC Target:** $2,500 (from won opportunities)
- **Submission Target:** 5 opportunities (all submitted opportunities)
- **Timeframe:** 4 months from Start_Date__c (8 months if Extension_Granted__c = true)
- **Status Indicators:**
  - ✅ Complete: Requirements_Met__c = TRUE
  - 🔴 Critical: < 14 days remaining AND requirements NOT met
  - ⚠️ At Risk: < 30 days remaining AND requirements NOT met
  - 🟢 On Track: ≥ 30 days remaining OR requirements met

### User Access Matrix

| User Type | View | Dropdown |
|-----------|------|----------|
| Sales Manager | Own unit only | No dropdown |
| Director | All units | Yes - select unit or "All Units" |
| System Administrator | All units | Yes - select unit or "All Units" |

**Role Detection Method:** Check User Profile name:
- Contains "Director" → Global view
- Contains "System Administrator" → Global view  
- Other → Sales Manager view (filtered to their unit)

### Data Source Decisions (Approved)

1. **Opportunity Field Standardization (Option C):**
   - Use `Soliciting_Agent__c` field (not ContactId)
   - Use `Amount` field (not FYC__c)
   - Track TWO metrics separately:
     - **Submitted:** COUNT(all Opportunities) WHERE Soliciting_Agent__c = agent
     - **Won:** COUNT(Opportunities WHERE IsWon = true) WHERE Soliciting_Agent__c = agent
     - **FYC:** SUM(Amount WHERE IsWon = true) WHERE Soliciting_Agent__c = agent

2. **Sales Manager Field Synchronization:**
   - **Source of Truth:** `Candidate__c.Sales_Manager__c`
   - **Sync Direction:** If `ALC__c.Sales_Manager__c` differs from Candidate, update ALC to match Candidate
   - **Implementation:** Research Agent should document current field usage patterns; future scheduled job can enforce sync

3. **Performance Strategy:**
   - **Real-time queries** - Accept 2-3 second load times
   - **No caching** - Always fetch fresh Opportunity data
   - **User experience:** Show loading spinner during data fetch

---

## 🔬 Research Phase (Task #002)

**Assigned to:** Research Agent  
**Status:** 🔵 In Progress  
**ETA:** 1-2 hours

### Research Objectives

1. **Audit Existing Opportunity Queries:**
   - Document how CandidateFYCRollupService queries Opportunities
   - Document how ContractBDashboardController queries Opportunities
   - Identify inconsistencies (ContactId vs Soliciting_Agent__c, FYC__c vs Amount)
   - Recommend standardized query pattern for new controller

2. **Verify Contact Automation:**
   - Confirm ALCRelationshipTrigger creates Contacts for all Candidates
   - Check for any gaps in Contact creation logic
   - Verify Contact__c field is populated on Candidate records

3. **Document Sales Manager Field Usage:**
   - Query production for `Candidate__c` records with `Sales_Manager__c` populated
   - Query production for `ALC__c` records with `Sales_Manager__c` populated
   - Identify any mismatches between Candidate and ALC Sales Manager values
   - Get list of unique Sales Manager names for dropdown options
   - Document field format (Text field, typical values)

4. **Profile Analysis:**
   - List all User Profile names in the org
   - Identify which profiles should have Director/Admin access
   - Confirm "Director" and "System Administrator" naming patterns

5. **Existing Code Patterns:**
   - Review how contractBPipelineDashboard implements Contract A qualification tables
   - Document the qualified/not-qualified split logic
   - Extract progress bar CSS classes and calculation logic
   - Note any reusable methods or patterns

### Deliverables

Create handoff document: `docs/handoffs/HANDOFF-RESEARCH-TO-APEX-2026-01-08.md` containing:

- ✅ Standardized Opportunity query pattern (SOQL examples)
- ✅ Sales Manager field analysis (sample data, mismatch count, unique values)
- ✅ Profile list with Director/Admin recommendations
- ✅ Contact creation verification results
- ✅ Reusable code patterns from existing components
- ✅ Any data quality concerns or edge cases discovered

---

## 💻 Apex Development Phase (Task #003)

**Assigned to:** Patrick's Agent  
**Status:** 🟡 Ready to Start  
**Dependencies:** Task #002 complete  
**ETA:** 3-4 hours

### Class to Create

**Class Name:** `SalesManagerQualificationController`  
**Location:** `force-app/main/default/classes/`

### Required Methods

#### 1. `getCurrentUserRole()`
```apex
@AuraEnabled(cacheable=false)
public static Map<String, Object> getCurrentUserRole() {
    // Query current user's Profile
    // Return: { 'isGlobalView': true/false, 'salesManagerUnit': 'Manager Name' or null }
    // Logic: Check if Profile.Name contains 'Director' or 'System Administrator'
    // If not global, query for user's Candidate__c.Sales_Manager__c (if they're a candidate)
    // or determine from related records
}
```

#### 2. `getSalesManagerUnits()`
```apex
@AuraEnabled(cacheable=true)
public static List<String> getSalesManagerUnits() {
    // Query distinct Sales_Manager__c values from Candidate__c
    // WHERE Sales_Manager__c != null
    // Return sorted list for dropdown options
}
```

#### 3. `getContractBAgentProgress(String salesManagerUnit)`
```apex
@AuraEnabled(cacheable=false)
public static List<ContractBAgentData> getContractBAgentProgress(String salesManagerUnit) {
    // Main query: Candidate__c WHERE Contract_Type__c = 'Contract B'
    // Filter: If salesManagerUnit != 'All Units', add WHERE Sales_Manager__c = :salesManagerUnit
    // Include fields: Name, Contact__c, Start_Date__c, Contract_End_Date__c, 
    //                 Extension_Granted__c, Requirements_Met__c, Total_FYC__c
    
    // Real-time Opportunity aggregation:
    // Query 1: SELECT Soliciting_Agent__c, COUNT(Id) submitted
    //          FROM Opportunity
    //          WHERE Soliciting_Agent__c IN :contactIds
    //          GROUP BY Soliciting_Agent__c
    
    // Query 2: SELECT Soliciting_Agent__c, COUNT(Id) won, SUM(Amount) totalFYC
    //          FROM Opportunity  
    //          WHERE Soliciting_Agent__c IN :contactIds AND IsWon = true
    //          GROUP BY Soliciting_Agent__c
    
    // Calculate progress percentages:
    // submissionsProgress = MIN(submitted / 5.0, 1.0) * 100
    // fycProgress = MIN(totalFYC / 2500.0, 1.0) * 100
    
    // Calculate days remaining:
    // deadline = Start_Date__c + 120 days (or 240 if Extension_Granted__c)
    // daysRemaining = deadline - TODAY
    
    // Determine status: Complete, Critical, At Risk, On Track
    
    // Return wrapper list with all calculated fields
}
```

#### 4. `getContractAAgentProgress(String salesManagerUnit)`
```apex
@AuraEnabled(cacheable=false)
public static List<ContractAAgentData> getContractAAgentProgress(String salesManagerUnit) {
    // Query Contract_Qualification__c records
    // Join with Candidate__c to filter by Sales_Manager__c
    // If salesManagerUnit != 'All Units', filter by Sales_Manager__c
    
    // Return similar structure as existing contractBPipelineDashboard.getContractAData()
    // Include: Agent name, Contract Date, YTD FYC, YTD WLADL, Progress %, Status
    
    // Real-time Opportunity metrics for Contract A agents (submitted + won counts):
    // Follow same pattern as Contract B but for Contract A agent Contacts
}
```

### Wrapper Classes

```apex
public class ContractBAgentData {
    @AuraEnabled public String agentName;
    @AuraEnabled public String candidateId;
    @AuraEnabled public String contactId;
    @AuraEnabled public Date startDate;
    @AuraEnabled public Date deadline;
    @AuraEnabled public Integer daysRemaining;
    @AuraEnabled public Integer opportunitiesSubmitted;
    @AuraEnabled public Integer opportunitiesWon;
    @AuraEnabled public Decimal totalFYC;
    @AuraEnabled public Decimal submissionsProgress; // 0-100
    @AuraEnabled public Decimal fycProgress; // 0-100
    @AuraEnabled public String status; // 'Complete', 'Critical', 'At Risk', 'On Track'
    @AuraEnabled public Boolean requirementsMet;
}

public class ContractAAgentData {
    @AuraEnabled public String agentName;
    @AuraEnabled public Date contractDate;
    @AuraEnabled public Decimal ytdFYC;
    @AuraEnabled public Decimal ytdWLADL;
    @AuraEnabled public Decimal wladlGoal;
    @AuraEnabled public Decimal progress; // 0-100
    @AuraEnabled public String qualStatus;
    @AuraEnabled public Integer opportunitiesSubmitted;
    @AuraEnabled public Integer opportunitiesWon;
}
```

### Test Class Requirements

**Class Name:** `SalesManagerQualificationController_Test`

**Test Coverage:**
- ✅ getCurrentUserRole() with Director profile
- ✅ getCurrentUserRole() with Sales Manager profile
- ✅ getSalesManagerUnits() returns correct list
- ✅ getContractBAgentProgress() with specific unit filter
- ✅ getContractBAgentProgress() with "All Units"
- ✅ getContractAAgentProgress() with specific unit filter
- ✅ Edge cases: No Opportunities, null Sales Manager, Extension granted
- ✅ Progress calculations (submissions and FYC)
- ✅ Status determination logic (Complete, Critical, At Risk, On Track)
- ✅ Days remaining calculation with extension
- **Target:** >= 80% code coverage

### Handoff Deliverable

Create: `docs/handoffs/HANDOFF-APEX-TO-LWC-2026-01-08.md` with:
- ✅ All method signatures with parameter details
- ✅ Wrapper class structures
- ✅ Sample return data (JSON examples)
- ✅ Any edge cases or limitations discovered
- ✅ Test results summary
- ✅ Deployment confirmation to ProdTest

---

## 🎨 LWC Development Phase (Task #004)

**Assigned to:** Cole's Agent  
**Status:** 🟡 Ready to Start  
**Dependencies:** Task #003 complete  
**ETA:** 4-5 hours

### Component to Create

**Component Name:** `salesManagerQualificationDashboard`  
**Location:** `force-app/main/default/lwc/salesManagerQualificationDashboard/`

### Component Structure

**Files:**
- `salesManagerQualificationDashboard.html`
- `salesManagerQualificationDashboard.js`
- `salesManagerQualificationDashboard.css`
- `salesManagerQualificationDashboard.js-meta.xml`

### UI Requirements

#### Layout

```
┌─────────────────────────────────────────────────────┐
│  Sales Manager Qualification Dashboard              │
│  [Dropdown: Select Unit] (if Director/Admin)        │
├─────────────────────────────────────────────────────┤
│  📊 Contract B Progress                             │
│  ├─ Requirements Met (X agents)          [Expand ▼]│
│  │   [Table with progress bars]                     │
│  │                                                   │
│  ├─ Not Yet Met (X agents)               [Expand ▼]│
│      [Table with progress bars]                     │
├─────────────────────────────────────────────────────┤
│  📊 Contract A Progress                             │
│  ├─ Qualified (X agents)                 [Expand ▼]│
│  │   [Table with YTD metrics]                       │
│  │                                                   │
│  ├─ Not Yet Qualified (X agents)         [Expand ▼]│
│      [Table with YTD metrics]                       │
└─────────────────────────────────────────────────────┘
```

#### Contract B Table Columns

| Column | Type | Notes |
|--------|------|-------|
| Agent Name | Text | Link to Candidate record |
| Start Date | Date | Formatted |
| Submitted | Number | "X / 5" format |
| Won | Number | Display count |
| FYC | Currency | "$X / $2,500" format |
| Progress | Component | Dual progress bars (Submissions + FYC) |
| Days Left | Number | Color-coded badge |
| Status | Badge | Complete/Critical/At Risk/On Track |

#### Contract A Table Columns

| Column | Type | Notes |
|--------|------|-------|
| Agent Name | Text | Linked |
| Contract Date | Date | Formatted |
| Submitted | Number | New column |
| Won | Number | New column |
| YTD FYC | Currency | Formatted |
| YTD WLADL | Currency | Formatted |
| Progress | Component | Progress bar |
| Status | Badge | Qualified status |

### JavaScript Structure

```javascript
import { LightningElement, wire } from 'lwc';
import getCurrentUserRole from '@salesforce/apex/SalesManagerQualificationController.getCurrentUserRole';
import getSalesManagerUnits from '@salesforce/apex/SalesManagerQualificationController.getSalesManagerUnits';
import getContractBAgentProgress from '@salesforce/apex/SalesManagerQualificationController.getContractBAgentProgress';
import getContractAAgentProgress from '@salesforce/apex/SalesManagerQualificationController.getContractAAgentProgress';

export default class SalesManagerQualificationDashboard extends LightningElement {
    // Properties
    isGlobalView = false;
    selectedUnit = '';
    salesManagerUnits = [];
    contractBData = [];
    contractAData = [];
    isLoading = true;
    error;
    
    // Lifecycle
    connectedCallback() {
        this.loadUserRole();
    }
    
    // Wire adapters (or imperative calls for non-cacheable methods)
    
    // Computed properties
    get showUnitDropdown() {
        return this.isGlobalView;
    }
    
    get unitOptions() {
        // Add "All Units" option for global view
    }
    
    get contractBMetAgents() {
        return this.contractBData.filter(agent => agent.requirementsMet);
    }
    
    get contractBNotMetAgents() {
        return this.contractBData.filter(agent => !agent.requirementsMet);
    }
    
    get contractAQualifiedAgents() {
        // Filter logic from contractBPipelineDashboard
    }
    
    get contractANotQualifiedAgents() {
        // Filter logic from contractBPipelineDashboard
    }
    
    // Event handlers
    handleUnitChange(event) {
        this.selectedUnit = event.detail.value;
        this.refreshData();
    }
    
    handleRefresh() {
        this.refreshData();
    }
    
    // Helper methods
    async loadUserRole() { }
    async loadSalesManagerUnits() { }
    async refreshData() { }
    formatCurrency(value) { }
    getStatusClass(status) { }
    getDaysRemainingClass(days) { }
}
```

### CSS Requirements

Reuse existing styles from [contractBPipelineDashboard.css](force-app/main/default/lwc/contractBPipelineDashboard/contractBPipelineDashboard.css):
- Progress bar styles
- Status badge colors
- Section collapsing
- Table styling

Add new styles for:
- Days remaining badges (color-coded)
- Dual progress bars (submissions + FYC side by side)

### Jest Test Requirements

**Test File:** `__tests__/salesManagerQualificationDashboard.test.js`

**Tests:**
- ✅ Component renders correctly
- ✅ Sales Manager view (no dropdown shown)
- ✅ Director/Admin view (dropdown shown)
- ✅ Unit dropdown populates correctly
- ✅ Unit selection triggers data refresh
- ✅ Contract B data renders in correct sections (met vs not met)
- ✅ Contract A data renders in correct sections (qualified vs not)
- ✅ Progress bars calculate correctly
- ✅ Status badges show correct colors
- ✅ Days remaining color-coded correctly
- ✅ Error handling displays error message
- ✅ Loading spinner shows during data fetch
- **Target:** >= 80% code coverage

### Handoff Deliverable

Create: `docs/handoffs/HANDOFF-LWC-TO-TESTING-2026-01-08.md` with:
- ✅ Component deployed to ProdTest
- ✅ Jest test results (all passing, coverage %)
- ✅ Screenshots of component in ProdTest
- ✅ Known issues or limitations
- ✅ Testing checklist for integration phase

---

## 🧪 Testing & Deployment Phase (Task #005)

**Assigned to:** Cole's Agent  
**Status:** 🟡 Ready to Start  
**Dependencies:** Task #004 complete  
**ETA:** 2-3 hours

### Test Scenarios

#### Test User Setup (ProdTest Sandbox)
1. **Sales Manager User:** Profile = custom or standard, no Director in name
2. **Director User:** Profile name contains "Director"
3. **Admin User:** Profile = "System Administrator"

#### Functional Tests

| Test | User | Expected Result |
|------|------|-----------------|
| Dashboard loads | Sales Manager | Only their unit shown, no dropdown |
| Dashboard loads | Director | Dropdown shown, all units available |
| Dashboard loads | Admin | Dropdown shown, all units available |
| Select "All Units" | Director | All agents across all units displayed |
| Select specific unit | Director | Only agents in that unit displayed |
| Contract B met section | Any | Agents with requirementsMet=true |
| Contract B not met section | Any | Agents with requirementsMet=false |
| Progress bars | Any | Correct % for submissions (X/5) and FYC (X/2500) |
| Status badges | Any | Correct color and label (Complete/Critical/At Risk/On Track) |
| Days remaining | Any | Correct calculation, color-coded |
| Real-time updates | Any | Click refresh, see updated Opportunity counts |
| Contract A section | Any | YTD metrics displayed correctly |
| Submitted/Won columns | Any | Both counts shown for Contract A agents |
| No data scenario | Any | Empty state message displayed |
| Error scenario | Any | Error message displayed, no crash |

### Performance Tests
- ✅ Dashboard loads in < 3 seconds with 50+ agents
- ✅ Unit dropdown change responds in < 3 seconds
- ✅ No console errors
- ✅ No performance warnings

### Deployment Checklist

#### ProdTest Deployment
- [ ] Deploy SalesManagerQualificationController to ProdTest
- [ ] Deploy SalesManagerQualificationController_Test to ProdTest
- [ ] Run Apex tests in ProdTest (verify >= 80% coverage)
- [ ] Deploy salesManagerQualificationDashboard to ProdTest
- [ ] Add component to test page layout
- [ ] Test with all 3 user types
- [ ] Verify all functional tests pass

#### Production Deployment
- [ ] Deploy Apex classes to ProductionCapstone
- [ ] Deploy LWC component to ProductionCapstone
- [ ] Create/update Permission Sets (if needed for role detection)
- [ ] Add component to Sales Manager home page layouts
- [ ] Add component to Director home page layouts
- [ ] Test with real Sales Manager user
- [ ] Test with real Director user
- [ ] Update [COLE_ARNOLD_DEVELOPMENT_GUIDE.md](COLE_ARNOLD_DEVELOPMENT_GUIDE.md)
- [ ] Update [copilot-instructions.md](.github/copilot-instructions.md) if needed
- [ ] Update training documentation (if applicable)

### Final Deliverable

Complete: `docs/handoffs/SALES-MANAGER-QUALIFICATION-COMPLETE-2026-01-08.md` with:
- ✅ All test results (functional + performance)
- ✅ Production deployment confirmation
- ✅ Screenshots from Production
- ✅ Known limitations or future enhancements
- ✅ Documentation updates completed
- ✅ Lessons learned / retrospective notes

---

## 📊 Success Metrics

- [ ] All Apex tests passing with >= 80% coverage
- [ ] All Jest tests passing with >= 80% coverage
- [ ] Dashboard loads in < 3 seconds
- [ ] Role-based views working correctly (Sales Manager vs Director/Admin)
- [ ] Real-time Opportunity data accurate
- [ ] Both Contract B and Contract A sections functional
- [ ] Deployed to Production successfully
- [ ] Documentation updated

---

## 🔄 Agent Coordination Workflow

```
Research Agent (Task #002)
    ↓ Creates: HANDOFF-RESEARCH-TO-APEX-2026-01-08.md
    ↓ Updates: SHARED_PLANNING.md (mark #002 complete, #003 in-progress)
    
Patrick's Agent (Task #003)
    ↓ Reads: HANDOFF-RESEARCH-TO-APEX-2026-01-08.md
    ↓ Builds Apex controller + tests
    ↓ Deploys to ProdTest
    ↓ Creates: HANDOFF-APEX-TO-LWC-2026-01-08.md
    ↓ Updates: SHARED_PLANNING.md (mark #003 complete, #004 in-progress)
    
Cole's Agent (Task #004)
    ↓ Reads: HANDOFF-APEX-TO-LWC-2026-01-08.md
    ↓ Builds LWC component + Jest tests
    ↓ Runs: npm run test:unit:coverage
    ↓ Deploys to ProdTest
    ↓ Creates: HANDOFF-LWC-TO-TESTING-2026-01-08.md
    ↓ Updates: SHARED_PLANNING.md (mark #004 complete, #005 in-progress)
    
Cole's Agent (Task #005)
    ↓ Reads: HANDOFF-LWC-TO-TESTING-2026-01-08.md
    ↓ Tests in ProdTest with multiple user types
    ↓ Deploys to Production
    ↓ Updates documentation
    ↓ Creates: SALES-MANAGER-QUALIFICATION-COMPLETE-2026-01-08.md
    ↓ Updates: SHARED_PLANNING.md (mark #005 complete)
    
✅ Project Complete
```

---

## 📚 Reference Documentation

- [Contract B Lifecycle Training](docs/Contract-B-Lifecycle-Training.md)
- [ContractBDashboardController](force-app/main/default/classes/ContractBDashboardController.cls)
- [contractBPipelineDashboard](force-app/main/default/lwc/contractBPipelineDashboard/)
- [CandidateFYCRollupService](force-app/main/default/classes/CandidateFYCRollupService.cls)
- [WORK_COORDINATION.md](WORK_COORDINATION.md)
- [AGENT_COORDINATION.md](AGENT_COORDINATION.md)
- [SHARED_PLANNING.md](SHARED_PLANNING.md)

---

**Last Updated:** 2026-01-08  
**Next Review:** After Task #002 completion
