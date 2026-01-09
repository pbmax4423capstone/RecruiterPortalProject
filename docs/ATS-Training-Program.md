# Recruiter Portal ATS Training Program
## Comprehensive Guide for Recruiters and Sales Managers

**Version:** 1.0  
**Effective Date:** December 19, 2025  
**Document Owner:** Recruiting Operations  
**Target Audience:** Recruiters, Sales Managers, Recruiting Leadership

---

## Table of Contents

1. [Program Overview](#1-program-overview)
2. [System Overview](#2-system-overview)
3. [Getting Started](#3-getting-started)
4. [Module 1: Dashboard Navigation](#module-1-dashboard-navigation)
5. [Module 2: Candidate Management](#module-2-candidate-management)
6. [Module 3: Interview Tracking](#module-3-interview-tracking)
7. [Module 4: Contract B Lifecycle](#module-4-contract-b-lifecycle)
8. [Module 5: LinkedIn Integration](#module-5-linkedin-integration)
9. [Module 6: ALC Contact/Candidate Automation](#module-6-alc-contactcandidate-automation)
10. [Role-Specific Training](#role-specific-training)
11. [Quick Reference Cards](#quick-reference-cards)
12. [Assessment & Certification](#assessment--certification)
13. [Support Resources](#support-resources)

---

## 1. Program Overview

### Training Objectives

By completing this training program, you will be able to:

✅ Navigate the Recruiter Portal dashboard effectively  
✅ Create and manage candidate records  
✅ Track interviews through the recruiting pipeline  
✅ Monitor Contract B candidates through their lifecycle  
✅ Interpret recruiting metrics and identify at-risk candidates  
✅ Import candidates from LinkedIn using the browser extension  
✅ Generate reports for recruiting performance

### Training Paths

| Role | Required Modules | Estimated Time |
|------|------------------|------6) | 4-5 hours |
| **Sales Manager** | Modules 1, 2, 4, 6 | 2.5 hours |
| **Recruiting Leadership** | Modules 1, 4, 6 (monitoring focus) | 1.5 hours
| **Recruiting Leadership** | Modules 1, 4 (metrics focus) | 1 hour |

### Prerequisites

- Salesforce login credentials
- Access to the Recruiting org
- Chrome or Edge browser (for LinkedIn extension)
- Basic Salesforce navigation knowledge

---

## 2. System Overview

### What is the Recruiter Portal ATS?

The Recruiter Portal is a Salesforce-based Applicant Tracking System designed to:

- **Track Candidates** from initial contact through contracting
- **Monitor Contract B Agents** through their 4-month probationary period
- **Measure Recruiting Performance** with real-time metrics
- **Streamline Workflows** with automation and integrations

### Key Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    RECRUITER PORTAL ATS                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Candidate   │  │  Interview   │  │   Contract   │          │
│  │  Management  │  │   Tracking   │  │  B Pipeline  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   LinkedIn   │  │  Recruiting  │  │   Reports    │          │
│  │  Extension   │  │   Metrics    │  │ & Analytics  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Contract Types

| Contract Type | Description | Requirements |
|---------------|-------------|--------------|
| **Contract A** | Experienced agents | Prior industry experience |
| **Contract B** | Career changers | $2,500 FYC + 5 submissions in 4 months |
| **Career Contract** | Career contract agents | Varies |
| **Broker** | Broker agents | Varies |

---

## 3. Getting Started

### Step 1: Access the System

1. Open your web browser
2. Navigate to: `https://massmutual--recruiting.sandbox.lightning.force.com`
3. Log in with your Salesforce credentials
4. Click **App Launcher** (9 dots) → Search "Recruiter Portal"

### Step 2: Navigate to the Dashboard

The main dashboard is your home base. You'll see:

- **Contract B Pipeline Dashboard** - Monitor active Contract B agents
- **Interview Statistics** - Track interviews by type and time period
- **YTD Recruiting Metrics** - View year-to-date performance

### Step 3: Understand the Navigation

| Tab/Section | Purpose |
|-------------|---------|
| Home | Main dashboard with all metrics |
| Candidates | List of all candidate records |
| Interviews | Interview scheduling and tracking |
| Reports | Custom reports and analytics |

---

## Module 1: Dashboard Navigation

### Learning Objectives
- Interpret summary cards and their meanings
- Use the interview period toggle
- Read progress bars and status indicators
- Identify at-risk candidates quickly

### 1.1 Summary Cards

The top of the dashboard displays six key metrics:

| Card | What It Shows | Why It Matters |
|------|---------------|----------------|
| **Active Contract B** | Total Contract B agents currently in probation | Overall pipeline size |
| **Requirements Met** | Contract B's who achieved $2,500 FYC + 5 submissions | Ready for transition |
| **On Track** | Candidates progressing well | Low concern |
| **At Risk** | <30 days remaining, requirements not met | **Needs immediate attention** |
| **Total FYC** | Combined FYC of all active Contract B | Revenue indicator |
| **Avg FYC** | Average FYC per candidate | Performance benchmark |

**Interactive Features:**
- **Clickable Cards:** Click any summary card to open a detailed modal with filtered candidates
- **Auto-Refresh:** The dashboard automatically refreshes data to show real-time updates
- **Priority Focus:** The "At Risk" count should ideally be zero - prioritize these candidates for immediate attention

### 1.2 Interview Statistics Section

This section shows completed interviews by type:

**Interview Types:**
- **Attraction** - Initial attraction interview (Ci-First)
- **SI 1** - Structured Interview 1 (Align-2nd)
- **SI 2** - Structured Interview 2 (Plan-3rd)
- **SI 3** - Structured Interview 3 (Present-4th)
- **Career** - Career presentation (Optional-5th)
- **Total** - Sum of all interviews

**Period Toggle:**
- **Current Month** - Shows only this month's completed interviews
- **Year to Date** - Shows all interviews completed this calendar year

> 💡 **Pro Tip:** Click the toggle button to switch between views. Use YTD for performance reviews and Current Month for weekly planning.

> 📊 **Important:** The Current Month / YTD toggle **only affects the Interview Statistics section**. All other dashboard sections (Contract B Pipeline, YTD Recruiting Metrics, etc.) always show year-to-date data.

### 1.3 YTD Recruiting Metrics

This section tracks your recruiting funnel:

| Metric | Description | Target |
|--------|-------------|--------|
| **Contract A** | Experienced agents recruited YTD | Varies by region |
| **Contract B** | Career changers recruited YTD | Varies by region |
| **B→A Transitions** | Contract B's who transitioned to A | Higher is better |
| **Terminations** | Agents who left | Lower is better |
| **Transition Rate** | (Transitions / Total B's) × 100 | Goal: >70% |
| **Termination Rate** | (Terminations / Total B's) × 100 | Goal: <30% |

### 1.4 Contract A Progress Section

Track Contract A candidates through the interview pipeline:

| Stage | Description |
|-------|-------------|
| **Ci (1st)** | Initial contact interview |
| **Align (2nd)** | Alignment interview |
| **Plan (3rd)** | Planning interview |
| **Present (4th)** | Presentation interview |
| **Optional (5th)** | Additional interview if needed |

### 1.5 Pipeline Details Table

The bottom table shows individual Contract B candidates:

| Column | What to Look For |
|--------|------------------|
| **Candidate** | Click name to open record |
| **Manager** | Assigned sales manager |
| **Start** | Contract start date |
| **Days Left** | Days until deadline (⚠️ watch for low numbers) |
| **FYC** | Total commission earned |
| **FYC Progress** | Visual bar showing % of $2,500 |
| **Submissions** | X/5 opportunities submitted |
| **Status** | On Track / At Risk / Critical / Complete |

**Status Badge Colors:**
- 🟢 **Complete** - Requirements met
- 🟡 **On Track** - Progressing well
- 🟠 **At Risk** - <30 days, needs attention
- 🔴 **Critical** - <14 days, urgent action needed

---

## Module 2: Candidate Management

### Learning Objectives
- Create new candidate records
- Update candidate information
- Link contacts to candidates
- Track candidate progress through stages

### 2.1 Creating a New Candidate

**Method 1: From Dashboard (Recommended)**

1. Navigate to the Recruiter Dashboard
2. Click **Create New Candidate** button (4th button in dashboard header)
3. Fill in the modal form:
   - **Required Fields:**
     - Full Name
     - Email Address
   - **Optional Fields:**
     - Phone Number
     - Position (dropdown)
     - Lead Source (dropdown)
     - Initial Notes (textarea)
4. Click **Create Candidate**
5. Modal closes and candidate is created

**Position Options:**
- Insurance Agent (default)
- Senior Insurance Agent
- Insurance Sales Representative
- Account Manager
- Team Lead
- Sales Manager
- Other

**Lead Source Options:**
- Recruiter Portal (default)
- LinkedIn
- Indeed
- Monster
- Employee Referral
- Company Website
- Job Fair
- Other

**Method 2: From Candidates Tab**

1. Click **Candidates** tab
2. Click **New** button
3. Select Record Type: **Candidate**
4. Fill in required fields:
   - First Name
   - Last Name
   - Contract Type
   - Status
   - Recruiter (defaults to you)
5. Click **Save**

**Method 3: LinkedIn Extension** (See Module 5)

### 2.2 Essential Candidate Fields

| Field | Description | When to Update |
|-------|-------------|----------------|
| **First Name / Last Name** | Candidate's name | At creation |
| **Contract Type** | Contract A, B, Career, Broker | At creation or transition |
| **Status** | Active, Terminated, etc. | When status changes |
| **Start Date** | Contract start date | When contracted |
| **Contact** | Linked Contact record | After contracting |
| **Recruiter** | Assigned recruiter | At creation |
| **Sales Manager** | Assigned manager | When assigned |

### 2.3 Candidate Stages (Highest Level Achieved)

Track candidates through the recruiting pipeline:

```
0-Prequal → Ci(1st) → Align(2nd) → Plan(3rd) → Present(4th) → Optional(5th) → 6-Offer Acc → 7-Contracted
```

**Stage Descriptions:**

| Stage | Description | Next Step |
|-------|-------------|-----------|
| **0-Prequal** | Initial qualification | Schedule Ci interview |
| **Ci(1st)** | Contact interview completed | Schedule Align interview |
| **Align(2nd)** | Alignment interview completed | Schedule Plan interview |
| **Plan(3rd)** | Planning interview completed | Schedule Present interview |
| **Present(4th)** | Presentation completed | Optional or Offer |
| **Optional(5th)** | Additional interview | Make offer |
| **6-Offer Acc** | Offer accepted | Begin contracting |
| **7-Contracted** | Fully contracted | Monitor lifecycle |

### 2.4 Updating Candidate Records

1. Open the candidate record
2. Click **Edit** or click directly on the field
3. Make your changes
4. Click **Save**

> ⚠️ **Important:** Changes save immediately when clicking outside a field in Lightning Experience.

---

## Module 3: Interview Tracking

### Learning Objectives
- Schedule interviews
- Record interview outcomes
- Track interview completion by type
- Manage interview reschedules

### 3.1 Interview Types

| Type | Purpose | Typical Duration |
|------|---------|------------------|
| **Ci-First** | Initial contact, assess interest | 30 min |
| **Align-2nd** | Deeper alignment discussion | 45-60 min |
| **Plan-3rd** | Career planning | 60 min |
| **Present-4th** | Final presentation | 60 min |
| **Optional-5th** | Additional if needed | 30-60 min |

### 3.2 Scheduling an Interview

**Method 1: From Dashboard (Recommended)**

1. Navigate to the Recruiter Dashboard
2. Click **Schedule Interview** button (5th button in dashboard header)
3. Fill in the modal form:
   - **Required Fields:**
     - Candidate (lookup field - search and select)
     - Interview Type (picklist)
     - Scheduled Date/Time (datetime field)
   - **Optional Fields:**
     - Interviewer(s)
     - Notes
4. Click **Schedule Interview**
5. Modal closes and interview is created

**Interview Type Options:**
- **Attraction Interview (Ci-First)** - Initial contact to assess interest
- **SI1 (Align-2nd)** - First structured interview to discuss alignment
- **SI2 (Plan-3rd)** - Second structured interview for career planning
- **SI3 (Present-4th)** - Third structured interview with final presentation
- **Career (Optional-5th)** - Optional career presentation if needed

**Method 2: From Candidate Record**

1. Navigate to the Candidate record
2. Find the **Interviews** related list
3. Click **New**
4. Fill in:
   - Interview Type
   - Scheduled Date/Time
   - Interviewer
   - Location/Meeting Link
5. Click **Save**

> ⚠️ **Important:** Candidate creation and interview scheduling are **separate steps**. You cannot schedule an interview from within the Create Candidate modal.

### 3.3 Recording Interview Completion

After conducting an interview:

1. Open the Interview record
2. Update **Status** to "Completed"
3. Add any notes in the Notes field
4. Click **Save**

> 📝 **Note:** The system automatically tracks the completion date when you change the status to "Completed". No manual date entry is needed.

### 3.4 Interview Best Practices

✅ **Do:**
- Schedule interviews promptly after previous stage completion
- Record completion dates accurately (affects metrics)
- Add meaningful notes for handoff to sales managers

❌ **Don't:**
- Leave interviews in "Scheduled" status after completion
- Schedule multiple interview types for same day
- Forget to update the candidate's Highest Level Achieved

---

## Module 4: Contract B Lifecycle

### Learning Objectives
- Understand Contract B requirements
- Monitor FYC and submission progress
- Process extensions when appropriate
- Handle transitions and terminations

### 4.1 Contract B Requirements

To transition from Contract B to Contract A, candidates must achieve:

| Requirement | Target | Timeframe |
|-------------|--------|-----------|
| **FYC (First Year Commission)** | $2,500 | 4 months |
| **Business Submissions** | 5 opportunities | 4 months |

### 4.2 Contract B Timeline

```
START DATE                    4 MONTHS                      8 MONTHS (if extended)
    │                            │                              │
    ▼                            ▼                              ▼
┌───────┐                  ┌───────────┐                  ┌───────────┐
│ Begin │ ──────────────► │ Decision  │ ──────────────► │  Final    │
│       │                  │  Point    │   (Extension)   │ Decision  │
└───────┘                  └───────────┘                  └───────────┘
                                │                              │
                    ┌───────────┼───────────┐                  │
                    ▼           ▼           ▼                  ▼
               Transition  Extension  Termination         Transition
                to A ✓     Granted    (Initial)          or Termination
```

### 4.3 Understanding Progress Fields

**FYC Progress:**
- Calculated from Opportunities linked to candidate's Contact
- Updates daily via scheduled job (6 AM) or when opportunities change
- Formula: (Total FYC / $2,500) × 100

**Submission Progress:**
- Count of Opportunities linked to candidate's Contact
- Formula: (Opportunity Count / 5) × 100

### 4.4 Granting an Extension

When a Contract B has pipeline but hasn't met requirements:

1. Open the Candidate record
2. Check the **Extension Granted** checkbox
3. Save the record

**Automatic Actions:**
- Extension Granted Date = Today
- Extended End Date = Today + 4 months
- Days remaining recalculates

> 📋 **When to Grant Extensions:**
> - Candidate has active pipeline/opportunities
> - Close to meeting one or both requirements
> - Demonstrates commitment and progress

### 4.5 Processing a Transition (B → A)

When a Contract B meets requirements:

1. Open the Candidate record
2. Change **Contract Type** from "Contract B" to "Contract A"
3. Save the record

**Automatic Actions:**
- Transition to A Date = Today
- Contract Outcome = "Transitioned to A"

### 4.6 Recording a Termination

When a Contract B doesn't meet requirements:

1. Open the Candidate record
2. Set **Status** = "Terminated"
3. Set **Termination Date** = Date of termination
4. Set **Termination Reason**:
   - Did not meet initial contract requirements
   - Did not meet extended contract requirements
   - Voluntary resignation
   - Other
5. Save the record

> ⚠️ **Critical:** The Termination Date field MUST be populated for the termination to appear in YTD metrics.

### 4.7 Monitoring At-Risk Candidates

**Daily Review Process:**

1. Open the Contract B Pipeline Dashboard
2. Check the "At Risk" count in summary cards
3. Review the Pipeline Details table
4. Filter/sort by "Days Left" (ascending)
5. Take action on candidates with <30 days remaining

**Action Items for At-Risk Candidates:**

| Days Remaining | Action |
|----------------|--------|
| 30 days | Schedule check-in with candidate and manager |
| 14 days | Escalate to leadership, discuss extension |
| 7 days | Final decision: extend or prepare termination |
| 0 days | Process extension or termination |

---

## Module 5: LinkedIn Integration

### Learning Objectives
- Install the LinkedIn browser extension
- Import candidates from LinkedIn profiles
- Troubleshoot common issues

### 5.1 Installing the Extension

**For Chrome:**
1. Contact your administrator for the extension files
2. Open Chrome → `chrome://extensions/`
3. Enable **Developer mode**
4. Click **Load unpacked**
5. Select the `chrome-extension-linkedin` folder

**For Edge:**
1. Contact your administrator for the extension files
2. Open Edge → `edge://extensions/`
3. Enable **Developer mode**
4. Click **Load unpacked**
5. Select the `edge-extension-linkedin` folder

### 5.2 First-Time Setup

1. Click the extension icon in your browser toolbar
2. Click **Connect to Salesforce**
3. Log in with your Salesforce credentials
4. Authorize the application
5. You'll see "Connected" when successful

### 5.3 Importing a Candidate

1. Navigate to a LinkedIn profile (linkedin.com/in/username)
2. Click the extension icon
3. Verify the extracted information:
   - First Name
   - Last Name
   - LinkedIn URL (if available)
4. Click **Create Candidate in Salesforce**
5. A new tab opens with the created candidate record

### 5.4 Automatic Field Population

When you create a candidate via the extension:

| Field | Value |
|-------|-------|
| First Name | Extracted from LinkedIn |
| Last Name | Extracted from LinkedIn |
| Agency | Capstone Financial |
| Position | Financial Advisor |
| Status | SOURCED |
| Next Step | Outreach |
| Recruiter | Your user record |
| LinkedIn Profile | Profile URL |

### 5.5 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Failed to connect" | Verify Connected App is set up correctly |
| Name not extracted | Manually enter the name |
| "Access token expired" | Click "Disconnect" then reconnect |
| Extension not working | Refresh the LinkedIn page |

---

## Module 6: ALC Contact/Candidate Automation

**Learning Objectives:**
- Understand how the ALC automation system works
- Know what happens when an ALC record is created
- Learn to use the monitoring dashboard
- Resolve automation errors
- Understand Contact/Candidate relationship requirements

**Time Required:** 30 minutes

---

### 6.1 What is ALC Automation?

The **ALC Contact/Candidate Automation** system automatically creates and links Contact and Candidate records whenever a new ALC (Agent Licensing & Contracting) record is created in Salesforce.

**Benefits:**
- ✅ **No Manual Entry** - Contact and Candidate records are created automatically
- ✅ **Data Consistency** - Single source of truth from ALC data
- ✅ **No Duplicates** - System matches existing Contacts by email/phone
- ✅ **Faster Onboarding** - Agents enter the system immediately

### 6.2 How It Works

#### Automatic Processing Flow

```
1. ALC Created → 2. System Checks → 3. Matches/Creates Contact → 4. Creates Candidate → 5. Links Records
```

**Step-by-Step:**

1. **You create an ALC record** with agent information
2. **System filters** by record type (Career, Broker, NRF, Registration only)
3. **System checks** for existing Contact with same email or phone
4. **If Contact exists:** Links to ALC
5. **If Contact doesn't exist:** Creates new Contact from ALC data
6. **System creates Candidate** with appropriate Contract Type
7. **All records linked** automatically

#### What Gets Created?

| ALC Record Type | Contact Created? | Candidate Contract Type |
|-----------------|------------------|-------------------------|
| **Career** | ✅ Yes | Career Contract |
| **Broker** | ✅ Yes | Broker |
| **NRF** | ✅ Yes | (blank) |
| **Registration** | ✅ Yes | (blank) |

#### What Gets Matched?

The system searches for existing Contacts using:

**Priority 1 - Email Match:**
- Compares ALC email to Contact email
- Case-insensitive (john@example.com = JOHN@example.com)
- Exact match required

**Priority 2 - Phone Match:**
- Compares standardized 10-digit phone numbers
- Strips formatting: (555) 123-4567 → 5551234567
- Handles 11-digit with country code: 1-555-123-4567 → 5551234567

**Important:** If neither email nor phone match, a **new Contact is created**.

### 6.3 Field Mapping

#### ALC → Contact Mapping

| ALC Field | → | Contact Field |
|-----------|---|---------------|
| First Name | → | FirstName |
| Last Name | → | LastName |
| Email | → | Email |
| Phone | → | Phone |
| Street | → | MailingStreet |
| City | → | MailingCity |
| State | → | MailingState |
| Zip | → | MailingPostalCode |

#### Candidate Defaults

All auto-created Candidates start with:
- **Status:** "Contracting Started"
- **Record Type:** Candidate
- **Contact:** Linked to the Contact
- **Contract Type:** Based on ALC Record Type (see table above)

### 6.4 When Automation Doesn't Run

The system **SKIPS** ALCs in these cases:

❌ **Excluded Stages:**
- CANCELLED
- TERMINATED
- Cancelled
- Terminated

❌ **Excluded Record Types:**
- Any record type not in the list (Career, Broker, NRF, Registration)

**Why?** No need to create Contact/Candidate for cancelled or terminated contracts.

### 6.5 Using the Monitoring Dashboard

#### Accessing the Dashboard

**Navigation:** App Launcher (⋮⋮⋮) → Recruiter Portal → **ALC Relationship Monitor**

#### Dashboard Sections

**1. Summary Cards**

Quick metrics at a glance:
- **ALCs Without Contacts** - How many ALCs are missing Contact links (by record type)
- **ALCs Without Candidates** - How many ALCs are missing Candidate links
- **Candidates Without Contacts** - Orphaned Candidate records
- **Recent Errors** - Failed operations in the last 7 days

**2. Relationship Gaps Table**

Shows ALCs that are missing Contact or Candidate relationships:

| What You See | What It Means |
|--------------|---------------|
| ALC Name | Link to the ALC record |
| Record Type | Career, Broker, NRF, or Registration |
| Email/Phone | Contact information from ALC |
| Missing | "Contact", "Candidate", or "Both" |
| Fix Button | Click to trigger backfill for that ALC |

**3. Candidates Without Contacts**

Lists Candidate records that don't have a linked Contact:

| What You See | What It Means |
|--------------|---------------|
| Candidate Name | Link to Candidate record |
| First/Last Name | From the Candidate |
| Related ALC | Link to the ALC (if exists) |
| Create Contact Button | Click to create missing Contact |

**4. Audit Logs**

Complete history of automation operations:

| What You See | What It Means |
|--------------|---------------|
| Operation Type | CONTACT_CREATED, CANDIDATE_CREATED, etc. |
| Success | ✅ Success or ❌ Error |
| Created Date | When the operation occurred |
| Actions | View Details, Mark Resolved |

**Filters:**
- **All Logs** - Show everything
- **Errors Only** - Show only failed operations
- **Successes Only** - Show only successful operations
- **Unresolved Errors** - Show errors that haven't been fixed

#### Auto-Refresh Feature

The dashboard automatically refreshes every 30 seconds to show real-time data.

**To disable:** Click the "Auto-Refresh" toggle at the top.

### 6.6 Resolving Errors

#### Common Error: "ALC has no Email or Phone"

**Cause:** ALC record is missing both email and phone.

**Solution:**
1. Click on the ALC name in the Relationship Gaps table
2. Add either an Email or Phone number
3. Click **Save**
4. Return to the monitor and click **Fix** button
5. System will re-process the ALC

#### Common Error: "Unable to create Contact: Required fields missing"

**Cause:** ALC is missing First Name or Last Name.

**Solution:**
1. Open the ALC record
2. Populate First Name and Last Name fields
3. Click **Save**
4. Click **Fix** button in the monitor dashboard

#### Common Error: "Duplicate Contacts detected"

**Cause:** Multiple Contacts exist with the same email.

**Solution:**
1. Navigate to Contacts
2. Search for the email address
3. Merge duplicate Contacts using Salesforce merge tool
4. Return to monitor and click **Fix** button

#### Using the "View Details" Button

When you see an error in the Audit Logs:

1. Click **View Details** next to the error
2. Read the Error Message to understand what went wrong
3. Check the Stack Trace for technical details (if needed)
4. Note the ALC, Contact, and Candidate IDs involved
5. Fix the underlying issue
6. Click **Mark Resolved** after fixing

### 6.7 Best Practices

✅ **Always Include Email or Phone**
- At least one is required for matching
- Both are recommended for best results

✅ **Use Standard Phone Formats**
- (555) 123-4567
- 555-123-4567
- 1-555-123-4567
All of these work!

✅ **Check for Duplicates Before Creating ALCs**
- Search for existing Contacts by email
- Link to existing Contact instead of creating duplicate ALC

✅ **Monitor the Dashboard Weekly**
- Review Summary Cards for gaps
- Check Error logs for issues
- Resolve errors promptly

✅ **Populate First and Last Name**
- Required for Contact creation
- Ensure they're correct before saving ALC

### 6.8 Hands-On Exercise

**Exercise: Create an ALC and Verify Automation**

1. **Create a Test ALC:**
   - Record Type: Career
   - First Name: Test
   - Last Name: Agent
   - Email: testagent@example.com
   - Phone: (555) 123-4567
   - Stage: ACTIVE

2. **Save the ALC**

3. **Verify Automation:**
   - Check Contact__c field - should be populated
   - Check Candidate__c field - should be populated
   - Click on Contact name - verify details match
   - Click on Candidate name - verify Contract Type = "Career Contract"

4. **View Audit Log:**
   - Go to ALC Relationship Monitor
   - Click "Audit Logs" section
   - Find your ALC in recent logs
   - Verify Operation Type = "CONTACT_CREATED" or "CONTACT_MATCHED"

5. **Cleanup:**
   - Delete the test ALC, Contact, and Candidate records

### 6.9 Knowledge Check

**Question 1:** What happens when you create a Career ALC with an email that matches an existing Contact?

- A) A new Contact is created anyway
- B) The existing Contact is linked to the ALC ✅
- C) The ALC creation fails
- D) Nothing happens

**Answer:** B - The existing Contact is linked to avoid duplicates.

---

**Question 2:** Which ALC record types trigger the automation?

- A) All record types
- B) Only Career
- C) Career, Broker, NRF, Registration ✅
- D) Only Broker and Career

**Answer:** C - Only these four record types trigger automation.

---

**Question 3:** What is the Candidate Status for all auto-created Candidates?

- A) SOURCED
- B) Contracting Started ✅
- C) Active
- D) New

**Answer:** B - All auto-created Candidates start with "Contracting Started".

---

**Question 4:** Where do you go to view automation errors?

- A) Setup → Debug Logs
- B) ALC Relationship Monitor → Audit Logs ✅
- C) Reports → Automation Errors
- D) System Logs

**Answer:** B - The ALC Relationship Monitor has an Audit Logs section.

---

**Question 5:** If an ALC has both email and phone, which does the system check first for matching?

- A) Phone
- B) Email ✅
- C) Both simultaneously
- D) Neither - always creates new Contact

**Answer:** B - Email is checked first, then phone if no email match.

### 6.10 Key Takeaways

✅ **Automation is Automatic** - No action required when creating ALCs  
✅ **Email/Phone Required** - At least one needed for matching  
✅ **Intelligent Matching** - Prevents duplicate Contacts  
✅ **Monitor Dashboard** - Check weekly for issues  
✅ **Quick Resolution** - Use Fix buttons to resolve gaps  
✅ **Complete Audit Trail** - Every operation is logged  

**For detailed technical documentation, see:** [ALC-RELATIONSHIP-AUTOMATION.md](ALC-RELATIONSHIP-AUTOMATION.md)

---

## Role-Specific Training

### For Recruiters

**Primary Responsibilities:**
- Source and create candidate records using "Create New Candidate" button
- Schedule interviews using "Schedule Interview" button (separate from candidate creation)
- Monitor candidate pipeline progress
- Use LinkedIn extension for efficient sourcing
- Update interview statuses to "Completed" after conducting interviews
- Update candidate stages as they progress

**Daily Workflow:**
1. Check Dashboard for new at-risk candidates
2. Follow up on scheduled interviews
3. **Update completed interview statuses** (change Status to "Completed" - system tracks date automatically)
4. Source new candidates via LinkedIn or "Create New Candidate" button
5. Schedule follow-up interviews using "Schedule Interview" button
6. Review and update candidate stages

**Weekly Review:**
- Review YTD interview counts vs goals
- Check transition and termination rates
- Identify pipeline gaps by stage

### For Sales Managers

**Primary Responsibilities:**
- Monitor Contract B agents on your team
- Track FYC and submission progress
- Recommend extensions or escalate concerns
- Support candidates in meeting requirements

**Daily Workflow:**
1. Review Contract B Pipeline for your candidates
2. Check "Days Left" for upcoming deadlines
3. Review FYC and submission progress bars
4. Coach candidates who are behind

**Key Metrics to Watch:**
- FYC Progress (should increase weekly)
- Submission Count (should reach 5 within timeline)
- Days Remaining (plan ahead for deadlines)

**Escalation Triggers:**
- Candidate at <30 days with <50% progress
- No new submissions in 2+ weeks
- FYC flat for 3+ weeks

---

## Quick Reference Cards

### Card 1: Status Meanings

| Status | Meaning | Action Required |
|--------|---------|-----------------|
| 🟢 **Complete** | Requirements met | Transition to A |
| 🟡 **On Track** | Good progress | Continue monitoring |
| 🟠 **At Risk** | <30 days, behind | Immediate attention |
| 🔴 **Critical** | <14 days, behind | Urgent escalation |

### Card 2: Common Tasks

| Task | Steps |
|------|-------|
| Create Candidate | Dashboard → "Create New Candidate" button → Fill required fields (Name, Email) → Click "Create Candidate" |
| Schedule Interview | Dashboard → "Schedule Interview" button → Select candidate → Choose type → Set date/time → Click "Schedule Interview" |
| Complete Interview | Open interview record → Status = "Completed" → Save (date tracked automatically) |
| Grant Extension | Candidate → Check Extension Granted → Save |
| Record Termination | Candidate → Status = Terminated → Fill dates/reason → Save |

### Card 3: Key Formulas

| Field | Formula |
|-------|---------|
| Days Left | Contract End Date - Today (or Extended End Date if extension) |
| FYC Progress % | (Total FYC / $2,500) × 100 |
| Submissions Progress % | (Opportunity Count / 5) × 100 |
| Requirements Met | FYC ≥ $2,500 AND Submissions ≥ 5 |

### Card 4: Interview Type Codes

| Code | Full Name |
|------|-----------|
| Ci | Contact Interview (1st) |
| Align | Alignment Interview (2nd) |
| Plan | Planning Interview (3rd) |
| Present | Presentation Interview (4th) |
| Optional | Optional Interview (5th) |

---

## Assessment & Certification

### Knowledge Check Questions

**Module 1: Dashboard Navigation**
1. What does the "At Risk" summary card indicate?
2. How do you switch between Current Month and YTD views?
3. What does a red "Critical" status badge mean?

**Module 2: Candidate Management**
1. What are the required fields when creating a candidate?
2. What is the correct order of candidate stages?
3. When should you update the "Highest Level Achieved" field?

**Module 3: Interview Tracking**
1. How many interview types are there?
2. What fields must be updated when completing an interview?
3. Why is accurate completion date important?

**Module 4: Contract B Lifecycle**
1. What are the two requirements for Contract B to transition?
2. How long is the initial contract period?
3. What happens automatically when you check "Extension Granted"?

**Module 5: LinkedIn Integration**
1. How do you connect the extension to Salesforce?
2. What fields are auto-populated when importing?
3. What should you do if the name isn't extracted?

### Certification Requirements

To receive certification:
- [ ] Complete all training modules
- [ ] Score 80% or higher on knowledge check
- [ ] Demonstrate system proficiency (practical exercise)
- [ ] Complete 5 supervised candidate entries

---

## Support Resources

### Getting Help

| Issue Type | Contact |
|------------|---------|
| Login/Access Issues | IT Help Desk |
| Training Questions | Recruiting Operations |
| System Bugs | Salesforce Administrator |
| Process Questions | Your Manager |

### Helpful Links

- [Contract B Lifecycle Training Guide](Contract-B-Lifecycle-Training.md)
- [System Design Documentation](LOXO-ATS-Design.md)
- [LinkedIn Extension Setup](../chrome-extension-linkedin/README.md)

### Scheduled System Updates

| Event | Time | Impact |
|-------|------|--------|
| FYC Rollup Job | 6:00 AM Daily | FYC/Submissions recalculated |
| Salesforce Maintenance | Sundays 2-6 AM | System may be slow |

### Feedback & Suggestions

We're continuously improving the Recruiter Portal. Submit feedback to:
- Email: recruiting-ops@company.com
- Slack: #recruiter-portal-support

---

## Appendix A: Glossary

| Term | Definition |
|------|------------|
| **ATS** | Applicant Tracking System |
| **Contract B** | New-to-industry financial advisor contract with 4-month probation |
| **FYC** | First Year Commission - commission earned in first year |
| **Pipeline** | Active opportunities/prospects a candidate is working |
| **Submission** | A business opportunity submitted for processing |
| **Transition** | Moving from Contract B to Contract A status |
| **YTD** | Year to Date - from January 1 to current date |

---

## Appendix B: System Requirements

| Component | Requirement |
|-----------|-------------|
| Browser | Chrome 90+ or Edge 90+ |
| Screen Resolution | 1920×1080 recommended |
| Internet | Stable broadband connection |
| Salesforce License | Salesforce Platform or higher |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Dec 19, 2025 | Initial release |

---

*Thank you for completing the Recruiter Portal ATS Training Program!*
