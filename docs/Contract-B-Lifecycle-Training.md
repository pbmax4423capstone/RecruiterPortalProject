# Contract B Lifecycle Tracking System

## Training Documentation

**Version:** 1.1  
**Last Updated:** December 19, 2025  
**Target Org:** Recruiting Sandbox  
**Status:** ✅ FULLY DEPLOYED

---

## Table of Contents

1. [Overview](#overview)
2. [Contract B Requirements](#contract-b-requirements)
3. [New Fields on Candidate Record](#new-fields-on-candidate-record)
4. [Automated Workflows](#automated-workflows)
5. [Contract B Pipeline Dashboard](#contract-b-pipeline-dashboard)
6. [Common Scenarios](#common-scenarios)
7. [Administrator Guide](#administrator-guide)
8. [FAQ](#faq)

---

## Overview

The Contract B Lifecycle Tracking System is designed to monitor and manage Contract B financial advisors through their 4-month probationary period. The system automatically:

- Calculates contract end dates
- Tracks FYC (First Year Commission) progress
- Counts business submissions (Opportunities)
- Identifies at-risk candidates
- Records transitions to Contract A
- Tracks terminations and reasons

### Key Business Rules

| Metric                 | Requirement                        |
| ---------------------- | ---------------------------------- |
| **FYC Target**         | $2,500                             |
| **Submissions Target** | 5 business submissions             |
| **Contract Period**    | 4 months from Start Date           |
| **Extension Period**   | Additional 4 months (when granted) |

---

## Contract B Requirements

To successfully complete their Contract B period and transition to Contract A, candidates must achieve:

1. **$2,500 in FYC** (First Year Commission)
2. **5 Business Submissions** (Opportunities)

Both requirements must be met within the contract period (4 months, or 8 months if an extension is granted).

---

## New Fields on Candidate Record

### Contract Lifecycle Fields

| Field                      | Type     | Description                                |
| -------------------------- | -------- | ------------------------------------------ |
| **Contract End Date**      | Date     | Auto-calculated: Start Date + 4 months     |
| **Extension Granted**      | Checkbox | Check to grant a 4-month extension         |
| **Extension Granted Date** | Date     | Auto-set when Extension Granted is checked |
| **Extended End Date**      | Date     | Auto-calculated: Extension Date + 4 months |
| **Contract Outcome**       | Picklist | Transitioned to A, Terminated, Extended    |
| **Termination Date**       | Date     | Date of termination                        |
| **Termination Reason**     | Picklist | Reason for termination                     |
| **Transition to A Date**   | Date     | Auto-set when Contract Type changes from B |

### Performance Tracking Fields

| Field                 | Type     | Description                                   |
| --------------------- | -------- | --------------------------------------------- |
| **Total FYC**         | Currency | Sum of all FYC from linked Opportunities      |
| **Opportunity Count** | Number   | Count of all Opportunities for this candidate |

### Formula Fields (Auto-Calculated)

| Field                            | Description                                             |
| -------------------------------- | ------------------------------------------------------- |
| **Days Until Contract End**      | Days remaining until deadline (considers extensions)    |
| **Contract Deadline Date**       | The actual deadline date (Contract End or Extended End) |
| **Requirements Met**             | TRUE if FYC ≥ $2,500 AND Submissions ≥ 5                |
| **FYC Progress Percent**         | (Total FYC / $2,500) × 100                              |
| **Submissions Progress Percent** | (Opportunity Count / 5) × 100                           |
| **Contract Status Indicator**    | On Track, At Risk, Critical, or Complete                |

### Status Indicator Logic

| Status       | Condition                                    |
| ------------ | -------------------------------------------- |
| **Complete** | Requirements Met = TRUE                      |
| **Critical** | < 14 days remaining AND Requirements NOT Met |
| **At Risk**  | < 30 days remaining AND Requirements NOT Met |
| **On Track** | ≥ 30 days remaining OR Requirements Met      |

---

## Automated Workflows

### 1. Contract End Date Calculation

**Trigger:** When Start Date is set on a Contract B candidate

**Action:** Automatically sets `Contract_End_Date__c = Start_Date__c + 4 months`

**Example:**

- Start Date: January 15, 2025
- Contract End Date: May 15, 2025

---

### 2. Extension Processing

**Trigger:** When `Extension_Granted__c` checkbox is checked

**Actions:**

- Sets `Extension_Granted_Date__c = TODAY`
- Sets `Extended_End_Date__c = TODAY + 4 months`

**Example:**

- Extension granted on April 1, 2025
- Extended End Date: August 1, 2025

---

### 3. Contract B Transition Tracking

**Trigger:** When `Contract_Type__c` changes FROM "Contract B" to another value

**Actions:**

- Sets `Transition_to_A_Date__c = TODAY`
- Sets `Contract_Outcome__c = "Transitioned to A"`

---

### 4. FYC Rollup Updates

**Trigger:** When Opportunities are created or updated

**Actions:**

- Recalculates `Total_FYC__c` (sum of all Opportunity FYC)
- Recalculates `Opportunity_Count__c` (count of all Opportunities)

**Note:** A daily scheduled job also runs at 6 AM to ensure all rollups are accurate.

---

## Contract B Pipeline Dashboard

### Accessing the Dashboard

1. Navigate to the **Contract B Pipeline** tab (or App Page where configured)
2. The dashboard loads automatically with current data

### Dashboard Sections

#### 1. Summary Cards

Six cards showing key metrics:

- **Active Contract B** - Total active Contract B candidates
- **Requirements Met** - Count who have achieved targets
- **On Track** - Progressing well
- **At Risk** - < 30 days remaining, requirements not met
- **Total FYC** - Combined FYC of all active Contract B
- **Avg FYC** - Average FYC per candidate

#### 2. At-Risk Alert Banner

A yellow warning banner appears when candidates are at risk, showing the count of candidates needing attention.

#### 3. Interview Statistics (with Period Toggle)

Shows completed interview counts by type:

- Attraction
- SI 1
- SI 2
- SI 3
- Career
- Total

**Toggle Options:**

- **Current Month** - Shows interviews completed this month
- **Year to Date** - Shows all interviews completed this year

#### 4. YTD Recruiting Metrics

- Contract A recruited
- Contract B recruited
- B→A Transitions
- Terminations
- Transition Rate (%)
- Termination Rate (%)

#### 5. Pipeline Details Table

Detailed view of each Contract B candidate:

| Column       | Description              |
| ------------ | ------------------------ |
| Candidate    | Link to candidate record |
| Manager      | Sales Manager assigned   |
| Start        | Contract start date      |
| Days Left    | Days until deadline      |
| FYC          | Total FYC earned         |
| FYC Progress | Visual progress bar      |
| Submissions  | X/5 with progress bar    |
| Status       | Badge showing status     |

---

## Common Scenarios

### Scenario 1: New Contract B Starts

1. Create new Candidate record
2. Set `Contract_Type__c = "Contract B"`
3. Set `Start_Date__c` to their start date
4. **Automatic:** Contract End Date is calculated

### Scenario 2: Granting an Extension

1. Open the Candidate record
2. Check the `Extension_Granted__c` checkbox
3. Save the record
4. **Automatic:** Extension dates are set

### Scenario 3: Contract B Meets Requirements

When a Contract B achieves:

- Total FYC ≥ $2,500
- Opportunity Count ≥ 5

The `Requirements_Met__c` formula automatically shows TRUE, and `Contract_Status_Indicator__c` shows "Complete".

**To transition them:**

1. Change `Contract_Type__c` to "Contract A" or "Career Contract"
2. Save
3. **Automatic:** Transition date and outcome are recorded

### Scenario 4: Terminating a Contract B

1. Set `Status__c = "Terminated"`
2. Set `Termination_Date__c` to the termination date
3. Set `Termination_Reason__c` (select from picklist)
4. Save

> **Important:** The `Termination_Date__c` field must be populated for the termination to appear in YTD Recruiting Metrics. The dashboard queries this field to count terminations by month.

### Scenario 5: Viewing At-Risk Candidates

1. Open the Contract B Pipeline Dashboard
2. Look at the **At Risk** summary card for count
3. Scroll to the Pipeline Details table
4. Filter/sort by "Days Left" or "Status"
5. Candidates with "At Risk" or "Critical" status need attention

---

## Administrator Guide

### Scheduled Jobs

A daily job runs at 6 AM to update FYC rollups:

**Job Name:** `Contract B Daily FYC Rollup`  
**Schedule:** Daily at 6:00 AM (Mountain Time)

**To verify job is scheduled:**

1. Setup → Scheduled Jobs
2. Look for "Contract B Daily FYC Rollup"

**To reschedule or unschedule:**

```apex
// In Execute Anonymous:

// Unschedule
ContractBDailyRollupScheduler.unscheduleJob();

// Reschedule
ContractBDailyRollupScheduler.scheduleDailyJob();
```

### Flows

Four active flows support this system:

| Flow Name                   | Object         | Trigger     |
| --------------------------- | -------------- | ----------- |
| Calculate_Contract_End_Date | Candidate\_\_c | Before Save |
| Process_Contract_Extension  | Candidate\_\_c | Before Save |
| Track_Contract_B_Transition | Candidate\_\_c | Before Save |
| Update_Candidate_FYC_Rollup | Opportunity    | After Save  |

**To deactivate flows:** Setup → Flows → Select flow → Deactivate

### Adding Dashboard to App Page

1. Setup → Lightning App Builder
2. Create New or Edit existing App Page
3. Drag **contractBPipelineDashboard** component onto page
4. Save and Activate

### Field Permissions

Ensure users have access to these fields on Candidate\_\_c:

- All Contract Lifecycle fields
- Total_FYC\_\_c
- Opportunity_Count\_\_c
- All formula fields

---

## FAQ

### Q: Why isn't my FYC updating?

**A:** FYC updates when:

1. An Opportunity is created/updated with the candidate's Contact
2. The daily 6 AM scheduled job runs

Try waiting for the daily job or manually trigger it:

```apex
CandidateFYCRollupService.updateAllContractBCandidates();
```

### Q: Can I extend a Contract B more than once?

**A:** The current system supports one extension. The Extension Granted checkbox captures a single 4-month extension from the date it's checked.

### Q: What happens to the data if someone transitions back from Contract A to Contract B?

**A:** The Transition_to_A_Date and Contract_Outcome fields retain their values. The system tracks the most recent transition.

### Q: How do I manually recalculate someone's FYC?

**A:** In Execute Anonymous:

```apex
// Get the Contact ID from the Candidate record
Id contactId = 'YOUR_CONTACT_ID';
CandidateFYCRollupService.updateCandidateFYCRollup(new List<Id>{ contactId });
```

### Q: Where does FYC data come from?

**A:** FYC is summed from the `FYC__c` field on Opportunity records where `Opportunity.ContactId` matches `Candidate__c.Contact__c`.

### Q: Why does Days Until Contract End show blank?

**A:** The formula requires either `Contract_End_Date__c` or `Extended_End_Date__c` to be populated. Ensure the candidate has a Start Date and is Contract Type B.

---

## Support

For technical issues or questions, contact your Salesforce Administrator.

**System Components:**

- Apex Classes: `ContractBDashboardController`, `CandidateFYCRollupService`, `ContractBDailyRollupScheduler`
- LWC: `contractBPipelineDashboard`
- Flows: Calculate_Contract_End_Date, Process_Contract_Extension, Track_Contract_B_Transition, Update_Candidate_FYC_Rollup
