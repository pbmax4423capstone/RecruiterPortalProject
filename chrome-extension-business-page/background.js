// Background service worker
// Handles API calls for content scripts (CORS workaround)
// Includes duplicate detection functionality

const CONFIG = {
  defaults: {
    recordTypeId: '0125f000000a5IlAAI'
  },
  testRecruiterId: '0055f00000DqpnpAAB'
};

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  console.log('[SF Background] Received message:', request.action);
  
  // Open the extension popup in a new window
  if (request.action === 'openPopup') {
    console.log('[SF Background] Opening popup window from tab:', sender.tab?.id, sender.tab?.url);
    console.log('[SF Background] Page data from button:', request.pageData);
    
    // Store the source tab ID and captured page data
    const sourceTabId = sender.tab?.id;
    const sourceTabUrl = sender.tab?.url;
    const pageData = request.pageData || null;
    
    chrome.storage.local.set({ 
      sourceTabId: sourceTabId,
      sourceTabUrl: sourceTabUrl,
      capturedPageData: pageData
    }, () => {
      chrome.windows.create({
        url: chrome.runtime.getURL('popup.html'),
        type: 'popup',
        width: 500,
        height: 700,
        focused: true
      }, (window) => {
        if (chrome.runtime.lastError) {
          console.error('[SF Background] Failed to create window:', chrome.runtime.lastError);
          sendResponse({ success: false, error: chrome.runtime.lastError.message });
        } else {
          console.log('[SF Background] Popup window created:', window);
          sendResponse({ success: true });
        }
      });
    });
    return true; // Keep channel open for async response
  }
  
  // Check for duplicates
  if (request.action === 'checkDuplicates') {
    console.log('[SF Background] Processing checkDuplicates');
    handleCheckDuplicates(request.data)
      .then(result => {
        console.log('[SF Background] checkDuplicates result:', result);
        sendResponse(result);
      })
      .catch(error => {
        console.error('[SF Background] checkDuplicates error:', error);
        sendResponse({ success: false, error: error.message });
      });
    return true;
  }

  // Create candidate with contact info and duplicate checking already done
  if (request.action === 'createCandidateWithContact') {
    console.log('[SF Background] Processing createCandidateWithContact');
    handleCreateCandidateWithContact(request.data)
      .then(result => {
        console.log('[SF Background] createCandidateWithContact result:', result);
        sendResponse(result);
      })
      .catch(error => {
        console.error('[SF Background] createCandidateWithContact error:', error);
        sendResponse({ success: false, error: error.message });
      });
    return true;
  }
  
  // Handle Feedback submission
  if (request.type === 'CREATE_FEEDBACK') {
    console.log('[SF Background] Processing CREATE_FEEDBACK');
    handleCreateFeedback(request.data)
      .then(result => {
        console.log('[SF Background] CREATE_FEEDBACK result:', result);
        sendResponse(result);
      })
      .catch(error => {
        console.error('[SF Background] CREATE_FEEDBACK error:', error);
        sendResponse({ success: false, error: error.message });
      });
    return true;
  }
  
  // Default response for unknown actions
  sendResponse({ success: false, error: 'Unknown action' });
  return true;
});

// Helper function to properly escape SOQL string literals
function escapeSoql(value) {
  if (!value) return '';
  // Escape single quotes, backslashes, and other special characters
  return value
    .replace(/\\/g, '\\\\')  // Escape backslashes first
    .replace(/'/g, "\\'")     // Escape single quotes
    .replace(/\n/g, '\\n')    // Escape newlines
    .replace(/\r/g, '\\r')    // Escape carriage returns
    .replace(/\t/g, '\\t');   // Escape tabs
}

// Check for duplicate candidates by email, phone, or name
async function handleCheckDuplicates(data) {
  console.log('[SF Background] handleCheckDuplicates called with data:', JSON.stringify(data));
  
  const stored = await chrome.storage.local.get(['accessToken', 'instanceUrl']);
  
  if (!stored.accessToken || !stored.instanceUrl) {
    throw new Error('Not authenticated. Click extension icon to connect.');
  }

  const { firstName, lastName, email, phone } = data;
  const duplicates = [];

  // Build SOQL query to check for duplicates
  const conditions = [];
  
  // Check by email (on both Candidate and Contact)
  if (email) {
    const escapedEmail = escapeSoql(email);
    conditions.push(`Email__c = '${escapedEmail}'`);
    conditions.push(`Personal_Email__c = '${escapedEmail}'`);
  }
  
  // Check by phone
  if (phone) {
    const cleanPhone = phone.replace(/\D/g, ''); // Remove non-digits
    if (cleanPhone.length >= 10) {
      // Only use digits in LIKE query, no escaping needed for numbers
      conditions.push(`Mobile__c LIKE '%${cleanPhone.slice(-10)}%'`);
    }
  }
  
  // Check by exact name match
  if (firstName && lastName) {
    const escapedFirstName = escapeSoql(firstName);
    const escapedLastName = escapeSoql(lastName);
    conditions.push(`(First_Name__c = '${escapedFirstName}' AND Last_Name__c = '${escapedLastName}')`);
  }

  if (conditions.length === 0) {
    return { success: true, duplicates: [] };
  }

  // Query Candidates
  const query = `SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Personal_Email__c, Mobile__c, Status__c, Agency__c, Position__c 
                 FROM Candidate__c 
                 WHERE ${conditions.join(' OR ')} 
                 LIMIT 10`;
  
  console.log('[SF Duplicate Check] Query:', query);

  const response = await fetch(
    `${stored.instanceUrl}/services/data/v59.0/query?q=${encodeURIComponent(query)}`,
    {
      headers: {
        'Authorization': `Bearer ${stored.accessToken}`,
        'Content-Type': 'application/json'
      }
    }
  );

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error[0]?.message || 'Duplicate check failed');
  }

  const result = await response.json();
  
  if (result.records && result.records.length > 0) {
    // Format duplicate records with URLs
    for (const record of result.records) {
      duplicates.push({
        id: record.Id,
        name: record.Name,
        firstName: record.First_Name__c,
        lastName: record.Last_Name__c,
        email: record.Email__c || record.Personal_Email__c,
        phone: record.Mobile__c,
        status: record.Status__c,
        agency: record.Agency__c,
        position: record.Position__c,
        url: `${stored.instanceUrl}/lightning/r/Candidate__c/${record.Id}/view`
      });
    }
  }

  console.log('[SF Duplicate Check] Found duplicates:', duplicates.length);
  
  return { 
    success: true, 
    duplicates: duplicates,
    hasDuplicates: duplicates.length > 0
  };
}

// Create candidate with contact info
async function handleCreateCandidateWithContact(data) {
  console.log('[SF Background] handleCreateCandidateWithContact called with data:', JSON.stringify(data));
  
  const stored = await chrome.storage.local.get(['accessToken', 'instanceUrl']);
  
  if (!stored.accessToken || !stored.instanceUrl) {
    throw new Error('Not authenticated. Click extension icon to connect.');
  }

  const { firstName, lastName, email, phone, company, location, pageUrl, agency, position, status, nextStep } = data;

  console.log('[SF Import] Creating contact with:', { firstName, lastName, email, phone });

  // Step 1: Create Contact WITH email, phone
  const contactBody = {
    FirstName: firstName,
    LastName: lastName
  };
  
  // Add email if provided
  if (email) {
    contactBody.Email = email;
    console.log('[SF Import] Adding email to contactBody:', email);
  }
  
  // Add phone if provided
  if (phone) {
    contactBody.Phone = phone;
    console.log('[SF Import] Adding phone to contactBody:', phone);
  }
  
  console.log('[SF Import] Final contactBody:', JSON.stringify(contactBody));

  const contactResponse = await fetch(`${stored.instanceUrl}/services/data/v59.0/sobjects/Contact`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${stored.accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(contactBody)
  });

  const contactResult = await contactResponse.json();
  
  if (!contactResponse.ok || !contactResult.success) {
    const errorMsg = contactResult.length ? contactResult.map(e => e.message).join(', ') : 
                     contactResult.message || 'Contact creation failed';
    throw new Error(errorMsg);
  }

  console.log('[SF Import] Contact created:', contactResult.id);

  // Step 2: Create Candidate with page URL
  const candidateBody = {
    Name: `${firstName} ${lastName}`,
    First_Name__c: firstName,
    Last_Name__c: lastName,
    Agency__c: agency || 'A157',
    Position__c: position || 'Agent',
    Status__c: status || 'Lead',
    Next_Step__c: nextStep || 'F/up to schedule AI',
    Type__c: 'Candidate',
    Recruiter__c: CONFIG.testRecruiterId,
    RecordTypeId: CONFIG.defaults.recordTypeId,
    Contact__c: contactResult.id
  };

  // Add email to Candidate if provided
  if (email) {
    candidateBody.Email__c = email;
    candidateBody.Personal_Email__c = email;
  }
  
  // Add phone to Candidate if provided
  if (phone) {
    candidateBody.Mobile__c = phone;
  }

  // Store page URL in website field
  if (pageUrl) {
    candidateBody.Website__c = pageUrl;
  }

  const candidateResponse = await fetch(`${stored.instanceUrl}/services/data/v59.0/sobjects/Candidate__c`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${stored.accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(candidateBody)
  });

  const candidateResult = await candidateResponse.json();

  if (candidateResponse.ok && candidateResult.success) {
    console.log('[SF Import] Candidate created:', candidateResult.id);
    return { 
      success: true, 
      candidateId: candidateResult.id,
      contactId: contactResult.id,
      recordUrl: `${stored.instanceUrl}/lightning/r/Candidate__c/${candidateResult.id}/view`
    };
  } else {
    const errorMsg = candidateResult.length ? candidateResult.map(e => e.message).join(', ') : 
                     candidateResult.message || 'Candidate creation failed';
    throw new Error(errorMsg);
  }
}

// Handle extension installation
chrome.runtime.onInstalled.addListener(() => {
  console.log('Business Page to Salesforce extension installed');
});

// Handle Feedback record creation
async function handleCreateFeedback(data) {
  console.log('[SF Background] handleCreateFeedback called with data:', JSON.stringify(data));
  
  const stored = await chrome.storage.local.get(['accessToken', 'instanceUrl']);
  
  if (!stored.accessToken || !stored.instanceUrl) {
    throw new Error('Not authenticated. Please connect to Salesforce first.');
  }

  const feedbackBody = {
    Subject__c: data.Subject__c,
    Feedback_Type__c: data.Feedback_Type__c,
    Description__c: data.Description__c,
    Status__c: data.Status__c || 'New'
  };

  console.log('[SF Feedback] Creating feedback record:', JSON.stringify(feedbackBody));

  const feedbackResponse = await fetch(`${stored.instanceUrl}/services/data/v59.0/sobjects/Feedback__c`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${stored.accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(feedbackBody)
  });

  const feedbackResult = await feedbackResponse.json();
  console.log('[SF Feedback] Response:', JSON.stringify(feedbackResult));

  if (feedbackResponse.ok && feedbackResult.success) {
    return { 
      success: true, 
      feedbackId: feedbackResult.id
    };
  } else {
    const errorMsg = feedbackResult.length ? feedbackResult.map(e => e.message).join(', ') : 
                     feedbackResult.message || 'Feedback creation failed';
    throw new Error(errorMsg);
  }
}
