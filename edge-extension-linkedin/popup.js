// Configuration - Production Setup
const CONFIG = {
  // Production Salesforce Login
  salesforceLoginUrl: 'https://login.salesforce.com',
  salesforceInstanceUrl: '', // Will be set after login
  
  // Connected App credentials (create in Salesforce Setup)
  clientId: '3MVG9p1Q1BCe9GmCK.2GT3FP11uBOviHb5qJPJvlkCtUE52LJ_ODY9s2ea_B5E3Fw3xVeiYH3bxLOESNXIMHF', // Production Consumer Key
  redirectUri: chrome.identity.getRedirectURL(),
  
  // Default field values
  defaults: {
    agency: 'A157',
    position: 'Agent',
    status: 'Lead',
    nextStep: 'F/up to schedule AI',
    recordTypeId: '0125f000000a5IlAAI' // Production Candidate Record Type ID
  }
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
let firstNameInput, lastNameInput, linkedinUrlInput, emailInput, phoneInput, birthdayInput;
let agencySelect, positionSelect, statusSelect, nextStepSelect;

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
  initializeElements();
  await checkAuth();
  await checkCurrentTab();
});

function initializeElements() {
  console.log('[Popup] Initializing elements...');
  
  loginSection = document.getElementById('loginSection');
  mainSection = document.getElementById('mainSection');
  notLinkedInSection = document.getElementById('notLinkedInSection');
  
  loginBtn = document.getElementById('loginBtn');
  createBtn = document.getElementById('createBtn');
  logoutBtn = document.getElementById('logoutBtn');
  
  console.log('[Popup] createBtn found:', createBtn);
  
  statusBar = document.getElementById('statusBar');
  statusIcon = statusBar.querySelector('.status-icon');
  statusText = statusBar.querySelector('.status-text');
  
  profileAvatar = document.getElementById('profileAvatar');
  profileName = document.getElementById('profileName');
  profileHeadline = document.getElementById('profileHeadline');
  
  firstNameInput = document.getElementById('firstName');
  lastNameInput = document.getElementById('lastName');
  linkedinUrlInput = document.getElementById('linkedinUrl');
  emailInput = document.getElementById('email');
  phoneInput = document.getElementById('phone');
  birthdayInput = document.getElementById('birthday');
  
  agencySelect = document.getElementById('agency');
  positionSelect = document.getElementById('position');
  statusSelect = document.getElementById('status');
  nextStepSelect = document.getElementById('nextStep');
  
  // Event listeners
  if (loginBtn) loginBtn.addEventListener('click', handleLogin);
  if (createBtn) {
    console.log('[Popup] Adding click listener to createBtn');
    createBtn.addEventListener('click', function(e) {
      console.log('[Popup] Create button clicked!');
      e.preventDefault();
      handleCreateCandidate();
    });
  }
  if (logoutBtn) logoutBtn.addEventListener('click', handleLogout);
  
  console.log('[Popup] Elements initialized');
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
  let tab = null;
  
  // First, check if we have captured profile data from the button click
  const stored = await chrome.storage.local.get(['sourceTabId', 'sourceTabUrl', 'capturedProfileData']);
  console.log('Stored data:', stored);
  
  // If we have captured profile data, use it directly!
  if (stored.capturedProfileData) {
    console.log('Using captured profile data:', stored.capturedProfileData);
    updateProfilePreview(stored.capturedProfileData);
    // Clear the stored data
    chrome.storage.local.remove(['sourceTabId', 'sourceTabUrl', 'capturedProfileData']);
    return;
  }
  
  // Otherwise, try to get data from the tab
  if (stored.sourceTabId) {
    try {
      tab = await chrome.tabs.get(stored.sourceTabId);
      console.log('Using source tab:', tab.url);
      chrome.storage.local.remove(['sourceTabId', 'sourceTabUrl', 'capturedProfileData']);
    } catch (e) {
      console.log('Source tab no longer exists:', e);
    }
  }
  
  // Fallback: try current active tab (when clicking extension icon directly)
  if (!tab) {
    const tabs = await chrome.tabs.query({ active: true, currentWindow: true });
    tab = tabs[0];
    
    // If current tab isn't LinkedIn, search for a LinkedIn tab
    if (!tab || !tab.url || !tab.url.includes('linkedin.com/in/')) {
      const linkedinTabs = await chrome.tabs.query({ url: '*://*.linkedin.com/in/*' });
      if (linkedinTabs.length > 0) {
        tab = linkedinTabs[0];
        console.log('Found LinkedIn tab:', tab.url);
      }
    }
  }
  
  if (!tab) {
    showStatus('Please navigate to a LinkedIn profile page', 'error');
    return;
  }
  
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
    
    // Populate email, phone, and birthday if available
    if (data.email) {
      emailInput.value = data.email;
    }
    if (data.phone) {
      phoneInput.value = data.phone;
    }
    if (data.birthday) {
      birthdayInput.value = data.birthday;
    }
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
  const email = emailInput.value.trim();
  const phone = phoneInput.value.trim();
  const birthday = birthdayInput.value.trim();
  
  console.log('[Popup] Form values - email:', email, 'phone:', phone, 'birthday:', birthday);
  
  if (!firstName || !lastName) {
    showStatus('Please enter first and last name', 'error');
    return;
  }
  
  createBtn.disabled = true;
  createBtn.innerHTML = '<span class="loading"><span class="spinner"></span> Creating...</span>';
  
  try {
    // Check if we have stored auth - the popup window may need to read from storage
    const stored = await chrome.storage.local.get(['accessToken', 'instanceUrl']);
    if (!stored.accessToken) {
      throw new Error('Not authenticated. Please click the extension icon to connect to Salesforce first.');
    }
    
    console.log('Creating candidate via background script...');
    console.log('With email:', email, 'phone:', phone, 'birthday:', birthday);
    
    // Route through background script to avoid CORS issues
    const response = await chrome.runtime.sendMessage({
      action: 'createCandidateWithContact',
      data: {
        firstName,
        lastName,
        email,
        phone,
        birthday,
        linkedinUrl,
        agency: agencySelect.value,
        position: positionSelect.value,
        status: statusSelect.value,
        nextStep: nextStepSelect.value
      }
    });
    
    console.log('Background response:', response);
    
    if (response && response.success) {
      showStatus(`✅ Candidate & Contact created!`, 'success');
      
      // Open the record in Salesforce
      if (response.recordUrl) {
        console.log('Opening record URL:', response.recordUrl);
        chrome.tabs.create({ url: response.recordUrl });
      }
    } else {
      throw new Error(response?.error || 'Unknown error occurred');
    }
    
  } catch (error) {
    console.error('Create error:', error);
    
    // Check for common errors and provide user-friendly messages
    const errorMsg = error.message || '';
    
    if (errorMsg.includes('duplicate value found') || errorMsg.includes('DUPLICATE')) {
      showStatus('⚠️ This person already exists in Salesforce (duplicate email found).', 'error');
    } else if (errorMsg.includes('Session expired') || errorMsg.includes('invalid') || errorMsg.includes('INVALID_SESSION')) {
      // Clear stored credentials
      await chrome.storage.local.remove(['accessToken', 'instanceUrl', 'userId']);
      showStatus('Session expired. Please click "Disconnect" then reconnect to Salesforce.', 'error');
    } else if (errorMsg.includes('REQUIRED_FIELD_MISSING')) {
      showStatus('⚠️ Missing required field. Please fill in all required information.', 'error');
    } else if (errorMsg.includes('No such column')) {
      showStatus('⚠️ Field configuration error. Please contact your administrator.', 'error');
    } else {
      showStatus('Failed: ' + errorMsg, 'error');
    }
  } finally {
    createBtn.disabled = false;
    createBtn.innerHTML = '✨ Create Candidate in Salesforce';
  }
}

// ============================================
// FEEDBACK FUNCTIONALITY
// ============================================

let selectedFeedbackType = null;

function toggleFeedback() {
  const feedbackSection = document.getElementById('feedbackSection');
  const arrow = document.getElementById('feedbackArrow');
  
  if (feedbackSection.classList.contains('hidden')) {
    feedbackSection.classList.remove('hidden');
    arrow.textContent = '▲';
  } else {
    feedbackSection.classList.add('hidden');
    arrow.textContent = '▼';
  }
}

function selectFbType(button) {
  // Remove selected from all buttons
  document.querySelectorAll('.fb-type-btn').forEach(btn => btn.classList.remove('selected'));
  
  // Select this button
  button.classList.add('selected');
  selectedFeedbackType = button.dataset.type;
  
  // Show the form
  document.getElementById('feedbackForm').classList.remove('hidden');
}

async function submitFeedback() {
  const subject = document.getElementById('fbSubject').value.trim();
  const description = document.getElementById('fbDescription').value.trim();
  const submitBtn = document.getElementById('submitFbBtn');
  const statusDiv = document.getElementById('fbStatus');
  
  if (!selectedFeedbackType) {
    showFbStatus('Please select a feedback type', 'error');
    return;
  }
  
  if (!subject) {
    showFbStatus('Please enter a subject', 'error');
    return;
  }
  
  if (!description) {
    showFbStatus('Please enter a description', 'error');
    return;
  }
  
  // Disable button
  submitBtn.disabled = true;
  submitBtn.textContent = 'Submitting...';
  
  try {
    // Get current user info for submitted by
    const userInfo = currentUserId ? `User ID: ${currentUserId}` : 'Unknown';
    
    // Build description with user info
    const fullDescription = `${description}\n\n--- Submitted via LinkedIn Extension ---\n${userInfo}`;
    
    // Create Feedback record via background script
    const response = await chrome.runtime.sendMessage({
      type: 'CREATE_FEEDBACK',
      data: {
        Subject__c: subject.substring(0, 255),
        Feedback_Type__c: selectedFeedbackType,
        Description__c: fullDescription,
        Status__c: 'New'
      }
    });
    
    if (response && response.success) {
      showFbStatus('✅ Feedback submitted! Thank you.', 'success');
      
      // Reset form
      setTimeout(() => {
        document.getElementById('fbSubject').value = '';
        document.getElementById('fbDescription').value = '';
        document.querySelectorAll('.fb-type-btn').forEach(btn => btn.classList.remove('selected'));
        document.getElementById('feedbackForm').classList.add('hidden');
        selectedFeedbackType = null;
        statusDiv.classList.add('hidden');
      }, 2000);
    } else {
      throw new Error(response?.error || 'Failed to submit feedback');
    }
  } catch (error) {
    console.error('Feedback submission error:', error);
    showFbStatus('❌ Error: ' + error.message, 'error');
  } finally {
    submitBtn.disabled = false;
    submitBtn.textContent = 'Submit Feedback';
  }
}

function showFbStatus(message, type) {
  const statusDiv = document.getElementById('fbStatus');
  statusDiv.textContent = message;
  statusDiv.className = 'fb-status ' + type;
  statusDiv.classList.remove('hidden');
}
