# LinkedIn to Salesforce Edge Extension

## Overview

This Microsoft Edge extension allows recruiters to import LinkedIn profiles directly as Candidates into Salesforce.

> **Note:** This is the Edge version of the Chrome extension. Both share the same Connected App configuration in Salesforce.

## Features

- Extract profile data (First Name, Last Name) from LinkedIn profiles
- Auto-fill Salesforce candidate fields (Agency, Position, Status, Next Step)
- Sets the logged-in user as the Recruiter
- Creates candidate with "Candidate" record type
- Opens the new record in Salesforce after creation

## Setup Instructions

### Step 1: Create a Connected App in Salesforce

1. Go to **Setup** → **Apps** → **App Manager**
2. Click **New Connected App**
3. Fill in the details:
   - **Connected App Name**: LinkedIn Import Extension
   - **API Name**: LinkedIn_Import_Extension
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
3. Replace `YOUR_CONNECTED_APP_CLIENT_ID` with your Consumer Key
4. For ProdTest sandbox, keep `salesforceLoginUrl: 'https://test.salesforce.com'`
5. For Production, change to `salesforceLoginUrl: 'https://login.salesforce.com'`

### Step 3: Load the Extension in Edge

1. Open Edge and go to `edge://extensions/`
2. Enable **Developer mode** (toggle in bottom left)
3. Click **Load unpacked**
4. Select the `edge-extension-linkedin` folder
5. Note the **Extension ID** shown below the extension name

### Step 4: Update Connected App Callback URL

1. Go back to Salesforce Setup → App Manager
2. Edit your Connected App
3. Update the Callback URL to: `https://<your-extension-id>.chromiumapp.org/`
4. Save

### Step 5: Create LinkedIn Profile URL Field (Optional)

If you want to store the LinkedIn URL, create a custom field on Candidate\_\_c:

- **Field Name**: LinkedIn_Profile\_\_c
- **Type**: URL
- **Label**: LinkedIn Profile

## Usage

1. Navigate to a LinkedIn profile page (linkedin.com/in/username)
2. Click the extension icon in Chrome toolbar
3. The extension will extract the profile name automatically
4. Verify/edit the information
5. Click "Create Candidate in Salesforce"
6. The new candidate record will open in a new tab

## Troubleshooting

### "Failed to connect" error

- Verify the Consumer Key is correct
- Check that the Callback URL matches exactly
- For sandbox, ensure you're using test.salesforce.com

### Profile data not extracted

- LinkedIn frequently changes their page structure
- Try refreshing the LinkedIn page
- Manually enter the name in the extension

### "Access token expired"

- Click "Disconnect from Salesforce" and reconnect

## Moving to Production

1. Update `popup.js`:
   - Change `salesforceLoginUrl` to `'https://login.salesforce.com'`
   - Update `recordTypeId` if different in Production
2. Create a new Connected App in Production (or promote existing)
3. Update the Consumer Key

## Files

- `manifest.json` - Extension configuration
- `popup.html` - Extension popup UI
- `popup.js` - Main extension logic
- `content.js` - Script that runs on LinkedIn pages
- `content.css` - Styles for LinkedIn page modifications
- `background.js` - Service worker for background tasks
- `icons/` - Extension icons (16x16, 48x48, 128x128)

## Security Notes

- The access token is stored locally in Chrome storage
- Never commit the Consumer Secret (we use the public OAuth flow)
- The extension only has access to LinkedIn and Salesforce domains
