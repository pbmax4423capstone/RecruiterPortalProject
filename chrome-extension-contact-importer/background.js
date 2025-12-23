// Contact Importer - Background Service Worker
// Handles Salesforce API calls to avoid CORS issues

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  console.log('Background received message:', request.action);
  
  switch (request.action) {
    case 'createCandidate':
      createCandidateRecord(request.accessToken, request.instanceUrl, request.candidateData)
        .then(response => sendResponse(response))
        .catch(error => sendResponse({ error: error.message }));
      return true; // Keep message channel open for async response
      
    case 'openPopup':
      // Can't programmatically open popup, but could show notification
      chrome.notifications.create({
        type: 'basic',
        iconUrl: 'icons/icon48.png',
        title: 'Contact Importer',
        message: 'Click the extension icon to import this contact to Salesforce'
      });
      break;
      
    case 'checkAuth':
      chrome.storage.local.get(['accessToken', 'instanceUrl'], sendResponse);
      return true;
  }
});

async function createCandidateRecord(accessToken, instanceUrl, candidateData) {
  try {
    const apiUrl = `${instanceUrl}/services/data/v59.0/sobjects/Candidate__c/`;
    
    console.log('Creating Candidate record:', candidateData);
    
    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(candidateData)
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error('Salesforce API error:', errorData);
      
      // Parse Salesforce error message
      if (errorData && Array.isArray(errorData) && errorData[0]?.message) {
        throw new Error(errorData[0].message);
      }
      throw new Error(`API Error: ${response.status} ${response.statusText}`);
    }

    const result = await response.json();
    console.log('Candidate created successfully:', result);
    
    return {
      success: true,
      id: result.id
    };
  } catch (error) {
    console.error('Error in createCandidateRecord:', error);
    throw error;
  }
}

// Handle extension installation/update
chrome.runtime.onInstalled.addListener((details) => {
  console.log('Contact Importer installed/updated:', details.reason);
  
  // Don't auto-open pages on install - user can access docs from popup footer
});

// Context menu for quick access
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: 'importContact',
    title: 'Import Contact to Salesforce',
    contexts: ['page', 'selection']
  });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === 'importContact') {
    // Open the popup by showing action
    chrome.action.openPopup();
  }
});
