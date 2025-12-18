// Configuration - UPDATE THESE VALUES
const CONFIG = {
  // ProdTest Sandbox - Change these for Production later
  salesforceLoginUrl: 'https://test.salesforce.com', // Use 'https://login.salesforce.com' for Production
  salesforceInstanceUrl: '', // Will be set after login
  
  // Connected App credentials (create in Salesforce Setup)
  clientId: '3MVG9AR068fT4usyVQdDlbJ3XVwtPbfdsuFVEcup3mEwR.dQlnrkDltgNCeCXb6bRrC.uTfLjhvHaFkrn7bWd', // ProdTest Consumer Key
  redirectUri: chrome.identity.getRedirectURL(),
  
  // Default field values
  defaults: {
    agency: 'A157',
    position: 'Agent',
    status: 'Lead',
    nextStep: 'F/up to schedule AI',
    recordTypeId: '0125f000000a5IlAAI' // Candidate record type
  },
  
  // TESTING: Hardcoded recruiter ID for Rachyll Tenny
  // Remove this when going to production and use currentUserId instead
  testRecruiterId: '0055f00000DqpnpAAB' // Rachyll Tenny's User ID
};

// State
let accessToken = null;
let instanceUrl = null;
let currentUserId = null;

// DOM Elements
let loginSection, mainSection, notLinkedInSection;
let loginBtn, createBtn, logoutBtn;
let statusBar, statusIcon, statusText;
let profileAvatar, profileName, profileHeadline;
let firstNameInput, lastNameInput, linkedinUrlInput;
let agencySelect, positionSelect, statusSelect, nextStepSelect;

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
  initializeElements();
  await checkAuth();
  await checkCurrentTab();
});

function initializeElements() {
  loginSection = document.getElementById('loginSection');
  mainSection = document.getElementById('mainSection');
  notLinkedInSection = document.getElementById('notLinkedInSection');
  
  loginBtn = document.getElementById('loginBtn');
  createBtn = document.getElementById('createBtn');
  logoutBtn = document.getElementById('logoutBtn');
  
  statusBar = document.getElementById('statusBar');
  statusIcon = statusBar.querySelector('.status-icon');
  statusText = statusBar.querySelector('.status-text');
  
  profileAvatar = document.getElementById('profileAvatar');
  profileName = document.getElementById('profileName');
  profileHeadline = document.getElementById('profileHeadline');
  
  firstNameInput = document.getElementById('firstName');
  lastNameInput = document.getElementById('lastName');
  linkedinUrlInput = document.getElementById('linkedinUrl');
  
  agencySelect = document.getElementById('agency');
  positionSelect = document.getElementById('position');
  statusSelect = document.getElementById('status');
  nextStepSelect = document.getElementById('nextStep');
  
  // Event listeners
  loginBtn.addEventListener('click', handleLogin);
  createBtn.addEventListener('click', handleCreateCandidate);
  logoutBtn.addEventListener('click', handleLogout);
}

async function checkAuth() {
  const stored = await chrome.storage.local.get(['accessToken', 'instanceUrl', 'userId']);
  if (stored.accessToken && stored.instanceUrl) {
    accessToken = stored.accessToken;
    instanceUrl = stored.instanceUrl;
    currentUserId = stored.userId;
    
    // Verify token is still valid
    try {
      const response = await fetch(`${instanceUrl}/services/data/v59.0/sobjects/User/${currentUserId}`, {
        headers: { 'Authorization': `Bearer ${accessToken}` }
      });
      
      if (response.ok) {
        showMainSection();
        return;
      }
    } catch (e) {
      console.log('Token expired, need to re-authenticate');
    }
    
    // Token invalid, clear and show login
    await chrome.storage.local.remove(['accessToken', 'instanceUrl', 'userId']);
    accessToken = null;
    instanceUrl = null;
  }
  
  showLoginSection();
}

async function checkCurrentTab() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  console.log('Current tab URL:', tab.url);
  
  if (tab.url && tab.url.includes('linkedin.com/in/')) {
    // On a LinkedIn profile page
    try {
      // First, try to inject the content script if it's not already there
      try {
        await chrome.scripting.executeScript({
          target: { tabId: tab.id },
          files: ['content.js']
        });
        console.log('Content script injected');
      } catch (injectError) {
        console.log('Content script already loaded or injection failed:', injectError);
      }
      
      // Wait a moment for the script to initialize
      await new Promise(resolve => setTimeout(resolve, 500));
      
      const response = await chrome.tabs.sendMessage(tab.id, { action: 'getProfileData' });
      console.log('Profile data response:', response);
      
      if (response && (response.firstName || response.profileUrl)) {
        updateProfilePreview(response);
        // Also update the linkedin URL even if name wasn't found
        if (!response.firstName && response.profileUrl) {
          linkedinUrlInput.value = response.profileUrl;
          showStatus('Profile URL captured. Please enter name manually.', 'info');
        }
      } else {
        // Try to at least get the URL from the tab
        linkedinUrlInput.value = tab.url.split('?')[0];
        showStatus('Could not auto-detect profile. Please enter name manually.', 'info');
      }
    } catch (e) {
      console.log('Could not get profile data:', e);
      // At least set the LinkedIn URL from the tab
      linkedinUrlInput.value = tab.url.split('?')[0];
      showStatus('Please enter candidate information manually.', 'info');
    }
  } else {
    // Not on LinkedIn profile
    if (!accessToken) {
      showLoginSection();
    } else {
      showNotLinkedInSection();
    }
  }
}

function showLoginSection() {
  loginSection.classList.remove('hidden');
  mainSection.classList.add('hidden');
  notLinkedInSection.classList.add('hidden');
}

function showMainSection() {
  loginSection.classList.add('hidden');
  mainSection.classList.remove('hidden');
  notLinkedInSection.classList.add('hidden');
}

function showNotLinkedInSection() {
  loginSection.classList.add('hidden');
  mainSection.classList.add('hidden');
  notLinkedInSection.classList.remove('hidden');
}

function updateProfilePreview(data) {
  if (data.firstName && data.lastName) {
    const initials = (data.firstName[0] || '') + (data.lastName[0] || '');
    profileAvatar.textContent = initials.toUpperCase();
    profileName.textContent = `${data.firstName} ${data.lastName}`;
    profileHeadline.textContent = data.headline || 'LinkedIn Profile';
    
    firstNameInput.value = data.firstName;
    lastNameInput.value = data.lastName;
    linkedinUrlInput.value = data.profileUrl || '';
  }
}

function showStatus(message, type = 'info') {
  statusBar.classList.remove('hidden', 'error', 'success');
  if (type === 'error') {
    statusBar.classList.add('error');
    statusIcon.textContent = '❌';
  } else if (type === 'success') {
    statusBar.classList.add('success');
    statusIcon.textContent = '✅';
  } else {
    statusIcon.textContent = 'ℹ️';
  }
  statusText.textContent = message;
}

async function handleLogin() {
  loginBtn.disabled = true;
  loginBtn.innerHTML = '<span class="loading"><span class="spinner"></span> Connecting...</span>';
  
  try {
    // Log the redirect URL for debugging
    console.log('Redirect URL:', CONFIG.redirectUri);
    
    const authUrl = `${CONFIG.salesforceLoginUrl}/services/oauth2/authorize?` +
      `response_type=token&` +
      `client_id=${encodeURIComponent(CONFIG.clientId)}&` +
      `redirect_uri=${encodeURIComponent(CONFIG.redirectUri)}`;
    
    console.log('Auth URL:', authUrl);
    
    const responseUrl = await chrome.identity.launchWebAuthFlow({
      url: authUrl,
      interactive: true
    });
    
    // Parse the response
    const hashParams = new URLSearchParams(responseUrl.split('#')[1]);
    accessToken = hashParams.get('access_token');
    instanceUrl = hashParams.get('instance_url');
    
    if (!accessToken || !instanceUrl) {
      throw new Error('Failed to get access token');
    }
    
    // Get current user ID
    const userResponse = await fetch(`${instanceUrl}/services/oauth2/userinfo`, {
      headers: { 'Authorization': `Bearer ${accessToken}` }
    });
    const userData = await userResponse.json();
    currentUserId = userData.user_id;
    
    // Store credentials
    await chrome.storage.local.set({
      accessToken,
      instanceUrl,
      userId: currentUserId
    });
    
    showMainSection();
    showStatus('Connected to Salesforce!', 'success');
    
  } catch (error) {
    console.error('Login error:', error);
    showStatus('Failed to connect: ' + error.message, 'error');
    showLoginSection();
  } finally {
    loginBtn.disabled = false;
    loginBtn.innerHTML = '🔐 Connect to Salesforce';
  }
}

async function handleLogout() {
  await chrome.storage.local.remove(['accessToken', 'instanceUrl', 'userId']);
  accessToken = null;
  instanceUrl = null;
  currentUserId = null;
  showLoginSection();
}

async function handleCreateCandidate() {
  const firstName = firstNameInput.value.trim();
  const lastName = lastNameInput.value.trim();
  const linkedinUrl = linkedinUrlInput.value.trim();
  
  if (!firstName || !lastName) {
    showStatus('Please enter first and last name', 'error');
    return;
  }
  
  createBtn.disabled = true;
  createBtn.innerHTML = '<span class="loading"><span class="spinner"></span> Creating...</span>';
  
  try {
    // Validate we have auth
    if (!instanceUrl || !accessToken) {
      throw new Error('Not authenticated. Please reconnect to Salesforce.');
    }
    
    console.log('Instance URL:', instanceUrl);
    console.log('Access Token exists:', !!accessToken);
    
    // Step 1: Create the Contact first
    const contact = {
      FirstName: firstName,
      LastName: lastName
    };
    
    console.log('Creating contact:', contact);
    
    const contactResponse = await fetch(`${instanceUrl}/services/data/v59.0/sobjects/Contact`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(contact)
    });
    
    const contactResponseText = await contactResponse.text();
    console.log('Contact response status:', contactResponse.status);
    console.log('Contact response body:', contactResponseText);
    
    let contactResult;
    try {
      contactResult = JSON.parse(contactResponseText);
    } catch (e) {
      throw new Error(`Invalid contact response: ${contactResponseText}`);
    }
    
    if (!contactResponse.ok || !contactResult.success) {
      const errorMsg = contactResult.length ? contactResult.map(e => e.message).join(', ') : 
                       contactResult.message || JSON.stringify(contactResult);
      throw new Error(`Failed to create Contact: ${errorMsg}`);
    }
    
    const contactId = contactResult.id;
    console.log('Contact created with ID:', contactId);
    
    // Step 2: Create the Candidate linked to the Contact
    // TESTING: Using hardcoded Rachyll Tenny's ID instead of currentUserId
    // For production, change back to: Recruiter__c: currentUserId
    const candidate = {
      Name: `${firstName} ${lastName}`, // Concatenate first and last name
      First_Name__c: firstName,
      Last_Name__c: lastName,
      Agency__c: agencySelect.value,
      Position__c: positionSelect.value,
      Status__c: statusSelect.value,
      Next_Step__c: nextStepSelect.value,
      Type__c: 'Candidate', // Default type for LinkedIn imports
      Recruiter__c: CONFIG.testRecruiterId, // Using Rachyll Tenny for testing
      RecordTypeId: CONFIG.defaults.recordTypeId,
      Contact__c: contactId // Link to the Contact we just created
    };
    
    // Note: LinkedIn_Profile__c field is not accessible via API
    // Storing LinkedIn URL in a different way or skipping for now
    // TODO: Add LinkedIn URL once field permissions are fixed
    
    console.log('Creating candidate:', candidate);
    console.log('LinkedIn URL (not saved):', linkedinUrl);
    
    // Create candidate via REST API
    const response = await fetch(`${instanceUrl}/services/data/v59.0/sobjects/Candidate__c`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(candidate)
    });
    
    const responseText = await response.text();
    console.log('Candidate response status:', response.status);
    console.log('Candidate response body:', responseText);
    
    let result;
    try {
      result = JSON.parse(responseText);
    } catch (e) {
      throw new Error(`Invalid response: ${responseText}`);
    }
    
    console.log('Response OK:', response.ok);
    console.log('Result success:', result.success);
    console.log('Result ID:', result.id);
    
    if (response.ok && result.success) {
      showStatus(`✅ Candidate & Contact created!`, 'success');
      
      // Open the record in Salesforce
      const recordUrl = `${instanceUrl}/lightning/r/Candidate__c/${result.id}/view`;
      console.log('Opening record URL:', recordUrl);
      chrome.tabs.create({ url: recordUrl });
      
    } else if (result.length && result[0].message) {
      // Salesforce returns array of errors
      throw new Error(result.map(e => e.message).join(', '));
    } else if (result.message) {
      throw new Error(result.message);
    } else if (result.error) {
      throw new Error(result.error_description || result.error);
    } else {
      throw new Error(`HTTP ${response.status}: ${JSON.stringify(result)}`);
    }
    
  } catch (error) {
    console.error('Create error:', error);
    showStatus('Failed: ' + error.message, 'error');
  } finally {
    createBtn.disabled = false;
    createBtn.innerHTML = '✨ Create Candidate in Salesforce';
  }
}
