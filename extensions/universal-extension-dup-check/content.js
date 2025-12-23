// Universal Candidate Creator - Content Script
// Retains LinkedIn parity plus universal business-page capture

(function() {
  if (window.__universalCandidateCreatorLoaded) return;
  window.__universalCandidateCreatorLoaded = true;

  const SITE_PATTERNS = {
    linkedin: /linkedin\.com\/(in|pub|sales|profile)\//,
    zoominfo: /zoominfo\.com\/p\//,
    apollo: /apollo\.io\/people\//,
    lusha: /lusha\.com\/person\//,
    rocketreach: /rocketreach\.co\/person\//
  };

  const MONTH_NAMES = [
    'january', 'february', 'march', 'april', 'may', 'june',
    'july', 'august', 'september', 'october', 'november', 'december'
  ];

  const CREDENTIAL_SUFFIXES = [
    'mba', 'emba', 'bba', 'bs', 'ba', 'ms', 'msc', 'macc', 'phd', 'edd', 'jd', 'md',
    'cpa', 'cfp', 'aif', 'cfa', 'ria', 'cic', 'lutcf', 'rhu', 'cco', 'chfc', 'clu',
    'crpc', 'cpcm', 'csm', 'pmp', 'six sigma', 'lean', 'esq'
  ];

  function escapeRegex(str) {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  function detectSiteType() {
    const url = window.location.href;
    for (const [site, pattern] of Object.entries(SITE_PATTERNS)) {
      if (pattern.test(url)) {
        return site;
      }
    }
    return 'generic';
  }

  function wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  function normalizeLinkedInUrl(url) {
    if (!url) return window.location.href.split('?')[0];
    return url.split('?')[0].split('#')[0];
  }

  function stripCredentialSuffixes(fullName) {
    if (!fullName) return '';

    let cleaned = fullName
      .replace(/\u00A0/g, ' ')
      .replace(/[|•·].*/g, '')
      .replace(/,.*/g, '')
      .replace(/\s+/g, ' ')
      .trim();

    CREDENTIAL_SUFFIXES.forEach(suffix => {
      const pattern = new RegExp(`(?:,|\|)?\\s*${escapeRegex(suffix)}$`, 'i');
      cleaned = cleaned.replace(pattern, '').trim();
    });

    return cleaned.trim();
  }

  function splitLinkedInName(fullName) {
    const cleaned = stripCredentialSuffixes(fullName || '');

    const parts = cleaned.split(/\s+/).filter(Boolean);
    if (parts.length === 0) {
      return { firstName: '', lastName: '' };
    }
    if (parts.length === 1) {
      return { firstName: parts[0], lastName: '' };
    }
    return {
      firstName: parts[0],
      lastName: parts.slice(1).join(' ')
    };
  }

  function parseLinkedInHeadline(headline = '') {
    if (!headline) {
      return { title: '', company: '' };
    }
    const parts = headline.split(/\bat\b/i);
    if (parts.length >= 2) {
      return {
        title: parts[0].trim(),
        company: parts.slice(1).join(' at ').trim()
      };
    }
    return { title: headline.trim(), company: '' };
  }

  function extractCurrentCompanyFromExperience() {
    const sections = document.querySelectorAll('section[data-view-name="profile-experience"], section[id*="experience"]');
    for (const section of sections) {
      const span = section.querySelector('span.pvs-entity__secondary-title, .pv-entity__secondary-title');
      if (span) {
        const raw = span.textContent || '';
        const cleaned = raw.split('·')[0].replace(/Company Name/i, '').trim();
        if (cleaned && cleaned.length < 80) {
          return cleaned;
        }
      }
    }
    return '';
  }

  function scrapeLinkedInProfile() {
    const data = {
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      birthday: '',
      headline: '',
      company: '',
      location: '',
      profileUrl: normalizeLinkedInUrl(window.location.href)
    };

    try {
      let nameEl = document.querySelector('h1.text-heading-xlarge');
      if (!nameEl) {
        const h1s = document.querySelectorAll('h1');
        for (const h1 of h1s) {
          const text = h1.textContent.trim();
          if (text && text.length < 80 && !/experience|education|highlights/i.test(text)) {
            nameEl = h1;
            break;
          }
        }
      }
      if (nameEl) {
        const { firstName, lastName } = splitLinkedInName(nameEl.textContent.trim());
        data.firstName = firstName;
        data.lastName = lastName;
      }

      const headlineEl = document.querySelector('.text-body-medium.break-words') ||
                         document.querySelector('.pv-text-details__left-panel .text-body-medium');
      if (headlineEl) {
        data.headline = headlineEl.textContent.trim();
      }

      const locationEl = document.querySelector('.text-body-small.inline.t-black--light.break-words') ||
                         document.querySelector('.pv-text-details__left-panel .text-body-small');
      if (locationEl) {
        data.location = locationEl.textContent.trim();
      }

      const emailLink = Array.from(document.querySelectorAll('a[href^="mailto:"]'))
        .find(link => link.href && !link.href.toLowerCase().includes('linkedin'));
      if (emailLink) {
        data.email = emailLink.href.replace('mailto:', '').split('?')[0].trim();
      }

      const phoneLink = Array.from(document.querySelectorAll('a[href^="tel:"]'))
        .find(link => link.href);
      if (phoneLink) {
        data.phone = phoneLink.href.replace('tel:', '').trim();
      }

      const currentCompany = extractCurrentCompanyFromExperience();
      if (currentCompany) {
        data.company = currentCompany;
      }

      const pageText = document.body.innerText || '';
      if (!data.phone) {
        const phoneMatch = pageText.match(/\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}/);
        if (phoneMatch) {
          data.phone = phoneMatch[0].trim();
        }
      }

      const birthdayIndex = pageText.toLowerCase().indexOf('birthday');
      if (birthdayIndex !== -1) {
        const snippet = pageText.substring(birthdayIndex, birthdayIndex + 60).toLowerCase();
        for (const month of MONTH_NAMES) {
          const regex = new RegExp(`${month}\\s+\\d{1,2}`);
          const match = snippet.match(regex);
          if (match) {
            const prettyMonth = month.charAt(0).toUpperCase() + month.slice(1);
            data.birthday = match[0].replace(month, prettyMonth);
            break;
          }
        }
      }
    } catch (error) {
      console.error('[Universal SF] Error scraping LinkedIn profile', error);
    }

    return data;
  }

  function scrapeLinkedInContactData() {
    const modal = document.querySelector('.artdeco-modal, .pv-contact-info');
    if (!modal) {
      return {};
    }

    const info = {};
    const emailEl = modal.querySelector('.ci-email a[href^="mailto:"], a[href^="mailto:"]');
    if (emailEl) {
      info.email = emailEl.href.replace('mailto:', '').split('?')[0].trim();
    }

    const phoneEl = modal.querySelector('.ci-phone span.t-14, .ci-phone li span');
    if (phoneEl) {
      info.phone = phoneEl.textContent.replace(/Phone|Mobile|Work|\(|\)|:/gi, '').replace(/\s+/g, ' ').trim();
    }

    const birthdayEl = modal.querySelector('.ci-birthday span.t-14, .ci-birthday li span');
    if (birthdayEl) {
      info.birthday = birthdayEl.textContent.trim();
    }

    const companyEl = modal.querySelector('.ci-company span.t-14, .ci-company li span');
    if (companyEl) {
      info.company = companyEl.textContent.trim();
    }

    return info;
  }

  async function openLinkedInContactModal() {
    const contactLink = document.querySelector('a[data-control-name="contact_see_more"]') ||
                        document.querySelector('a[href*="overlay/contact-info"]') ||
                        document.querySelector('#top-card-text-details-contact-info') ||
                        document.querySelector('.pv-top-card-v2-ctas__contact-info');
    if (!contactLink) {
      return false;
    }
    contactLink.click();
    await wait(2500);
    return true;
  }

  function closeLinkedInModal() {
    const closeBtn = document.querySelector('.artdeco-modal__dismiss') ||
                     document.querySelector('button[aria-label="Dismiss"]');
    if (closeBtn) {
      closeBtn.click();
    }
  }

  async function captureLinkedInProfileData(includeModal = true) {
    let modalOpened = false;
    let contactInfo = {};
    if (includeModal) {
      modalOpened = await openLinkedInContactModal();
      if (modalOpened) {
        contactInfo = scrapeLinkedInContactData();
      }
    }
    const mapped = mapLinkedInData({
      ...scrapeLinkedInProfile(),
      ...contactInfo
    });
    if (modalOpened) {
      closeLinkedInModal();
    }
    return mapped;
  }

  function mapLinkedInData(raw) {
    const { title, company } = parseLinkedInHeadline(raw.headline);
    return {
      firstName: raw.firstName || '',
      lastName: raw.lastName || '',
      email: raw.email || '',
      phone: raw.phone || '',
      birthday: raw.birthday || '',
      company: raw.company || company || '',
      title: title || raw.headline || '',
      location: raw.location || '',
      source: 'LinkedIn',
      sourceUrl: raw.profileUrl || normalizeLinkedInUrl(window.location.href),
      linkedinUrl: raw.profileUrl || normalizeLinkedInUrl(window.location.href)
    };
  }

  function extractGenericData() {
    const data = {
      source: 'Web',
      sourceUrl: window.location.href
    };

    const schemaBlock = document.querySelector('script[type="application/ld+json"]');
    if (schemaBlock) {
      try {
        const schema = JSON.parse(schemaBlock.textContent);
        if (schema['@type'] === 'Person') {
          data.firstName = schema.givenName || '';
          data.lastName = schema.familyName || '';
          data.email = schema.email || '';
          data.phone = schema.telephone || '';
          data.title = schema.jobTitle || '';
          data.company = schema.worksFor?.name || '';
        }
      } catch (_) {
        // ignore malformed schema
      }
    }

    const vcard = document.querySelector('.vcard, .h-card');
    if (vcard) {
      const fullName = vcard.querySelector('.fn, .p-name');
      if (fullName && (!data.firstName || !data.lastName)) {
        const parts = fullName.textContent.trim().split(/\s+/);
        data.firstName = data.firstName || parts[0] || '';
        data.lastName = data.lastName || parts.slice(1).join(' ') || parts[0] || '';
      }

      const emailEl = vcard.querySelector('.email, .u-email, a[href^="mailto:"]');
      if (emailEl && !data.email) {
        data.email = emailEl.textContent.trim() || emailEl.href.replace('mailto:', '');
      }

      const telEl = vcard.querySelector('.tel, .p-tel, a[href^="tel:"]');
      if (telEl && !data.phone) {
        data.phone = telEl.textContent.trim() || telEl.href.replace('tel:', '');
      }

      const titleEl = vcard.querySelector('.title, .p-job-title');
      if (titleEl && !data.title) {
        data.title = titleEl.textContent.trim();
      }

      const orgEl = vcard.querySelector('.org, .p-org');
      if (orgEl && !data.company) {
        data.company = orgEl.textContent.trim();
      }
    }

    if (!data.email) {
      const emailMatch = (document.body.textContent || '').match(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/);
      if (emailMatch) {
        data.email = emailMatch[0];
      }
    }

    if (!data.phone) {
      const phoneMatch = (document.body.textContent || '').match(/(\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}/);
      if (phoneMatch) {
        data.phone = phoneMatch[0];
      }
    }

    if (!data.firstName && !data.lastName) {
      const title = document.title.split(/[-|–]/)[0].trim();
      const parts = title.split(/\s+/);
      if (parts.length >= 2) {
        data.firstName = parts[0];
        data.lastName = parts.slice(1).join(' ');
      }
    }

    return data;
  }

  async function extractCandidateData() {
    const siteType = detectSiteType();
    if (siteType === 'linkedin') {
      return captureLinkedInProfileData(true);
    }
    return extractGenericData();
  }

  async function storeAndLaunchPopup(data) {
    if (!data) return;
    const payload = {
      ...data,
      source: data.source || (detectSiteType() === 'linkedin' ? 'LinkedIn' : 'Web'),
      sourceUrl: data.sourceUrl || window.location.href,
      timestamp: Date.now()
    };
    await chrome.storage.local.set({ extractedData: payload });
    chrome.runtime.sendMessage({ action: 'openPopupWindow' }, response => {
      if (chrome.runtime.lastError) {
        console.error('[Universal SF] Failed to open popup window', chrome.runtime.lastError);
      } else if (response && !response.success) {
        console.warn('[Universal SF] Popup window error', response.error);
      }
    });
  }

  function addLinkedInButton() {
    if (!window.location.href.match(SITE_PATTERNS.linkedin)) {
      return;
    }

    if (document.getElementById('universal-sf-save-button')) {
      return;
    }

    const actionsArea = document.querySelector('.pv-top-card-v2-ctas') ||
                        document.querySelector('.pvs-profile-actions') ||
                        document.querySelector('.ph5.pb5');

    if (!actionsArea) {
      setTimeout(addLinkedInButton, 1000);
      return;
    }

    const button = document.createElement('button');
    button.id = 'universal-sf-save-button';
    button.type = 'button';
    button.textContent = '☁️ Save to Salesforce';
    button.style.cssText = '
      background: linear-gradient(135deg, #0176d3 0%, #014486 100%);
      color: #fff;
      border: none;
      padding: 8px 16px;
      border-radius: 24px;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      margin-left: 8px;
      transition: all 0.2s;
    ';

    button.addEventListener('mouseenter', () => {
      if (button.disabled) return;
      button.style.transform = 'translateY(-2px)';
      button.style.boxShadow = '0 4px 12px rgba(1, 118, 211, 0.3)';
    });

    button.addEventListener('mouseleave', () => {
      button.style.transform = 'translateY(0)';
      button.style.boxShadow = 'none';
    });

    button.addEventListener('click', async () => {
      if (button.disabled) {
        return;
      }
      const originalText = button.textContent;
      button.disabled = true;
      button.textContent = '⏳ Capturing...';
      button.style.opacity = '0.8';
      try {
        const data = await captureLinkedInProfileData(true);
        await storeAndLaunchPopup(data);
      } catch (error) {
        console.error('[Universal SF] LinkedIn extraction failed', error);
      } finally {
        button.disabled = false;
        button.textContent = originalText;
        button.style.opacity = '1';
      }
    });

    actionsArea.appendChild(button);
  }

  function addFloatingButton() {
    const siteType = detectSiteType();
    if (siteType === 'linkedin') {
      return;
    }

    if (document.getElementById('universal-sf-fab')) {
      return;
    }

    const fab = document.createElement('button');
    fab.id = 'universal-sf-fab';
    fab.className = 'universal-sf-fab';
    fab.innerHTML = '☁️';
    fab.title = 'Save to Salesforce';

    fab.addEventListener('click', async () => {
      fab.disabled = true;
      fab.textContent = '⏳';
      try {
        const data = await extractCandidateData();
        await storeAndLaunchPopup(data);
      } catch (error) {
        console.error('[Universal SF] Generic extraction failed', error);
      } finally {
        fab.disabled = false;
        fab.innerHTML = '☁️';
      }
    });

    document.body.appendChild(fab);
  }

  chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'storeData') {
      chrome.storage.local.set({ extractedData: request.data }).then(() => {
        sendResponse({ success: true });
      });
      return true;
    }

    if (request.action === 'extractData') {
      extractCandidateData()
        .then(data => sendResponse({ success: true, data }))
        .catch(error => sendResponse({ success: false, error: error.message }));
      return true;
    }
  });

  function initialize() {
    const siteType = detectSiteType();
    if (siteType === 'linkedin') {
      addLinkedInButton();
      let attempts = 0;
      const buttonInterval = setInterval(() => {
        attempts += 1;
        addLinkedInButton();
        if (document.getElementById('universal-sf-save-button') || attempts > 30 || !window.location.href.match(SITE_PATTERNS.linkedin)) {
          clearInterval(buttonInterval);
        }
      }, 1000);
      if (document.body) {
        const observer = new MutationObserver(() => {
          if (window.location.href.match(SITE_PATTERNS.linkedin)) {
            setTimeout(addLinkedInButton, 800);
          }
        });
        observer.observe(document.body, { childList: true, subtree: true });
      }
    } else {
      addFloatingButton();
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initialize);
  } else {
    initialize();
  }
})();
