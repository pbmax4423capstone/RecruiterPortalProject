# Contract Lifecycle & Recruiting Metrics System
## Recruiter Portal Enhancement - Recruiting Sandbox

**Date:** December 19, 2025  
**Status:** ✅ DEPLOYED - FULLY OPERATIONAL  
**Target Org:** Recruiting Sandbox (`patrickbakeradmin2@financialguide.com.recruiting`)

---

## Executive Summary

This system enhances the Recruiter Portal with **Contract B lifecycle tracking** and **recruiting metrics dashboards**. The focus is on tracking:
- Contract B agents through their 4-month probation period
- Extension grants for agents with pipeline but not yet meeting requirements
- Transition rates from Contract B → Contract A
- Termination tracking with reasons
- Interview completion metrics by type and time period
- FYC and submission progress toward contract requirements

### Agent Types
| Type | Description | Application Object |
|------|-------------|-------------------|
| **Contract A** | Experienced Agents | `EAP_Applications__c` |
| **Contract B** | Career Changers (new to industry) | `Job_Application__c` |
| **Career Contract** | Career Contract agents | - |
| **Broker** | Broker agents | - |

### Contract B Requirements (to transition to Contract A)
| Requirement | Target | Source |
|-------------|--------|--------|
| FYC (First Year Commission) | $2,500 | `Opportunity.Commission` |
| Business Submissions | 5 | Count of Opportunities |
| Timeframe | 4 months | From `Start_Date__c` |

### Contract B Lifecycle
```
Recruited as Contract B
        ↓
  4-Month Probation
        ↓
   Decision Point ────────────────────────────────────────┐
        │                                                 │
   Met Requirements?                               Has Pipeline?
        │                                                 │
       YES                                               YES
        ↓                                                 ↓
  Transition to                                    Extension Granted
   Contract A ✓                                    (+4 more months)
                                                         │
                                                   Met Requirements?
                                                    │           │
                                                   YES          NO
                                                    ↓           ↓
                                              Transition    Terminated
                                              to A ✓       (Extended) ✗
        │
        NO (and no pipeline)
        ↓
   Terminated
   (Initial) ✗
```

---

## 1. Current State Analysis

### Existing Objects
| Object | Purpose | Key Fields |
|--------|---------|------------|
| `Candidate__c` | Candidate profiles | **Highest_Level_Achieved__c** (PIPELINE), Contract_Type__c, Start_Date__c, Contact__c |
| `Interview__c` | Interview scheduling | Type (Ci-First, Align-2nd, Plan-3rd, Present-4th, Optional-5th), Status |
| `ALC__c` | Agent Licensing & Contracting | Linked to Candidate |
| `Opportunity` | New Business/Pipeline | Commission field, linked to Contact |
| `Contact` | Standard Contact | Linked from Candidate__c via Contact__c lookup |
| `Job_Application__c` | New Recruit Application | Created after Align-2nd for Contract B |
| `EAP_Applications__c` | EAP Application | Created after Align-2nd for Contract A |

### ✅ EXISTING PIPELINE (Highest_Level_Achieved__c) - PRESERVED
```
0-Prequal → Ci(1st) → Align(2nd) → Plan(3rd) → Present(4th) → Optional(5th) → 6-Offer Acc → 7-Contracted
```

### ✅ EXISTING Contract_Type__c Values
- Contract B
- Career Contract
- Broker
- (Need to add: Contract A for experienced agents)

### Interview Types (Interview__c.Interview_Type__c)
- Ci-First
- Align-2nd
- Plan-3rd
- Present-4th
- Optional-5th

### What We're ADDING
1. ✅ Contract lifecycle fields on Candidate__c
2. ✅ Formula fields for FYC/submission tracking
3. ✅ Interview metrics dashboard (current month vs YTD)
4. ✅ Contract B pipeline dashboard
5. ✅ Recruiting metrics dashboard (A vs B, transition rates, termination rates)

---

## 2. Data Model Changes

### 2.1 New Fields on Candidate__c

These fields track the Contract B lifecycle from recruitment through transition/termination:

| Field | Type | Description | Notes |
|-------|------|-------------|-------|
| `Contract_End_Date__c` | Date | Contract expiration date | Start_Date__c + 4 months for Contract B |
| `Extension_Granted__c` | Checkbox | Was extension granted? | For Contract B's with pipeline |
| `Extension_Granted_Date__c` | Date | When extension was approved | |
| `Extended_End_Date__c` | Date | New end date after extension | Extension_Granted_Date + 4 months |
| `Contract_Outcome__c` | Picklist | Final outcome | See values below |
| `Termination_Date__c` | Date | If terminated, when | |
| `Termination_Reason__c` | Picklist | Why terminated | See values below |
| `Transition_to_A_Date__c` | Date | When transitioned B→A | |

**Contract_Outcome__c Picklist Values:**
- `Active` - Currently under contract
- `Transitioned to A` - Contract B successfully became Contract A
- `Terminated` - Contract ended without transition

**Termination_Reason__c Picklist Values:**
- `Did not meet initial contract requirements`
- `Did not meet extended contract requirements`
- `Voluntary resignation`
- `Other`

### 2.2 Formula Fields on Candidate__c

| Field | Type | Formula | Purpose |
|-------|------|---------|---------|
| `Days_Until_Contract_End__c` | Number | `IF(Extension_Granted__c, Extended_End_Date__c - TODAY(), Contract_End_Date__c - TODAY())` | Days remaining |
| `Contract_Deadline_Date__c` | Date | `IF(Extension_Granted__c, Extended_End_Date__c, Contract_End_Date__c)` | Current deadline |
| `Contract_Status_Indicator__c` | Text | Shows status color | Red/Yellow/Green |

### 2.3 Rollup Summary Fields (via Flow or Apex)

Since `Opportunity` links to `Contact` (not `Candidate__c`), we need Flow-based rollups:

| Field | Type | Source | Purpose |
|-------|------|--------|---------|
| `Total_FYC__c` | Currency | SUM of Opportunity.Commission via Contact__c | Track toward $2,500 requirement |
| `Opportunity_Count__c` | Number | COUNT of Opportunities via Contact__c | Track toward 5 submissions requirement |
| `FYC_Progress_Percent__c` | Percent | `(Total_FYC__c / 2500) * 100` | Visual progress |
| `Submissions_Progress_Percent__c` | Percent | `(Opportunity_Count__c / 5) * 100` | Visual progress |
| `Requirements_Met__c` | Checkbox | `Total_FYC__c >= 2500 AND Opportunity_Count__c >= 5` | Quick check |

### 2.4 Update to Contract_Type__c Picklist

Add `Contract A` to existing picklist (currently has: Contract B, Career Contract, Broker, College Intern)

---

## 3. Dashboard Design

### 3.1 Interview Tracking Dashboard

**Purpose:** Track interview completions by type with Current Month vs YTD toggle

**Components:**

| Widget | Type | Description |
|--------|------|-------------|
| Interview Completions by Type | Bar Chart | Ci-First, Align-2nd, Plan-3rd, Present-4th, Optional-5th |
| Interview Trend | Line Chart | Interviews completed over time |
| Interviews This Month | Metric | Total count for current month |
| YTD Interviews | Metric | Total count for year |
| Interviews by Recruiter | Table | Breakdown by recruiter |
| Interview Types Breakdown | Donut | Percentage by type |

**Filter:** Toggle between Current Month and Year to Date

### 3.2 Contract B Pipeline Dashboard

**Purpose:** Monitor Contract B agents through probation period

**Components:**

| Widget | Type | Description |
|--------|------|-------------|
| Active Contract B's | Metric | Count of active Contract B agents |
| At Risk (≤30 days, not meeting requirements) | List | URGENT attention needed |
| Approaching Deadline (≤60 days) | List | Need review |
| FYC Progress | Table | Each Contract B with FYC total, % of $2,500 |
| Submission Progress | Table | Each Contract B with opportunity count, % of 5 |
| Extensions Active | Metric | Contract B's in extension period |
| Days Until Contract End | Gauge | Average across active Contract B's |

**Columns for At Risk/Approaching Lists:**
- Candidate Name
- Contract Start Date
- Days Remaining
- FYC Total / $2,500
- Opportunities / 5
- Requirements Met (Y/N)
- Extension Status

### 3.3 Recruiting Metrics Dashboard

**Purpose:** Track recruiting outcomes and conversion rates

**Components:**

| Widget | Type | Description |
|--------|------|-------------|
| Recruited by Contract Type | Stacked Bar | Contract A vs Contract B by month |
| Contract B Transition Rate | Metric | % of B's that become A's |
| Contract B Termination Rate | Metric | % of B's terminated |
| Terminations by Reason | Donut | Breakdown by Termination_Reason__c |
| Transition Funnel | Funnel | Recruited → Active → Extended → Transitioned |
| Monthly Recruiting Trend | Line | Hires over time |
| Average Time to Transition | Metric | Days from B start to A transition |

---

## 4. Automation Design

### 4.1 Contract End Date Calculation (Flow)

**Trigger:** When `Candidate__c.Start_Date__c` is set AND `Contract_Type__c` = 'Contract B'

**Actions:**
1. Set `Contract_End_Date__c` = `Start_Date__c` + 4 months
2. Set `Contract_Outcome__c` = 'Active'

### 4.2 Extension Processing (Flow)

**Trigger:** When `Extension_Granted__c` changes to TRUE

**Actions:**
1. Set `Extension_Granted_Date__c` = TODAY()
2. Set `Extended_End_Date__c` = `Extension_Granted_Date__c` + 4 months

### 4.3 Transition Processing (Flow)

**Trigger:** When `Contract_Type__c` changes from 'Contract B' to any other value

**Actions:**
1. Set `Transition_to_A_Date__c` = TODAY()
2. Set `Contract_Outcome__c` = 'Transitioned to A'

### 4.4 FYC/Opportunity Rollup (Scheduled Flow)

**Runs:** Daily (or on Opportunity changes via Platform Event)

**Logic:**
1. For each Contract B Candidate with Contact__c populated:
   - Query Opportunities where Contact = Candidate__c.Contact__c
   - Sum Commission field → `Total_FYC__c`
   - Count records → `Opportunity_Count__c`
2. Update `Requirements_Met__c` checkbox

### 4.5 Contract Deadline Alert (Scheduled Flow)

**Runs:** Daily at 8 AM

**Logic:**
1. Find Contract B Candidates where:
   - `Contract_Outcome__c` = 'Active'
   - `Days_Until_Contract_End__c` <= 30
   - `Requirements_Met__c` = FALSE
2. Send alert email to Recruiter and Director
3. Create Task for review

---

## 5. Implementation Plan

### Phase 1: Contract Lifecycle Fields ✅ COMPLETE
- [x] Design document finalized
- [x] Create contract lifecycle fields on Candidate__c
- [x] Create formula fields for tracking
- [x] Add 'Contract A' to Contract_Type__c picklist
- [x] Deploy to Recruiting sandbox

### Phase 2: FYC/Opportunity Rollup ✅ COMPLETE
- [x] Build Apex service to calculate Total_FYC__c
- [x] Build Apex service to calculate Opportunity_Count__c
- [x] Create Requirements_Met__c formula
- [x] Test with sample data
- [x] Daily scheduled job at 6 AM (ContractBDailyRollupScheduler)

### Phase 3: Dashboards ✅ COMPLETE
- [x] Interview Tracking Dashboard (Current Month vs YTD toggle)
- [x] Contract B Pipeline Dashboard with progress bars
- [x] YTD Recruiting Metrics Dashboard (A/B recruited, transitions, terminations)
- [x] Contract A Progress section added
- [x] Add dashboards to home page

### Phase 4: Automation ✅ COMPLETE
- [x] Contract end date auto-calculation (Flow)
- [x] Extension processing flow
- [x] Transition tracking flow
- [x] FYC rollup scheduled job

### Phase 5: Documentation ✅ COMPLETE
- [x] User training guide (Contract-B-Lifecycle-Training.md)
- [x] Process documentation (this document)
- [x] Dashboard interpretation guide

---

## 6. Key Metrics Summary

| Metric | Target | Source |
|--------|--------|--------|
| Contract B FYC Requirement | $2,500 | Opportunity.Commission via Contact |
| Contract B Submission Requirement | 5 Opportunities | Opportunity count via Contact |
| Initial Contract Period | 4 months | Start_Date__c + 4 months |
| Extension Period | 4 months | Extension_Granted_Date__c + 4 months |
| Interview Types Tracked | 5 | Ci-First, Align-2nd, Plan-3rd, Present-4th, Optional-5th |

---

## 7. Data Flow Diagram

```
Candidate__c
    │
    ├── Contract_Type__c (Contract B)
    ├── Start_Date__c ─────────────────┐
    ├── Contract_End_Date__c ←─────────┘ (Start + 4 months)
    ├── Extension_Granted__c
    ├── Extension_Granted_Date__c
    ├── Extended_End_Date__c ←───────── (Extension Date + 4 months)
    ├── Contract_Outcome__c
    ├── Termination_Date__c
    ├── Termination_Reason__c
    ├── Transition_to_A_Date__c
    │
    └── Contact__c (Lookup)
            │
            └──► Contact
                    │
                    └──► Opportunity (many)
                            ├── Commission ──► SUM = Total_FYC__c
                            └── COUNT ──────► Opportunity_Count__c
```

---

## Approved Requirements

✅ Contract Type tracking (A vs B)
✅ Contract B 4-month probation tracking
✅ Extension grant tracking (+4 months)
✅ FYC requirement: $2,500 from Opportunity.Commission
✅ Submission requirement: 5 Opportunities
✅ Termination reason tracking
✅ Transition B→A tracking
✅ Interview metrics by type (Current Month vs YTD)
✅ Dashboard for Contract B pipeline with at-risk alerts
✅ Recruiting metrics dashboard (A vs B, transition rates, termination rates)