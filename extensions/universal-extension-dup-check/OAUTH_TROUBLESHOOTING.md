# OAuth Authentication Troubleshooting

## Error: "Authorization page could not be loaded"

This error occurs when the Salesforce Connected App doesn't have the Chrome extension's redirect URI registered.

### Step 1: Get Your Extension's Redirect URI

1. Load the extension in Chrome (`chrome://extensions/`)
2. Open Chrome DevTools Console (F12)
3. Run this command:
   ```javascript
   chrome.runtime.sendMessage({action: 'getRedirectUri'}, response => console.log('Redirect URI:', response.redirectUri));
   ```
4. Copy the redirect URI (should look like: `https://abcdefghijklmnop.chromiumapp.org/`)

**OR** use this simpler method:

1. Click the extension icon
2. Open browser console (F12)
3. Look for log message: `[Universal SF] Redirect URI: https://...`
4. Copy that URL

### Step 2: Add Redirect URI to Salesforce Connected App

1. Log into Salesforce (test.salesforce.com for sandbox)
2. Go to **Setup** → **App Manager**
3. Find your Connected App (should have Client ID: `3MVG9AR068fT4usyVQdDlbJ3XVwtPbfdsuFVEcup3mEwR...`)
4. Click dropdown → **Edit**
5. Scroll to **OAuth Settings**
6. In **Callback URL** field, add your extension's redirect URI on a new line:
   ```
   https://YOUR-EXTENSION-ID.chromiumapp.org/
   ```
7. Ensure these OAuth scopes are selected:
   - Full access (full)
   - Perform requests at any time (refresh_token, offline_access)
   - Access unique user identifiers (openid)
8. Click **Save**
9. Wait 2-10 minutes for changes to propagate

### Step 3: Retry Authentication

1. Reload the extension in Chrome
2. Click extension icon
3. Click "Connect to Salesforce"
4. Should now successfully authenticate

### Alternative: Use Existing LinkedIn Extension Redirect URI

If you already have the LinkedIn Chrome extension working:

1. Get the LinkedIn extension's redirect URI from its logs
2. Copy the **entire** `extensions/universal-extension-dup-check` folder
3. Load it as a new extension with the SAME extension ID as the LinkedIn one
   (This is complex - easier to just add the new redirect URI to Salesforce)

### Still Not Working?

Check these:

1. **Client ID mismatch**: Verify the clientId in `background.js` matches your Salesforce Connected App
2. **Wrong Salesforce org**: Using `test.salesforce.com` for sandbox, `login.salesforce.com` for production
3. **Extension not loaded**: Verify extension shows in `chrome://extensions/` with no errors
4. **Browser console errors**: Check for CORS or network errors in F12 DevTools
5. **Connected App disabled**: Verify the app is active in Salesforce Setup

### Get Extension ID

Your extension ID is visible in `chrome://extensions/` under the extension name. It's a 32-character string like `abcdefghijklmnopqrstuvwxyz123456`.

### Quick Fix Script

Run this in Salesforce Developer Console (Anonymous Apex) to verify your Connected App:

```apex
ConnectedApplication app = [SELECT Id, Name, OptionsAllowAdminApprovedUsersOnly, 
                             MobileStartUrl, CallbackUrl 
                             FROM ConnectedApplication 
                             WHERE Name LIKE '%Recruiter%' 
                             LIMIT 1];
System.debug('App Name: ' + app.Name);
System.debug('Callback URLs: ' + app.CallbackUrl);
```

The `CallbackUrl` field should include your extension's redirect URI.

---

## Manual OAuth Token Method (Workaround)

If OAuth continues to fail, you can manually obtain tokens:

1. Open this URL in your browser (replace CLIENT_ID):
   ```
   https://test.salesforce.com/services/oauth2/authorize?response_type=token&client_id=YOUR_CLIENT_ID&redirect_uri=https://login.salesforce.com/
   ```
2. Log in and authorize
3. Copy the `access_token` and `instance_url` from the redirect URL
4. Store them manually in the extension:
   ```javascript
   chrome.storage.local.set({
     accessToken: 'YOUR_ACCESS_TOKEN',
     instanceUrl: 'YOUR_INSTANCE_URL',
     userId: 'YOUR_USER_ID'
   });
   ```
5. Reload extension popup

This is temporary (tokens expire) but useful for testing.
