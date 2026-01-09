# ALC Contact/Candidate Relationship Automation
## Technical Documentation

**Version:** 1.0  
**Author:** Patrick Baker  
**Last Updated:** January 8, 2026  
**Status:** Production Active  

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Architecture](#2-architecture)
3. [Matching Logic](#3-matching-logic)
4. [Phone Standardization](#4-phone-standardization)
5. [Levenshtein Distance Algorithm](#5-levenshtein-distance-algorithm)
6. [Record Type Mapping](#6-record-type-mapping)
7. [Trigger Architecture](#7-trigger-architecture)
8. [Audit Logging System](#8-audit-logging-system)
9. [Monitoring Dashboard](#9-monitoring-dashboard)
10. [Backfill Wizard](#10-backfill-wizard)
11. [Troubleshooting Guide](#11-troubleshooting-guide)
12. [Deployment Instructions](#12-deployment-instructions)
13. [Testing Strategy](#13-testing-strategy)
14. [FAQs](#14-faqs)

---

## 1. System Overview

### Purpose

The ALC Contact/Candidate Relationship Automation system automatically creates and links Contact and Candidate records when new ALC (Agent Licensing & Contracting) records are created in Salesforce. This eliminates manual data entry, ensures data consistency, and accelerates the agent onboarding process.

### Key Benefits

✅ **Eliminates Manual Entry** - No need to manually create Contact or Candidate records  
✅ **Ensures Data Consistency** - Single source of truth from ALC data  
✅ **Prevents Duplicates** - Intelligent matching by email and phone  
✅ **Audit Trail** - Complete logging of all operations  
✅ **Self-Healing** - Automatic backfill for historical data  
✅ **Record Type Aware** - Maps ALC types to correct Candidate contract types  

### Workflow Summary

```
ALC Created → Filter by Type → Match Contacts → Create/Link → Create Candidate → Audit Log
```

---

## 2. Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    ALC RELATIONSHIP AUTOMATION                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌───────────────────────┐                                              │
│  │  ALCRelationship      │  Trigger fires on ALC insert/update          │
│  │  Trigger              │                                              │
│  └──────────┬────────────┘                                              │
│             │                                                           │
│             ▼                                                           │
│  ┌───────────────────────┐                                              │
│  │  ALCRelationship      │  Main processing logic:                      │
│  │  TriggerHandler       │  - Filter applicable ALCs                    │
│  │                       │  - Bulk query Contacts                       │
│  │                       │  - Match by email/phone                      │
│  │                       │  - Create missing records                    │
│  │                       │  - Link relationships                        │
│  └──────────┬────────────┘                                              │
│             │                                                           │
│             ├──────────────────┬─────────────────┬────────────────┐     │
│             ▼                  ▼                 ▼                ▼     │
│  ┌──────────────┐   ┌──────────────┐   ┌─────────────┐  ┌──────────┐  │
│  │   Contact    │   │  Candidate   │   │    ALC      │  │  Audit   │  │
│  │   Create     │   │   Create     │   │   Update    │  │   Log    │  │
│  └──────────────┘   └──────────────┘   └─────────────┘  └──────────┘  │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  Supporting Components                                            │  │
│  │  - ALCRelationshipMonitorController (monitoring dashboard)        │  │
│  │  - ALCRelationshipBackfillService (historical data processing)    │  │
│  │  - ALCBackfillWizardController (backfill UI)                      │  │
│  │  - ALC_Automation_Log__c (audit object)                           │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Data Flow Diagram

```
┌─────────────┐
│  New ALC    │  User creates ALC record
│   Created   │  (Career, Broker, NRF, Registration)
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Trigger Fires: ALCRelationshipTrigger  │  Before Insert/Update
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Filter ALCs                            │  Valid record types + not cancelled
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Bulk Query Existing Contacts           │  By email + standardized phone
│  (contactsByEmail, contactsByPhone Maps)│
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Process Each ALC:                      │
│  ┌─────────────────────────────────┐   │
│  │ Has Candidate?                  │   │
│  │   Yes → Get Contact from Cand   │   │
│  │   No  → Match by email/phone    │   │
│  └─────────────────────────────────┘   │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Contact Found?                         │
│  Yes → Link to ALC                      │
│  No  → Create new Contact               │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Has Candidate?                         │
│  Yes → Link existing Candidate          │
│  No  → Create new Candidate             │
│       (with correct Contract_Type__c)   │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Execute Bulk DML                       │
│  - Insert Contacts                      │
│  - Update Candidates                    │
│  - Insert Candidates                    │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Create Audit Logs (Async)              │
│  - Log operation type                   │
│  - Record success/failure               │
│  - Store error details                  │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────┐
│  Complete   │
└─────────────┘
```

---

## 3. Matching Logic

### Email Matching

The system uses **case-insensitive email matching** to find existing Contacts:

```apex
// Normalize email to lowercase
String emailKey = alc.Email__c.toLowerCase();

// Check map of pre-queried Contacts
Contact matchedContact = contactsByEmail.get(emailKey);
```

**Email Matching Rules:**
- Email is converted to lowercase for case-insensitive matching
- Exact match required (no fuzzy matching)
- First match wins if duplicates exist
- Only processes non-blank email values

### Phone Matching

Phone matching uses **standardized 10-digit format**:

```apex
// Standardize both ALC and Contact phones
String stdPhone = standardizePhone(alc.Phone__c);
Contact matchedContact = contactsByPhone.get(stdPhone);
```

**Phone Matching Rules:**
1. Strip all non-digit characters: `(555) 123-4567` → `5551234567`
2. Handle 11-digit with country code: `15551234567` → `5551234567`
3. Validate exactly 10 digits
4. Return `null` for invalid formats
5. Match using standardized format only

### Matching Priority

When both email and phone are present:

1. **First** - Try email match
2. **Second** - If no email match, try phone match
3. **Third** - If neither match, create new Contact

### Levenshtein Distance (Future Enhancement)

While not currently active in production, the codebase includes Levenshtein distance logic for fuzzy name matching. See [Section 5](#5-levenshtein-distance-algorithm) for details.

---

## 4. Phone Standardization

### Algorithm

The `standardizePhone()` method performs the following operations:

```apex
private String standardizePhone(String phone) {
    if (String.isBlank(phone)) {
        return null;
    }
    
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll('[^0-9]', '');
    
    // Handle 11-digit numbers starting with 1
    if (digitsOnly.length() == 11 && digitsOnly.startsWith('1')) {
        digitsOnly = digitsOnly.substring(1);
    }
    
    // Return if exactly 10 digits
    if (digitsOnly.length() == 10) {
        return digitsOnly;
    }
    
    return null;
}
```

### Regex Pattern

The regex `[^0-9]` removes all characters except digits:

| Input | After Regex | Valid? | Output |
|-------|-------------|--------|--------|
| `(555) 123-4567` | `5551234567` | ✅ Yes | `5551234567` |
| `1-555-123-4567` | `15551234567` | ✅ Yes (11→10) | `5551234567` |
| `555.123.4567` | `5551234567` | ✅ Yes | `5551234567` |
| `+1 555 123 4567` | `15551234567` | ✅ Yes (11→10) | `5551234567` |
| `555-1234` | `5551234` | ❌ No (7 digits) | `null` |
| `123-4567` | `1234567` | ❌ No (7 digits) | `null` |
| `abc-def-ghij` | `` | ❌ No (0 digits) | `null` |

### 10-Digit Validation

**Requirements:**
- Must contain exactly 10 digits after standardization
- Rejects 7-digit local numbers
- Rejects invalid formats
- Returns `null` for invalid inputs

**Why 10 Digits?**
- Standard US phone format: (NPA) NXX-XXXX
- NPA = 3-digit area code
- NXX = 3-digit exchange
- XXXX = 4-digit subscriber

---

## 5. Levenshtein Distance Algorithm

### Overview

The Levenshtein distance algorithm measures the minimum number of single-character edits (insertions, deletions, substitutions) required to transform one string into another. This is useful for fuzzy name matching.

### Implementation

```apex
private Integer levenshteinDistance(String s1, String s2) {
    if (String.isBlank(s1)) return String.isBlank(s2) ? 0 : s2.length();
    if (String.isBlank(s2)) return s1.length();
    
    Integer len1 = s1.length();
    Integer len2 = s2.length();
    List<List<Integer>> dp = new List<List<Integer>>();
    
    // Initialize matrix
    for (Integer i = 0; i <= len1; i++) {
        List<Integer> row = new List<Integer>();
        for (Integer j = 0; j <= len2; j++) {
            if (i == 0) {
                row.add(j);
            } else if (j == 0) {
                row.add(i);
            } else {
                row.add(0);
            }
        }
        dp.add(row);
    }
    
    // Fill matrix
    for (Integer i = 1; i <= len1; i++) {
        for (Integer j = 1; j <= len2; j++) {
            Integer cost = s1.substring(i-1, i) == s2.substring(j-1, j) ? 0 : 1;
            dp[i][j] = Math.min(
                Math.min(dp[i-1][j] + 1, dp[i][j-1] + 1),
                dp[i-1][j-1] + cost
            );
        }
    }
    
    return dp[len1][len2];
}
```

### Example

**Comparing "Smith" vs "Smyth":**

```
     ""  S  m  y  t  h
""    0  1  2  3  4  5
S     1  0  1  2  3  4
m     2  1  0  1  2  3
i     3  2  1  1  2  3
t     4  3  2  2  1  2
h     5  4  3  3  2  1
```

**Result:** Distance = 1 (substitute "i" → "y")

### Fuzzy Matching Logic

```apex
// Normalize names
String alcName = (alc.First_Name__c + ' ' + alc.Last_Name__c).toLowerCase();
String contactName = (con.FirstName + ' ' + con.LastName).toLowerCase();

// Calculate distance
Integer distance = levenshteinDistance(alcName, contactName);

// Accept if distance <= 2 (allows for typos)
if (distance <= 2) {
    // Fuzzy match found!
}
```

### Use Cases

| Scenario | Distance | Match? |
|----------|----------|--------|
| "John Smith" vs "John Smith" | 0 | ✅ Exact |
| "John Smith" vs "Jon Smith" | 1 | ✅ Typo |
| "John Smith" vs "John Smyth" | 1 | ✅ Typo |
| "John Smith" vs "Jon Smyth" | 2 | ✅ 2 typos |
| "John Smith" vs "Jane Smith" | 3 | ❌ Different |

**Note:** Currently not active in production. Email/phone matching takes priority.

---

## 6. Record Type Mapping

### ALC → Candidate Contract Type

The system maps ALC Record Types to Candidate `Contract_Type__c` values:

| ALC Record Type | Candidate Contract_Type__c | Candidate Status |
|-----------------|---------------------------|------------------|
| **Broker** | `Broker` | `Contracting Started` |
| **Career** | `Career Contract` | `Contracting Started` |
| **NRF** | `null` (blank) | `Contracting Started` |
| **Registration** | `null` (blank) | `Contracting Started` |

### Code Implementation

```apex
private Candidate__c createCandidateFromALC(ALC__c alc) {
    Candidate__c cand = new Candidate__c();
    cand.Contact__c = alc.Contact__c;
    cand.Status__c = 'Contracting Started';
    cand.RecordTypeId = candidateRecordTypeId; // "Candidate" record type
    
    // Get record type name for Contract_Type__c mapping
    String recordTypeName = getRecordTypeName(alc.RecordTypeId);
    if (recordTypeName == 'Broker') {
        cand.Contract_Type__c = 'Broker';
    } else if (recordTypeName == 'Career') {
        cand.Contract_Type__c = 'Career Contract';
    }
    // NRF and Registration get null Contract_Type__c
    
    return cand;
}
```

### Valid Record Types

The trigger **only processes** these record types:

```apex
private static final Set<String> VALID_RECORD_TYPES = new Set<String>{
    'Career', 'Broker', 'NRF', 'Registration'
};
```

**Excluded Record Types:**
- Any other custom record types
- System default record types

### Excluded Stages

The trigger **skips** ALCs in these stages:

```apex
private static final Set<String> EXCLUDED_STAGES = new Set<String>{
    'CANCELLED', 'TERMINATED', 'Cancelled', 'Terminated'
};
```

**Rationale:** No need to create Contact/Candidate for cancelled/terminated contracts.

---

## 7. Trigger Architecture

### Trigger Definition

```apex
trigger ALCRelationshipTrigger on ALC__c (before insert, before update) {
    ALCRelationshipTriggerHandler handler = new ALCRelationshipTriggerHandler();
    
    if (Trigger.isBefore && Trigger.isInsert) {
        handler.handleBeforeInsert(Trigger.new);
    }
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        handler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
}
```

### Before Insert Context

**Purpose:** Create Contact and Candidate **before** ALC record is saved.

**Advantages:**
- ✅ Can set `Contact__c` and `Candidate__c` fields on ALC in-memory
- ✅ No additional DML on ALC record needed
- ✅ Atomic transaction - all or nothing

**Limitations:**
- ❌ Cannot perform DML on Trigger.new records
- ❌ Must use in-memory field updates

### Before Update Context

**Purpose:** Fill missing relationships when ALC is updated.

**Use Cases:**
- User manually updates ALC and adds email/phone
- Data import updates existing ALCs
- Backfill operations fix historical data

### Bulk Processing Pattern

The handler uses **bulkified queries** to handle up to 200 ALCs per transaction:

```apex
// Step 1: Collect all emails and phones
Set<String> emails = new Set<String>();
Set<String> phones = new Set<String>();
for (ALC__c alc : alcs) {
    emails.add(alc.Email__c);
    phones.add(standardizePhone(alc.Phone__c));
}

// Step 2: Single SOQL query for all Contacts
Map<String, Contact> contactsByEmail = new Map<String, Contact>();
for (Contact con : [SELECT Id, Email, Phone FROM Contact WHERE Email IN :emails]) {
    contactsByEmail.put(con.Email.toLowerCase(), con);
}

// Step 3: Process all ALCs using pre-queried data
for (ALC__c alc : alcs) {
    Contact matched = contactsByEmail.get(alc.Email__c.toLowerCase());
    // ... process ALC
}
```

### Governor Limit Considerations

| Governor Limit | Usage | Max Allowed | Notes |
|----------------|-------|-------------|-------|
| SOQL Queries | 3-5 per transaction | 100 | Bulkified queries |
| DML Statements | 3-4 per transaction | 150 | Insert Contacts, Candidates |
| DML Rows | Up to 200 ALCs | 10,000 | Well within limit |
| Future Calls | 1 (audit logs) | 50 | Async logging |

---

## 8. Audit Logging System

### ALC_Automation_Log__c Object

**Purpose:** Track all automation operations for debugging and compliance.

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `Operation_Type__c` | Picklist | Type of operation performed |
| `Success__c` | Checkbox | Whether operation succeeded |
| `ALC__c` | Lookup | Related ALC record |
| `Contact__c` | Lookup | Related Contact record |
| `Candidate__c` | Lookup | Related Candidate record |
| `Error_Message__c` | Long Text | Error message if failed |
| `Stack_Trace__c` | Long Text | Exception stack trace |
| `Processing_Date__c` | DateTime | When operation occurred |
| `Resolved__c` | Checkbox | Whether error was resolved |
| `Resolved_By__c` | Lookup (User) | Who resolved the error |
| `Resolution_Notes__c` | Long Text | How error was resolved |

### Operation Types

| Operation Type | Description |
|----------------|-------------|
| `CONTACT_LINKED` | Existing Contact linked to ALC |
| `CONTACT_CREATED` | New Contact created from ALC |
| `CONTACT_MATCHED` | Contact matched by email/phone |
| `CANDIDATE_CREATED` | New Candidate created |
| `CANDIDATE_UPDATED` | Existing Candidate updated |
| `ERROR` | Operation failed |

### Async Logging

Audit logs are created asynchronously to avoid blocking the main transaction:

```apex
@future
private static void insertAuditLogsAsync(String logsJson) {
    try {
        List<ALC_Automation_Log__c> logs = (List<ALC_Automation_Log__c>) 
            JSON.deserialize(logsJson, List<ALC_Automation_Log__c>.class);
        insert logs;
    } catch (Exception e) {
        System.debug('Failed to insert audit logs: ' + e.getMessage());
    }
}
```

**Benefits:**
- ✅ Doesn't block ALC creation
- ✅ Doesn't count against main transaction DML limits
- ✅ Graceful failure - won't roll back ALC creation

### Log Retention

**Recommendation:** Archive logs older than 90 days.

**Query to find old logs:**
```soql
SELECT Id FROM ALC_Automation_Log__c 
WHERE CreatedDate < LAST_N_DAYS:90
```

---

## 9. Monitoring Dashboard

### Access

**Navigation:** App Launcher → Recruiter Portal → ALC Relationship Monitor

**Permissions Required:**
- `ALC_Relationship_Monitor` permission set
- Read access to ALC__c, Contact, Candidate__c
- Read/Write access to ALC_Automation_Log__c

### Dashboard Sections

#### 1. Summary Cards

Displays high-level metrics:

- **ALCs Without Contacts** - Count by record type
- **ALCs Without Candidates** - Count by record type
- **Candidates Without Contacts** - Orphaned Candidate records
- **Recent Errors** - Failed operations in last 7 days

#### 2. Relationship Gaps Table

Shows ALCs missing Contact or Candidate links:

| Column | Description |
|--------|-------------|
| ALC Name | Link to ALC record |
| Record Type | Career, Broker, NRF, Registration |
| First Name | From ALC |
| Last Name | From ALC |
| Email | From ALC |
| Phone | From ALC |
| Missing | "Contact", "Candidate", or "Both" |
| Actions | "Fix" button |

**Fix Button:** Triggers backfill service to create missing records.

#### 3. Candidates Without Contacts

Lists orphaned Candidates:

| Column | Description |
|--------|-------------|
| Candidate Name | Link to Candidate record |
| First Name | From linked Contact (if exists) |
| Last Name | From linked Contact (if exists) |
| Email | From Contact |
| Related ALC | Link to ALC record |
| Actions | "Create Contact" button |

#### 4. Audit Logs

Recent automation logs with filtering:

| Column | Description |
|--------|-------------|
| Log Name | Link to log record |
| Operation Type | Type of operation |
| Success | ✅ or ❌ |
| Created Date | When operation occurred |
| Actions | "View Details", "Mark Resolved" |

**Filters:**
- All Logs
- Errors Only
- Successes Only
- Unresolved Errors

### Auto-Refresh

Dashboard auto-refreshes every 30 seconds when enabled:

```javascript
@track autoRefreshEnabled = true;

connectedCallback() {
    if (this.autoRefreshEnabled) {
        this.startAutoRefresh();
    }
}

startAutoRefresh() {
    this.refreshInterval = setInterval(() => {
        this.handleRefresh();
    }, 30000); // 30 seconds
}
```

### Using the Dashboard

**Common Workflow:**

1. Open ALC Relationship Monitor
2. Review Summary Cards for issues
3. Click "Relationship Gaps" to see ALCs missing links
4. Click "Fix" button to trigger backfill
5. Monitor Audit Logs for results
6. Review "Errors Only" filter for failures
7. Investigate error details via "View Details"
8. Resolve errors and mark as resolved

---

## 10. Backfill Wizard

### Purpose

The Backfill Wizard processes historical ALC records that were created before the automation system was deployed.

### Components

**Apex Classes:**
- `ALCRelationshipBackfillService` - Core backfill logic
- `ALCBackfillWizardController` - UI controller
- `ALCRelationshipBackfillBatch` - Batch job for large datasets

**LWC Component:**
- `alcBackfillWizard` - User interface (if exists)

### Using the Backfill Service

#### Option 1: Monitoring Dashboard

1. Navigate to ALC Relationship Monitor
2. Identify ALCs with missing relationships
3. Click "Fix" button on individual records
4. System triggers backfill for that ALC

#### Option 2: Anonymous Apex

For bulk backfill operations:

```apex
// Find all ALCs missing relationships
List<ALC__c> unlinkedAlcs = ALCRelationshipBackfillService.findUnlinkedALCs();
System.debug('Found ' + unlinkedAlcs.size() + ' ALCs to process');

// Process up to 200 at a time
List<ALC__c> batch = new List<ALC__c>();
for (Integer i = 0; i < Math.min(200, unlinkedAlcs.size()); i++) {
    batch.add(unlinkedAlcs[i]);
}

// Execute backfill
ALCRelationshipBackfillService.backfillRelationships(batch);
```

#### Option 3: Batch Job

For thousands of records:

```apex
// Start batch job to process all unlinked ALCs
ALCRelationshipBackfillBatch batchJob = new ALCRelationshipBackfillBatch();
Database.executeBatch(batchJob, 200);
```

**Monitor Batch Job:**
```
Setup → Apex Jobs → Find "ALCRelationshipBackfillBatch"
```

### Backfill Logic

The backfill service uses the same logic as the trigger:

1. Query unlinked ALCs
2. Bulk query existing Contacts
3. Match by email/phone
4. Create missing Contacts
5. Create missing Candidates
6. Update ALC records
7. Log audit records

**Difference from Trigger:**
- ✅ Can DML update ALCs (not in trigger context)
- ✅ Processes existing records (not just new inserts)
- ✅ Can handle larger batches with batch jobs

---

## 11. Troubleshooting Guide

### Common Errors

#### Error 1: "ALC has no Email or Phone"

**Cause:** ALC record missing both email and phone fields.

**Solution:**
1. Open ALC record
2. Add Email or Phone
3. Save record
4. System will auto-process on update

**Prevention:** Make Email or Phone required on ALC page layouts.

---

#### Error 2: "Unable to create Contact: Required fields missing"

**Cause:** ALC missing First Name or Last Name.

**Solution:**
1. Open ALC record
2. Populate First_Name__c and Last_Name__c
3. Save record
4. Run backfill from monitor dashboard

**Check Required Fields:**
```soql
SELECT Id, Name, First_Name__c, Last_Name__c, Email__c 
FROM ALC__c 
WHERE (First_Name__c = null OR Last_Name__c = null)
AND RecordType.DeveloperName IN ('Career', 'Broker', 'NRF', 'Registration')
AND Stage__c NOT IN ('CANCELLED', 'TERMINATED')
```

---

#### Error 3: "Duplicate Contacts detected"

**Cause:** Multiple Contacts exist with same email.

**Solution:**
1. Run Contact deduplication
2. Merge duplicate Contacts in Salesforce
3. Re-run backfill for affected ALCs

**Find Duplicates:**
```soql
SELECT Email, COUNT(Id) cnt
FROM Contact
GROUP BY Email
HAVING COUNT(Id) > 1
```

---

#### Error 4: "Candidate already exists"

**Cause:** ALC already has Candidate__c populated.

**Expected:** This is not an error - system will link existing Candidate.

**Check Audit Log:** Should show `CANDIDATE_LINKED` operation type.

---

#### Error 5: "System.LimitException: Too many SOQL queries"

**Cause:** Processing more than 100 ALCs with inefficient queries.

**Solution:** Use batch job instead of single transaction:
```apex
ALCRelationshipBackfillBatch batchJob = new ALCRelationshipBackfillBatch();
Database.executeBatch(batchJob, 200);
```

---

### Debug Mode

Enable debug logs for troubleshooting:

```apex
// In Developer Console → Debug → Change Log Levels
// Set these to FINEST:
- Apex Code: FINEST
- Apex Profiling: FINEST
- Callout: FINEST
- Database: FINEST
```

### Monitoring Queries

**Check trigger status:**
```soql
SELECT Id, Name, Status, UsageAfterInsert, UsageAfterUpdate 
FROM ApexTrigger 
WHERE Name = 'ALCRelationshipTrigger'
```

**Check recent automation logs:**
```soql
SELECT Id, Operation_Type__c, Success__c, Error_Message__c, CreatedDate
FROM ALC_Automation_Log__c
WHERE CreatedDate = TODAY
ORDER BY CreatedDate DESC
LIMIT 50
```

**Find unlinked ALCs:**
```soql
SELECT Id, Name, Contact__c, Candidate__c, Email__c, Phone__c
FROM ALC__c
WHERE RecordType.DeveloperName IN ('Career', 'Broker', 'NRF', 'Registration')
AND Stage__c NOT IN ('CANCELLED', 'TERMINATED')
AND (Contact__c = null OR Candidate__c = null)
```

---

## 12. Deployment Instructions

### Prerequisites

- [ ] Salesforce DX CLI installed
- [ ] Production org connected: `ProductionCapstone`
- [ ] Permission sets created
- [ ] Custom object `ALC_Automation_Log__c` deployed

### Deployment Order

#### Step 1: Deploy Custom Object

```bash
sf project deploy start --source-dir "force-app/main/default/objects/ALC_Automation_Log__c" --target-org ProductionCapstone
```

#### Step 2: Deploy Apex Classes

```bash
sf project deploy start --source-dir "force-app/main/default/classes/ALCRelationshipTriggerHandler.cls" --target-org ProductionCapstone
sf project deploy start --source-dir "force-app/main/default/classes/ALCRelationshipTriggerHandler_Test.cls" --target-org ProductionCapstone
sf project deploy start --source-dir "force-app/main/default/classes/ALCRelationshipBackfillService.cls" --target-org ProductionCapstone
sf project deploy start --source-dir "force-app/main/default/classes/ALCBackfillWizardController.cls" --target-org ProductionCapstone
sf project deploy start --source-dir "force-app/main/default/classes/ALCRelationshipMonitorController.cls" --target-org Productstone
```

#### Step 3: Deploy Trigger

```bash
sf project deploy start --source-dir "force-app/main/default/triggers/ALCRelationshipTrigger.trigger" --target-org ProductionCapstone
```

#### Step 4: Deploy LWC Components

```bash
sf project deploy start --source-dir "force-app/main/default/lwc/alcRelationshipMonitor" --target-org ProductionCapstone
```

#### Step 5: Run Test Classes

```bash
sf apex run test --test ALCRelationshipTriggerHandler_Test --target-org ProductionCapstone
sf apex run test --test ALCRelationshipBackfillService_Test --target-org ProductionCapstone
sf apex run test --test ALCBackfillWizardController_Test --target-org ProductionCapstone
```

**Verify:**
- All tests pass
- Code coverage > 75%

#### Step 6: Assign Permission Sets

```apex
// Anonymous Apex
PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ALC_Relationship_Monitor'];
List<User> users = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'Recruiter'];

List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
for (User u : users) {
    assignments.add(new PermissionSetAssignment(
        PermissionSetId = ps.Id,
        AssigneeId = u.Id
    ));
}
insert assignments;
```

#### Step 7: Run Backfill (Optional)

For historical data:

```apex
ALCRelationshipBackfillBatch batchJob = new ALCRelationshipBackfillBatch();
Database.executeBatch(batchJob, 200);
```

### Rollback Plan

If issues occur:

```bash
# Deactivate trigger
sf apex trigger deactivate --name ALCRelationshipTrigger --target-org ProductionCapstone

# Remove trigger entirely (if needed)
sf project delete --source-dir "force-app/main/default/triggers/ALCRelationshipTrigger.trigger" --target-org ProductionCapstone
```

---

## 13. Testing Strategy

### Unit Tests

**Coverage Requirements:**
- Trigger Handler: 100%
- Backfill Service: 90%+
- Controllers: 85%+

### Test Scenarios

#### Scenario 1: New ALC with No Contact/Candidate

```apex
@isTest
static void testInsertALC_NoContactOrCandidate_CreatesBoth() {
    ALC__c newAlc = new ALC__c(
        RecordTypeId = careerRecordTypeId,
        First_Name__c = 'John',
        Last_Name__c = 'Doe',
        Email__c = 'john.doe@example.com',
        Phone__c = '555-123-4567',
        Stage__c = 'ACTIVE'
    );
    
    Test.startTest();
    insert newAlc;
    Test.stopTest();
    
    ALC__c insertedAlc = [SELECT Contact__c, Candidate__c FROM ALC__c WHERE Id = :newAlc.Id];
    System.assertNotEquals(null, insertedAlc.Contact__c, 'Contact should be created');
    System.assertNotEquals(null, insertedAlc.Candidate__c, 'Candidate should be created');
}
```

#### Scenario 2: Existing Contact Match by Email

```apex
@isTest
static void testInsertALC_WithMatchingContact_LinksContact() {
    Contact existingContact = new Contact(
        FirstName = 'Jane',
        LastName = 'Smith',
        Email = 'jane.smith@example.com'
    );
    insert existingContact;
    
    ALC__c newAlc = new ALC__c(
        RecordTypeId = brokerRecordTypeId,
        First_Name__c = 'Jane',
        Last_Name__c = 'Smith',
        Email__c = 'jane.smith@example.com',
        Stage__c = 'ACTIVE'
    );
    
    Test.startTest();
    insert newAlc;
    Test.stopTest();
    
    ALC__c insertedAlc = [SELECT Contact__c FROM ALC__c WHERE Id = :newAlc.Id];
    System.assertEquals(existingContact.Id, insertedAlc.Contact__c, 'Should link existing Contact');
}
```

#### Scenario 3: Bulk Insert (200 ALCs)

```apex
@isTest
static void testBulkInsert_200ALCs() {
    List<ALC__c> bulkAlcs = new List<ALC__c>();
    for (Integer i = 0; i < 200; i++) {
        bulkAlcs.add(new ALC__c(
            RecordTypeId = careerRecordTypeId,
            First_Name__c = 'Agent',
            Last_Name__c = 'Number' + i,
            Email__c = 'agent' + i + '@example.com',
            Stage__c = 'ACTIVE'
        ));
    }
    
    Test.startTest();
    insert bulkAlcs;
    Test.stopTest();
    
    List<ALC__c> insertedAlcs = [SELECT Contact__c, Candidate__c FROM ALC__c WHERE Id IN :bulkAlcs];
    for (ALC__c alc : insertedAlcs) {
        System.assertNotEquals(null, alc.Contact__c, 'All ALCs should have Contacts');
        System.assertNotEquals(null, alc.Candidate__c, 'All ALCs should have Candidates');
    }
}
```

### Manual Testing Checklist

- [ ] Create Career ALC → Verify Contact + Candidate created
- [ ] Create Broker ALC → Verify `Contract_Type__c = 'Broker'`
- [ ] Create NRF ALC → Verify `Contract_Type__c = null`
- [ ] Create ALC with existing Contact email → Verify Contact linked (not duplicated)
- [ ] Create ALC with CANCELLED stage → Verify no Contact/Candidate created
- [ ] Update ALC to add email → Verify Contact created on update
- [ ] View Monitoring Dashboard → Verify all sections load
- [ ] Click "Fix" button → Verify backfill works
- [ ] View Audit Logs → Verify operations logged

---

## 14. FAQs

### Q1: What happens if an ALC is cancelled after Contact/Candidate are created?

**A:** The Contact and Candidate remain in the system. They are not deleted when the ALC is cancelled. This preserves historical data and allows re-use if the agent reactivates.

---

### Q2: Can I disable the automation temporarily?

**A:** Yes. Deactivate the trigger:
```bash
sf apex trigger deactivate --name ALCRelationshipTrigger --target-org ProductionCapstone
```

To reactivate:
```bash
sf apex trigger activate --name ALCRelationshipTrigger --target-org ProductionCapstone
```

---

### Q3: What if I need to manually create a Contact for an ALC?

**A:** You can manually create the Contact and populate the `Contact__c` field on the ALC. The trigger will detect the existing Contact and create only the Candidate.

---

### Q4: Does the system handle middle names?

**A:** No. The ALC object only has `First_Name__c` and `Last_Name__c`. Middle names should be included in the appropriate field by the user.

---

### Q5: Can I customize the matching logic?

**A:** Yes, but with caution. Edit the `ALCRelationshipTriggerHandler` class and modify the `processIndividualALC()` method. Ensure you maintain bulkification and test thoroughly.

---

### Q6: What's the performance impact of the trigger?

**A:** Minimal. The trigger uses bulkified queries and processes up to 200 ALCs in ~2-3 seconds. Audit logging is async and doesn't block the transaction.

---

### Q7: How do I export audit logs?

**A:**
```soql
SELECT Id, Operation_Type__c, Success__c, Error_Message__c, 
       ALC__c, Contact__c, Candidate__c, CreatedDate
FROM ALC_Automation_Log__c
WHERE CreatedDate = LAST_N_DAYS:30
```

Export from Data Loader or Reports.

---

### Q8: Can the system match by name only (no email/phone)?

**A:** Not by default. Email or phone is required for matching. However, you could enable the Levenshtein distance logic for fuzzy name matching (see Section 5).

---

### Q9: What if an ALC has multiple Contacts with the same email?

**A:** The first match wins. To prevent issues, deduplicate Contacts regularly using Salesforce's built-in deduplication tools or third-party apps.

---

### Q10: How do I troubleshoot a specific ALC that didn't process?

1. Check the ALC stage (must not be CANCELLED/TERMINATED)
2. Check the ALC record type (must be Career, Broker, NRF, or Registration)
3. Query audit logs for that ALC:
```soql
SELECT * FROM ALC_Automation_Log__c WHERE ALC__c = '001xxxxxxxxxxxx'
```
4. Check for error messages in the log
5. Run backfill manually from the monitor dashboard

---

## Appendix A: Object Field Mapping

### ALC → Contact Mapping

| ALC Field | Contact Field |
|-----------|---------------|
| `First_Name__c` | `FirstName` |
| `Last_Name__c` | `LastName` |
| `Email__c` | `Email` |
| `Phone__c` | `Phone` |
| `Street__c` | `MailingStreet` |
| `City__c` | `MailingCity` |
| `State__c` | `MailingState` |
| `Zip__c` | `MailingPostalCode` |

### ALC → Candidate Mapping

| ALC Field | Candidate Field | Notes |
|-----------|-----------------|-------|
| `Contact__c` | `Contact__c` | Lookup to Contact |
| Record Type | `Contract_Type__c` | See mapping table |
| *(system)* | `Status__c` | Always "Contracting Started" |
| *(system)* | `RecordTypeId` | "Candidate" record type |

---

## Appendix B: Useful SOQL Queries

### Find ALCs Without Contacts

```soql
SELECT Id, Name, Email__c, Phone__c, RecordType.DeveloperName
FROM ALC__c
WHERE Contact__c = null
AND RecordType.DeveloperName IN ('Career', 'Broker', 'NRF', 'Registration')
AND Stage__c NOT IN ('CANCELLED', 'TERMINATED')
LIMIT 100
```

### Find ALCs Without Candidates

```soql
SELECT Id, Name, Contact__c, RecordType.DeveloperName
FROM ALC__c
WHERE Candidate__c = null
AND Contact__c != null
AND RecordType.DeveloperName IN ('Career', 'Broker', 'NRF', 'Registration')
AND Stage__c NOT IN ('CANCELLED', 'TERMINATED')
LIMIT 100
```

### Find Recent Errors

```soql
SELECT Id, ALC__c, Operation_Type__c, Error_Message__c, CreatedDate
FROM ALC_Automation_Log__c
WHERE Success__c = false
AND CreatedDate = LAST_N_DAYS:7
ORDER BY CreatedDate DESC
```

### Count ALCs Processed Today

```soql
SELECT COUNT(Id)
FROM ALC_Automation_Log__c
WHERE Operation_Type__c IN ('CONTACT_CREATED', 'CONTACT_LINKED', 'CANDIDATE_CREATED')
AND CreatedDate = TODAY
```

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 8, 2026 | Patrick Baker | Initial release |

---

**For support or questions, contact:**  
- **Email:** help@capstonetechsupport.com  
- **Salesforce Chatter:** @Patrick Baker  

---

*End of Technical Documentation*
