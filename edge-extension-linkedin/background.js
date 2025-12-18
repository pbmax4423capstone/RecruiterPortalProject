// Background service worker

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'showPopup') {
    // Store the profile data for the popup to access
    chrome.storage.local.set({ pendingProfileData: request.data });
  }
});

// Handle extension installation
chrome.runtime.onInstalled.addListener(() => {
  console.log('LinkedIn to Salesforce extension installed');
});
