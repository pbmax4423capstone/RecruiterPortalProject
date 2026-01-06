# Production Deployment - Next Steps

## ✅ Completed Steps

1. **Connected App Status**: The LinkedIn Import Extension Connected App already exists in Production with Consumer Key: `3MVG9AR068fT4usyVQdDlbJ3XVwtPbfdsuFVEcup3mEwR.dQlnrkDltgNCeCXb6bRrC.uTfLjhvHaFkrn7bWd`

2. **Record Type Verification**: Confirmed Production Candidate Record Type ID: `0125f000000a5IlAAI`

3. **Code Updates Completed**:
   - ✅ Edge extension: Updated to use `https://login.salesforce.com`
   - ✅ Edge extension: Removed hardcoded `testRecruiterId`
   - ✅ Edge extension: Implemented dynamic user ID fetching with error handling
   - ✅ Chrome extension: Updated to use `https://login.salesforce.com`
   - ✅ Chrome extension: Removed hardcoded `testRecruiterId`
   - ✅ Chrome extension: Implemented dynamic user ID fetching with error handling

## 📋 Manual Steps Required

### Step 1: Load Extensions in Browsers

#### Edge Browser:
1. Open Edge and navigate to: `edge://extensions/`
2. Enable "Developer mode" (toggle in bottom left)
3. Click "Load unpacked"
4. Navigate to: `c:\SF Projects VS Code\RecruiterPortal\RecruiterPortal\edge-extension-linkedin`
5. **Copy the Extension ID** (looks like: `abcdefghijklmnopqrstuvwxyz123456`)

#### Chrome Browser:
1. Open Chrome and navigate to: `chrome://extensions/`
2. Enable "Developer mode" (toggle in top right)
3. Click "Load unpacked"
4. Navigate to: `c:\SF Projects VS Code\RecruiterPortal\RecruiterPortal\chrome-extension-linkedin`
5. **Copy the Extension ID** (looks like: `abcdefghijklmnopqrstuvwxyz123456`)

### Step 2: Update Connected App with Production Extension IDs

1. **Log into Production Org**:
   - Navigate to: https://login.salesforce.com
   - Username: `patrickbakeradmin2@financialguide.com`
   - Or use: `sf org open --target-org ProductionCapstone`

2. **Update Connected App**:
   - Go to: **Setup** → **App Manager**
   - Search for: **LinkedIn Import Extension**
   - Click the dropdown arrow → **Edit**
   - Scroll to **Callback URL** section

3. **Add Both Extension Callback URLs**:
   ```
   https://[EDGE-EXTENSION-ID].chromiumapp.org/
   https://[CHROME-EXTENSION-ID].chromiumapp.org/
   ```
   
   **Note**: Keep the existing callback URLs in the list (they won't hurt anything)

4. **Save** the Connected App

### Step 3: Test Edge Extension

1. **Load Edge Extension** (if not already loaded from Step 1)

2. **Navigate to a LinkedIn Profile** (e.g., https://www.linkedin.com/in/someone/)

3. **Click the Extension Icon** in the Edge toolbar (or the popup should appear)

4. **Click "Connect to Salesforce"**:
   - Should redirect to: `https://login.salesforce.com` (NOT `test.salesforce.com`)
   - Login with Production credentials
   - Authorize the app

5. **Import a Test Candidate**:
   - Fill in the form with LinkedIn profile data
   - Click "Import to Salesforce"
   - Verify success message

6. **Verify in Production**:
   - Go to Salesforce Production org
   - Navigate to Candidates tab
   - Find the newly created candidate
   - **Check the "Recruiting Manager" field** - should be YOUR user, not Rachyll Tenny

### Step 4: Test Chrome Extension

Repeat the same testing steps for Chrome extension:
1. Load Chrome extension
2. Navigate to LinkedIn profile
3. Connect to Salesforce (should use `login.salesforce.com`)
4. Import test candidate
5. Verify in Production that Recruiting Manager is set to current user

### Step 5: Verify Error Handling

Test that the error handling works correctly:

1. **Clear Extension Storage** (to simulate missing user ID):
   - In Edge/Chrome: `F12` → **Application** tab → **Storage** → **Extension** → **Clear**
   - Or right-click extension icon → **Remove**

2. **Reload Extension** without reconnecting to Salesforce

3. **Try to Import Candidate** - should see error:
   > "Unable to create candidate: User authentication incomplete. Please reconnect to Salesforce."

4. **Reconnect** and verify it works again

## 🔍 Troubleshooting

### Issue: "Failed to connect" Error
- **Check**: Extension ID is added to Connected App callback URLs
- **Solution**: Verify the exact Extension ID matches what's in the Connected App

### Issue: Still Connecting to test.salesforce.com
- **Check**: Make sure you reloaded the extension after code changes
- **Solution**: Go to `edge://extensions/` or `chrome://extensions/` and click the **Reload** button

### Issue: "User authentication incomplete" Error
- **Check**: The extension has been authenticated at least once
- **Solution**: Click "Connect to Salesforce" and complete OAuth flow

### Issue: Candidate Created with Wrong Recruiter
- **Check**: Extension is fetching user ID from OAuth response
- **Solution**: Disconnect and reconnect to force new authentication

## 📝 Key Changes Made

### Edge Extension Files Updated:
- **edge-extension-linkedin/background.js**:
  - Removed `testRecruiterId: '0055f00000DqpnpAAB'`
  - Added dynamic user ID fetching from `chrome.storage.local`
  - Added error handling for missing user ID
  
- **edge-extension-linkedin/popup.js**:
  - Changed `salesforceLoginUrl` from `'https://test.salesforce.com'` to `'https://login.salesforce.com'`
  - Removed `testRecruiterId` field
  - Updated comments to reflect Production setup

### Chrome Extension Files Updated:
- **chrome-extension-linkedin/background.js**:
  - Removed `testRecruiterId: '0055f00000DqpnpAAB'`
  - Added dynamic user ID fetching from `chrome.storage.local`
  - Added error handling for missing user ID
  
- **chrome-extension-linkedin/popup.js**:
  - Changed `salesforceLoginUrl` from `'https://test.salesforce.com'` to `'https://login.salesforce.com'`
  - Removed `testRecruiterId` field
  - Updated comments to reflect Production setup

## 🎯 Expected Behavior After Deployment

1. **OAuth Flow**: Extensions should redirect to `login.salesforce.com` (Production)
2. **User ID**: Automatically fetched after authentication via `/services/oauth2/userinfo`
3. **Candidate Creation**: `Recruiting_Manager__c` field set to currently authenticated user
4. **Error Prevention**: Cannot create candidates without valid user authentication
5. **Record Type**: Uses Production Candidate Record Type: `0125f000000a5IlAAI`

## ⚠️ Important Notes

- The Consumer Key is the **same** for both sandbox and Production (this is unusual but valid)
- The **Extension IDs will be different** for each browser and will change if you reload unpacked extensions
- **Always update the Connected App** with new Extension IDs after reloading extensions
- The extensions now **dynamically fetch the current user's ID** instead of using a hardcoded value

## 🚀 Deployment Complete

Once you've completed the manual steps above and verified both extensions work correctly:
1. The extensions are ready for use in Production
2. All candidates will be assigned to the user who imports them
3. The OAuth flow uses Production login (not sandbox)
4. User authentication is validated before candidate creation

---

**Questions or Issues?** Check the console logs in the extension popup:
- Right-click extension popup → **Inspect**
- Check **Console** tab for detailed logs
