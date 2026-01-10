# Universal Candidate Creator Extension - Testing Guide

## Extension Location

`c:\Users\patba\OneDrive - MassMutual\SF Projects VS Code\SalesforceRecruiterPortal\RecruiterPortal\extensions\universal-extension-dup-check`

## Installation Steps

1. Open Chrome browser
2. Navigate to `chrome://extensions/`
3. Enable **Developer mode** (toggle in top-right)
4. Click **Load unpacked**
5. Select folder: `extensions\universal-extension-dup-check`
6. Extension should load successfully

## Test Scenarios

### Test 1: OAuth Authentication

**Goal**: Verify Salesforce connection works

1. Click extension icon in Chrome toolbar
2. Click "Connect to Salesforce" button
3. Should redirect to Salesforce login (test.salesforce.com)
4. Log in with credentials
5. Verify successful authentication message
6. Popup should show form section

**Expected**: OAuth flow completes, tokens stored, form appears

---

### Test 2: LinkedIn Profile Extraction

**Goal**: Verify LinkedIn-specific features work

1. Navigate to any LinkedIn profile: `https://www.linkedin.com/in/[profile]`
2. Wait for page to load
3. Look for "☁️ Save to Salesforce" button in profile header
4. Click the button
5. Extension should auto-open contact info modal (if available)
6. Wait 2.5 seconds
7. Popup should open with extracted data:
   - First Name
   - Last Name
   - Headline (in Title field)
   - Location
   - LinkedIn URL
   - Email (if available in modal)
   - Phone (if available in modal)
   - Birthday (if available in modal)

**Expected**: Data extracted, popup populated, contact modal closes

---

### Test 3: Duplicate Detection - Contact Match

**Goal**: Verify duplicate detection for existing Contact

**Setup**:

- Create a test Contact in Salesforce with email: `testdup@example.com`

**Test**:

1. Open extension popup
2. Enter:
   - First Name: Test
   - Last Name: Duplicate
   - Email: `testdup@example.com`
3. Click "Create Candidate"
4. Extension should query Salesforce
5. Duplicate banner should appear (yellow)
6. Should show: "Potential Duplicates Found"
7. List should show Contact with link
8. "Create Candidate" button should hide
9. "Proceed Anyway" button should show

**Expected**: Duplicate detected, banner shown, proceed option available

---

### Test 4: Duplicate Detection - Proceed Anyway

**Goal**: Verify override works

**Continuation from Test 3**:

1. Click "Proceed Anyway" button
2. Extension should create records despite duplicate
3. Success message should appear
4. New tab should open with Candidate record
5. Verify in Salesforce:
   - Contact created (new one, not duplicate)
   - Candidate\_\_c created
   - Candidate\_\_c linked to new Contact
   - Agency\_\_c = 'A157' (hardcoded)
   - Position_Interested_In\_\_c = 'Agent' (hardcoded)
   - Status\_\_c = 'Lead' (hardcoded)
   - Recruiter\_\_c = current user ID

**Expected**: Record created with hardcoded defaults

---

### Test 5: No Duplicates - Direct Creation

**Goal**: Verify normal creation flow

1. Open extension popup
2. Enter unique data:
   - First Name: Unique
   - Last Name: Test
   - Email: `unique${Date.now()}@example.com`
   - Phone: 555-0100
3. Click "Create Candidate"
4. Should skip duplicate check (no matches)
5. Records should create immediately
6. Success message appears
7. New tab opens with Candidate record

**Expected**: Contact + Candidate created, no duplicate warning

---

### Test 6: Generic Website Extraction

**Goal**: Verify non-LinkedIn extraction

1. Navigate to a company website or ZoomInfo page
2. Look for floating ☁️ button (bottom-right)
3. Click FAB
4. Extension attempts generic extraction
5. Popup opens with any found data
6. May need manual entry if extraction fails
7. Fill in required fields (First Name, Last Name)
8. Click "Create Candidate"

**Expected**: FAB appears, extraction attempted, creation works

---

### Test 7: Right-Click Context Menu

**Goal**: Verify context menu integration

1. Navigate to any webpage
2. Right-click anywhere on page
3. Look for "Save to Salesforce" option
4. Click it
5. Extension popup should open

**Expected**: Context menu appears, popup opens

---

### Test 8: LinkedIn SPA Navigation

**Goal**: Verify button persists during LinkedIn navigation

1. Navigate to LinkedIn profile page
2. Verify "☁️ Save to Salesforce" button appears
3. Click on another LinkedIn profile (via search or connections)
4. Wait 1-2 seconds
5. Button should re-appear on new profile
6. Test extraction on second profile

**Expected**: MutationObserver detects navigation, button re-injected

---

### Test 9: Field Validation

**Goal**: Verify required field validation

1. Open extension popup
2. Leave First Name and Last Name empty
3. Click "Create Candidate"
4. Should show error message: "First Name and Last Name are required"
5. No Salesforce API call should be made

**Expected**: Validation prevents submission

---

### Test 10: Logout and Re-authentication

**Goal**: Verify logout clears tokens

1. Open extension popup (while authenticated)
2. Click "Logout" button
3. Popup should switch to auth section
4. Click "Connect to Salesforce" again
5. Should prompt for credentials again
6. Re-authenticate successfully

**Expected**: Tokens cleared, re-auth works

---

## Hardcoded Values to Verify

After any successful Candidate creation, check Salesforce record has:

| Field                       | Expected Value               |
| --------------------------- | ---------------------------- |
| `Agency__c`                 | A157                         |
| `Position_Interested_In__c` | Agent                        |
| `Status__c`                 | Lead                         |
| `Next_Step__c`              | F/up to schedule AI          |
| `Type__c`                   | Candidate                    |
| `RecordTypeId`              | 0125f000000a5IlAAI           |
| `Recruiter__c`              | Current user's Salesforce ID |

These should **NOT** appear in the popup UI - verify they're hidden.

---

## Known Issues to Watch For

1. **LinkedIn modal doesn't open**: Some profiles don't have contact info button
2. **Phone formatting**: Different formats should all match in duplicate check
3. **Token expiration**: Long testing sessions may require re-auth
4. **CORS errors**: Ensure background.js handles Salesforce API calls (not content.js)
5. **Button injection timing**: MutationObserver may need adjustment for slow pages

---

## Bug Reporting Template

If you find issues, report with:

```
**Test Scenario**: [Test # and name]
**Steps to Reproduce**:
1.
2.
3.

**Expected Behavior**:
**Actual Behavior**:
**Console Errors**: [From F12 DevTools]
**Screenshots**: [If applicable]
**Browser**: Chrome [version]
```

---

## Success Criteria

✅ OAuth authentication works  
✅ LinkedIn extraction captures all available fields  
✅ Generic website extraction attempts data capture  
✅ Duplicate detection queries Salesforce correctly  
✅ Duplicate banner shows matches with links  
✅ "Proceed Anyway" creates despite duplicates  
✅ Normal flow creates without duplicate warning  
✅ Hardcoded defaults (A157, Agent, Lead) applied correctly  
✅ Hardcoded fields NOT shown in UI  
✅ Contact created before Candidate  
✅ Recruiter\_\_c set to current user dynamically  
✅ FAB appears on non-LinkedIn sites  
✅ Inline button appears on LinkedIn  
✅ Context menu works  
✅ Logout clears authentication  
✅ SPA navigation maintains button on LinkedIn

---

## Handoff to Coding Agent

If bugs found, provide:

1. List of failing tests
2. Console error logs
3. Expected vs actual behavior
4. Specific file/function where issue likely occurs

Agent should fix and re-test before Git commit.
