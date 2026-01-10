// Contact Importer - Popup Script
// Handles Salesforce OAuth and Candidate creation

// Configuration
const CONFIG = {
  // Salesforce OAuth settings
  salesforceLoginUrl: "https://test.salesforce.com", // Use login.salesforce.com for production
  clientId:
    "3MVG9AR068fT4usyVQdDlbJ3XVwtPbfdsuFVEcup3mEwR.dQlnrkDltgNCeCXb6bRrC.uTfLjhvHaFkrn7bWd",
  redirectUri: chrome.identity.getRedirectURL(),

  // Default values for Candidate record
  defaults: {
    agency: "A157",
    position: "Agent",
    status: "Lead",
    recordTypeId: "0125f000000a5IlAAI" // Candidate Record Type
  },

  // Test recruiter ID
  testRecruiterId: "0055f00000DqpnpAAB" // Rachyll Tenny
};

// Site type display configuration
const SITE_CONFIG = {
  linkedin: { icon: "💼", name: "LinkedIn", class: "linkedin" },
  zoominfo: { icon: "🔍", name: "ZoomInfo", class: "zoominfo" },
  apollo: { icon: "🚀", name: "Apollo", class: "generic" },
  lusha: { icon: "📞", name: "Lusha", class: "generic" },
  rocketreach: { icon: "🎯", name: "RocketReach", class: "generic" },
  generic: { icon: "🌐", name: "Website", class: "generic" }
};

// State
let currentMode = "auto";
let extractedData = null;

// DOM Elements
const elements = {
  statusMessage: null,
  loginSection: null,
  formSection: null,
  userInfo: null,
  userName: null,
  siteBadge: null,
  profilePreview: null,
  previewName: null,
  previewSubtitle: null,
  sourceText: null,
  locationText: null,
  previewLocation: null,
  firstName: null,
  lastName: null,
  email: null,
  phone: null,
  company: null,
  headline: null,
  location: null,
  agency: null,
  position: null,
  status: null,
  openRecord: null,
  loginBtn: null,
  logoutBtn: null,
  createBtn: null,
  refreshBtn: null,
  autoModeBtn: null,
  manualModeBtn: null
};

// Initialize on DOM load
document.addEventListener("DOMContentLoaded", async () => {
  initializeElements();
  addEventListeners();
  await checkAuthStatus();
  await detectSiteAndExtract();
});

function initializeElements() {
  elements.statusMessage = document.getElementById("statusMessage");
  elements.loginSection = document.getElementById("loginSection");
  elements.formSection = document.getElementById("formSection");
  elements.userInfo = document.getElementById("userInfo");
  elements.userName = document.getElementById("userName");
  elements.siteBadge = document.getElementById("siteBadge");
  elements.profilePreview = document.getElementById("profilePreview");
  elements.previewName = document.getElementById("previewName");
  elements.previewSubtitle = document.getElementById("previewSubtitle");
  elements.sourceText = document.getElementById("sourceText");
  elements.locationText = document.getElementById("locationText");
  elements.previewLocation = document.getElementById("previewLocation");
  elements.firstName = document.getElementById("firstName");
  elements.lastName = document.getElementById("lastName");
  elements.email = document.getElementById("email");
  elements.phone = document.getElementById("phone");
  elements.company = document.getElementById("company");
  elements.headline = document.getElementById("headline");
  elements.location = document.getElementById("location");
  elements.agency = document.getElementById("agency");
  elements.position = document.getElementById("position");
  elements.status = document.getElementById("status");
  elements.openRecord = document.getElementById("openRecord");
  elements.loginBtn = document.getElementById("loginBtn");
  elements.logoutBtn = document.getElementById("logoutBtn");
  elements.createBtn = document.getElementById("createBtn");
  elements.refreshBtn = document.getElementById("refreshBtn");
  elements.autoModeBtn = document.getElementById("autoModeBtn");
  elements.manualModeBtn = document.getElementById("manualModeBtn");
}

function addEventListeners() {
  elements.loginBtn?.addEventListener("click", handleLogin);
  elements.logoutBtn?.addEventListener("click", handleLogout);
  elements.createBtn?.addEventListener("click", handleCreateCandidate);
  elements.refreshBtn?.addEventListener("click", refreshData);

  // Form validation
  elements.firstName?.addEventListener("input", validateForm);
  elements.lastName?.addEventListener("input", validateForm);
}

// Mode switching
window.setMode = function (mode) {
  currentMode = mode;
  elements.autoModeBtn.classList.toggle("active", mode === "auto");
  elements.manualModeBtn.classList.toggle("active", mode === "manual");

  if (mode === "auto") {
    refreshData();
  } else {
    // Clear auto-filled styling
    document.querySelectorAll(".auto-filled").forEach((el) => {
      el.classList.remove("auto-filled");
    });
    elements.previewName.textContent = "Manual Entry Mode";
    elements.previewSubtitle.textContent = "Enter contact information below";
  }
};

async function detectSiteAndExtract() {
  try {
    const [tab] = await chrome.tabs.query({
      active: true,
      currentWindow: true
    });

    if (!tab?.id) {
      showStatus("Unable to access current tab", "warning");
      return;
    }

    // First, inject content script if needed
    try {
      await chrome.scripting.executeScript({
        target: { tabId: tab.id },
        files: ["content.js"]
      });
    } catch (e) {
      // Script might already be injected
      console.log("Content script may already be loaded:", e.message);
    }

    // Get site type from content script
    chrome.tabs.sendMessage(tab.id, { action: "getSiteType" }, (response) => {
      if (chrome.runtime.lastError) {
        console.log("Error getting site type:", chrome.runtime.lastError);
        updateSiteBadge("generic");
        return;
      }
      updateSiteBadge(response?.site || "generic");
    });

    // Extract data
    if (currentMode === "auto") {
      await refreshData();
    }
  } catch (error) {
    console.error("Error detecting site:", error);
    showStatus("Error accessing page content", "error");
  }
}

function updateSiteBadge(siteType) {
  const config = SITE_CONFIG[siteType] || SITE_CONFIG.generic;

  elements.siteBadge.className = `site-badge ${config.class}`;
  elements.siteBadge.querySelector(".icon").textContent = config.icon;
  elements.siteBadge.querySelector(".site-name").textContent = config.name;
}

async function refreshData() {
  if (currentMode !== "auto") return;

  elements.previewName.textContent = "Loading...";
  elements.previewSubtitle.textContent = "";

  try {
    const [tab] = await chrome.tabs.query({
      active: true,
      currentWindow: true
    });

    if (!tab?.id) {
      showStatus("Unable to access current tab", "warning");
      return;
    }

    chrome.tabs.sendMessage(tab.id, { action: "getContactData" }, (data) => {
      if (chrome.runtime.lastError) {
        console.log("Error extracting data:", chrome.runtime.lastError);
        elements.previewName.textContent = "No data detected";
        elements.previewSubtitle.textContent =
          "Try manual entry or navigate to a profile page";
        return;
      }

      if (data) {
        extractedData = data;
        populateForm(data);
        updatePreview(data);
        validateForm();
      }
    });
  } catch (error) {
    console.error("Error refreshing data:", error);
    showStatus("Error extracting contact data", "error");
  }
}

function populateForm(data) {
  if (data.firstName) {
    elements.firstName.value = data.firstName;
    elements.firstName.classList.add("auto-filled");
  }
  if (data.lastName) {
    elements.lastName.value = data.lastName;
    elements.lastName.classList.add("auto-filled");
  }
  if (data.email) {
    elements.email.value = data.email;
    elements.email.classList.add("auto-filled");
  }
  if (data.phone) {
    elements.phone.value = data.phone;
    elements.phone.classList.add("auto-filled");
  }
  if (data.company) {
    elements.company.value = data.company;
    elements.company.classList.add("auto-filled");
  }
  if (data.headline) {
    elements.headline.value = data.headline;
    elements.headline.classList.add("auto-filled");
  }
  if (data.location) {
    elements.location.value = data.location;
    elements.location.classList.add("auto-filled");
  }
}

function updatePreview(data) {
  const fullName =
    [data.firstName, data.lastName].filter(Boolean).join(" ") ||
    "Unknown Contact";
  elements.previewName.textContent = fullName;
  elements.previewSubtitle.textContent = data.headline || data.company || "";
  elements.sourceText.textContent = data.source || "Website";

  if (data.location) {
    elements.locationText.textContent = data.location;
    elements.previewLocation.style.display = "inline-flex";
  } else {
    elements.previewLocation.style.display = "none";
  }
}

function validateForm() {
  const firstName = elements.firstName.value.trim();
  const lastName = elements.lastName.value.trim();
  const isValid = firstName.length > 0 && lastName.length > 0;

  elements.createBtn.disabled = !isValid;
}

// Authentication
async function checkAuthStatus() {
  const data = await chrome.storage.local.get([
    "accessToken",
    "instanceUrl",
    "userName"
  ]);

  if (data.accessToken && data.instanceUrl) {
    showLoggedInState(data.userName || "Salesforce User");
  } else {
    showLoggedOutState();
  }
}

function showLoggedInState(userName) {
  elements.loginSection.classList.remove("show");
  elements.formSection.classList.add("show");
  elements.userInfo.style.display = "flex";
  elements.userName.textContent = userName;
}

function showLoggedOutState() {
  elements.loginSection.classList.add("show");
  elements.formSection.classList.remove("show");
  elements.userInfo.style.display = "none";
}

async function handleLogin() {
  showStatus("Connecting to Salesforce...", "info");
  elements.loginBtn.disabled = true;
  elements.loginBtn.innerHTML = '<div class="spinner"></div> Connecting...';

  try {
    // Get the redirect URL and log it for debugging
    const redirectUrl = chrome.identity.getRedirectURL();
    console.log("Redirect URL:", redirectUrl);

    const authUrl =
      `${CONFIG.salesforceLoginUrl}/services/oauth2/authorize?` +
      `response_type=token&` +
      `client_id=${encodeURIComponent(CONFIG.clientId)}&` +
      `redirect_uri=${encodeURIComponent(redirectUrl)}`;

    console.log("Auth URL:", authUrl);

    const responseUrl = await chrome.identity.launchWebAuthFlow({
      url: authUrl,
      interactive: true
    });

    // Parse the response
    const hashParams = new URLSearchParams(responseUrl.split("#")[1]);
    const accessToken = hashParams.get("access_token");
    const instanceUrl = hashParams.get("instance_url");

    if (!accessToken || !instanceUrl) {
      throw new Error("Invalid authentication response");
    }

    // Get user info
    const userInfoResponse = await fetch(
      `${instanceUrl}/services/oauth2/userinfo`,
      {
        headers: { Authorization: `Bearer ${accessToken}` }
      }
    );

    if (!userInfoResponse.ok) {
      throw new Error("Failed to get user info");
    }

    const userInfo = await userInfoResponse.json();

    // Store credentials
    await chrome.storage.local.set({
      accessToken,
      instanceUrl,
      userName: userInfo.name || userInfo.preferred_username
    });

    showStatus("Successfully connected to Salesforce!", "success");
    showLoggedInState(userInfo.name || userInfo.preferred_username);
  } catch (error) {
    console.error("Login error:", error);
    showStatus("Login failed: " + error.message, "error");
  } finally {
    elements.loginBtn.disabled = false;
    elements.loginBtn.innerHTML = "<span>🔐</span> Login with Salesforce";
  }
}

async function handleLogout() {
  await chrome.storage.local.remove(["accessToken", "instanceUrl", "userName"]);
  showStatus("Logged out successfully", "info");
  showLoggedOutState();
}

// Create Candidate
async function handleCreateCandidate() {
  const firstName = elements.firstName.value.trim();
  const lastName = elements.lastName.value.trim();

  if (!firstName || !lastName) {
    showStatus("First name and last name are required", "error");
    return;
  }

  showStatus("Creating Candidate...", "info");
  elements.createBtn.disabled = true;
  elements.createBtn.innerHTML = '<div class="spinner"></div> Creating...';

  try {
    const data = await chrome.storage.local.get(["accessToken", "instanceUrl"]);

    if (!data.accessToken || !data.instanceUrl) {
      throw new Error("Not authenticated. Please login first.");
    }

    // Build the Candidate record
    const candidateData = {
      RecordTypeId: CONFIG.defaults.recordTypeId,
      First_Name__c: firstName,
      Last_Name__c: lastName,
      Candidate_Status__c: elements.status.value || CONFIG.defaults.status,
      Position_Applying_For__c:
        elements.position.value || CONFIG.defaults.position,
      Agency__c: elements.agency.value || CONFIG.defaults.agency,
      Assigned_Recruiter__c: CONFIG.testRecruiterId
    };

    // Add optional fields
    if (elements.email.value)
      candidateData.Email__c = elements.email.value.trim();
    if (elements.phone.value)
      candidateData.Phone__c = elements.phone.value.trim();
    if (elements.company.value)
      candidateData.Current_Employer__c = elements.company.value.trim();
    if (elements.headline.value)
      candidateData.Current_Title__c = elements.headline.value.trim();
    if (elements.location.value)
      candidateData.Location__c = elements.location.value.trim();

    // Add source tracking
    if (extractedData?.profileUrl) {
      candidateData.Source_URL__c = extractedData.profileUrl;
    }
    if (extractedData?.source) {
      candidateData.Lead_Source__c = extractedData.source;
    }

    // Make API call via background script (to avoid CORS)
    const response = await chrome.runtime.sendMessage({
      action: "createCandidate",
      accessToken: data.accessToken,
      instanceUrl: data.instanceUrl,
      candidateData
    });

    if (response.error) {
      throw new Error(response.error);
    }

    showStatus("✓ Candidate created successfully!", "success");

    // Open the record if checkbox is checked
    if (elements.openRecord.checked && response.id) {
      chrome.tabs.create({
        url: `${data.instanceUrl}/lightning/r/Candidate__c/${response.id}/view`
      });
    }

    // Clear form after successful creation
    setTimeout(() => {
      clearForm();
    }, 2000);
  } catch (error) {
    console.error("Error creating candidate:", error);
    showStatus("Error: " + error.message, "error");
  } finally {
    elements.createBtn.disabled = false;
    elements.createBtn.innerHTML = "<span>➕</span> Create Candidate";
    validateForm();
  }
}

function clearForm() {
  elements.firstName.value = "";
  elements.lastName.value = "";
  elements.email.value = "";
  elements.phone.value = "";
  elements.company.value = "";
  elements.headline.value = "";
  elements.location.value = "";

  document.querySelectorAll(".auto-filled").forEach((el) => {
    el.classList.remove("auto-filled");
  });

  extractedData = null;
  validateForm();
}

function showStatus(message, type) {
  elements.statusMessage.textContent = message;
  elements.statusMessage.className = `status ${type} show`;

  if (type === "success" || type === "info") {
    setTimeout(() => {
      elements.statusMessage.classList.remove("show");
    }, 5000);
  }
}
