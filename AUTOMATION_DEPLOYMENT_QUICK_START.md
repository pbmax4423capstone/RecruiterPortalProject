# Quick Deployment Guide - Automations to Production

**Date:** January 9, 2026  
**Target Org:** ProductionCapstone  
**Status:** ✅ Ready to Deploy

---

## ✅ Pre-Deployment Complete

### Changes Made:
1. ✅ Updated ALC_Application_Follow_Up_Reminders start date: 2025-12-10 → 2026-01-09
2. ✅ Updated Background_Check_Follow_Up_Tasks start date: 2025-12-10 → 2026-01-09
3. ✅ Updated Interview_48hr_Reminders start date: 2025-12-10 → 2026-01-09
4. ✅ Updated Anna's user ID in ALC_Task_Creation_Subflow: 0055f00000EYNKi → 0055f00000EYNKiAAP

### User ID Verification:
✅ **Rachyll Tenny:** 0055f00000DqpnpAAB (verified in Production)  
✅ **Anna Haney:** 0055f00000EYNKiAAP (verified in Production)

### Current Production Status:
| Flow | Status in Production |
|------|---------------------|
| ALC_Application_Follow_Up_Reminders | ✅ Active (needs update for start date) |
| Background_Check_Follow_Up_Tasks | ✅ Active (needs update for start date) |
| Interview_48hr_Reminders | ✅ Active (needs update for start date) |
| ALC_Broker_Task_Creation_Record_Triggered_Flow | ✅ Active |
| ALC_NRF_Task_Creation_Record_Triggered_Flow | ✅ Active |
| ALC_Task_Creation_Subflow | ✅ Active (needs update for Anna's user ID) |
| Candidate_Stage_Email_Automation | ⚠️ **NOT DEPLOYED** (exists locally as Draft) |

---

## 🚀 Deployment Commands

### Step 1: Deploy Updated Scheduled Flows (with new start dates)

```powershell
# Deploy ALC Application Follow-Up Flow
sf project deploy start --source-dir "force-app\main\default\flows\ALC_Application_Follow_Up_Reminders.flow-meta.xml" --target-org ProductionCapstone --wait 15

# Deploy Background Check Flow
sf project deploy start --source-dir "force-app\main\default\flows\Background_Check_Follow_Up_Tasks.flow-meta.xml" --target-org ProductionCapstone --wait 15

# Deploy Interview 48hr Reminders Flow
sf project deploy start --source-dir "force-app\main\default\flows\Interview_48hr_Reminders.flow-meta.xml" --target-org ProductionCapstone --wait 15
```

### Step 2: Deploy ALC Task Subflow (with updated Anna user ID)

```powershell
sf project deploy start --source-dir "force-app\main\default\flows\ALC_Task_Creation_Subflow.flow-meta.xml" --target-org ProductionCapstone --wait 15
```

### Step 3: Deploy Email Templates (if needed)

```powershell
sf project deploy start --source-dir "force-app\main\default\email\Candidate_Outreach" --target-org ProductionCapstone --wait 15
```

### Step 4: Deploy Candidate Stage Email Automation Flow

⚠️ **IMPORTANT:** This flow is currently in Draft status. Before deploying, decide if you want to:

**Option A: Deploy as Draft (test first)**
```powershell
# Deploy as Draft - won't send emails yet
sf project deploy start --source-dir "force-app\main\default\flows\Candidate_Stage_Email_Automation.flow-meta.xml" --target-org ProductionCapstone --wait 15
```

**Option B: Activate before deploying**
1. Open the flow file: `force-app\main\default\flows\Candidate_Stage_Email_Automation.flow-meta.xml`
2. Change line 786 from `<status>Draft</status>` to `<status>Active</status>`
3. Save and deploy:
```powershell
sf project deploy start --source-dir "force-app\main\default\flows\Candidate_Stage_Email_Automation.flow-meta.xml" --target-org ProductionCapstone --wait 15
```

**Recommendation:** Deploy as Draft first, test with one candidate, then activate.

---

## 🧪 Quick Test Commands

### Test 1: Check ALC records eligible for follow-up
```powershell
sf data query --query "SELECT Id, Name, First_Name__c, Last_Name__c, Stage__c, CreatedDate, Personal_Email_Address__c FROM ALC__c WHERE Stage__c = 'Initial Form Sent' AND Personal_Email_Address__c != null ORDER BY CreatedDate DESC LIMIT 10" --target-org ProductionCapstone
```

### Test 2: Check Background Check follow-ups needed
```powershell
sf data query --query "SELECT Id, Name, Stage__c, In_Background_Since__c, Background_Check_Task_Created__c FROM ALC__c WHERE Stage__c = 'In Background' AND In_Background_Since__c != null AND Background_Check_Task_Created__c = false ORDER BY In_Background_Since__c LIMIT 10" --target-org ProductionCapstone
```

### Test 3: Check upcoming interviews for 48hr reminders
```powershell
sf data query --query "SELECT Id, Name, Date_Time_Scheduled__c, Interview_Type__c, Status__c, Reminder_48hr_Sent__c, Candidate__r.First_Name__c, Candidate__r.Email__c FROM Interview__c WHERE Date_Time_Scheduled__c >= TODAY AND Date_Time_Scheduled__c <= NEXT_N_DAYS:3 AND Status__c NOT IN ('Cancelled', 'Completed') AND Reminder_48hr_Sent__c = false AND Candidate__r.Email__c != null ORDER BY Date_Time_Scheduled__c LIMIT 10" --target-org ProductionCapstone
```

### Test 4: Check recent email sends
```powershell
sf data query --query "SELECT Id, ToAddress, Subject, CreatedDate, Status FROM EmailMessage WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT 20" --target-org ProductionCapstone
```

### Test 5: Check recent task creation
```powershell
sf data query --query "SELECT Id, Subject, OwnerId, Owner.Name, WhatId, CreatedDate FROM Task WHERE CreatedDate = TODAY AND (Subject LIKE '%URGENT%' OR Subject LIKE '%Background Check%' OR Subject LIKE '%DocuSign%') ORDER BY CreatedDate DESC LIMIT 20" --target-org ProductionCapstone
```

---

## 📊 Monitoring Queries (Save for Weekly Review)

### Email Activity Report
```sql
SELECT 
    Id,
    ToAddress,
    Subject,
    Status,
    CreatedDate,
    RelatedToId,
    RelatedTo.Name
FROM EmailMessage
WHERE CreatedDate = THIS_WEEK
  AND (Subject LIKE '%Reminder%'
    OR Subject LIKE '%URGENT%'
    OR Subject LIKE '%Interview%'
    OR Subject LIKE '%Career Interview%')
ORDER BY CreatedDate DESC
```

### Task Creation Report
```sql
SELECT 
    Id,
    Subject,
    Priority,
    Status,
    OwnerId,
    Owner.Name,
    WhatId,
    What.Name,
    CreatedDate
FROM Task
WHERE CreatedDate = THIS_WEEK
  AND (Subject LIKE '%URGENT%'
    OR Subject LIKE '%Follow%up%'
    OR Subject LIKE '%Background Check%'
    OR Subject LIKE '%DocuSign%')
ORDER BY CreatedDate DESC
```

---

## ✅ Post-Deployment Checklist

After deploying, verify:
- [ ] All flows show as Active in Setup → Flows
- [ ] Schedule start date is 2026-01-09 (view flow details)
- [ ] Anna's user ID is correct (0055f00000EYNKiAAP)
- [ ] Run test queries to identify eligible records
- [ ] Monitor for 24 hours to ensure first scheduled run succeeds
- [ ] Check email send volume (EmailMessage object)
- [ ] Check task creation volume (Task object)
- [ ] Notify Rachyll Tenny about incoming automated tasks
- [ ] Notify Anna about A007 DocuSign tasks

---

## 🔧 Troubleshooting

### If flow deployment fails:
```powershell
# Check current flow status
sf data query --query "SELECT ApiName, IsActive, Label FROM FlowDefinitionView WHERE ApiName = 'ALC_Application_Follow_Up_Reminders'" --target-org ProductionCapstone

# View deployment errors
sf project deploy report --target-org ProductionCapstone
```

### If emails aren't sending:
1. Check Org-Wide Email Address exists: Setup → Organization-Wide Addresses → Look for "noreply@financialguide.com"
2. Check Deliverability: Setup → Email Administration → Deliverability → Should be "All Email"
3. Query EmailMessage object for error logs

### If tasks aren't creating:
1. Verify user IDs are correct (Rachyll: 0055f00000DqpnpAAB, Anna: 0055f00000EYNKiAAP)
2. Check users are active in Production
3. Review flow debug logs: Setup → Debug Logs

---

## 📝 Documentation

Full deployment plan: [AUTOMATION_DEPLOYMENT_PLAN.md](AUTOMATION_DEPLOYMENT_PLAN.md)

Update these files after deployment:
- [ ] SHARED_PLANNING.md - Mark automation deployment as complete
- [ ] COLE_ARNOLD_DEVELOPMENT_GUIDE.md - Add automation details
- [ ] docs/ATS-Training-Program.md - Add automation training

---

**Ready to Deploy:** ✅ Yes  
**Prepared By:** GitHub Copilot Agent  
**Date:** January 9, 2026

