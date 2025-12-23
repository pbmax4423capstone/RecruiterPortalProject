# Universal Candidate Creator for Salesforce

A Chrome extension that creates Salesforce candidates from any business page (LinkedIn, ZoomInfo, Apollo, or generic websites) with intelligent duplicate detection.

## Features

- **Universal Support**: Works on LinkedIn, ZoomInfo, Apollo, Lusha, RocketReach, and any business page
- **Smart Extraction**: Automatically extracts name, email, phone, title, company, and location from web pages
- **Duplicate Detection**: Checks for existing Contact and Candidate records before creation
- **LinkedIn Integration**: Auto-opens contact info modal to capture email, phone, and birthday
- **Proceed Anyway Option**: Override duplicate warnings when intentional
- **Hardcoded Defaults**: Agency (A157), Position (Agent), and Status (Lead) automatically set
- **OAuth Security**: Secure Salesforce authentication with token storage

## Installation

### 1. Load Extension in Chrome

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable **Developer mode** (toggle in top-right corner)
3. Click **Load unpacked**
4. Navigate to: `c:\Users\patba\OneDrive - MassMutual\SF Projects VS Code\SalesforceRecruiterPortal\RecruiterPortal\extensions\universal-extension-dup-check`
5. Click **Select Folder**

### 2. Connect to Salesforce

#### Get Your Extension's Redirect URI

1. After loading the extension, right-click the extension icon
2. Select **Inspect popup**
3. In the console, you'll see: `[Universal SF] Redirect URI: https://...`
4. **OR** navigate to: `chrome-extension://[your-extension-id]/oauth-setup.html`
5. Copy the redirect URI shown

#### Add Redirect URI to Salesforce Connected App

1. Log into Salesforce (test.salesforce.com for sandbox)
2. Go to **Setup** → **App Manager**
3. Find the Connected App with Client ID: `3MVG9AR068fT4usy...`
4. Click dropdown → **Edit**
5. Under **OAuth Settings** → **Callback URL**, add your redirect URI on a new line
6. Click **Save**
7. Wait 2-10 minutes for changes to propagate

See [OAUTH_TROUBLESHOOTING.md](OAUTH_TROUBLESHOOTING.md) for detailed OAuth setup instructions.

#### Authenticate

1. Click the extension icon in Chrome toolbar
2. Click **Connect to Salesforce**
3. Log in with your Salesforce credentials
4. Grant permissions when prompted

## Usage

### On LinkedIn Profiles

1. Navigate to any LinkedIn profile (`linkedin.com/in/...`)
2. Click the **☁️ Save to Salesforce** button (appears in profile header)
3. Extension auto-extracts:
   - Name, headline, location from profile
   - Email, phone, birthday from contact info modal
4. Review extracted data in popup
5. Click **Create Candidate**

### On Other Websites

1. Navigate to any business page (ZoomInfo, company website, etc.)
2. Click the **☁️** floating button (bottom-right corner)
   - Or click the extension icon in toolbar
   - Or right-click → **Save to Salesforce**
3. Extension attempts to extract contact data
4. Review and edit data in popup
5. Click **Create Candidate**

### Duplicate Detection Flow

1. When you click **Create Candidate**, the extension checks for duplicates
2. If matches found:
   - **Yellow banner** appears showing duplicate records
   - Links to view each matching Contact or Candidate
   - **Create Candidate** button is disabled
   - **Proceed Anyway** button is enabled
3. Review the duplicates by clicking "View Record" links
4. If you want to create anyway, click **Proceed Anyway**

## Field Mapping

### Extracted from Web Pages

| Web Page Field | Salesforce Field |
|----------------|------------------|
| First Name | `Contact.FirstName` and `Candidate__c.First_Name__c` |
| Last Name | `Contact.LastName` and `Candidate__c.Last_Name__c` |
| Email | `Contact.Email`, `Candidate__c.Email__c`, `Candidate__c.Email_2__c` |
| Phone | `Contact.Phone` and `Candidate__c.Phone__c` |
| Birthday (text) | `Contact.Birthdate_Text__c` |
| Title/Headline | `Candidate__c.Title__c` |
| Company | `Candidate__c.Company__c` |
| Location | `Candidate__c.Location__c` |
| LinkedIn URL | `Candidate__c.LinkedIn_URL__c` |
| Page URL | `Candidate__c.Source_URL__c` |

### Hardcoded Defaults (Not Shown in UI)

| Field | Value |
|-------|-------|
| `Agency__c` | A157 |
| `Position_Interested_In__c` | Agent |
| `Status__c` | Lead |
| `Next_Step__c` | F/up to schedule AI |
| `Type__c` | Candidate |
| `RecordTypeId` | 0125f000000a5IlAAI |
| `Recruiter__c` | Current logged-in user |

## Supported Sites

### Site-Specific Extraction

- **LinkedIn**: Profile name, headline, location, email, phone, birthday
- **ZoomInfo**: Contact details, company info
- **Apollo**: Lead information
- **Lusha**: Contact enrichment data
- **RocketReach**: Professional contact info

### Generic Extraction

For any other website, the extension attempts to extract data using:

1. **Schema.org Person markup** (JSON-LD)
2. **vCard/h-card microformats**
3. **Regex patterns** for email and phone numbers
4. **Page title analysis** for name extraction

## Duplicate Detection Logic

The extension queries Salesforce for existing records:

### Contact Duplicates

- Matches by email: `Contact WHERE Email = '{email}'`
- Matches by phone: `Contact WHERE Phone LIKE '%{last10digits}%'`

### Candidate Duplicates

- Matches by email: `Candidate__c WHERE Email__c = '{email}'`
- Matches by LinkedIn URL: `Candidate__c WHERE LinkedIn_URL__c = '{url}'`

## Technical Details

### Architecture

- **manifest.json**: Extension configuration (Manifest V3)
- **background.js**: Service worker for Salesforce API calls
- **content.js**: Page data extraction and button injection
- **popup.html/js**: User interface for data review
- **content.css**: Styles for injected elements

### Salesforce API

- **OAuth 2.0**: Secure authentication flow
- **REST API v59.0**: Record creation and queries
- **Endpoints Used**:
  - `/services/oauth2/authorize` - Authentication
  - `/services/oauth2/userinfo` - User details
  - `/services/data/v59.0/query` - Duplicate checks
  - `/services/data/v59.0/sobjects/Contact` - Contact creation
  - `/services/data/v59.0/sobjects/Candidate__c` - Candidate creation

### Permissions

- `activeTab`: Access current page content
- `storage`: Store OAuth tokens locally
- `identity`: OAuth authentication flow
- `scripting`: Inject content scripts dynamically
- `contextMenus`: Right-click menu option
- `host_permissions`: Access all URLs for extraction

## Troubleshooting

### Extension Not Appearing on Page

- Ensure extension is enabled in `chrome://extensions/`
- Refresh the page after loading extension
- Check for console errors (F12 → Console)

### Authentication Fails

- Verify you're using correct Salesforce credentials
- Check if your Salesforce org allows OAuth apps
- Try logging out and reconnecting
- Clear extension storage: `chrome://extensions/` → Details → Clear storage data

### Data Not Extracted

- **LinkedIn**: Contact info modal must be accessible (not all profiles have it)
- **Generic sites**: Limited data if no Schema.org/vCard markup present
- Manually enter data if extraction fails

### Duplicate Not Detected

- Ensure email/phone formatting matches Salesforce records
- Phone matching uses last 10 digits (ignores formatting)
- Email matching is case-insensitive
- LinkedIn URL must match exactly

### Button Not Showing

- **LinkedIn**: Button appears in top card actions area (may take 1-2 seconds)
- **Other sites**: FAB appears in bottom-right corner
- Try refreshing page or clicking extension icon

## Development

### Modify Hardcoded Values

Edit `background.js` CONFIG section:

```javascript
const CONFIG = {
  salesforceLoginUrl: 'https://test.salesforce.com', // Change for production
  clientId: 'YOUR_CLIENT_ID',
  defaults: {
    agency: 'A157',        // Change default agency
    position: 'Agent',     // Change default position
    status: 'Lead',        // Change default status
    nextStep: 'F/up to schedule AI',
    recordTypeId: '0125f000000a5IlAAI'
  }
};
```

### Add New Site Support

Edit `content.js` SITE_PATTERNS and add extraction function:

```javascript
const SITE_PATTERNS = {
  linkedin: /linkedin\.com\/in\//,
  newsite: /example\.com\/profile\//,  // Add pattern
  // ...
};

function extractNewSiteData() {
  // Add extraction logic
  return { firstName, lastName, email, ... };
}
```

### Debugging

1. Open `chrome://extensions/`
2. Click **Details** on the extension
3. Click **Inspect views: background page** (for background.js)
4. Use F12 on any page (for content.js)
5. Click extension icon → right-click → **Inspect** (for popup.js)

## Privacy & Security

- OAuth tokens stored locally in Chrome storage
- No data sent to third parties
- Direct Salesforce API communication only
- Tokens cleared on logout
- Extension only active when user clicks buttons

## Support

For issues or questions:

1. Check console for error messages
2. Review Salesforce API limits and permissions
3. Verify field API names match your Salesforce org
4. Test OAuth connection in Salesforce Setup → Connected Apps

## Version History

### v1.0.0 (Initial Release)
- Universal site support (LinkedIn, ZoomInfo, Apollo, generic)
- Duplicate detection with "Proceed Anyway" option
- LinkedIn contact info modal auto-extraction
- Hardcoded Agency/Position/Status defaults
- OAuth 2.0 authentication
- Two-step Contact + Candidate creation
- Dynamic Recruiter assignment

## License

Internal use only - MassMutual Salesforce Recruiting Portal

---

**Created for**: Salesforce Recruiter Portal Project  
**Repository**: RecruiterPortalProject  
**Date**: December 2025
