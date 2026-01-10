// Background service worker
// Handles API calls for content scripts (CORS workaround)

const CONFIG = {
  defaults: {
    recordTypeId: "0125f000000a5IlAAI" // Production Candidate Record Type ID
  }
};

// Helper function to convert "July 23" or "Jul 23" format to YYYY-MM-DD
function parseBirthdayToDate(birthdayStr) {
  if (!birthdayStr) return null;

  const months = {
    january: "01",
    jan: "01",
    february: "02",
    feb: "02",
    march: "03",
    mar: "03",
    april: "04",
    apr: "04",
    may: "05",
    june: "06",
    jun: "06",
    july: "07",
    jul: "07",
    august: "08",
    aug: "08",
    september: "09",
    sep: "09",
    sept: "09",
    october: "10",
    oct: "10",
    november: "11",
    nov: "11",
    december: "12",
    dec: "12"
  };

  // Match patterns like "July 23", "Jul 23", "23 July", etc.
  const match = birthdayStr.match(/(\w+)\s+(\d{1,2})|(\d{1,2})\s+(\w+)/i);
  if (!match) return null;

  let monthName, day;
  if (match[1] && match[2]) {
    monthName = match[1].toLowerCase();
    day = match[2];
  } else if (match[3] && match[4]) {
    day = match[3];
    monthName = match[4].toLowerCase();
  }

  const month = months[monthName];
  if (!month) return null;

  // Use current year or a placeholder year (Salesforce Birthdate needs full date)
  const year = new Date().getFullYear();
  const dayPadded = day.padStart(2, "0");

  return `${year}-${month}-${dayPadded}`;
}

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  console.log("[SF Background] Received message:", request.action);

  // Open the extension popup in a new window
  if (request.action === "openPopup") {
    console.log(
      "[SF Background] Opening popup window from tab:",
      sender.tab?.id,
      sender.tab?.url
    );
    console.log(
      "[SF Background] Profile data from button:",
      request.profileData
    );

    // Store the source tab ID and captured profile data
    const sourceTabId = sender.tab?.id;
    const sourceTabUrl = sender.tab?.url;
    const profileData = request.profileData || null;

    chrome.storage.local.set(
      {
        sourceTabId: sourceTabId,
        sourceTabUrl: sourceTabUrl,
        capturedProfileData: profileData
      },
      () => {
        chrome.windows.create(
          {
            url: chrome.runtime.getURL("popup.html"),
            type: "popup",
            width: 420,
            height: 650,
            focused: true
          },
          (window) => {
            if (chrome.runtime.lastError) {
              console.error(
                "[SF Background] Failed to create window:",
                chrome.runtime.lastError
              );
              sendResponse({
                success: false,
                error: chrome.runtime.lastError.message
              });
            } else {
              console.log("[SF Background] Popup window created:", window);
              sendResponse({ success: true });
            }
          }
        );
      }
    );
    return true; // Keep channel open for async response
  }

  if (request.action === "showPopup") {
    chrome.storage.local.set({ pendingProfileData: request.data });
    sendResponse({ success: true });
    return true;
  }

  // Handle API calls from content script (old version without contact info)
  if (request.action === "createCandidate") {
    handleCreateCandidate(request.data)
      .then((result) => {
        console.log("[SF Background] createCandidate result:", result);
        sendResponse(result);
      })
      .catch((error) => {
        console.error("[SF Background] createCandidate error:", error);
        sendResponse({ success: false, error: error.message });
      });
    return true; // Keep message channel open for async response
  }

  // Handle new version with contact info (email, phone)
  if (request.action === "createCandidateWithContact") {
    console.log("[SF Background] Processing createCandidateWithContact");
    handleCreateCandidateWithContact(request.data)
      .then((result) => {
        console.log(
          "[SF Background] createCandidateWithContact result:",
          result
        );
        sendResponse(result);
      })
      .catch((error) => {
        console.error(
          "[SF Background] createCandidateWithContact error:",
          error
        );
        sendResponse({ success: false, error: error.message });
      });
    return true; // CRITICAL: Keep message channel open for async response
  }

  // Handle Feedback submission
  if (request.type === "CREATE_FEEDBACK") {
    console.log("[SF Background] Processing CREATE_FEEDBACK");
    handleCreateFeedback(request.data)
      .then((result) => {
        console.log("[SF Background] CREATE_FEEDBACK result:", result);
        sendResponse(result);
      })
      .catch((error) => {
        console.error("[SF Background] CREATE_FEEDBACK error:", error);
        sendResponse({ success: false, error: error.message });
      });
    return true;
  }

  // Default response for unknown actions
  sendResponse({ success: false, error: "Unknown action" });
  return true;
});

// New handler that includes email, phone, linkedinUrl on the Contact
async function handleCreateCandidateWithContact(data) {
  console.log(
    "[SF Background] handleCreateCandidateWithContact called with data:",
    JSON.stringify(data)
  );

  const stored = await chrome.storage.local.get(["accessToken", "instanceUrl"]);

  if (!stored.accessToken || !stored.instanceUrl) {
    throw new Error("Not authenticated. Click extension icon to connect.");
  }

  const {
    firstName,
    lastName,
    email,
    phone,
    birthday,
    linkedinUrl,
    agency,
    position,
    status,
    nextStep
  } = data;

  console.log(
    "[SF Import] Destructured values - email:",
    email,
    "phone:",
    phone,
    "birthday:",
    birthday
  );
  console.log("[SF Import] Creating contact with:", {
    firstName,
    lastName,
    email,
    phone,
    birthday,
    linkedinUrl
  });

  // Step 1: Create Contact WITH email, phone, and birthdate
  const contactBody = {
    FirstName: firstName,
    LastName: lastName
  };

  // Add email if provided
  if (email) {
    contactBody.Email = email;
    console.log("[SF Import] Adding email to contactBody:", email);
  }

  // Add phone if provided
  if (phone) {
    contactBody.Phone = phone;
    console.log("[SF Import] Adding phone to contactBody:", phone);
  }

  // Add birthdate if provided - store as text (e.g., "July 23")
  if (birthday) {
    contactBody.Birthday__c = birthday;
    console.log("[SF Import] Setting birthday text field:", birthday);
  }

  console.log("[SF Import] Final contactBody:", JSON.stringify(contactBody));

  const contactResponse = await fetch(
    `${stored.instanceUrl}/services/data/v59.0/sobjects/Contact`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${stored.accessToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(contactBody)
    }
  );

  const contactResult = await contactResponse.json();

  if (!contactResponse.ok || !contactResult.success) {
    const errorMsg = contactResult.length
      ? contactResult.map((e) => e.message).join(", ")
      : contactResult.message || "Contact creation failed";
    throw new Error(errorMsg);
  }

  console.log("[SF Import] Contact created:", contactResult.id);

  // Step 2: Create Candidate with LinkedIn URL
  // Get current user ID for Recruiter field
  const userInfo = await chrome.storage.local.get(["userId"]);
  if (!userInfo.userId) {
    throw new Error(
      "Unable to create candidate: User authentication incomplete. Please reconnect to Salesforce."
    );
  }

  const candidateBody = {
    Name: `${firstName} ${lastName}`,
    First_Name__c: firstName,
    Last_Name__c: lastName,
    Agency__c: agency || "A157",
    Position__c: position || "Agent",
    Status__c: status || "Lead",
    Next_Step__c: nextStep || "F/up to schedule AI",
    Type__c: "Candidate",
    Recruiter__c: userInfo.userId,
    RecordTypeId: CONFIG.defaults.recordTypeId,
    Contact__c: contactResult.id
  };

  // Add email to Candidate if provided
  if (email) {
    candidateBody.Email__c = email;
    candidateBody.Personal_Email__c = email; // Also populate personal email
  }

  // Add phone to Candidate if provided
  if (phone) {
    candidateBody.Mobile__c = phone;
  }

  // Store LinkedIn URL in website field
  if (linkedinUrl) {
    candidateBody.Website__c = linkedinUrl;
  }

  const candidateResponse = await fetch(
    `${stored.instanceUrl}/services/data/v59.0/sobjects/Candidate__c`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${stored.accessToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(candidateBody)
    }
  );

  const candidateResult = await candidateResponse.json();

  if (candidateResponse.ok && candidateResult.success) {
    console.log("[SF Import] Candidate created:", candidateResult.id);
    return {
      success: true,
      candidateId: candidateResult.id,
      contactId: contactResult.id,
      recordUrl: `${stored.instanceUrl}/lightning/r/Candidate__c/${candidateResult.id}/view`
    };
  } else {
    const errorMsg = candidateResult.length
      ? candidateResult.map((e) => e.message).join(", ")
      : candidateResult.message || "Candidate creation failed";
    throw new Error(errorMsg);
  }
}

// Original handler (for backward compatibility)
async function handleCreateCandidate(data) {
  const stored = await chrome.storage.local.get(["accessToken", "instanceUrl"]);

  if (!stored.accessToken || !stored.instanceUrl) {
    throw new Error("Not authenticated. Click extension icon to connect.");
  }

  const { firstName, lastName, agency, position, status, nextStep } = data;

  // Get current user ID for Recruiter field
  const userInfo = await chrome.storage.local.get(["userId"]);
  if (!userInfo.userId) {
    throw new Error(
      "Unable to create candidate: User authentication incomplete. Please reconnect to Salesforce."
    );
  }

  // Step 1: Create Contact
  const contactResponse = await fetch(
    `${stored.instanceUrl}/services/data/v59.0/sobjects/Contact`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${stored.accessToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ FirstName: firstName, LastName: lastName })
    }
  );

  const contactResult = await contactResponse.json();

  if (!contactResponse.ok || !contactResult.success) {
    const errorMsg = contactResult.length
      ? contactResult.map((e) => e.message).join(", ")
      : contactResult.message || "Contact creation failed";
    throw new Error(errorMsg);
  }

  // Step 2: Create Candidate
  const candidateResponse = await fetch(
    `${stored.instanceUrl}/services/data/v59.0/sobjects/Candidate__c`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${stored.accessToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        Name: `${firstName} ${lastName}`,
        First_Name__c: firstName,
        Last_Name__c: lastName,
        Agency__c: agency,
        Position__c: position,
        Status__c: status,
        Next_Step__c: nextStep,
        Type__c: "Candidate",
        Recruiter__c: userInfo.userId,
        RecordTypeId: CONFIG.defaults.recordTypeId,
        Contact__c: contactResult.id
      })
    }
  );

  const candidateResult = await candidateResponse.json();

  if (candidateResponse.ok && candidateResult.success) {
    return {
      success: true,
      candidateId: candidateResult.id,
      recordUrl: `${stored.instanceUrl}/lightning/r/Candidate__c/${candidateResult.id}/view`
    };
  } else {
    const errorMsg = candidateResult.length
      ? candidateResult.map((e) => e.message).join(", ")
      : candidateResult.message || "Candidate creation failed";
    throw new Error(errorMsg);
  }
}

// Handle extension installation
chrome.runtime.onInstalled.addListener(() => {
  console.log("LinkedIn to Salesforce extension installed");
});

// Handle Feedback record creation
async function handleCreateFeedback(data) {
  console.log(
    "[SF Background] handleCreateFeedback called with data:",
    JSON.stringify(data)
  );

  const stored = await chrome.storage.local.get(["accessToken", "instanceUrl"]);

  if (!stored.accessToken || !stored.instanceUrl) {
    throw new Error("Not authenticated. Please connect to Salesforce first.");
  }

  const feedbackBody = {
    Subject__c: data.Subject__c,
    Feedback_Type__c: data.Feedback_Type__c,
    Description__c: data.Description__c,
    Status__c: data.Status__c || "New"
  };

  console.log(
    "[SF Feedback] Creating feedback record:",
    JSON.stringify(feedbackBody)
  );

  const feedbackResponse = await fetch(
    `${stored.instanceUrl}/services/data/v59.0/sobjects/Feedback__c`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${stored.accessToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(feedbackBody)
    }
  );

  const feedbackResult = await feedbackResponse.json();
  console.log("[SF Feedback] Response:", JSON.stringify(feedbackResult));

  if (feedbackResponse.ok && feedbackResult.success) {
    return {
      success: true,
      feedbackId: feedbackResult.id
    };
  } else {
    const errorMsg = feedbackResult.length
      ? feedbackResult.map((e) => e.message).join(", ")
      : feedbackResult.message || "Feedback creation failed";
    throw new Error(errorMsg);
  }
}
