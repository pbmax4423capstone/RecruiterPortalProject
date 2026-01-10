# Business Page to Salesforce Extension

## Overview

This Microsoft Edge extension allows recruiters to import candidates from **any business page** into Salesforce with built-in duplicate detection.

## Key Features

### 🌐 Universal Business Page Support

- Works on any webpage, not just LinkedIn
- Extracts contact information from business pages
- Floating "Save to Salesforce" button on all pages

### 🔍 Duplicate Detection

- Automatically checks for existing candidates before creating
- Matches by:
  - Email address
  - Phone number
  - Name (First Name + Last Name)
- Shows clear modal with matching records and direct links
- Option to create anyway if needed

### 📋 Smart Data Extraction

- Email addresses (from mailto: links or page text)
- Phone numbers (from tel: links or formatted text)
- Company information
- Page URL (stored in Website field)

### 💬 User-Friendly Modal

- Clean, readable duplicate display
- Record links open in new tabs
- Shows key fields: Email, Phone, Status, Agency
- Clear "Create Anyway" or "Cancel" options

## Setup Instructions

### Step 1: Create a Connected App in Salesforce

1. Go to **Setup** → **Apps** → **App Manager**
2. Click **New Connected App**
3. Fill in the details:
   - **Connected App Name**: Business Page Import Extension
   - **API Name**: Business_Page_Import_Extension
   - **Contact Email**: your-email@company.com
   - Check **Enable OAuth Settings**
   - **Callback URL**: `https://<extension-id>.chromiumapp.org/` (get this after loading the extension)
   - **Selected OAuth Scopes**:
     - Access and manage your data (api)
     - Perform requests on your behalf at any time (refresh_token, offline_access)
     - Access your basic information (id, profile, email, address, phone)
4. Click **Save**
5. Copy the **Consumer Key** (Client ID)

### Step 2: Update Extension Configuration

1. Open `popup.js`
2. Find the `CONFIG` object at the top
3. Replace the `clientId` with your Consumer Key
4. For ProdTest sandbox, keep `salesforceLoginUrl: 'https://test.salesforce.com'`
5. For Production, change to `salesforceLoginUrl: 'https://login.salesforce.com'`

### Step 3: Load the Extension in Edge

1. Open Edge and go to `edge://extensions/`
2. Enable **Developer mode** (toggle in bottom left)
3. Click **Load unpacked**
4. Select the `edge-extension-business-page` folder
5. Note the **Extension ID** shown below the extension name

### Step 4: Update Connected App Callback URL

1. Go back to Salesforce Setup → App Manager
2. Edit your Connected App
3. Update the Callback URL to: `https://<your-extension-id>.chromiumapp.org/`
4. Save

## Usage

### Method 1: Using the Floating Button

1. Navigate to any business page with contact information
2. Look for the floating "☁️ Save to Salesforce" button (bottom right)
3. Click the button to open the extension popup
4. The extension will auto-fill any detected email, phone, company info
5. Enter the candidate's first and last name
6. Click "🔍 Check for Duplicates & Create"
7. If duplicates are found:
   - Review the matching records in the modal
   - Click record links to view existing candidates
   - Choose "Create Anyway" or "Cancel"
8. If no duplicates, candidate is created immediately
9. The new candidate record opens in a new tab

### Method 2: Using the Extension Icon

1. Navigate to any business page
2. Click the extension icon in Edge toolbar
3. Follow steps 4-9 above

## Duplicate Detection Policy

The extension checks for duplicates using the following criteria:

1. **Email Match**: Checks both `Email__c` and `Personal_Email__c` fields
2. **Phone Match**: Checks `Mobile__c` field (matches last 10 digits)
3. **Name Match**: Checks exact match on `First_Name__c` AND `Last_Name__c`

### Duplicate Modal Display

When duplicates are found, the modal shows:

- Clear warning message explaining the situation
- Each matching record with:
  - Candidate name
  - Email (if available)
  - Phone (if available)
  - Status
  - Agency
  - Direct link to view the record in Salesforce
- Options to:
  - **Cancel**: Stop the creation process
  - **Create Anyway**: Proceed with creating a duplicate

## Field Mapping

### Contact Fields

- `FirstName` → First Name
- `LastName` → Last Name
- `Email` → Email
- `Phone` → Phone

### Candidate Fields

- `Name` → Full Name
- `First_Name__c` → First Name
- `Last_Name__c` → Last Name
- `Email__c` → Email
- `Personal_Email__c` → Email
- `Mobile__c` → Phone
- `Website__c` → Page URL
- `Agency__c` → Selected Agency (default: A157)
- `Position__c` → Selected Position (default: Agent)
- `Status__c` → Selected Status (default: Lead)
- `Next_Step__c` → Selected Next Step (default: F/up to schedule AI)
- `Type__c` → "Candidate"
- `Recruiter__c` → Test Recruiter ID
- `RecordTypeId` → Candidate Record Type
- `Contact__c` → Related Contact ID

## Troubleshooting

### "Failed to connect" error

- Verify the Consumer Key is correct in popup.js
- Check that the Callback URL matches exactly
- For sandbox, ensure you're using test.salesforce.com

### Duplicate detection not working

- Ensure you're connected to Salesforce
- Check that you have the required permissions
- Verify the Candidate\_\_c object fields exist

### "Session expired"

- Click "Disconnect from Salesforce"
- Click "Connect to Salesforce" to re-authenticate

### Data not auto-filling

- Not all websites have structured contact information
- Manually enter missing information
- Email and phone detection works best with mailto: and tel: links

## Moving to Production

1. Update `popup.js`:
   - Change `salesforceLoginUrl` to `'https://login.salesforce.com'`
   - Update `recordTypeId` if different in Production
   - Update `testRecruiterId` to use current user ID
2. Create a new Connected App in Production (or promote existing)
3. Update the Consumer Key in CONFIG

## Files

- `manifest.json` - Extension configuration
- `popup.html` - Extension popup UI with duplicate modal
- `popup.js` - Main extension logic with duplicate detection
- `content.js` - Script that runs on all pages
- `content.css` - Styles for content script elements
- `background.js` - Service worker with duplicate checking API
- `icons/` - Extension icons (16x16, 48x48, 128x128)

## Differences from LinkedIn Extension

1. **Universal Page Support**: Works on any webpage, not just LinkedIn
2. **Duplicate Detection**: Built-in duplicate checking with clear modal display
3. **Floating Button**: Always-visible save button on all pages
4. **Simplified Extraction**: Focuses on core contact fields (no birthday)
5. **Enhanced Modal**: Follows ultra-compact modal design guidelines

## Security Notes

- The access token is stored locally in Chrome storage
- Never commit the Consumer Secret
- The extension has access to all URLs (required for universal support)
- Duplicate checks are performed server-side via Salesforce API

## Support

For issues or feature requests, use the feedback form in the extension popup.
