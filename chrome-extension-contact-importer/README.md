# Contact Importer - Chrome Extension

## Overview

A universal Chrome extension for importing contacts from **any website** to Salesforce as Candidate records. Works with LinkedIn, ZoomInfo, company websites, and more.

## Features

### 🌐 Universal Website Support

- **LinkedIn** - Automatically extracts profile data (name, headline, location)
- **ZoomInfo** - Extracts contact information including email and phone
- **Any Website** - Smart detection for:
  - Email addresses
  - Phone numbers
  - Names (from Schema.org markup, vCard, page title)
  - Company names
  - Job titles

### 🔄 Dual Mode Operation

- **Auto Detect** - Automatically extracts contact information from the current page
- **Manual Entry** - Type in contact details for any source

### 🔐 Secure Salesforce Integration

- OAuth 2.0 authentication (no passwords stored)
- Creates Candidate records in Salesforce
- Configurable defaults (Agency, Position, Status)
- Optional: Open record in Salesforce after creation

## Installation

### From Source (Developer Mode)

1. Clone or download this folder
2. Open Chrome and go to `chrome://extensions/`
3. Enable **Developer mode** (toggle in top right)
4. Click **Load unpacked**
5. Select the `chrome-extension-contact-importer` folder

### First Time Setup

1. Click the extension icon in your browser toolbar
2. Click **Login with Salesforce**
3. Enter your Salesforce credentials
4. You're ready to import contacts!

## Usage

### Importing from LinkedIn

1. Navigate to a LinkedIn profile page (linkedin.com/in/...)
2. Click the extension icon (or the floating button)
3. Review the auto-detected information
4. Adjust any fields as needed
5. Click **Create Candidate**

### Importing from ZoomInfo

1. Navigate to a ZoomInfo contact page
2. Click the extension icon
3. Review and confirm the extracted data
4. Click **Create Candidate**

### Importing from Any Website

1. Navigate to any page with contact information
2. Click the extension icon
3. Switch to **Manual Entry** mode if auto-detect doesn't find data
4. Enter the contact details
5. Click **Create Candidate**

### Right-Click Menu

Right-click on any page and select **Import Contact to Salesforce** for quick access.

## Configuration

### Salesforce Settings (in popup.js)

```javascript
const CONFIG = {
  salesforceLoginUrl: "https://test.salesforce.com", // Change to login.salesforce.com for production
  clientId: "YOUR_CONNECTED_APP_CLIENT_ID",
  defaults: {
    agency: "A157",
    position: "Agent",
    status: "Lead",
    recordTypeId: "0125f000000a5IlAAI"
  },
  testRecruiterId: "0055f00000DqpnpAAB"
};
```

## Files Structure

```
chrome-extension-contact-importer/
├── manifest.json      # Extension configuration
├── background.js      # Service worker for API calls
├── content.js         # Page content extraction
├── popup.html         # Extension popup UI
├── popup.js           # Popup logic and OAuth
├── icons/             # Extension icons
│   ├── icon16.png
│   ├── icon48.png
│   └── icon128.png
└── README.md          # This file
```

## Salesforce Connected App Setup

To use this extension with your own Salesforce org:

1. Go to **Setup** > **App Manager** > **New Connected App**
2. Fill in:
   - Connected App Name: `Contact Importer Extension`
   - API Name: `Contact_Importer_Extension`
   - Contact Email: Your email
3. Enable OAuth Settings:
   - Callback URL: `https://<extension-id>.chromiumapp.org/`
   - Selected OAuth Scopes:
     - `api`
     - `refresh_token, offline_access`
4. Save and copy the Consumer Key (Client ID)
5. Update `popup.js` with your Client ID

## Troubleshooting

### "Unable to access current tab"

- Make sure you're on a regular webpage (not chrome:// pages)
- Try refreshing the page

### "Not authenticated"

- Click the Logout button and log in again
- Check if your Salesforce session has expired

### No data detected

- Switch to Manual Entry mode
- Try highlighting text on the page before opening the extension

### CORS errors

- The extension uses a background script to make API calls
- Check that background.js is properly loaded

## Version History

### 2.0.0 (Current)

- Complete rewrite for universal website support
- Added ZoomInfo extraction
- Added generic extraction (emails, phones, names)
- New modern UI with site detection badge
- Added Manual Entry mode
- Right-click context menu

### 1.0.0

- Initial LinkedIn-only version

## License

Capstone Recruiter Portal - Internal Use Only
