# Case Contact Override Issue - Root Cause Analysis & Fix

## Problem Summary
Cases created via the "Create Ticket" button were being assigned the wrong Contact (Brian Darzev instead of Pat Baker) and were being owned by the creator instead of going to the Unassigned queue.

## Root Cause Analysis

### Issue 1: Contact Field Override

**Flow:** `Update_Contact_on_forwarded_email_case`

**Original Trigger Criteria (FLAWED):**
```
(Subject contains "FW:" OR Subject contains "FWD:" OR ContactId IsChanged) 
AND Agents_Staff__c IsNull
```

**The Problem:**
1. When users manually set ContactId in the Create Ticket form, the flow triggered because `ContactId IsChanged = true`
2. Flow checked if the assigned Contact (Pat Baker) is a Service User → YES (found in Service_User__mdt)
3. Flow assumed this was a forwarded email and tried to extract sender's email from Description field
4. Description contained only "test" or "more test cases" (no "From:" line)
5. ExtractedSenderEmail formula returned empty string ("")
6. Flow queried: `SELECT Id FROM Contact WHERE Personal_Email__c = ''`
7. **Salesforce returned Brian Darzev's Contact as first result** (he has null/blank Personal_Email__c)
8. Flow updated Case.ContactId = Brian Darzev (0035f000023HJL7AAO)

**Key Finding:**
Brian Darzev's Contact record was being returned when querying for `Personal_Email__c = ''` because:
- Brian Darzev has no Personal_Email__c value (null)
- In SOQL, `WHERE field = ''` can match null values depending on field type
- Brian Darzev was created earlier than other null-email Contacts, so appeared first in results

### Issue 2: Case Ownership

**Original Behavior:**
- Cases created via lightning-record-edit-form defaulted to OwnerId = Current User
- No OwnerId assignment in form, so Salesforce assigned to creator

## Solutions Implemented

### Fix 1: Modified Flow Trigger Criteria

**Updated Trigger Logic:**
```
((Subject contains "FW:" OR Subject contains "FWD:") AND Agents_Staff__c IsNull)
```

**Result:**
- Flow now ONLY triggers for actual forwarded emails (Subject contains FW: or FWD:)
- Flow will NOT trigger when ContactId is manually set in forms
- Manually assigned Contacts will be preserved

### Fix 2: Added OwnerId Assignment

**Updated Form (recruiterPortalHeader.html):**
```html
<!-- Hidden OwnerId field set to Unassigned queue -->
<lightning-input-field field-name="OwnerId" value="00G5f000004Hc9hEAC" class="slds-hide"></lightning-input-field>
```

**Result:**
- All Cases created via Create Ticket button will now be owned by Unassigned queue
- OwnerId field is hidden from user (slds-hide class)
- Queue ID: 00G5f000004Hc9hEAC (Unassigned)

## Verification Steps

To verify the fixes work:

1. **Test Contact Assignment:**
   ```apex
   // Create a test Case via UI Create Ticket button
   // Check that ContactId = Pat Baker (0035f000023HJU8AAO), NOT Brian Darzev
   Case c = [SELECT Id, CaseNumber, ContactId, Contact.Name FROM Case WHERE Id = 'YOUR_CASE_ID'];
   System.debug('Contact: ' + c.Contact.Name + ' (Expected: Patrick Baker)');
   ```

2. **Test Case Ownership:**
   ```apex
   // Check that OwnerId = Unassigned queue (00G5f000004Hc9hEAC)
   Case c = [SELECT Id, CaseNumber, OwnerId, Owner.Name FROM Case WHERE Id = 'YOUR_CASE_ID'];
   System.debug('Owner: ' + c.Owner.Name + ' (Expected: Unassigned)');
   ```

3. **Verify Flow Still Works for Forwarded Emails:**
   - Create a Case with Subject = "FW: Test Forward"
   - Add "From: John Doe <john@example.com>" in Description
   - Verify flow extracts email and updates Contact accordingly

## Files Modified

1. **Update_Contact_on_forwarded_email_case.flow-meta.xml**
   - Changed trigger filterLogic from "or" to "((1 OR 2) AND 3)"
   - Removed ContactId IsChanged filter (previously filter #3)
   - Now only triggers on forwarded emails with FW:/FWD: in subject

2. **recruiterPortalHeader.html**
   - Added hidden OwnerId field with value="00G5f000004Hc9hEAC"
   - Cases now assigned to Unassigned queue instead of creator

## Deployment Status

✅ Both fixes deployed successfully to Production
✅ Flow: Update_Contact_on_forwarded_email_case (Deploy ID: 0AfVo000000q5jZKAQ)
✅ Component: recruiterPortalHeader (Deploy ID: 0AfVo000000q5lBKAQ)

## Additional Context

**Service Users in Metadata:**
- Pat Baker (ContactId: 0035f000023HJU8AAO)
- Donna Deluca (ContactId: 003Vo00000UBv6ZIAT)

**Agents_Staff Records for Pat Baker:**
- a0a5f00000AQ0MtAAL (Name: Pat Baker)
- a0a5f00000BEK9HAAX (Name: Patrick Baker)

**Brian Darzev Contact:**
- ID: 0035f000023HJL7AAO
- Personal_Email__c: null
- Email: null
- Status: Inactive employee

## Recommendations

1. Consider adding validation to ensure Personal_Email__c is not blank when queried in flows
2. Review all flows using Personal_Email__c to ensure they handle null/empty values correctly
3. Consider updating Brian Darzev's Contact to inactive status or add a Personal_Email__c value to prevent future matches
4. Document Service User metadata records and their purpose for future maintainers

---
**Fixed By:** GitHub Copilot
**Date:** November 20, 2024
**Production Org:** patrickbakeradmin2@financialguide.com
