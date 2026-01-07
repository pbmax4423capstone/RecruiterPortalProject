# Test Data Factory - Usage Guide

## Overview

The `TestDataFactory` Apex class generates comprehensive test data for the RecruiterPortal application in sandbox environments. It creates a realistic dataset that mirrors production data relationships and volumes.

## What It Creates

| Object Type | Count | Details |
|------------|-------|---------|
| **Candidates** | 500 | Linked to Contacts, distributed across sales managers |
| **Contacts** | 500 | One per candidate, linked to Capstone Partners account |
| **Interviews** | 800 | Distributed: 500 Ci-First, 150 Plan-3rd, 100 Present-4th, 50 Optional-5th |
| **ALC Records** | 300 | For first 300 candidates (contracting scenarios) |
| **Opportunities** | 1000 | Linked to agent Contacts for FYC rollup testing |

## Key Features

✅ **Incremental Data Generation** - Run multiple times to add more test data  
✅ **Realistic Relationships** - Proper linking: Account → Contact → Candidate → Interview/ALC → Opportunity  
✅ **Data Variety** - Varied statuses, stages, types, and field values  
✅ **Bulk Operation Safe** - Batches large DML operations (200 records per batch)  
✅ **Cleanup Method** - `deleteAllTestData()` for resetting between test runs  

## Usage Instructions

### Method 1: Execute via Salesforce CLI (Recommended)

```powershell
# Deploy the factory class to your sandbox
sf project deploy start --source-dir "force-app\main\default\classes\TestDataFactory.cls" --target-org ProdTest

# Execute the data generation
sf apex run --target-org ProdTest --file scripts\TestDataFactoryInvoker.apex
```

### Method 2: Execute via Developer Console

1. Open Developer Console in your sandbox
2. Go to **Debug → Open Execute Anonymous Window**
3. Paste this code:
   ```apex
   TestDataFactory.generateCompleteTestData();
   ```
4. Check **"Open Log"** checkbox
5. Click **Execute**
6. Review debug logs for execution progress

### Method 3: Execute via VS Code Apex Extension

1. Open `scripts/TestDataFactoryInvoker.apex`
2. Right-click in the file
3. Select **"SFDX: Execute Anonymous Apex with Currently Selected Text"**
4. Or select the code and use Command Palette: **"SFDX: Execute Anonymous Apex"**

## Data Cleanup

To delete all test data created by the factory:

```apex
TestDataFactory.deleteAllTestData();
```

Or uncomment the cleanup line in `scripts/TestDataFactoryInvoker.apex`:

```apex
// === CLEAN UP TEST DATA ===
TestDataFactory.deleteAllTestData();
```

**What Gets Deleted:**
- All Opportunities linked to Capstone Partners account
- All ALC records
- All Interview records
- All Candidate records
- All Contacts with email containing "testfactory"
- **Preserves** the Capstone Partners account for reuse

## Important Considerations

### 1. Flow Automation Triggers

⚠️ **This factory creates real Candidate records that trigger production flows:**
- `Candidate_Stage_Email_Automation` flow
- `Add Contact Name to Newly Created Activity Record` flow

**If flows fail in your sandbox due to missing configuration:**

**Option A: Temporarily Deactivate Flows**
1. In sandbox Setup, go to **Process Automation → Flows**
2. Find: `Candidate Stage Email Automation`
3. Click **Deactivate** (you can reactivate later)

**Option B: Configure Required Email Templates**
1. Ensure email templates exist in sandbox (check `force-app/main/default/email/Candidate_Outreach/`)
2. Verify org-wide email address is configured (`help@capstonetechsupport.com`)
3. Update flow to use sandbox-safe email settings

**Option C: Modify Factory for Partial Success** (Advanced)
- Change `insert` statements to `Database.insert(records, false)` to allow partial success
- This is not currently implemented but can be added if needed

### 2. Governor Limits

The factory is designed to work within Salesforce governor limits:
- Uses batches of 200 records for Opportunity creation
- Total DML statements: ~10 (well under limit of 150)
- Total records created: ~2,600 (under single transaction limit)

**If you need MORE data:**
- Run the factory multiple times (incremental data support)
- Or modify constants in the class and run in separate executions

### 3. Data Relationships

The factory creates proper relationship chains:

```
Account (Capstone Partners)
    ↓
Contact (500 contacts)
    ↓
Candidate__c (500 candidates)
    ↓                    ↓
Interview__c (800)   ALC__c (300)
                         ↓
                    Contact (agent)
                         ↓
                    Opportunity (1000) → FYC rollup to Candidate
```

**Key Relationship Fields:**
- `Candidate__c.Contact__c` → Links candidate to Contact
- `Interview__c.Candidate__c` → Links interview to Candidate
- `ALC__c.Candidate__c` & `ALC__c.Contact__c` → Links contracting to both
- `Opportunity.ContactId` → Links opportunity to agent (for FYC rollup)

### 4. Realistic Field Values

The factory uses production-like values:

**Sales Managers:** Tim Denton, Elizabeth Kagele, Van Hess, Michael Yang, Bradley Sofonia, Rachyll Tenny

**Candidate Statuses:** Active/In Process (weighted), Contracting Started, Contracted- Contract B, Keep In Touch

**Interview Types:** Ci-First (500), Plan-3rd (150), Present-4th (100), Optional-5th (50)

**Contract Types:** Contract B (weighted), Contract A, Broker, College Intern

**FYC Amounts:** $500-$2,400 (realistic range for testing rollups)

### 5. Testing Workflow

**Recommended workflow for sandbox testing:**

1. **Initial Setup:**
   ```apex
   TestDataFactory.generateCompleteTestData();
   ```

2. **Test Your Features:**
   - Use realistic data to test dashboards
   - Validate FYC rollups
   - Test interview scheduling
   - Verify Contract B lifecycle tracking

3. **Clean Up Before Next Test Run:**
   ```apex
   TestDataFactory.deleteAllTestData();
   ```

4. **Regenerate Fresh Data:**
   ```apex
   TestDataFactory.generateCompleteTestData();
   ```

### 6. Customization

To modify the data volumes, edit the constants in `TestDataFactory.cls`:

```apex
private static final Integer CANDIDATE_COUNT = 500;
private static final Integer ALC_COUNT = 300;
private static final Integer OPPORTUNITY_COUNT = 1000;

// Interview distribution
private static final Integer INTERVIEW_CI_FIRST = 500;
private static final Integer INTERVIEW_PLAN_3RD = 150;
private static final Integer INTERVIEW_PRESENT_4TH = 100;
private static final Integer INTERVIEW_OPTIONAL_5TH = 50;
```

**After changes:**
1. Save the file
2. Re-deploy to your sandbox
3. Execute the factory

## Troubleshooting

### Error: "Candidate Stage Email Automation process failed"

**Cause:** Flow automation is trying to send emails but missing required configuration.

**Solution:**
- Option 1: Deactivate the flow in sandbox (see Section 1 above)
- Option 2: Configure email templates and org-wide email in sandbox

### Error: "List has no rows for assignment to SObject"

**Cause:** Usually related to missing User records or configuration.

**Solution:** Check that your sandbox has active users with appropriate profiles

### Error: "Too many DML statements: 151"

**Cause:** Governor limit exceeded (unlikely with current implementation).

**Solution:**
- Reduce data volumes in constants
- Run factory multiple times with smaller batches

### Error: "Insert failed... UNABLE_TO_LOCK_ROW"

**Cause:** Record locking conflict (rare in sandbox).

**Solution:** Wait a moment and retry the operation

## Verification Queries

After running the factory, verify data creation:

```apex
// Check counts
System.debug('Candidates: ' + [SELECT COUNT() FROM Candidate__c]);
System.debug('Contacts: ' + [SELECT COUNT() FROM Contact WHERE Email LIKE '%testfactory%']);
System.debug('Interviews: ' + [SELECT COUNT() FROM Interview__c]);
System.debug('ALCs: ' + [SELECT COUNT() FROM ALC__c]);
System.debug('Opportunities: ' + [SELECT COUNT() FROM Opportunity]);

// Check interview type distribution
for (AggregateResult ar : [SELECT Interview_Type__c, COUNT(Id) cnt 
                            FROM Interview__c 
                            GROUP BY Interview_Type__c]) {
    System.debug(ar.get('Interview_Type__c') + ': ' + ar.get('cnt'));
}

// Check FYC rollup (should show aggregated values)
List<Candidate__c> candidatesWithFYC = [SELECT Name, Total_FYC__c, Opportunity_Count__c 
                                         FROM Candidate__c 
                                         WHERE Total_FYC__c > 0 
                                         LIMIT 10];
for (Candidate__c c : candidatesWithFYC) {
    System.debug(c.Name + ' - FYC: ' + c.Total_FYC__c + ', Opps: ' + c.Opportunity_Count__c);
}
```

## Best Practices

1. **Always test in ProdTest sandbox first** before using in other environments
2. **Deactivate email flows** in sandboxes to avoid failed emails
3. **Run cleanup between test cycles** to maintain predictable data
4. **Use incremental generation** if you need more than 500 candidates
5. **Verify data relationships** after generation using queries above
6. **Document any customizations** you make to the factory

## Files Reference

| File | Purpose |
|------|---------|
| `force-app/main/default/classes/TestDataFactory.cls` | Main factory class |
| `force-app/main/default/classes/TestDataFactory.cls-meta.xml` | Metadata file |
| `scripts/TestDataFactoryInvoker.apex` | Anonymous Apex execution script |
| `docs/TEST_DATA_FACTORY_README.md` | This documentation file |

## Support

For issues or questions about the TestDataFactory:
1. Check the troubleshooting section above
2. Review debug logs for detailed error messages
3. Verify sandbox configuration (flows, email templates, users)
4. Contact your Salesforce admin for org-specific configuration help

---

**Last Updated:** January 7, 2026  
**Version:** 1.0  
**Author:** RecruiterPortal Team
