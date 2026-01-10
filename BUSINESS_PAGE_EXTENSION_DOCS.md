# Business Page to Salesforce Extension - Documentation

## Overview

This document describes the new **Business Page to Salesforce** browser extension that was created to expand candidate sourcing capabilities beyond LinkedIn. This extension works on **any business webpage** and includes built-in duplicate detection to prevent creating duplicate candidate records.

## Location

The extension is available in two versions:

- **Chrome**: `/chrome-extension-business-page/`
- **Edge**: `/edge-extension-business-page/`

Both versions are functionally identical and share the same codebase, with only minor branding differences.

## Key Features

### 1. Universal Business Page Support

Unlike the LinkedIn-specific extension, this extension works on any webpage:

- Company websites
- Business directories
- Professional profiles on any platform
- Contact pages
- Team pages
- Any webpage with contact information

### 2. Built-in Duplicate Detection

**This is the major new feature requested by the user.**

The extension automatically checks for existing candidates before creating new ones. It searches for duplicates using:

- **Email address** (checks both `Email__c` and `Personal_Email__c` fields)
- **Phone number** (checks `Mobile__c` field, matches last 10 digits)
- **Exact name match** (checks both `First_Name__c` AND `Last_Name__c`)

When duplicates are found:

1. A clear, user-friendly modal appears
2. Shows all matching records with key details:
   - Candidate name
   - Email
   - Phone
   - Status
   - Agency
3. Each record has a "View Record" link that opens in Salesforce
4. User can choose to:
   - **Cancel** - Stop the creation process
   - **Create Anyway** - Proceed despite duplicates

### 3. Smart Data Extraction

The extension intelligently extracts contact information from any page:

- Email addresses (from `mailto:` links or text patterns)
- Phone numbers (from `tel:` links or formatted text)
- Company name (from meta tags, headers, or page title)
- Page URL (stored in the `Website__c` field)

### 4. Floating Action Button

A persistent "☁️ Save to Salesforce" button appears on every webpage:

- Fixed position (bottom right corner)
- Always visible
- Modern gradient design
- Smooth hover effects
- Captures data and opens popup when clicked

## Architecture

### Files and Components

#### 1. `manifest.json`

- Defines extension permissions and configuration
- Requests access to all URLs (`<all_urls>`)
- Configures content scripts to run on all pages
- Sets up background service worker

#### 2. `content.js`

- Runs on every webpage
- Extracts contact information intelligently:
  - Searches for email in links and text
  - Finds phone numbers in various formats
  - Identifies company information
  - Captures page URL and title
- Adds floating "Save to Salesforce" button
- Communicates with background service worker

#### 3. `popup.html` & `popup.js`

- Extension popup interface (480px width)
- Form fields for candidate information:
  - First Name & Last Name (required)
  - Email & Phone (auto-filled from page)
  - Company (auto-filled from page)
  - Page URL (auto-filled, disabled)
  - Salesforce fields (Agency, Position, Status, Next Step)
- **Duplicate Detection Modal**:
  - Compact design following MODAL_DESIGN_GUIDELINES.md
  - Ultra-compact spacing (8px padding, 4px margins)
  - Small fonts (11-14px)
  - Scrollable content area (max-height: 450px)
  - Clean, professional duplicate record display
  - Direct links to Salesforce records
- Authentication flow with Salesforce OAuth
- Status messages and error handling

#### 4. `background.js`

- Service worker handling API calls
- **Duplicate checking logic**:
  - `handleCheckDuplicates()` - Queries Salesforce for matches
  - Builds dynamic SOQL queries based on available data
  - Returns formatted duplicate records with URLs
- **Candidate creation logic**:
  - `handleCreateCandidateWithContact()` - Creates Contact and Candidate
  - Maps all fields properly
  - Returns Salesforce record URL
- Handles OAuth token storage and validation
- CORS workaround for Salesforce API calls

#### 5. `content.css`

- Minimal styles for floating button
- Ensures consistent look across websites

#### 6. `README.md`

- Complete setup and usage instructions
- Troubleshooting guide
- Field mapping documentation
- Production deployment checklist

## Duplicate Detection Flow

### User Flow

1. User fills in candidate information (at minimum: First Name, Last Name)
2. User clicks "🔍 Check for Duplicates & Create"
3. Extension button shows "Checking..." with spinner
4. Background worker queries Salesforce for duplicates
5. If duplicates found:
   - Modal appears with warning message
   - Shows all matching candidates with details
   - Each candidate has "View Record" link
   - User reviews and decides:
     - Click "Cancel" to stop
     - Click "Create Anyway" to proceed
6. If no duplicates (or user chose "Create Anyway"):
   - Creates Contact and Candidate records
   - Shows success message
   - Opens new candidate record in Salesforce

### Technical Flow

1. **Frontend (`popup.js`)**:

   ```javascript
   handleCheckDuplicates() {
     // Collect form data
     // Send to background worker
     // Wait for response
     // Show modal if duplicates found
   }
   ```

2. **Background (`background.js`)**:

   ```javascript
   handleCheckDuplicates(data) {
     // Build SOQL query with OR conditions
     // Query Candidate__c object
     // Format results with URLs
     // Return to popup
   }
   ```

3. **SOQL Query Example**:
   ```sql
   SELECT Id, Name, First_Name__c, Last_Name__c,
          Email__c, Personal_Email__c, Mobile__c,
          Status__c, Agency__c, Position__c
   FROM Candidate__c
   WHERE Email__c = 'john@example.com'
      OR Personal_Email__c = 'john@example.com'
      OR Mobile__c LIKE '%5551234567%'
      OR (First_Name__c = 'John' AND Last_Name__c = 'Smith')
   LIMIT 10
   ```

## Differences from LinkedIn Extension

| Feature                 | LinkedIn Extension          | Business Page Extension                       |
| ----------------------- | --------------------------- | --------------------------------------------- |
| **Page Support**        | LinkedIn profiles only      | Any business webpage                          |
| **Duplicate Detection** | No                          | Yes, with modal display                       |
| **Action Button**       | In LinkedIn page layout     | Floating button on all pages                  |
| **Data Extraction**     | LinkedIn-specific selectors | Generic patterns and smart detection          |
| **Birthday Field**      | Yes                         | No (not commonly available on business pages) |
| **Modal Design**        | Standard form               | Follows ultra-compact guidelines              |

## Setup & Configuration

### Salesforce Requirements

1. **Connected App** with OAuth enabled
2. **Callback URL**: `https://<extension-id>.chromiumapp.org/`
3. **OAuth Scopes**: api, refresh_token, offline_access, id, profile, email, address, phone

### Extension Configuration

In `popup.js`, update the CONFIG object:

```javascript
const CONFIG = {
  salesforceLoginUrl: "https://test.salesforce.com", // or 'https://login.salesforce.com'
  clientId: "YOUR_CONNECTED_APP_CLIENT_ID",
  redirectUri: chrome.identity.getRedirectURL()
  // ... other settings
};
```

### Field Mappings

**Contact Object**:

- `FirstName` ← First Name
- `LastName` ← Last Name
- `Email` ← Email
- `Phone` ← Phone

**Candidate\_\_c Object**:

- `Name` ← Full Name
- `First_Name__c` ← First Name
- `Last_Name__c` ← Last Name
- `Email__c` ← Email
- `Personal_Email__c` ← Email
- `Mobile__c` ← Phone
- `Website__c` ← Page URL
- `Agency__c` ← Selected value (default: A157)
- `Position__c` ← Selected value (default: Agent)
- `Status__c` ← Selected value (default: Lead)
- `Next_Step__c` ← Selected value (default: F/up to schedule AI)
- `Type__c` ← "Candidate"
- `Recruiter__c` ← Test Recruiter ID (configured)
- `RecordTypeId` ← Candidate Record Type ID
- `Contact__c` ← Related Contact ID

## Testing Checklist

- [ ] Load extension in Chrome
- [ ] Load extension in Edge
- [ ] Test OAuth login flow
- [ ] Navigate to various business pages
- [ ] Verify floating button appears
- [ ] Click floating button, verify popup opens
- [ ] Verify auto-filled data (email, phone, company, URL)
- [ ] Enter name manually
- [ ] Click "Check for Duplicates & Create"
- [ ] Verify duplicate detection works (test with existing candidate)
- [ ] Verify duplicate modal displays correctly
- [ ] Click record links, verify they open in Salesforce
- [ ] Test "Cancel" button
- [ ] Test "Create Anyway" button
- [ ] Verify candidate and contact are created
- [ ] Verify record opens in Salesforce
- [ ] Test with no duplicates scenario
- [ ] Test error handling (invalid session, network errors)

## Deployment

### Development (ProdTest Sandbox)

1. Use `salesforceLoginUrl: 'https://test.salesforce.com'`
2. Create Connected App in ProdTest
3. Use test recruiter ID

### Production

1. Change to `salesforceLoginUrl: 'https://login.salesforce.com'`
2. Create or promote Connected App to Production
3. Update Consumer Key in CONFIG
4. Update `testRecruiterId` to use current user ID or remove hardcoding
5. Verify `recordTypeId` matches Production

## User Benefits

1. **Prevents Duplicates**: No more duplicate candidate records cluttering the system
2. **Saves Time**: Quickly see if a candidate already exists before creating
3. **Universal Sourcing**: Import from any website, not just LinkedIn
4. **Data Integrity**: Ensures email and phone uniqueness
5. **Easy Navigation**: Direct links to existing records for quick review
6. **Informed Decisions**: Clear display of why records match (email, phone, or name)

## Security Considerations

- Access tokens stored locally in browser storage (encrypted by browser)
- No credentials hardcoded in extension
- Uses public OAuth flow (no consumer secret needed)
- All API calls go through Salesforce's secure REST API
- Extension requires user authentication before any operations

## Future Enhancements

Possible improvements for future versions:

1. **Fuzzy Name Matching**: Catch similar names (e.g., "Bob" vs "Robert")
2. **Merge Duplicate UI**: Allow merging duplicates directly from extension
3. **Bulk Import**: Import multiple candidates from a list
4. **Custom Field Mapping**: Allow users to configure which fields to extract
5. **Advanced Filters**: More sophisticated duplicate detection rules
6. **Statistics Dashboard**: Show how many duplicates prevented
7. **Company Matching**: Link candidates to existing Account records

## Support

For issues or questions:

1. Check the README.md in the extension folder
2. Review Salesforce setup (Connected App, permissions)
3. Check browser console for error messages
4. Verify Salesforce field names match expected values
5. Use extension feedback form for feature requests

## Related Files

- `/edge-extension-business-page/` - Edge version of extension
- `/chrome-extension-business-page/` - Chrome version of extension
- `/edge-extension-linkedin/` - Original LinkedIn-only extension (unchanged)
- `/chrome-extension-linkedin/` - Original LinkedIn-only extension (unchanged)
- `/MODAL_DESIGN_GUIDELINES.md` - Modal design standards followed

---

**Last Updated**: December 23, 2025
**Version**: 1.0.0
**Status**: Implementation Complete - Ready for Testing
