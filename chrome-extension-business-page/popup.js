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
  testRecruiterId: '0055f00000DqpnpAAB' // Rachyll Tenny's User ID
};

// State
let accessToken = null;
let instanceUrl = null;
let currentUserId = null;
let pendingDuplicates = null;

// DOM Elements
let loginSection, mainSection;
let loginBtn, checkDuplicatesBtn, logoutBtn;
let statusBar, statusIcon, statusText;
let firstNameInput, lastNameInput, emailInput, phoneInput, companyInput, pageUrlInput;
let agencySelect, positionSelect, statusSelect, nextStepSelect;
let duplicateModal, duplicateList, cancelDuplicateBtn, createAnywayBtn;

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
  
  loginBtn = document.getElementById('loginBtn');
  checkDuplicatesBtn = document.getElementById('checkDuplicatesBtn');
  logoutBtn = document.getElementById('logoutBtn');
  
  statusBar = document.getElementById('statusBar');
  statusIcon = statusBar.querySelector('.status-icon');
  statusText = statusBar.querySelector('.status-text');
  
  firstNameInput = document.getElementById('firstName');
  lastNameInput = document.getElementById('lastName');
  emailInput = document.getElementById('email');
  phoneInput = document.getElementById('phone');
  companyInput = document.getElementById('company');
  pageUrlInput = document.getElementById('pageUrl');
  
  agencySelect = document.getElementById('agency');
  positionSelect = document.getElementById('position');
  statusSelect = document.getElementById('status');
  nextStepSelect = document.getElementById('nextStep');
  
  duplicateModal = document.getElementById('duplicateModal');
  duplicateList = document.getElementById('duplicateList');
  cancelDuplicateBtn = document.getElementById('cancelDuplicateBtn');
  createAnywayBtn = document.getElementById('createAnywayBtn');
  
  // Event listeners
  if (loginBtn) loginBtn.addEventListener('click', handleLogin);
  if (checkDuplicatesBtn) checkDuplicatesBtn.addEventListener('click', handleCheckDuplicates);
  if (logoutBtn) logoutBtn.addEventListener('click', handleLogout);
  if (cancelDuplicateBtn) cancelDuplicateBtn.addEventListener('click', closeDuplicateModal);
  if (createAnywayBtn) createAnywayBtn.addEventListener('click', handleCreateAnyway);
  
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
  // Check if we have captured page data from the button click
  const stored = await chrome.storage.local.get(['sourceTabId', 'sourceTabUrl', 'capturedPageData']);
  console.log('Stored data:', stored);
  
  // If we have captured page data, use it directly!
  if (stored.capturedPageData) {
    console.log('Using captured page data:', stored.capturedPageData);
    updateFormFromPageData(stored.capturedPageData);
    // Clear the stored data
    chrome.storage.local.remove(['sourceTabId', 'sourceTabUrl', 'capturedPageData']);
    return;
  }
  
  showStatus('Enter candidate information manually.', 'info');
}

function showLoginSection() {
  loginSection.classList.remove('hidden');
  mainSection.classList.add('hidden');
}

function showMainSection() {
  loginSection.classList.add('hidden');
  mainSection.classList.remove('hidden');
}

function updateFormFromPageData(data) {
  if (data.email) {
    emailInput.value = data.email;
  }
  if (data.phone) {
    phoneInput.value = data.phone;
  }
  if (data.company) {
    companyInput.value = data.company;
  }
  if (data.pageUrl) {
    pageUrlInput.value = data.pageUrl;
  }
  
  showStatus('Page data captured. Please enter name.', 'info');
}

function showStatus(message, type = 'info') {
  statusBar.classList.remove('hidden', 'error', 'success', 'warning');
  if (type === 'error') {
    statusBar.classList.add('error');
    statusIcon.textContent = '❌';
  } else if (type === 'success') {
    statusBar.classList.add('success');
    statusIcon.textContent = '✅';
  } else if (type === 'warning') {
    statusBar.classList.add('warning');
    statusIcon.textContent = '⚠️';
  } else {
    statusIcon.textContent = 'ℹ️';
  }
  statusText.textContent = message;
}

async function handleLogin() {
  loginBtn.disabled = true;
  loginBtn.innerHTML = '<span class="loading"><span class="spinner"></span> Connecting...</span>';
  
  try {
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

async function handleCheckDuplicates() {
  const firstName = firstNameInput.value.trim();
  const lastName = lastNameInput.value.trim();
  const email = emailInput.value.trim();
  const phone = phoneInput.value.trim();
  
  if (!firstName || !lastName) {
    showStatus('Please enter first and last name', 'error');
    return;
  }
  
  checkDuplicatesBtn.disabled = true;
  checkDuplicatesBtn.innerHTML = '<span class="loading"><span class="spinner"></span> Checking...</span>';
  
  try {
    // Check for duplicates
    const response = await chrome.runtime.sendMessage({
      action: 'checkDuplicates',
      data: {
        firstName,
        lastName,
        email,
        phone
      }
    });
    
    console.log('Duplicate check response:', response);
    
    if (response && response.success) {
      if (response.hasDuplicates && response.duplicates.length > 0) {
        // Show duplicate modal
        showDuplicateModal(response.duplicates);
      } else {
        // No duplicates, create directly
        await createCandidate();
      }
    } else {
      throw new Error(response?.error || 'Duplicate check failed');
    }
    
  } catch (error) {
    console.error('Duplicate check error:', error);
    showStatus('Error checking duplicates: ' + error.message, 'error');
  } finally {
    checkDuplicatesBtn.disabled = false;
    checkDuplicatesBtn.innerHTML = '🔍 Check for Duplicates & Create';
  }
}

function showDuplicateModal(duplicates) {
  pendingDuplicates = duplicates;
  
  // Helper function to escape HTML
  function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
  
  // Build duplicate list using DOM manipulation for security
  duplicateList.innerHTML = ''; // Clear existing content
  
  for (const dup of duplicates) {
    const recordDiv = document.createElement('div');
    recordDiv.className = 'duplicate-record';
    
    // Header
    const headerDiv = document.createElement('div');
    headerDiv.className = 'duplicate-record-header';
    
    const nameSpan = document.createElement('span');
    nameSpan.className = 'duplicate-record-name';
    nameSpan.textContent = dup.name || 'Unknown';
    headerDiv.appendChild(nameSpan);
    
    const link = document.createElement('a');
    link.href = escapeHtml(dup.url);
    link.target = '_blank';
    link.className = 'duplicate-record-link';
    link.textContent = 'View Record →';
    headerDiv.appendChild(link);
    
    recordDiv.appendChild(headerDiv);
    
    // Details
    const detailsDiv = document.createElement('div');
    detailsDiv.className = 'duplicate-record-details';
    
    if (dup.email) {
      const emailDiv = document.createElement('div');
      emailDiv.className = 'duplicate-detail';
      const strong = document.createElement('strong');
      strong.textContent = 'Email';
      emailDiv.appendChild(strong);
      emailDiv.appendChild(document.createTextNode(dup.email));
      detailsDiv.appendChild(emailDiv);
    }
    
    if (dup.phone) {
      const phoneDiv = document.createElement('div');
      phoneDiv.className = 'duplicate-detail';
      const strong = document.createElement('strong');
      strong.textContent = 'Phone';
      phoneDiv.appendChild(strong);
      phoneDiv.appendChild(document.createTextNode(dup.phone));
      detailsDiv.appendChild(phoneDiv);
    }
    
    if (dup.status) {
      const statusDiv = document.createElement('div');
      statusDiv.className = 'duplicate-detail';
      const strong = document.createElement('strong');
      strong.textContent = 'Status';
      statusDiv.appendChild(strong);
      statusDiv.appendChild(document.createTextNode(dup.status));
      detailsDiv.appendChild(statusDiv);
    }
    
    if (dup.agency) {
      const agencyDiv = document.createElement('div');
      agencyDiv.className = 'duplicate-detail';
      const strong = document.createElement('strong');
      strong.textContent = 'Agency';
      agencyDiv.appendChild(strong);
      agencyDiv.appendChild(document.createTextNode(dup.agency));
      detailsDiv.appendChild(agencyDiv);
    }
    
    recordDiv.appendChild(detailsDiv);
    duplicateList.appendChild(recordDiv);
  }
  
  duplicateModal.classList.remove('hidden');
}

function closeDuplicateModal() {
  duplicateModal.classList.add('hidden');
  pendingDuplicates = null;
  showStatus('Duplicate check cancelled. Review existing records.', 'warning');
}

async function handleCreateAnyway() {
  closeDuplicateModal();
  await createCandidate();
}

async function createCandidate() {
  const firstName = firstNameInput.value.trim();
  const lastName = lastNameInput.value.trim();
  const email = emailInput.value.trim();
  const phone = phoneInput.value.trim();
  const company = companyInput.value.trim();
  const pageUrl = pageUrlInput.value.trim();
  
  checkDuplicatesBtn.disabled = true;
  checkDuplicatesBtn.innerHTML = '<span class="loading"><span class="spinner"></span> Creating...</span>';
  
  try {
    const response = await chrome.runtime.sendMessage({
      action: 'createCandidateWithContact',
      data: {
        firstName,
        lastName,
        email,
        phone,
        company,
        pageUrl,
        agency: agencySelect.value,
        position: positionSelect.value,
        status: statusSelect.value,
        nextStep: nextStepSelect.value
      }
    });
    
    console.log('Create response:', response);
    
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
    
    const errorMsg = error.message || '';
    
    if (errorMsg.includes('duplicate value found') || errorMsg.includes('DUPLICATE')) {
      showStatus('⚠️ This person already exists in Salesforce (duplicate email found).', 'error');
    } else if (errorMsg.includes('Session expired') || errorMsg.includes('invalid') || errorMsg.includes('INVALID_SESSION')) {
      await chrome.storage.local.remove(['accessToken', 'instanceUrl', 'userId']);
      showStatus('Session expired. Please disconnect then reconnect to Salesforce.', 'error');
    } else if (errorMsg.includes('REQUIRED_FIELD_MISSING')) {
      showStatus('⚠️ Missing required field. Please fill in all required information.', 'error');
    } else {
      showStatus('Failed: ' + errorMsg, 'error');
    }
  } finally {
    checkDuplicatesBtn.disabled = false;
    checkDuplicatesBtn.innerHTML = '🔍 Check for Duplicates & Create';
  }
}
