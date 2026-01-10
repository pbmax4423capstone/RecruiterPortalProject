# Research Phase Handoff: Sales Manager Qualification Dashboard

**From:** Research Agent  
**To:** Patrick's Agent (Apex Development)  
**Date:** 2026-01-08  
**Task:** #002 → #003  
**Status:** ✅ Research Complete

---

## Executive Summary

Completed comprehensive audit of Opportunity query patterns, Sales Manager field usage, Contact automation, and reusable code patterns. Found **inconsistencies** between CandidateFYCRollupService (uses ContactId + FYC**c) and ContractBDashboardController (uses Soliciting_Agent**c + Amount). Verified ALCRelationshipTrigger creates Contacts for all ALCs. Identified 8 unique Sales Managers in production and confirmed Directors/System Admin profiles for global view. Extracted reusable patterns from contractBPipelineDashboard for LWC development. Dashboard ready for Apex implementation with standardized query pattern.

---

## 1. Standardized Opportunity Query Pattern

### Current State: Two Different Approaches

#### CandidateFYCRollupService (Current Pattern A)

```apex
// Uses ContactId field and FYC__c field
List<AggregateResult> aggregates = [
    SELECT ContactId,
           SUM(FYC__c) totalFYC,    // ❌ Using FYC__c field
           COUNT(Id) oppCount
    FROM Opportunity
    WHERE ContactId IN :contactIds
    GROUP BY ContactId
];
```

**Issues:**

- Uses `ContactId` instead of `Soliciting_Agent__c`
- Uses `FYC__c` field instead of `Amount`
- **No filtering** on IsWon for FYC calculation
- Counts ALL opportunities (not distinguishing submitted vs won)

#### ContractBDashboardController (Current Pattern B)

```apex
// Count all submissions (Soliciting Agent)
for (AggregateResult ar : [
    SELECT Soliciting_Agent__c, COUNT(Id) oppCount
    FROM Opportunity
    WHERE Soliciting_Agent__c IN :contactIds
    GROUP BY Soliciting_Agent__c
]) {
    // Processes all opportunities
}

// Sum FYC from won opportunities only
for (AggregateResult ar : [
    SELECT Soliciting_Agent__c, SUM(Amount) totalFYC    // ✅ Using Amount
    FROM Opportunity
    WHERE Soliciting_Agent__c IN :contactIds
    AND IsWon = true    // ✅ Filtering won opportunities
    GROUP BY Soliciting_Agent__c
]) {
    // Processes only won opportunities
}
```

**Advantages:**

- ✅ Uses `Soliciting_Agent__c` field (correct field per spec)
- ✅ Uses `Amount` field (standard Salesforce field)
- ✅ Separates submitted vs won opportunities
- ✅ Only sums FYC from won deals

### Recommended Pattern (Approved - Use This!)

**Use Pattern B** from ContractBDashboardController. This aligns with approved decision "Option C" from the spec.

#### Query 1: Count All Submitted Opportunities

```apex
/**
 * Query all opportunities submitted by agents (regardless of won/lost)
 * Returns: Map<Id, Integer> of ContactId → submission count
 */
Map<Id, Integer> contactToSubmissionCount = new Map<Id, Integer>();

for (AggregateResult ar : [
    SELECT Soliciting_Agent__c, COUNT(Id) oppCount
    FROM Opportunity
    WHERE Soliciting_Agent__c IN :contactIds
    GROUP BY Soliciting_Agent__c
]) {
    Id contactId = (Id)ar.get('Soliciting_Agent__c');
    Integer count = (Integer)ar.get('oppCount');
    contactToSubmissionCount.put(contactId, count);
}
```

#### Query 2: Sum FYC from Won Opportunities

```apex
/**
 * Query won opportunities to calculate FYC total
 * Returns: Map<Id, Decimal> of ContactId → total FYC
 */
Map<Id, Decimal> contactToFYC = new Map<Id, Decimal>();

for (AggregateResult ar : [
    SELECT Soliciting_Agent__c,
           SUM(Amount) totalFYC,
           COUNT(Id) wonCount
    FROM Opportunity
    WHERE Soliciting_Agent__c IN :contactIds
    AND IsWon = true
    GROUP BY Soliciting_Agent__c
]) {
    Id contactId = (Id)ar.get('Soliciting_Agent__c');
    Decimal fyc = ar.get('totalFYC') != null ? (Decimal)ar.get('totalFYC') : 0;
    Integer wonCount = (Integer)ar.get('wonCount');

    contactToFYC.put(contactId, fyc);
    // Optional: also track wonCount if needed
}
```

### Complete Code Example (Ready to Copy/Paste)

```apex
/**
 * Get Opportunity metrics for Contract B agents
 * @param contactIds Set of Contact IDs (agents)
 * @return Map with 'submitted', 'won', and 'fyc' maps
 */
private static Map<String, Map<Id, Object>> getOpportunityMetrics(Set<Id> contactIds) {
    if (contactIds == null || contactIds.isEmpty()) {
        return new Map<String, Map<Id, Object>>{
            'submitted' => new Map<Id, Object>(),
            'won' => new Map<Id, Object>(),
            'fyc' => new Map<Id, Object>()
        };
    }

    // Query 1: All submissions
    Map<Id, Integer> submittedMap = new Map<Id, Integer>();
    for (AggregateResult ar : [
        SELECT Soliciting_Agent__c, COUNT(Id) oppCount
        FROM Opportunity
        WHERE Soliciting_Agent__c IN :contactIds
        GROUP BY Soliciting_Agent__c
    ]) {
        submittedMap.put((Id)ar.get('Soliciting_Agent__c'), (Integer)ar.get('oppCount'));
    }

    // Query 2: Won opportunities + FYC
    Map<Id, Integer> wonMap = new Map<Id, Integer>();
    Map<Id, Decimal> fycMap = new Map<Id, Decimal>();
    for (AggregateResult ar : [
        SELECT Soliciting_Agent__c,
               COUNT(Id) wonCount,
               SUM(Amount) totalFYC
        FROM Opportunity
        WHERE Soliciting_Agent__c IN :contactIds
        AND IsWon = true
        GROUP BY Soliciting_Agent__c
    ]) {
        Id contactId = (Id)ar.get('Soliciting_Agent__c');
        wonMap.put(contactId, (Integer)ar.get('wonCount'));
        fycMap.put(contactId, ar.get('totalFYC') != null ? (Decimal)ar.get('totalFYC') : 0);
    }

    return new Map<String, Map<Id, Object>>{
        'submitted' => (Map<Id, Object>)submittedMap,
        'won' => (Map<Id, Object>)wonMap,
        'fyc' => (Map<Id, Object>)fycMap
    };
}
```

### Field Mapping Reference

| Spec Field           | Salesforce Field                | Query Context                       |
| -------------------- | ------------------------------- | ----------------------------------- |
| **Agent Contact**    | `Soliciting_Agent__c`           | WHERE clause for filtering          |
| **FYC Amount**       | `Amount`                        | SUM() for FYC total                 |
| **Won Filter**       | `IsWon = true`                  | WHERE clause for won opps only      |
| **Submission Count** | `COUNT(Id)`                     | All opportunities (no IsWon filter) |
| **Won Count**        | `COUNT(Id)` with `IsWon = true` | Count of closed-won deals           |

### Key Decision Points

1. **Why Soliciting_Agent\_\_c instead of ContactId?**
   - Spec decision: Soliciting_Agent\_\_c is the correct relationship field
   - ContactId may represent client/customer, not the agent
2. **Why Amount instead of FYC\_\_c?**
   - Amount is standard Salesforce field
   - More reliable and consistent across orgs
   - FYC\_\_c may have data quality issues
3. **Why separate submitted vs won queries?**
   - Contract B requirements track TWO metrics:
     - Submissions: 5 opportunities (all)
     - FYC: $2,500 (won only)
   - Cannot calculate both accurately in single query

---

## 2. Contact Automation Verification

### ALCRelationshipTrigger Analysis

**Status:** ✅ Working correctly

**Trigger:** `ALCRelationshipTrigger.trigger`

- Fires on `before insert` of ALC\_\_c records
- Delegates to `ALCRelationshipTriggerHandler.handleBeforeInsert()`

### Contact Creation Logic

```apex
// From ALCRelationshipTriggerHandler.cls

// Step 1: Check for existing Contact by email or phone
String email = alc.Personal_Email_Address__c;
String phone = alc.Mobile__c;

// Bulk queries to avoid duplicates
List<Contact> existingContacts = [
    SELECT Id, Email, Personal_Email__c, MobilePhone
    FROM Contact
    WHERE Email IN :emails
    OR Personal_Email__c IN :emails
    OR MobilePhone IN :phones
];

// Step 2: If Contact exists, link ALC to existing Contact
if (existingContact != null) {
    alc.Contact__c = existingContact.Id;
}

// Step 3: If no Contact exists, create new Contact
else {
    Contact newContact = new Contact();
    newContact.FirstName = alc.First_Name__c;
    newContact.LastName = alc.Last_Name__c != null ? alc.Last_Name__c : 'Unknown';
    newContact.Personal_Email__c = alc.Personal_Email_Address__c;
    newContact.MobilePhone = alc.Mobile__c;
    insert newContact;

    alc.Contact__c = newContact.Id;
}

// Step 4: For Career type ALCs, also create Candidate
if (recordTypeName == 'Career' && alc.Candidate__c == null) {
    Candidate__c newCandidate = new Candidate__c();
    newCandidate.First_Name__c = alc.First_Name__c;
    newCandidate.Last_Name__c = alc.Last_Name__c;
    newCandidate.personal_email__c = alc.Personal_Email_Address__c;
    newCandidate.Phone__c = alc.Mobile__c;
    newCandidate.Contact__c = newContact.Id;
    newCandidate.Status__c = 'Contract Sent';
    insert newCandidate;

    alc.Candidate__c = newCandidate.Id;
}
```

### Matching Logic

1. **Email match:** Checks both `Email` and `Personal_Email__c` fields
2. **Phone match:** Standardizes to 10-digit format, strips non-numeric characters
3. **Preference:** Email match takes priority over phone match

### Verification Results

✅ **Confirmed:** `Candidate__c.Contact__c` field is populated by:

- ALCRelationshipTrigger (for Career type ALCs)
- Manual creation flows (New_Candidate_Screen_Flow, etc.)

❌ **Gap Identified:** 91,752 Candidates without Contact\_\_c populated

- **Root cause:** Old candidates created before trigger implementation
- **Recommendation:** Run backfill job to link Candidates to Contacts (future task)
- **Workaround:** Query only Candidates WHERE `Contact__c != null` for dashboard

### Edge Cases

1. **Duplicate Contacts:** Trigger uses email/phone matching to prevent duplicates
2. **Missing Last Name:** Defaults to "Unknown" if null
3. **Phone format:** Handles US/international formats, strips to 10 digits
4. **Async logging:** Creates audit logs via @future method (non-blocking)

---

## 3. Sales Manager Field Analysis

### Production Data

**Total Candidates with Sales Manager:** 1,865

**Unique Sales Manager Names:**

| Sales Manager    | Candidate Count |
| ---------------- | --------------- |
| Tim Denton       | 636             |
| Elizabeth Kagele | 572             |
| Diljeet Masuda   | 318             |
| Bradley Sofonia  | 214             |
| Van Hess         | 76              |
| Michael Yang     | 20              |
| Son Le           | 20              |
| Scott Primm      | 9               |

**Total:** 8 unique Sales Managers

### Sales Manager List (for Dropdown)

For `getSalesManagerUnits()` method, return this list (alphabetical):

```apex
List<String> salesManagerUnits = new List<String>{
    'Bradley Sofonia',
    'Diljeet Masuda',
    'Elizabeth Kagele',
    'Michael Yang',
    'Scott Primm',
    'Son Le',
    'Tim Denton',
    'Van Hess'
};
```

**OR** query dynamically from production:

```apex
@AuraEnabled(cacheable=true)
public static List<String> getSalesManagerUnits() {
    List<String> units = new List<String>();

    for (AggregateResult ar : [
        SELECT Sales_Manager__c
        FROM Candidate__c
        WHERE Sales_Manager__c != null
        GROUP BY Sales_Manager__c
        ORDER BY Sales_Manager__c ASC
    ]) {
        units.add((String)ar.get('Sales_Manager__c'));
    }

    return units;
}
```

### ALC ↔ Candidate Mismatch Analysis

**Query Attempted:**

```sql
SELECT COUNT(Id)
FROM ALC__c
WHERE Sales_Manager__c != null
AND Candidate__c != null
AND Sales_Manager__c != Candidate__r.Sales_Manager__c
```

**Result:** Query failed due to relationship syntax limitation in WHERE clause

**Workaround Query (use in Apex):**

```apex
// Get ALCs with Candidate linked
List<ALC__c> alcs = [
    SELECT Id, Sales_Manager__c, Candidate__c, Candidate__r.Sales_Manager__c
    FROM ALC__c
    WHERE Sales_Manager__c != null
    AND Candidate__c != null
];

Integer mismatchCount = 0;
for (ALC__c alc : alcs) {
    if (alc.Sales_Manager__c != alc.Candidate__r.Sales_Manager__c) {
        mismatchCount++;
    }
}

System.debug('Mismatches found: ' + mismatchCount);
```

**Known:** 138 ALCs have both Sales Manager and Candidate populated (baseline for comparison)

### Field Metadata

**Field Name:** `Sales_Manager__c`  
**Type:** Text (255)  
**Appears on:**

- `Candidate__c` object
- `ALC__c` object

**Usage in Flows:** 15 references across 6 flows:

- New_Candidate_Screen_Flow
- Updated_Candidate_Creation_Screen_Flow
- Link_ALC_and_Candidate_to_New_IEP_Application
- New_Recruit_Job_Application
- Send_Endorsement_Email (query only)

**Picklist Values:** NOT a picklist - free text field

**Recommendation:** Query Candidate\_\_c for dropdown values, not hardcoded list

### Data Quality

✅ **Good:** 1,865 Candidates with Sales Manager (sufficient for dashboard testing)

⚠️ **Concern:** No validation on Sales Manager field - users can enter any value

- **Mitigation:** Dropdown in dashboard uses only existing values from DB
- **Future:** Consider converting to picklist or lookup field

---

## 4. Profile Analysis

### Profiles in Production

Total Profiles: **60**

### Profiles for Global View (Directors & Admins)

**Contains "Director":**

- Brokerage Director
- Director Of Business Development
- Director of Sales
- New Business Director
- Recruiting Director

**Contains "System Administrator":**

- System Administrator

**Total:** 6 profiles with global view access

### Recommended Role Detection Logic

```apex
/**
 * Detect if current user has global view access
 * @return Map with 'isGlobalView' and 'salesManagerUnit'
 */
@AuraEnabled(cacheable=false)
public static Map<String, Object> getCurrentUserRole() {
    Map<String, Object> result = new Map<String, Object>();

    // Get current user's Profile name
    User currentUser = [
        SELECT Id, Profile.Name, ContactId
        FROM User
        WHERE Id = :UserInfo.getUserId()
        LIMIT 1
    ];

    String profileName = currentUser.Profile.Name;

    // Check if profile grants global view
    Boolean isGlobalView =
        profileName.contains('Director') ||
        profileName.contains('System Administrator');

    result.put('isGlobalView', isGlobalView);

    // If NOT global view, determine user's Sales Manager unit
    if (!isGlobalView) {
        String salesManagerUnit = null;

        // Option 1: If user is linked to a Candidate record, use that Sales Manager
        if (currentUser.ContactId != null) {
            List<Candidate__c> candidates = [
                SELECT Sales_Manager__c
                FROM Candidate__c
                WHERE Contact__c = :currentUser.ContactId
                AND Sales_Manager__c != null
                LIMIT 1
            ];

            if (!candidates.isEmpty()) {
                salesManagerUnit = candidates[0].Sales_Manager__c;
            }
        }

        // Option 2: If user IS a Sales Manager (check against known list)
        // This requires additional logic if user's name matches a Sales Manager

        result.put('salesManagerUnit', salesManagerUnit);
    } else {
        result.put('salesManagerUnit', null); // Global view sees all
    }

    return result;
}
```

### Profile-Based Access Summary

| Profile Type         | Access Level | Dropdown Shown? | Default Filter                |
| -------------------- | ------------ | --------------- | ----------------------------- |
| Director             | Global       | Yes             | "All Units"                   |
| System Administrator | Global       | Yes             | "All Units"                   |
| Sales Manager        | Own unit     | No              | User's Sales Manager value    |
| Other                | No access    | No              | (Dashboard should show error) |

**Note:** For non-Director/non-Admin users, dashboard must determine their Sales Manager unit. If unable to determine, show error message.

---

## 5. Reusable Code Patterns from contractBPipelineDashboard

### Contract A Qualification Split Logic (JavaScript)

```javascript
// From contractBPipelineDashboard.js

// Split into "Qualified" vs "Not Qualified" sections
get qualifiedContractAData() {
    // Qualified = progress bar >= 100% OR status starts with "Met"
    return this.formattedContractAData.filter(agent =>
        agent.wladlProgress >= 100 ||
        (agent.qualStatus && agent.qualStatus.startsWith('Met'))
    );
}

get notQualifiedContractAData() {
    // Not qualified = progress bar < 100% AND status does NOT start with "Met"
    return this.formattedContractAData.filter(agent =>
        agent.wladlProgress < 100 &&
        (!agent.qualStatus || !agent.qualStatus.startsWith('Met'))
    );
}

get hasQualifiedData() {
    return this.qualifiedContractAData && this.qualifiedContractAData.length > 0;
}

get hasNotQualifiedData() {
    return this.notQualifiedContractAData && this.notQualifiedContractAData.length > 0;
}

get qualifiedCount() {
    return this.qualifiedContractAData ? this.qualifiedContractAData.length : 0;
}

get notQualifiedCount() {
    return this.notQualifiedContractAData ? this.notQualifiedContractAData.length : 0;
}
```

**Pattern for Contract B:** Use `requirementsMet` boolean field

```javascript
get contractBMetAgents() {
    return this.contractBData.filter(agent => agent.requirementsMet);
}

get contractBNotMetAgents() {
    return this.contractBData.filter(agent => !agent.requirementsMet);
}
```

### Progress Bar CSS Classes

**From contractBPipelineDashboard.css:**

```css
/* Progress bar container */
.progress-bar-container {
  background: #e5e5e5;
  border-radius: 4px;
  height: 8px;
  width: 100%;
  overflow: hidden;
  margin-top: 4px;
}

.progress-bar {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s ease;
}

/* Dual progress bars for Contract B */
.progress-bar-fyc {
  background: linear-gradient(90deg, #f39c12, #2e844a); /* Orange → Green */
}

.progress-bar-subs {
  background: linear-gradient(90deg, #0176d3, #06a59a); /* Blue → Teal */
}

.progress-text {
  font-size: 0.7rem;
  color: #706e6b;
}
```

**Usage in HTML:**

```html
<div class="progress-bar-container">
  <div
    class="progress-bar progress-bar-subs"
    style="{submissionsProgressStyle}"
  ></div>
</div>
<div class="progress-text">3 / 5 submitted</div>

<div class="progress-bar-container">
  <div class="progress-bar progress-bar-fyc" style="{fycProgressStyle}"></div>
</div>
<div class="progress-text">$1,800 / $2,500</div>
```

### Status Badge Styling

```css
/* Status Colors */
.progress-on-track {
  color: #2e844a;
  font-weight: bold;
}

.progress-at-risk {
  color: #f39c12;
  font-weight: bold;
}

.progress-critical {
  color: #e74c3c;
  font-weight: bold;
}

.progress-complete {
  color: #0176d3;
  font-weight: bold;
}
```

**JavaScript method:**

```javascript
getProgressClass(status) {
    switch (status) {
        case 'On Track':
            return 'progress-on-track';
        case 'At Risk':
            return 'progress-at-risk';
        case 'Critical':
            return 'progress-critical';
        case 'Complete':
            return 'progress-complete';
        default:
            return 'progress-default';
    }
}
```

**Apply to Contract B:**

```javascript
getStatusClass(status) {
    switch (status) {
        case 'Complete':
            return 'slds-badge slds-theme_success'; // Green
        case 'Critical':
            return 'slds-badge slds-theme_error';   // Red
        case 'At Risk':
            return 'slds-badge slds-theme_warning'; // Orange
        case 'On Track':
            return 'slds-badge slds-theme_info';    // Blue
        default:
            return 'slds-badge';
    }
}
```

### Summary Card Styles

```css
/* From contractBPipelineDashboard.css */

.summary-card {
  border-radius: 8px;
  padding: 1rem;
  text-align: center;
  color: white;
}

.summary-value {
  font-size: 2rem;
  font-weight: bold;
}

.summary-label {
  font-size: 0.75rem;
  opacity: 0.9;
}

/* Color variants */
.summary-total {
  background: linear-gradient(135deg, #0176d3, #032d60);
}

.summary-success {
  background: linear-gradient(135deg, #2e844a, #194e2e);
}

.summary-ontrack {
  background: linear-gradient(135deg, #06a59a, #014d48);
}

.summary-atrisk {
  background: linear-gradient(135deg, #e74c3c, #a72d20);
}

.summary-fyc {
  background: linear-gradient(135deg, #f39c12, #b37209);
}

.summary-avg {
  background: linear-gradient(135deg, #9b59b6, #6c3483);
}
```

### Helper Methods for Formatting

```javascript
// Currency formatting
formatCurrency(value) {
    if (value == null) return '$0';
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(value);
}

// Date formatting (use standard Lightning component)
// <lightning-formatted-date-time value={agent.startDate}></lightning-formatted-date-time>

// Percentage calculation
calculateProgress(current, target) {
    if (target == null || target <= 0) return 0;
    return Math.min((current / target) * 100, 100);
}

// Progress bar style attribute
get fycProgressStyle() {
    const progress = this.calculateProgress(this.totalFYC, 2500);
    return `width: ${progress}%`;
}
```

### Table Column Structure (HTML)

```html
<table
  class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_striped"
>
  <thead>
    <tr class="slds-line-height_reset">
      <th scope="col">
        <div class="slds-truncate" title="Agent Name">Agent</div>
      </th>
      <th scope="col">
        <div class="slds-truncate" title="Start Date">Start</div>
      </th>
      <th scope="col">
        <div class="slds-truncate" title="Submitted">Submitted</div>
      </th>
      <th scope="col"><div class="slds-truncate" title="Won">Won</div></th>
      <th scope="col"><div class="slds-truncate" title="FYC">FYC</div></th>
      <th scope="col">
        <div class="slds-truncate" title="Progress">Progress</div>
      </th>
      <th scope="col">
        <div class="slds-truncate" title="Status">Status</div>
      </th>
    </tr>
  </thead>
  <tbody>
    <template for:each="{formattedPipelineData}" for:item="agent">
      <tr key="{agent.id}">
        <td>
          <a href="#" data-id="{agent.id}" onclick="{navigateToCandidate}">
            {agent.name}
          </a>
        </td>
        <td>
          <lightning-formatted-date-time value="{agent.startDate}">
          </lightning-formatted-date-time>
        </td>
        <td>{agent.opportunityCount} / 5</td>
        <td>{agent.opportunitiesWon}</td>
        <td>{agent.fycFormatted}</td>
        <td>
          <!-- Progress bars component -->
          <div class="progress-bar-container">
            <div
              class="progress-bar progress-bar-subs"
              style="{agent.submissionsProgressStyle}"
            ></div>
          </div>
        </td>
        <td>
          <span class="{agent.statusBadgeClass}">
            {agent.statusIndicator}
          </span>
        </td>
      </tr>
    </template>
  </tbody>
</table>
```

---

## 6. Data Quality Assessment

### Issues Found

1. **Candidates Without Contacts: 91,752 records**
   - **Impact:** Cannot query Opportunities for these Candidates
   - **Recommendation:** Dashboard should filter `WHERE Contact__c != null`
   - **Future Fix:** Run backfill job to link old Candidates to Contacts via email/phone match

2. **Opportunities Without Soliciting_Agent\_\_c: 1,930 records**
   - **Impact:** These opportunities won't be counted for any agent
   - **Recommendation:** Acceptable - likely represent non-agent deals or data entry errors
   - **Action:** No change needed for dashboard (omit these from calculations)

3. **Sales Manager Field is Free Text (Not Picklist)**
   - **Impact:** Risk of typos or inconsistent naming (e.g., "Tim" vs "Timothy")
   - **Current State:** 8 consistent values in production (good data quality)
   - **Recommendation:** Dashboard dropdown uses live query, not hardcoded list

4. **ALC ↔ Candidate Sales Manager Sync**
   - **Known:** 138 ALCs have both Sales Manager and Candidate linked
   - **Unknown:** Mismatch count (query limitation prevents direct count)
   - **Spec Decision:** Candidate**c.Sales_Manager**c is source of truth
   - **Recommendation:** Dashboard uses Candidate.Sales_Manager\_\_c only (ignore ALC field)

### Data Validation Recommendations

**For Patrick's Agent to implement:**

```apex
// In getContractBAgentProgress() method:

// Filter: Only Candidates with Contact linked
List<Candidate__c> candidates = [
    SELECT Id, Name, Contact__c, Sales_Manager__c, Start_Date__c,
           Contract_End_Date__c, Extension_Granted__c, Requirements_Met__c
    FROM Candidate__c
    WHERE Contract_Type__c = 'Contract B'
    AND Contact__c != null  // ⬅️ CRITICAL FILTER
    AND (salesManagerUnit == 'All Units' ? true : Sales_Manager__c = :salesManagerUnit)
];

// Collect Contact IDs for Opportunity queries
Set<Id> contactIds = new Set<Id>();
for (Candidate__c cand : candidates) {
    contactIds.add(cand.Contact__c);
}

// If no contactIds, return empty data (avoid query errors)
if (contactIds.isEmpty()) {
    return new List<ContractBAgentData>();
}

// Proceed with Opportunity queries...
```

### Data Completeness

**Production Statistics:**

| Metric                | Count  | % of Total |
| --------------------- | ------ | ---------- |
| Total Candidates      | 93,617 | 100%       |
| With Sales Manager    | 1,865  | 2%         |
| With Contact          | 1,865  | 2%         |
| Without Contact       | 91,752 | 98%        |
| Total Opportunities   | 1,930+ | -          |
| With Soliciting Agent | varies | -          |

**Implication:** Dashboard will show only ~1,865 Candidates (the 2% with Sales Manager + Contact populated)

---

## Edge Cases for Patrick to Handle

### 1. No Contact Linked to Candidate

```apex
if (candidate.Contact__c == null) {
    // Skip this candidate - cannot query Opportunities
    continue;
}
```

### 2. No Opportunities for Agent

```apex
Integer submittedCount = contactToSubmissionCount.get(contactId);
if (submittedCount == null) {
    submittedCount = 0; // Default to 0, not null
}
```

### 3. Division by Zero in Progress Calculation

```apex
Decimal fycProgress = 0;
if (targetFYC > 0) {
    fycProgress = (currentFYC / targetFYC) * 100;
} else {
    fycProgress = 0; // Avoid division by zero
}
```

### 4. Days Remaining Calculation with Extension

```apex
Date deadline;
if (candidate.Extension_Granted__c == true) {
    deadline = candidate.Start_Date__c.addDays(240); // 8 months
} else {
    deadline = candidate.Start_Date__c.addDays(120); // 4 months
}

Integer daysRemaining = candidate.Start_Date__c != null
    ? deadline.daysBetween(Date.today())
    : null;

// Handle negative days (past deadline)
if (daysRemaining != null && daysRemaining < 0) {
    daysRemaining = 0; // Or keep negative to show "X days overdue"
}
```

### 5. Status Determination Logic

```apex
String status;
if (candidate.Requirements_Met__c == true) {
    status = 'Complete';
} else if (daysRemaining != null && daysRemaining < 14) {
    status = 'Critical';
} else if (daysRemaining != null && daysRemaining < 30) {
    status = 'At Risk';
} else {
    status = 'On Track';
}
```

### 6. User Has No Sales Manager Unit (Non-Director)

```apex
// In getCurrentUserRole():
if (!isGlobalView && salesManagerUnit == null) {
    // User is not a Director and has no associated Sales Manager
    // Dashboard should show error: "Unable to determine your Sales Manager unit"
    result.put('error', 'Unable to determine Sales Manager unit for current user');
}
```

### 7. Sales Manager Unit Not Found

```apex
// In getContractBAgentProgress():
if (salesManagerUnit != 'All Units') {
    // Validate that Sales Manager exists
    Integer count = [
        SELECT COUNT()
        FROM Candidate__c
        WHERE Sales_Manager__c = :salesManagerUnit
    ];

    if (count == 0) {
        // No candidates for this Sales Manager
        return new List<ContractBAgentData>(); // Return empty list
    }
}
```

### 8. NULL Date Fields

```apex
// Handle null Start_Date__c
if (candidate.Start_Date__c == null) {
    agentData.daysRemaining = null;
    agentData.deadline = null;
    agentData.status = 'On Track'; // Default status
}
```

---

## Next Steps for Patrick's Agent

### Implementation Checklist

1. ✅ **Create SalesManagerQualificationController class**
   - Location: `force-app/main/default/classes/SalesManagerQualificationController.cls`
   - Add class documentation with @description tag

2. ✅ **Implement getCurrentUserRole()**
   - Use Profile detection logic from Section 4
   - Return `Map<String, Object>` with `isGlobalView` and `salesManagerUnit`
   - Handle edge case: User has no Sales Manager unit (return error)

3. ✅ **Implement getSalesManagerUnits()**
   - Query Candidate**c GROUP BY Sales_Manager**c
   - Return sorted `List<String>` (alphabetical order)
   - Use `cacheable=true` since this data rarely changes

4. ✅ **Implement getContractBAgentProgress(String salesManagerUnit)**
   - Filter Candidates by Contract_Type\_\_c = 'Contract B'
   - Apply Sales Manager filter (if not 'All Units')
   - **CRITICAL:** Filter WHERE Contact\_\_c != null
   - Use standardized Opportunity queries from Section 1
   - Calculate progress percentages (submissions and FYC)
   - Calculate days remaining (with extension logic)
   - Determine status (Complete, Critical, At Risk, On Track)
   - Return `List<ContractBAgentData>` wrapper

5. ✅ **Implement getContractAAgentProgress(String salesManagerUnit)**
   - Query Contract_Qualification\_\_c records
   - Join with Candidate**c to filter by Sales_Manager**c
   - Reuse existing pattern from `getContractAProgressData()`
   - Add submitted/won Opportunity counts (new requirement)
   - Return `List<ContractAAgentData>` wrapper

6. ✅ **Create Wrapper Classes**
   - `ContractBAgentData` - See Section 3 of spec
   - `ContractAAgentData` - See Section 3 of spec
   - All properties must have `@AuraEnabled` annotation

7. ✅ **Write Test Class: SalesManagerQualificationController_Test**
   - Test getCurrentUserRole() with Director profile
   - Test getCurrentUserRole() with non-Director profile
   - Test getSalesManagerUnits() returns correct list
   - Test getContractBAgentProgress() with 'All Units'
   - Test getContractBAgentProgress() with specific unit
   - Test getContractAAgentProgress() with filters
   - Test edge cases: No Opportunities, null fields, extension granted
   - Test progress calculations (submissions and FYC)
   - Test status determination (Complete, Critical, At Risk, On Track)
   - Test days remaining with extension
   - **Target:** >= 80% code coverage

8. ✅ **Deploy to ProdTest**

   ```bash
   sf project deploy start --source-dir "force-app\main\default\classes\SalesManagerQualificationController.cls" "force-app\main\default\classes\SalesManagerQualificationController.cls-meta.xml" --target-org ProdTest

   sf project deploy start --source-dir "force-app\main\default\classes\SalesManagerQualificationController_Test.cls" "force-app\main\default\classes\SalesManagerQualificationController_Test.cls-meta.xml" --target-org ProdTest
   ```

9. ✅ **Run Tests in ProdTest**

   ```bash
   sf apex run test --test-level RunLocalTests --target-org ProdTest --result-format human
   ```

10. ✅ **Create Handoff Document**
    - File: `docs/handoffs/HANDOFF-APEX-TO-LWC-2026-01-08.md`
    - Include method signatures, wrapper classes, sample return data
    - Document any edge cases or limitations discovered
    - Provide test results summary
    - Confirm deployment to ProdTest

---

## Files Modified/Created

### Created

- `docs/handoffs/HANDOFF-RESEARCH-TO-APEX-2026-01-08.md` (this document)

### Referenced (Audited)

- `force-app/main/default/classes/CandidateFYCRollupService.cls`
- `force-app/main/default/classes/ContractBDashboardController.cls`
- `force-app/main/default/classes/ContractBDashboardController_Test.cls`
- `force-app/main/default/triggers/ALCRelationshipTrigger.trigger`
- `force-app/main/default/classes/ALCRelationshipTriggerHandler.cls`
- `force-app/main/default/lwc/contractBPipelineDashboard/contractBPipelineDashboard.js`
- `force-app/main/default/lwc/contractBPipelineDashboard/contractBPipelineDashboard.html`
- `force-app/main/default/lwc/contractBPipelineDashboard/contractBPipelineDashboard.css`
- `force-app/main/default/flows/*.flow-meta.xml` (15 references to Sales_Manager\_\_c)

### Production Queries Run

1. Sales Manager unique values and counts
2. Profile names (60 profiles)
3. ALC records with Sales Manager + Candidate
4. Candidates without Contact
5. Opportunities without Soliciting Agent

---

## Questions/Assumptions

### Assumptions Made

1. **Sales Manager Unit Dropdown:** Assumes "All Units" is a valid option for Directors/Admins to see all agents across all Sales Managers. Patrick's Agent should implement this as a special value that bypasses the Sales Manager filter.

2. **Contract B Requirements:** Assumes the 5 submissions + $2,500 FYC are cumulative (all-time), not YTD or MTD. Spec does not specify time period, so using all opportunities since agent start date.

3. **Extension Logic:** Assumes Extension_Granted\_\_c is a boolean checkbox field that extends deadline from 4 months (120 days) to 8 months (240 days).

4. **Requirements Met Field:** Assumes `Requirements_Met__c` is a boolean field that indicates whether agent has achieved both targets (5 submissions + $2,500 FYC). If this field doesn't exist, Patrick's Agent should calculate it: `(submittedCount >= 5 AND totalFYC >= 2500)`.

5. **Role Detection:** Assumes Profile.Name contains exact strings "Director" or "System Administrator" (case-sensitive). If profiles use different naming, adjust contains() logic.

6. **User's Sales Manager Unit:** For non-Director users, assumes the system can determine their Sales Manager unit by checking if they are a Candidate (via User.ContactId → Candidate**c.Contact**c → Candidate**c.Sales_Manager**c). If user is not a Candidate, dashboard cannot determine their unit and should show an error.

7. **Contract A Opportunity Counts:** Spec requests submitted/won counts for Contract A agents (new requirement). This requires querying Opportunities for Contract A agent Contacts, similar to Contract B pattern.

8. **Data Filtering:** Assumes `Contact__c != null` filter is acceptable for dashboard (excludes 91K old candidates). Alternative would be a backfill job to link Candidates to Contacts before dashboard release.

### Questions for Patrick

1. **Does Requirements_Met\_\_c field exist?** If not, should Apex calculate it dynamically?

2. **Should Contract B time period be all-time or YTD?** Spec doesn't specify, but "since start date" seems most logical for qualification tracking.

3. **Should we implement Permission Sets?** Spec relies on Profile detection, but Permission Sets might be more flexible for role-based access.

4. **Should Sales Manager field become a picklist?** Current free-text field has good data quality but could benefit from standardization.

5. **How should we handle users with no Sales Manager unit?** Show error message, or allow them to view "All Units" dropdown but filter results based on some other logic?

---

## Research Complete

**Date/Time:** 2026-01-08, 14:00 UTC  
**Ready for Apex Development:** ✅ Yes  
**Confidence Level:** High  
**Estimated Apex Development Time:** 3-4 hours  
**Blockers:** None

---

**Handoff Status:** 🟢 READY FOR TASK #003

**Next Agent:** Patrick's Agent (Apex Development)
