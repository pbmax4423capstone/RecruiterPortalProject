// Content script - runs on LinkedIn profile pages
// Extracts profile data from the page
// Wrapped in IIFE to prevent variable redeclaration errors

(function() {
  // Guard against multiple injections (LinkedIn SPA can cause this)
  if (window.__linkedinToSalesforceLoaded) {
    console.log('LinkedIn to Salesforce extension already loaded, skipping...');
    return;
  }
  window.__linkedinToSalesforceLoaded = true;

  console.log('LinkedIn to Salesforce extension loaded on:', window.location.href);

  function extractProfileData() {
    console.log('Extracting profile data...');
    
    const data = {
      firstName: '',
      lastName: '',
      headline: '',
      company: '',
      location: '',
      profileUrl: window.location.href.split('?')[0]
    };
    
    try {
      // Method 1: Try multiple h1 selectors for the name
      let nameElement = document.querySelector('h1.text-heading-xlarge');
      
      if (!nameElement) {
        // Try other common selectors
        const h1Elements = document.querySelectorAll('h1');
        for (const h1 of h1Elements) {
          const text = h1.textContent.trim();
          // Skip if it looks like a company name or section header
          if (text && !text.includes('Experience') && !text.includes('Education') && text.length < 60) {
            nameElement = h1;
            break;
          }
        }
      }
      
      if (nameElement) {
        const fullName = nameElement.textContent.trim();
        console.log('Found name:', fullName);
        const nameParts = fullName.split(' ').filter(p => p.length > 0);
        
        if (nameParts.length >= 2) {
          data.firstName = nameParts[0];
          data.lastName = nameParts.slice(1).join(' ');
        } else if (nameParts.length === 1) {
          data.firstName = nameParts[0];
        }
      }
      
      // Method 2: Get headline - it's usually the div after the name
      const headlineElement = document.querySelector('.text-body-medium.break-words') ||
                              document.querySelector('div.text-body-medium');
      
      if (headlineElement) {
        data.headline = headlineElement.textContent.trim();
        console.log('Found headline:', data.headline);
      }
      
      // Method 3: Get location
      const locationElement = document.querySelector('.text-body-small.inline.t-black--light.break-words') ||
                              document.querySelector('span.text-body-small.inline');
      
      if (locationElement) {
        data.location = locationElement.textContent.trim();
        console.log('Found location:', data.location);
      }
      
      console.log('Extracted data:', data);
      
    } catch (e) {
      console.error('Error extracting profile data:', e);
    }
    
    return data;
  }

  // Listen for messages from popup
  chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'getProfileData') {
      const data = extractProfileData();
      sendResponse(data);
    }
    return true;
  });

  // Add a visual indicator that the extension is active
  function addSaveButton() {
    // Check if button already exists
    if (document.getElementById('sf-save-btn')) return;
    
    // Find the action buttons area
    const actionsArea = document.querySelector('.pv-top-card-v2-ctas') ||
                        document.querySelector('.pvs-profile-actions') ||
                        document.querySelector('.ph5.pb5');
    
    if (actionsArea) {
      const btn = document.createElement('button');
      btn.id = 'sf-save-btn';
      btn.innerHTML = '☁️ Save to Salesforce';
      btn.style.cssText = `
        background: linear-gradient(135deg, #0176d3 0%, #014486 100%);
        color: white;
        border: none;
        padding: 8px 16px;
        border-radius: 24px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        margin-left: 8px;
        transition: all 0.2s;
      `;
      
      btn.addEventListener('mouseenter', () => {
        btn.style.transform = 'translateY(-2px)';
        btn.style.boxShadow = '0 4px 12px rgba(1, 118, 211, 0.3)';
      });
      
      btn.addEventListener('mouseleave', () => {
        btn.style.transform = 'translateY(0)';
        btn.style.boxShadow = 'none';
      });
      
      btn.addEventListener('click', () => {
        // Open the extension popup programmatically isn't directly possible,
        // but we can show a notification
        const data = extractProfileData();
        chrome.runtime.sendMessage({ action: 'showPopup', data });
        
        // Show a tooltip
        btn.innerHTML = '✓ Click extension icon to complete';
        setTimeout(() => {
          btn.innerHTML = '☁️ Save to Salesforce';
        }, 3000);
      });
      
      actionsArea.appendChild(btn);
    }
  }

  // Run when page loads
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', addSaveButton);
  } else {
    addSaveButton();
  }

  // Also run when LinkedIn navigates (it's a SPA)
  const observer = new MutationObserver(() => {
    if (window.location.href.includes('/in/')) {
      setTimeout(addSaveButton, 1000);
    }
  });

  if (document.body) {
    observer.observe(document.body, { childList: true, subtree: true });
  }

})();
