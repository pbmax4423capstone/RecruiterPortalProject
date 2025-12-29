// Content script - runs on any business page
// Extracts candidate data from the current page
// Wrapped in IIFE to prevent variable redeclaration errors

(function() {
  // Guard against multiple injections
  if (window.__businessToSalesforceLoaded) {
    console.log('Business to Salesforce extension already loaded, skipping...');
    return;
  }
  window.__businessToSalesforceLoaded = true;

  console.log('Business to Salesforce extension loaded on:', window.location.href);

  function extractBusinessPageData() {
    console.log('Extracting business page data...');
    
    const data = {
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      company: '',
      location: '',
      pageUrl: window.location.href,
      pageTitle: document.title
    };
    
    try {
      // Extract email from mailto: links anywhere on the page
      const emailLinks = document.querySelectorAll('a[href^="mailto:"]');
      for (const link of emailLinks) {
        const href = link.getAttribute('href');
        if (href) {
          const email = href.replace('mailto:', '').split('?')[0].trim();
          if (email && email.includes('@')) {
            data.email = email;
            console.log('Found email:', data.email);
            break;
          }
        }
      }
      
      // Extract phone from tel: links
      const phoneLinks = document.querySelectorAll('a[href^="tel:"]');
      for (const link of phoneLinks) {
        const href = link.getAttribute('href');
        if (href) {
          data.phone = href.replace('tel:', '').trim();
          console.log('Found phone from tel link:', data.phone);
          break;
        }
      }
      
      // Get page text for additional searches
      const pageText = document.body.innerText || '';
      
      // Try to find phone numbers in text if not found via tel: links
      if (!data.phone) {
        // Match patterns like (555) 123-4567, 555-123-4567, 555.123.4567
        const phoneMatch = pageText.match(/\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}/);
        if (phoneMatch && !phoneMatch[0].startsWith('800') && !phoneMatch[0].startsWith('(800')) {
          data.phone = phoneMatch[0].trim();
          console.log('Found phone from text:', data.phone);
        }
      }
      
      // Try to find email in text if not found via links
      if (!data.email) {
        const emailMatch = pageText.match(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/);
        if (emailMatch) {
          data.email = emailMatch[0];
          console.log('Found email from text:', data.email);
        }
      }
      
      // Try to extract company name from various sources
      // Look for common patterns
      const companyPatterns = [
        document.querySelector('meta[property="og:site_name"]')?.content,
        document.querySelector('meta[name="application-name"]')?.content,
        document.querySelector('.company-name')?.textContent,
        document.querySelector('[class*="company"]')?.textContent,
        document.querySelector('header h1')?.textContent,
        document.title.split('|')[0].split('-')[0].trim()
      ];
      
      for (const pattern of companyPatterns) {
        if (pattern && pattern.length > 2 && pattern.length < 100) {
          data.company = pattern.trim();
          console.log('Found company:', data.company);
          break;
        }
      }
      
      // Try to extract location
      const locationPatterns = [
        document.querySelector('[class*="location"]')?.textContent,
        document.querySelector('[class*="address"]')?.textContent,
        document.querySelector('address')?.textContent
      ];
      
      for (const pattern of locationPatterns) {
        if (pattern && pattern.length > 2 && pattern.length < 200) {
          data.location = pattern.trim().replace(/\s+/g, ' ');
          console.log('Found location:', data.location);
          break;
        }
      }
      
      console.log('Extracted data:', data);
      
    } catch (e) {
      console.error('Error extracting business page data:', e);
    }
    
    return data;
  }

  // Listen for messages from popup
  chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'getPageData') {
      const data = extractBusinessPageData();
      sendResponse(data);
    }
    return true;
  });

  // Add a floating save button
  function addSaveButton() {
    // Check if button already exists
    if (document.getElementById('sf-save-btn-float')) return;
    
    const btn = document.createElement('button');
    btn.id = 'sf-save-btn-float';
    btn.innerHTML = '☁️ Save to Salesforce';
    btn.style.cssText = `
      position: fixed;
      bottom: 20px;
      right: 20px;
      background: linear-gradient(135deg, #0176d3 0%, #014486 100%);
      color: white;
      border: none;
      padding: 12px 20px;
      border-radius: 28px;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      z-index: 999999;
      box-shadow: 0 4px 12px rgba(1, 118, 211, 0.4);
      transition: all 0.3s;
    `;
    
    btn.addEventListener('mouseenter', () => {
      btn.style.transform = 'translateY(-2px) scale(1.05)';
      btn.style.boxShadow = '0 6px 20px rgba(1, 118, 211, 0.5)';
    });
    
    btn.addEventListener('mouseleave', () => {
      btn.style.transform = 'translateY(0) scale(1)';
      btn.style.boxShadow = '0 4px 12px rgba(1, 118, 211, 0.4)';
    });
    
    btn.addEventListener('click', async () => {
      // Extract data
      const data = extractBusinessPageData();
      
      // Send data to background to open popup
      chrome.runtime.sendMessage({ 
        action: 'openPopup',
        pageData: data 
      });
    });
    
    document.body.appendChild(btn);
  }

  // Run when page loads
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', addSaveButton);
  } else {
    addSaveButton();
  }

})();
