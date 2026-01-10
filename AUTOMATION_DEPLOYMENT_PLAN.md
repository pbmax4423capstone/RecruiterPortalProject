# Automation Deployment to Production
**Date:** January 9, 2026  
**Status:** Ready for Deployment

---

## ✅ Verification Results

### User ID Verification (Production)
| User Name | Production ID | Flow Reference | Status |
|-----------|---------------|----------------|--------|
| Rachyll Tenny | `0055f00000DqpnpAAB` | ALC_Application_Follow_Up_Reminders | ✅ Matches |
| Rachyll Tenny | `0055f00000DqpnpAAB` | Background_Check_Follow_Up_Tasks | ✅ Matches |
| Anna Haney | `0055f00000EYNKiAAP` | ALC_Task_Creation_Subflow | ⚠️ **Needs Update** |

**Action Required:** Anna's user ID in ALC_Task_Creation_Subflow needs to be updated from `0055f00000EYNKi` to `0055f00000EYNKiAAP`.

---

## 📋 Pre-Deployment Checklist

### 1. Update Schedule Start Dates ✅ REQUIRED
All three scheduled flows currently have `startDate>2025-12-10</startDate>` and need to be updated to **2026-01-09**:

- [ ] ALC_Application_Follow_Up_Reminders.flow-meta.xml
- [ ] Background_Check_Follow_Up_Tasks.flow-meta.xml
- [ ] Interview_48hr_Reminders.flow-meta.xml

**Rationale:** The flows should calculate from the ALC record's stage entry date (today), not a historical start date.

### 2. Update Anna's User ID ✅ REQUIRED
- [ ] ALC_Task_Creation_Subflow.flow-meta.xml - Update Anna's user ID from `0055f00000EYNKi` to `0055f00000EYNKiAAP`

### 3. Verify Email Templates ✅ CONFIRMED
All 7 email templates in `Candidate_Outreach` folder:
- [x] Use correct merge field syntax: `{!Contact.FirstName}`
- [x] Sender: help@capstonetechsupport.com
- [x] BCC: pbaker@capstone.financial, rtenny@capstone.financial

### 4. Check Candidate_Stage_Email_Automation Flow Status
- [ ] Verify if flow is Active or Draft in Production
- [ ] Activate if needed (currently shown as Draft in research)

---

## 🚀 Deployment Steps

### Phase 1: Update Flow Metadata (Local Changes)

**Update Start Dates to Today (2026-01-09):**
1. Update `ALC_Application_Follow_Up_Reminders.flow-meta.xml` line 530
2. Update `Background_Check_Follow_Up_Tasks.flow-meta.xml` line 266
3. Update `Interview_48hr_Reminders.flow-meta.xml` line 237

**Update Anna's User ID:**
4. Update `ALC_Task_Creation_Subflow.flow-meta.xml` line 71

### Phase 2: Deploy Scheduled Flows to Production

```powershell
# Deploy ALC Application Follow-Up Flow
sf project deploy start --source-dir "force-app\main\default\flows\ALC_Application_Follow_Up_Reminders.flow-meta.xml" --target-org ProductionCapstone --wait 15

# Deploy Background Check Flow
sf project deploy start --source-dir "force-app\main\default\flows\Background_Check_Follow_Up_Tasks.flow-meta.xml" --target-org ProductionCapstone --wait 15

# Deploy Interview 48hr Reminders Flow
sf project deploy start --source-dir "force-app\main\default\flows\Interview_48hr_Reminders.flow-meta.xml" --target-org ProductionCapstone --wait 15

# Deploy ALC Task Creation Subflow (with updated Anna user ID)
sf project deploy start --source-dir "force-app\main\default\flows\ALC_Task_Creation_Subflow.flow-meta.xml" --target-org ProductionCapstone --wait 15
```

### Phase 3: Verify Record-Triggered Flows (Already Active)

Check that these flows are Active in Production:
```powershell
sf data query --query "SELECT DeveloperName, ProcessType, IsActive FROM FlowDefinitionView WHERE DeveloperName IN ('ALC_Broker_Task_Creation_Record_Triggered_Flow', 'ALC_NRF_Task_Creation_Record_Triggered_Flow')" --target-org ProductionCapstone
```

### Phase 4: Activate Candidate Stage Email Flow (If Needed)

```powershell
# First, check current status
sf data query --query "SELECT DeveloperName, ProcessType, IsActive FROM FlowDefinitionView WHERE DeveloperName = 'Candidate_Stage_Email_Automation'" --target-org ProductionCapstone

# If Draft, deploy as Active
sf project deploy start --source-dir "force-app\main\default\flows\Candidate_Stage_Email_Automation.flow-meta.xml" --target-org ProductionCapstone --wait 15
```

### Phase 5: Deploy Email Templates (If Not Already Deployed)

```powershell
sf project deploy start --source-dir "force-app\main\default\email\Candidate_Outreach" --target-org ProductionCapstone --wait 15
```

---

## 🧪 Testing Plan

### Test 1: ALC Application Follow-Up
**Objective:** Verify 5-day, 10-day, and 12-day reminders work

**Test Data:**
- Create test ALC record with Stage = "Initial Form Sent"
- Set `CreatedDate` to trigger conditions (or wait for scheduled run)

**Expected Results:**
- 5 days: Email sent to applicant
- 10 days: Urgent email sent to applicant
- 12 days: Task created for Rachyll Tenny (ID: `0055f00000DqpnpAAB`)

**Verification Queries:**
```sql
-- Check ALC records eligible for follow-up
SELECT Id, Name, First_Name__c, Last_Name__c, Stage__c, CreatedDate, 
       Personal_Email_Address__c
FROM ALC__c
WHERE Stage__c = 'Initial Form Sent'
  AND Personal_Email_Address__c != null
ORDER BY CreatedDate DESC
LIMIT 10

-- Check EmailMessage logs
SELECT Id, ToAddress, Subject, CreatedDate, Status
FROM EmailMessage
WHERE Subject LIKE '%Complete Your%Application%'
ORDER BY CreatedDate DESC
LIMIT 20

-- Check Tasks created
SELECT Id, Subject, OwnerId, Owner.Name, Description, Priority, CreatedDate
FROM Task
WHERE Subject LIKE '%URGENT: Follow up on incomplete ALC application%'
ORDER BY CreatedDate DESC
LIMIT 10
```

### Test 2: Background Check Follow-Up
**Objective:** Verify task creation after 12 days in "In Background" stage

**Test Data:**
- ALC record with `Stage__c = 'In Background'`
- `In_Background_Since__c` = 12+ days ago
- `Background_Check_Task_Created__c = false`

**Expected Results:**
- Task created for Rachyll Tenny
- Email sent to rtenny@financialguide.com
- `Background_Check_Task_Created__c` flag set to true

**Verification Queries:**
```sql
-- Check ALC records eligible
SELECT Id, Name, First_Name__c, Last_Name__c, Stage__c, 
       In_Background_Since__c, Background_Check_Task_Created__c,
       DAYS_SINCE(In_Background_Since__c) as DaysInBackground
FROM ALC__c
WHERE Stage__c = 'In Background'
  AND In_Background_Since__c != null
  AND Background_Check_Task_Created__c = false
  AND DAYS_SINCE(In_Background_Since__c) >= 12
ORDER BY In_Background_Since__c
LIMIT 10

-- Check Tasks
SELECT Id, Subject, Description, OwnerId, Owner.Name, Priority, CreatedDate
FROM Task
WHERE Subject = 'Background Check Follow-Up Required'
ORDER BY CreatedDate DESC
LIMIT 10
```

### Test 3: Interview 48hr Reminders
**Objective:** Verify email sent 48 hours before interview

**Test Data:**
- Interview record with `Date_Time_Scheduled__c` = 48-72 hours in future
- Status != "Cancelled" or "Completed"
- `Reminder_48hr_Sent__c = false`
- Candidate has valid email

**Expected Results:**
- Email sent to candidate with interview details
- Confirmation link generated
- `Reminder_48hr_Sent__c` flag set to true
- EmailMessage record created

**Verification Queries:**
```sql
-- Check upcoming interviews eligible for reminders
SELECT Id, Name, Date_Time_Scheduled__c, Interview_Type__c, Status__c,
       Reminder_48hr_Sent__c, Candidate__r.First_Name__c, 
       Candidate__r.Last_Name__c, Candidate__r.Email__c
FROM Interview__c
WHERE Date_Time_Scheduled__c >= :NOW
  AND Date_Time_Scheduled__c <= :TWO_DAYS_FROM_NOW
  AND Status__c NOT IN ('Cancelled', 'Completed')
  AND Reminder_48hr_Sent__c = false
  AND Candidate__r.Email__c != null
ORDER BY Date_Time_Scheduled__c
LIMIT 10

-- Check EmailMessage logs
SELECT Id, ToAddress, Subject, CreatedDate, Status
FROM EmailMessage
WHERE Subject = 'Interview Reminder - Please Confirm Your Attendance'
ORDER BY CreatedDate DESC
LIMIT 20
```

### Test 4: ALC Task Creation (Record-Triggered)
**Objective:** Verify tasks created when ALC records are updated

**Test Data:**
- Update an ALC record with `Position__c = 'Broker'`
- Update an ALC record with `Position__c = 'Staff'` or `'Agent Assistant'`

**Expected Results:**
- Broker: Tasks created via A157_ALC_Broker_Task_Creation_Subflow
- Staff/Agent Assistant: Tasks created via ALC_NRF_Task_Creation_Subflow
- Tasks assigned to appropriate users (Anna for A007: `0055f00000EYNKiAAP`)

**Verification Queries:**
```sql
-- Check recently created tasks
SELECT Id, Subject, Description, OwnerId, Owner.Name, WhatId, What.Name, CreatedDate
FROM Task
WHERE CreatedDate = TODAY
  AND (Subject LIKE '%DocuSign%' 
    OR Subject LIKE '%Background Check%'
    OR Subject LIKE '%Broker Check%')
ORDER BY CreatedDate DESC
LIMIT 20
```

### Test 5: Candidate Stage Email Automation
**Objective:** Verify emails sent when candidates progress through stages

**Test Data:**
- Create new Candidate record with Email populated
- Update Candidate stage to: Ci_1st, Align (2nd), Plan_3rd, Present-4th, 6-Offer Acc, 7-Contracted

**Expected Results:**
- Email sent at each stage change
- Correct template used for each stage
- EmailMessage records created with BCC to pbaker@capstone.financial, rtenny@capstone.financial

**Verification Queries:**
```sql
-- Check recent candidate stage changes
SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Stage__c, LastModifiedDate
FROM Candidate__c
WHERE LastModifiedDate = TODAY
  AND Email__c != null
ORDER BY LastModifiedDate DESC
LIMIT 10

-- Check EmailMessage logs for stage emails
SELECT Id, ToAddress, Subject, CreatedDate, Status, BccAddress
FROM EmailMessage
WHERE (Subject LIKE '%Career Interview%'
   OR Subject LIKE '%Alignment Stage%'
   OR Subject LIKE '%Planning Stage%'
   OR Subject LIKE '%Presentation Stage%'
   OR Subject LIKE '%Welcome to Capstone%'
   OR Subject LIKE '%Contracting Complete%')
ORDER BY CreatedDate DESC
LIMIT 20
```

---

## 📊 Monitoring & Reporting Setup

### Email Send Tracking Query
Save this query as a Custom Report or execute regularly:

```sql
SELECT 
    Id,
    ToAddress,
    Subject,
    Status,
    CreatedDate,
    CreatedBy.Name,
    RelatedToId,
    RelatedTo.Name
FROM EmailMessage
WHERE CreatedDate = THIS_WEEK
  AND (Subject LIKE '%Reminder%'
    OR Subject LIKE '%URGENT%'
    OR Subject LIKE '%Interview%'
    OR Subject LIKE '%Career Interview%'
    OR Subject LIKE '%Alignment%'
    OR Subject LIKE '%Welcome to Capstone%')
ORDER BY CreatedDate DESC
```

### Task Creation Monitoring Query
Save this query as a Custom Report or execute regularly:

```sql
SELECT 
    Id,
    Subject,
    Description,
    Priority,
    Status,
    OwnerId,
    Owner.Name,
    WhatId,
    What.Name,
    What.Type,
    CreatedDate,
    CreatedBy.Name
FROM Task
WHERE CreatedDate = THIS_WEEK
  AND (Subject LIKE '%URGENT%'
    OR Subject LIKE '%Follow%up%'
    OR Subject LIKE '%Background Check%'
    OR Subject LIKE '%DocuSign%'
    OR Subject LIKE '%Broker Check%')
ORDER BY CreatedDate DESC
```

### Flow Execution Monitoring
Use Setup → Environments → Flows → Time-Based Workflow to monitor scheduled flows:
- Check "Last Run" timestamp
- Review "Status" (Success/Error)
- View "Failed Records" if any errors

### Apex Scheduler Monitoring
Navigate to: Setup → Apex Jobs → Scheduled Jobs
- Verify "Contract B Daily FYC Rollup" is scheduled
- Check "Next Run" time (should be 6:00 AM daily)
- Review job history for errors

---

## 🔧 Troubleshooting Guide

### Issue: Scheduled Flow Not Running
**Symptoms:** No emails sent, no tasks created
**Diagnosis:**
1. Check flow status: Setup → Flows → Find flow → Check "Active" checkbox
2. Check schedule: Verify start date and frequency in flow metadata
3. Check debug logs: Setup → Debug Logs → Create log for Automated Process user

**Resolution:**
```powershell
# Deactivate and reactivate flow
sf data update --sobject FlowDefinition --where "DeveloperName='ALC_Application_Follow_Up_Reminders'" --values "ActiveVersion=null" --target-org ProductionCapstone

# Deploy updated flow
sf project deploy start --source-dir "force-app\main\default\flows\ALC_Application_Follow_Up_Reminders.flow-meta.xml" --target-org ProductionCapstone --wait 15
```

### Issue: Emails Not Being Sent
**Symptoms:** EmailMessage records not created
**Diagnosis:**
1. Check Org-Wide Email Address: Setup → Organization-Wide Addresses → Verify "noreply@financialguide.com" exists
2. Check Deliverability: Setup → Email Administration → Deliverability → Set to "All Email"
3. Check email field population: Verify candidate/ALC records have valid email addresses

**Resolution:**
- If Org-Wide Email missing, create it or update flow to use verified sender
- If deliverability is restricted, change to "All Email" or "System Email Only"

### Issue: Tasks Assigned to Wrong User
**Symptoms:** Tasks not appearing for Rachyll Tenny or Anna
**Diagnosis:**
1. Verify user IDs in flows match Production users
2. Check user is active: `SELECT Id, Name, IsActive FROM User WHERE Id = '0055f00000DqpnpAAB'`

**Resolution:**
- Update user ID in flow metadata
- Redeploy flow

### Issue: User ID Mismatch (Anna)
**Current Issue:** Anna's user ID in `ALC_Task_Creation_Subflow` is `0055f00000EYNKi` but should be `0055f00000EYNKiAAP`

**Resolution:** See Phase 1 - Update Anna's user ID before deployment

---

## 📝 Post-Deployment Actions

### 1. Update Documentation
- [ ] Update COLE_ARNOLD_DEVELOPMENT_GUIDE.md with automation details
- [ ] Update SHARED_PLANNING.md - Mark automation deployment as complete
- [ ] Create user-facing documentation for new email workflows

### 2. Train Users
- [ ] Notify Rachyll Tenny about automated tasks she'll receive
- [ ] Notify Anna about A007 DocuSign tasks
- [ ] Update ATS-Training-Program.md with automation information

### 3. Monitor for 1 Week
- [ ] Daily check: Email send volume
- [ ] Daily check: Task creation volume
- [ ] Daily check: Flow execution errors
- [ ] Review with users: Are reminders effective? Any issues?

### 4. Optimize if Needed
Based on first week feedback:
- [ ] Adjust reminder timing (5/10/12 days)
- [ ] Adjust email templates based on response rates
- [ ] Add/remove task assignments based on team feedback

---

## ✅ Deployment Checklist Summary

**Before Deployment:**
- [ ] Update start dates in 3 scheduled flows (2025-12-10 → 2026-01-09)
- [ ] Update Anna's user ID in ALC_Task_Creation_Subflow
- [ ] Commit changes to git
- [ ] Pull latest from main branch

**Deployment:**
- [ ] Deploy ALC_Application_Follow_Up_Reminders.flow-meta.xml
- [ ] Deploy Background_Check_Follow_Up_Tasks.flow-meta.xml
- [ ] Deploy Interview_48hr_Reminders.flow-meta.xml
- [ ] Deploy ALC_Task_Creation_Subflow.flow-meta.xml
- [ ] Deploy Candidate_Outreach email templates (if needed)
- [ ] Activate Candidate_Stage_Email_Automation (if Draft)

**Testing:**
- [ ] Run Test 1: ALC Application Follow-Up
- [ ] Run Test 2: Background Check Follow-Up
- [ ] Run Test 3: Interview 48hr Reminders
- [ ] Run Test 4: ALC Task Creation
- [ ] Run Test 5: Candidate Stage Email Automation

**Monitoring Setup:**
- [ ] Save Email Send Tracking query as Custom Report
- [ ] Save Task Creation Monitoring query as Custom Report
- [ ] Set up weekly review of Flow Execution logs
- [ ] Set up daily monitoring for first week

**Documentation:**
- [ ] Update project documentation
- [ ] Create user training materials
- [ ] Update SHARED_PLANNING.md

---

**Deployment Prepared By:** GitHub Copilot Agent  
**Date:** January 9, 2026  
**Approved By:** [Pending - Patrick Baker]

