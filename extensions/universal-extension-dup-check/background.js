// Universal Candidate Creator - Background Service Worker
// Handles Salesforce OAuth, duplicate detection, and record creation

const CONFIG = {
  salesforceLoginUrl: "https://test.salesforce.com",
  clientId:
    "3MVG9AR068fT4usyVQdDlbJ3XVwtPbfdsuFVEcup3mEwR.dQlnrkDltgNCeCXb6bRrC.uTfLjhvHaFkrn7bWd",
  get redirectUri() {
    return chrome.identity.getRedirectURL();
  },

  // Hardcoded defaults (not shown in UI)
  defaults: {
    agency: "A157",
    position: "Agent",
    status: "Lead",
    nextStep: "F/up to schedule AI",
    recordTypeId: "0125f000000a5IlAAI"
  }
};

// Context menu setup
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: "saveToSalesforce",
    title: "Save to Salesforce",
    contexts: ["page", "selection"]
  });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === "saveToSalesforce") {
    chrome.action.openPopup();
  }
});

// Message handler
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === "getRedirectUri") {
    sendResponse({ redirectUri: CONFIG.redirectUri });
    return true;
  }

  if (request.action === "authenticate") {
    handleAuthentication()
      .then((result) => sendResponse(result))
      .catch((error) => sendResponse({ success: false, error: error.message }));
    return true;
  }

  if (request.action === "openPopupWindow") {
    chrome.windows.create(
      {
        url: chrome.runtime.getURL("popup.html"),
        type: "popup",
        width: 420,
        height: 650,
        focused: true
      },
      (windowInfo) => {
        if (chrome.runtime.lastError) {
          sendResponse({
            success: false,
            error: chrome.runtime.lastError.message
          });
        } else {
          sendResponse({ success: true, windowId: windowInfo?.id });
        }
      }
    );
    return true;
  }

  if (request.action === "checkAuth") {
    checkAuthStatus()
      .then((result) => sendResponse(result))
      .catch((error) => sendResponse({ success: false, authenticated: false }));
    return true;
  }

  if (request.action === "createCandidate") {
    handleCreateCandidate(request.data, request.proceedAnyway)
      .then((result) => sendResponse(result))
      .catch((error) => sendResponse({ success: false, error: error.message }));
    return true;
  }

  if (request.action === "logout") {
    chrome.storage.local
      .remove(["accessToken", "instanceUrl", "userId"])
      .then(() => sendResponse({ success: true }))
      .catch((error) => sendResponse({ success: false, error: error.message }));
    return true;
  }
});

// OAuth authentication
async function handleAuthentication() {
  const redirectUri = CONFIG.redirectUri;
  console.log("[Universal SF] Redirect URI:", redirectUri);

  const authUrl =
    `${CONFIG.salesforceLoginUrl}/services/oauth2/authorize?` +
    `response_type=token&` +
    `client_id=${CONFIG.clientId}&` +
    `redirect_uri=${encodeURIComponent(redirectUri)}`;

  console.log("[Universal SF] Auth URL:", authUrl);

  return new Promise((resolve, reject) => {
    chrome.identity.launchWebAuthFlow(
      { url: authUrl, interactive: true },
      async (redirectUrl) => {
        if (chrome.runtime.lastError) {
          console.error(
            "[Universal SF] Auth flow error:",
            chrome.runtime.lastError
          );
          reject(new Error(chrome.runtime.lastError.message));
          return;
        }

        if (!redirectUrl) {
          console.error("[Universal SF] No redirect URL received");
          reject(new Error("No redirect URL received"));
          return;
        }

        console.log("[Universal SF] Redirect URL received:", redirectUrl);

        try {
          const params = new URLSearchParams(redirectUrl.split("#")[1]);
          const accessToken = params.get("access_token");
          const instanceUrl = params.get("instance_url");

          if (!accessToken || !instanceUrl) {
            reject(new Error("Missing access token or instance URL"));
            return;
          }

          // Get user info
          const userInfoResponse = await fetch(
            `${instanceUrl}/services/oauth2/userinfo`,
            {
              headers: { Authorization: `Bearer ${accessToken}` }
            }
          );

          if (!userInfoResponse.ok) {
            reject(new Error("Failed to fetch user info"));
            return;
          }

          const userInfo = await userInfoResponse.json();
          const userId = userInfo.user_id;

          // Store credentials
          await chrome.storage.local.set({ accessToken, instanceUrl, userId });

          resolve({
            success: true,
            authenticated: true,
            userName: userInfo.name,
            userId: userId
          });
        } catch (error) {
          reject(error);
        }
      }
    );
  });
}

// Check authentication status
async function checkAuthStatus() {
  const data = await chrome.storage.local.get([
    "accessToken",
    "instanceUrl",
    "userId"
  ]);

  if (data.accessToken && data.instanceUrl && data.userId) {
    // Verify token is still valid
    try {
      const response = await fetch(
        `${data.instanceUrl}/services/data/v59.0/sobjects`,
        {
          headers: { Authorization: `Bearer ${data.accessToken}` }
        }
      );

      if (response.ok) {
        return { success: true, authenticated: true };
      }
    } catch (error) {
      // Token invalid, clear storage
      await chrome.storage.local.remove([
        "accessToken",
        "instanceUrl",
        "userId"
      ]);
    }
  }

  return { success: true, authenticated: false };
}

// Normalize phone number for comparison
function normalizePhone(phone) {
  if (!phone) return "";
  return phone.replace(/\D/g, ""); // Remove all non-digits
}

// Find duplicate records
async function findDuplicates(data) {
  const { accessToken, instanceUrl } = await chrome.storage.local.get([
    "accessToken",
    "instanceUrl"
  ]);

  if (!accessToken || !instanceUrl) {
    throw new Error("Not authenticated");
  }

  const duplicates = [];

  // Normalize email and phone
  const email = data.email ? data.email.toLowerCase().trim() : "";
  const phoneDigits = normalizePhone(data.phone);
  const linkedinUrl = data.linkedinUrl || "";

  // Search for Contact duplicates
  if (email || phoneDigits) {
    let contactQuery = "SELECT Id, Name, Email, Phone FROM Contact WHERE ";
    const conditions = [];

    if (email) {
      conditions.push(`Email = '${email}'`);
    }
    if (phoneDigits.length >= 10) {
      conditions.push(`Phone LIKE '%${phoneDigits.slice(-10)}%'`);
    }

    contactQuery += conditions.join(" OR ");

    try {
      const response = await fetch(
        `${instanceUrl}/services/data/v59.0/query?q=${encodeURIComponent(contactQuery)}`,
        {
          headers: { Authorization: `Bearer ${accessToken}` }
        }
      );

      if (response.ok) {
        const result = await response.json();
        if (result.records && result.records.length > 0) {
          result.records.forEach((record) => {
            duplicates.push({
              type: "Contact",
              id: record.Id,
              name: record.Name,
              email: record.Email,
              phone: record.Phone,
              url: `${instanceUrl}/${record.Id}`
            });
          });
        }
      }
    } catch (error) {
      console.error("Error searching for Contact duplicates:", error);
    }
  }

  // Search for Candidate duplicates
  if (email || linkedinUrl) {
    let candidateQuery =
      "SELECT Id, Name__c, Email__c, LinkedIn_URL__c FROM Candidate__c WHERE ";
    const conditions = [];

    if (email) {
      conditions.push(`Email__c = '${email}'`);
    }
    if (linkedinUrl) {
      conditions.push(`LinkedIn_URL__c = '${linkedinUrl}'`);
    }

    candidateQuery += conditions.join(" OR ");

    try {
      const response = await fetch(
        `${instanceUrl}/services/data/v59.0/query?q=${encodeURIComponent(candidateQuery)}`,
        {
          headers: { Authorization: `Bearer ${accessToken}` }
        }
      );

      if (response.ok) {
        const result = await response.json();
        if (result.records && result.records.length > 0) {
          result.records.forEach((record) => {
            duplicates.push({
              type: "Candidate",
              id: record.Id,
              name: record.Name__c,
              email: record.Email__c,
              linkedinUrl: record.LinkedIn_URL__c,
              url: `${instanceUrl}/${record.Id}`
            });
          });
        }
      }
    } catch (error) {
      console.error("Error searching for Candidate duplicates:", error);
    }
  }

  return duplicates;
}

// Create candidate with duplicate check
async function handleCreateCandidate(data, proceedAnyway = false) {
  const { accessToken, instanceUrl, userId } = await chrome.storage.local.get([
    "accessToken",
    "instanceUrl",
    "userId"
  ]);

  if (!accessToken || !instanceUrl || !userId) {
    throw new Error("Not authenticated");
  }

  // Check for duplicates first (unless proceeding anyway)
  if (!proceedAnyway) {
    const duplicates = await findDuplicates(data);
    if (duplicates.length > 0) {
      return {
        success: false,
        duplicatesFound: true,
        duplicates: duplicates
      };
    }
  }

  // Create Contact first
  const contactData = {
    FirstName: data.firstName,
    LastName: data.lastName,
    Email: data.email,
    Phone: data.phone
  };

  if (data.birthday) {
    contactData.Birthdate_Text__c = data.birthday;
  }

  const contactResponse = await fetch(
    `${instanceUrl}/services/data/v59.0/sobjects/Contact`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(contactData)
    }
  );

  if (!contactResponse.ok) {
    const error = await contactResponse.json();
    throw new Error(
      `Failed to create Contact: ${error[0]?.message || "Unknown error"}`
    );
  }

  const contactResult = await contactResponse.json();
  const contactId = contactResult.id;

  // Create Candidate with hardcoded defaults
  const candidateData = {
    First_Name__c: data.firstName,
    Last_Name__c: data.lastName,
    Name__c: `${data.firstName} ${data.lastName}`,
    Email__c: data.email,
    Email_2__c: data.email,
    Phone__c: data.phone,
    Contact__c: contactId,
    LinkedIn_URL__c: data.linkedinUrl || "",

    // Hardcoded defaults
    Agency__c: CONFIG.defaults.agency,
    Position_Interested_In__c: CONFIG.defaults.position,
    Status__c: CONFIG.defaults.status,
    Next_Step__c: CONFIG.defaults.nextStep,
    Type__c: "Candidate",
    RecordTypeId: CONFIG.defaults.recordTypeId,
    Recruiter__c: userId
  };

  // Add optional fields
  if (data.company) {
    candidateData.Company__c = data.company;
  }
  if (data.title) {
    candidateData.Title__c = data.title;
  }
  if (data.location) {
    candidateData.Location__c = data.location;
  }
  if (data.sourceUrl) {
    candidateData.Source_URL__c = data.sourceUrl;
  }
  if (data.source) {
    candidateData.Source__c = data.source;
  }

  const candidateResponse = await fetch(
    `${instanceUrl}/services/data/v59.0/sobjects/Candidate__c`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(candidateData)
    }
  );

  if (!candidateResponse.ok) {
    const error = await candidateResponse.json();
    throw new Error(
      `Failed to create Candidate: ${error[0]?.message || "Unknown error"}`
    );
  }

  const candidateResult = await candidateResponse.json();

  return {
    success: true,
    contactId: contactId,
    candidateId: candidateResult.id,
    candidateUrl: `${instanceUrl}/${candidateResult.id}`,
    message: "Candidate created successfully!"
  };
}
