// Universal Candidate Creator - Popup Script
// Handles UI logic, form submission, and duplicate detection display

document.addEventListener('DOMContentLoaded', async () => {
  // Check authentication status
  const authStatus = await checkAuth();
  
  if (authStatus.authenticated) {
    showForm();
    await loadExtractedData();
  } else {
    showAuth();
  }

  // Event listeners
  document.getElementById('authButton').addEventListener('click', handleAuth);
  document.getElementById('createButton').addEventListener('click', handleCreate);
  document.getElementById('proceedAnywayButton').addEventListener('click', handleProceedAnyway);
  document.getElementById('logoutButton').addEventListener('click', handleLogout);
});

// Check authentication status
async function checkAuth() {
  return new Promise((resolve) => {
    chrome.runtime.sendMessage({ action: 'checkAuth' }, (response) => {
      resolve(response);
    });
  });
}

// Handle authentication
async function handleAuth() {
  const authButton = document.getElementById('authButton');
  authButton.disabled = true;
  authButton.innerHTML = '<span class="spinner"></span> Connecting...';

  try {
    const response = await new Promise((resolve) => {
      chrome.runtime.sendMessage({ action: 'authenticate' }, resolve);
    });

    if (response.success && response.authenticated) {
      showMessage('Successfully connected to Salesforce!', 'success');
      setTimeout(() => {
        showForm();
        loadExtractedData();
      }, 1000);
    } else {
      throw new Error(response.error || 'Authentication failed');
    }
  } catch (error) {
    showMessage(`Authentication failed: ${error.message}`, 'error');
    authButton.disabled = false;
    authButton.textContent = 'Connect to Salesforce';
  }
}

// Handle logout
async function handleLogout() {
  chrome.runtime.sendMessage({ action: 'logout' }, (response) => {
    if (response.success) {
      showAuth();
      showMessage('Logged out successfully', 'success');
    }
  });
}

// Load extracted data from content script
async function loadExtractedData() {
  // First, try to get from storage
  chrome.storage.local.get(['extractedData'], (result) => {
    if (result.extractedData) {
      populateForm(result.extractedData);
      // Clear the stored data
      chrome.storage.local.remove(['extractedData']);
    } else {
      // If no stored data, request extraction from current tab
      chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        if (tabs[0]) {
          chrome.tabs.sendMessage(tabs[0].id, { action: 'extractData' }, (response) => {
            if (response && response.success && response.data) {
              populateForm(response.data);
            }
          });
        }
      });
    }
  });
}

// Populate form with extracted data
function populateForm(data) {
  if (data.firstName) document.getElementById('firstName').value = data.firstName;
  if (data.lastName) document.getElementById('lastName').value = data.lastName;
  if (data.email) document.getElementById('email').value = data.email;
  if (data.phone) document.getElementById('phone').value = data.phone;
  if (data.birthday) document.getElementById('birthday').value = data.birthday;
  if (data.company) document.getElementById('company').value = data.company;
  if (data.title) document.getElementById('title').value = data.title;
  if (data.location) document.getElementById('location').value = data.location;
  if (data.linkedinUrl) document.getElementById('linkedinUrl').value = data.linkedinUrl;

  // Update profile preview
  if (data.firstName || data.lastName) {
    const previewSection = document.getElementById('profilePreview');
    previewSection.classList.remove('hidden');
    document.getElementById('previewName').textContent = `${data.firstName || ''} ${data.lastName || ''}`.trim();
    document.getElementById('previewTitle').textContent = data.title || '—';
    document.getElementById('previewLocation').textContent = data.location || '—';
  }

  // Update header subtitle with source
  if (data.source) {
    document.getElementById('headerSubtitle').textContent = `Source: ${data.source}`;
  }
}

// Get form data
function getFormData() {
  return {
    firstName: document.getElementById('firstName').value.trim(),
    lastName: document.getElementById('lastName').value.trim(),
    email: document.getElementById('email').value.trim(),
    phone: document.getElementById('phone').value.trim(),
    birthday: document.getElementById('birthday').value.trim(),
    company: document.getElementById('company').value.trim(),
    title: document.getElementById('title').value.trim(),
    location: document.getElementById('location').value.trim(),
    linkedinUrl: document.getElementById('linkedinUrl').value.trim(),
    sourceUrl: document.getElementById('linkedinUrl').value.trim() || window.location.href
  };
}

// Validate form
function validateForm(data) {
  if (!data.firstName || !data.lastName) {
    showMessage('First Name and Last Name are required', 'error');
    return false;
  }
  return true;
}

// Handle create candidate (with duplicate check)
async function handleCreate() {
  const data = getFormData();
  
  if (!validateForm(data)) {
    return;
  }

  const createButton = document.getElementById('createButton');
  createButton.disabled = true;
  createButton.innerHTML = '<span class="spinner"></span> Checking for duplicates...';

  try {
    const response = await new Promise((resolve) => {
      chrome.runtime.sendMessage({ 
        action: 'createCandidate', 
        data: data,
        proceedAnyway: false
      }, resolve);
    });

    if (response.success) {
      // No duplicates, candidate created
      showMessage('Candidate created successfully!', 'success');
      
      // Open the candidate record
      if (response.candidateUrl) {
        setTimeout(() => {
          chrome.tabs.create({ url: response.candidateUrl });
          window.close();
        }, 1500);
      }
    } else if (response.duplicatesFound && response.duplicates) {
      // Duplicates found, show banner
      displayDuplicates(response.duplicates);
      createButton.disabled = false;
      createButton.textContent = 'Create Candidate';
      
      // Disable create button, show proceed anyway button
      createButton.style.display = 'none';
      document.getElementById('proceedAnywayButton').classList.add('show');
    } else {
      throw new Error(response.error || 'Failed to create candidate');
    }
  } catch (error) {
    showMessage(`Error: ${error.message}`, 'error');
    createButton.disabled = false;
    createButton.textContent = 'Create Candidate';
  }
}

// Handle proceed anyway (override duplicate check)
async function handleProceedAnyway() {
  const data = getFormData();
  
  if (!validateForm(data)) {
    return;
  }

  const proceedButton = document.getElementById('proceedAnywayButton');
  proceedButton.disabled = true;
  proceedButton.innerHTML = '<span class="spinner"></span> Creating...';

  try {
    const response = await new Promise((resolve) => {
      chrome.runtime.sendMessage({ 
        action: 'createCandidate', 
        data: data,
        proceedAnyway: true
      }, resolve);
    });

    if (response.success) {
      showMessage('Candidate created successfully!', 'success');
      
      // Hide duplicate banner
      document.getElementById('duplicateBanner').classList.remove('show');
      
      // Open the candidate record
      if (response.candidateUrl) {
        setTimeout(() => {
          chrome.tabs.create({ url: response.candidateUrl });
          window.close();
        }, 1500);
      }
    } else {
      throw new Error(response.error || 'Failed to create candidate');
    }
  } catch (error) {
    showMessage(`Error: ${error.message}`, 'error');
    proceedButton.disabled = false;
    proceedButton.innerHTML = 'Proceed Anyway';
  }
}

// Display duplicate records
function displayDuplicates(duplicates) {
  const banner = document.getElementById('duplicateBanner');
  const list = document.getElementById('duplicateList');
  
  // Clear existing list
  list.innerHTML = '';
  
  // Add each duplicate to the list
  duplicates.forEach(dup => {
    const li = document.createElement('li');
    li.className = 'duplicate-item';
    
    let html = `<strong>${dup.type}: ${dup.name || 'Unknown'}</strong>`;
    
    if (dup.email) {
      html += `<div>Email: ${dup.email}</div>`;
    }
    if (dup.phone) {
      html += `<div>Phone: ${dup.phone}</div>`;
    }
    if (dup.linkedinUrl) {
      html += `<div>LinkedIn: ${dup.linkedinUrl}</div>`;
    }
    
    html += `<div style="margin-top: 5px;"><a href="${dup.url}" target="_blank">View Record →</a></div>`;
    
    li.innerHTML = html;
    list.appendChild(li);
  });
  
  // Show the banner
  banner.classList.add('show');
  
  // Scroll to banner
  banner.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// Show/hide sections
function showAuth() {
  document.getElementById('authSection').classList.remove('hidden');
  document.getElementById('formSection').classList.add('hidden');
  document.getElementById('buttonGroup').classList.add('hidden');
}

function showForm() {
  document.getElementById('authSection').classList.add('hidden');
  document.getElementById('formSection').classList.remove('hidden');
  document.getElementById('buttonGroup').classList.remove('hidden');
}

// Show status message
function showMessage(message, type) {
  const messageEl = document.getElementById('statusMessage');
  messageEl.textContent = message;
  messageEl.className = `status-message show ${type}`;
  
  setTimeout(() => {
    messageEl.classList.remove('show');
  }, 5000);
}
