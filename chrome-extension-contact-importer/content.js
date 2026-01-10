// Universal Contact Importer - Content Script
// Extracts contact information from any webpage
// Supports: LinkedIn, ZoomInfo, company websites, and more

(function () {
  // Guard against multiple injections
  if (window.__contactImporterLoaded) {
    console.log("Contact Importer already loaded, skipping...");
    return;
  }
  window.__contactImporterLoaded = true;

  console.log("Contact Importer loaded on:", window.location.href);

  // Site detection patterns
  const SITE_PATTERNS = {
    linkedin: /linkedin\.com\/in\//i,
    zoominfo: /zoominfo\.com/i,
    apollo: /apollo\.io/i,
    lusha: /lusha\.com/i,
    rocketreach: /rocketreach\.co/i,
    hunter: /hunter\.io/i,
    clearbit: /clearbit\.com/i,
    generic: /.*/
  };

  function detectSite() {
    const url = window.location.href;
    for (const [site, pattern] of Object.entries(SITE_PATTERNS)) {
      if (site !== "generic" && pattern.test(url)) {
        return site;
      }
    }
    return "generic";
  }

  // LinkedIn-specific extraction
  function extractLinkedInData() {
    const data = {
      firstName: "",
      lastName: "",
      headline: "",
      company: "",
      location: "",
      email: "",
      phone: "",
      profileUrl: window.location.href.split("?")[0],
      source: "LinkedIn"
    };

    try {
      // Name extraction
      let nameElement = document.querySelector("h1.text-heading-xlarge");
      if (!nameElement) {
        const h1Elements = document.querySelectorAll("h1");
        for (const h1 of h1Elements) {
          const text = h1.textContent.trim();
          if (
            text &&
            !text.includes("Experience") &&
            !text.includes("Education") &&
            text.length < 60
          ) {
            nameElement = h1;
            break;
          }
        }
      }

      if (nameElement) {
        const fullName = nameElement.textContent.trim();
        const nameParts = fullName.split(" ").filter((p) => p.length > 0);
        if (nameParts.length >= 2) {
          data.firstName = nameParts[0];
          data.lastName = nameParts.slice(1).join(" ");
        } else if (nameParts.length === 1) {
          data.firstName = nameParts[0];
        }
      }

      // Headline
      const headlineElement =
        document.querySelector(".text-body-medium.break-words") ||
        document.querySelector("div.text-body-medium");
      if (headlineElement) {
        data.headline = headlineElement.textContent.trim();
      }

      // Location
      const locationElement =
        document.querySelector(
          ".text-body-small.inline.t-black--light.break-words"
        ) || document.querySelector("span.text-body-small.inline");
      if (locationElement) {
        data.location = locationElement.textContent.trim();
      }

      // Try to find company from experience section or headline
      const experienceSection = document.querySelector("#experience");
      if (experienceSection) {
        const companyEl = experienceSection.querySelector(
          '.t-bold span[aria-hidden="true"]'
        );
        if (companyEl) {
          data.company = companyEl.textContent.trim();
        }
      }
    } catch (e) {
      console.error("Error extracting LinkedIn data:", e);
    }

    return data;
  }

  // ZoomInfo-specific extraction
  function extractZoomInfoData() {
    const data = {
      firstName: "",
      lastName: "",
      headline: "",
      company: "",
      location: "",
      email: "",
      phone: "",
      profileUrl: window.location.href.split("?")[0],
      source: "ZoomInfo"
    };

    try {
      // ZoomInfo profile name
      const nameElement =
        document.querySelector('[data-testid="profile-name"]') ||
        document.querySelector(".profile-name") ||
        document.querySelector("h1");
      if (nameElement) {
        const fullName = nameElement.textContent.trim();
        const nameParts = fullName.split(" ").filter((p) => p.length > 0);
        if (nameParts.length >= 2) {
          data.firstName = nameParts[0];
          data.lastName = nameParts.slice(1).join(" ");
        }
      }

      // Title/Headline
      const titleElement =
        document.querySelector('[data-testid="profile-title"]') ||
        document.querySelector(".profile-title");
      if (titleElement) {
        data.headline = titleElement.textContent.trim();
      }

      // Company
      const companyElement =
        document.querySelector('[data-testid="profile-company"]') ||
        document.querySelector(".company-name");
      if (companyElement) {
        data.company = companyElement.textContent.trim();
      }

      // Email (if visible)
      const emailElement =
        document.querySelector('[data-testid="email"]') ||
        document.querySelector('a[href^="mailto:"]');
      if (emailElement) {
        data.email =
          emailElement.textContent.trim() ||
          emailElement.href.replace("mailto:", "");
      }

      // Phone (if visible)
      const phoneElement =
        document.querySelector('[data-testid="phone"]') ||
        document.querySelector('a[href^="tel:"]');
      if (phoneElement) {
        data.phone =
          phoneElement.textContent.trim() ||
          phoneElement.href.replace("tel:", "");
      }

      // Location
      const locationElement =
        document.querySelector('[data-testid="profile-location"]') ||
        document.querySelector(".location");
      if (locationElement) {
        data.location = locationElement.textContent.trim();
      }
    } catch (e) {
      console.error("Error extracting ZoomInfo data:", e);
    }

    return data;
  }

  // Generic extraction - works on any website
  function extractGenericData() {
    const data = {
      firstName: "",
      lastName: "",
      headline: "",
      company: "",
      location: "",
      email: "",
      phone: "",
      profileUrl: window.location.href.split("?")[0],
      source: "Website"
    };

    try {
      // Try to find email addresses on the page
      const emailRegex = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;
      const pageText = document.body.innerText;
      const emails = pageText.match(emailRegex);
      if (emails && emails.length > 0) {
        // Filter out common non-personal emails
        const personalEmails = emails.filter(
          (e) =>
            !e.includes("noreply") &&
            !e.includes("support@") &&
            !e.includes("info@") &&
            !e.includes("contact@") &&
            !e.includes("sales@")
        );
        data.email = personalEmails[0] || emails[0];
      }

      // Try to find phone numbers
      const phoneRegex =
        /(?:\+?1[-.\s]?)?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}/g;
      const phones = pageText.match(phoneRegex);
      if (phones && phones.length > 0) {
        data.phone = phones[0];
      }

      // Try to find name from common patterns
      const namePatterns = [
        // Schema.org Person
        () => {
          const personSchema = document.querySelector(
            '[itemtype*="schema.org/Person"] [itemprop="name"]'
          );
          return personSchema?.textContent.trim();
        },
        // vCard
        () => {
          const vcard = document.querySelector(".vcard .fn, .h-card .p-name");
          return vcard?.textContent.trim();
        },
        // Common "About" or profile sections
        () => {
          const aboutSection = document.querySelector(
            '.about-name, .profile-name, .author-name, [class*="person-name"]'
          );
          return aboutSection?.textContent.trim();
        },
        // Page title often contains name on profile pages
        () => {
          const title = document.title;
          // Check if title looks like a name (2-4 words, no common page words)
          const words = title.split(/[\s\-|]+/).filter((w) => w.length > 1);
          if (words.length >= 2 && words.length <= 4) {
            const commonWords = [
              "home",
              "page",
              "profile",
              "about",
              "contact",
              "welcome",
              "the",
              "and",
              "company"
            ];
            const isName = !words.some((w) =>
              commonWords.includes(w.toLowerCase())
            );
            if (isName) return words.slice(0, 3).join(" ");
          }
          return null;
        }
      ];

      for (const pattern of namePatterns) {
        const name = pattern();
        if (name) {
          const nameParts = name.split(" ").filter((p) => p.length > 0);
          if (nameParts.length >= 2) {
            data.firstName = nameParts[0];
            data.lastName = nameParts.slice(1).join(" ");
            break;
          }
        }
      }

      // Try to find company name
      const companyPatterns = [
        document.querySelector(
          '[itemtype*="schema.org/Organization"] [itemprop="name"]'
        ),
        document.querySelector(
          '.company-name, .organization-name, [class*="company"]'
        ),
        document.querySelector('meta[property="og:site_name"]')
      ];

      for (const el of companyPatterns) {
        if (el) {
          data.company = el.textContent?.trim() || el.content;
          break;
        }
      }

      // Try to find title/headline
      const titlePatterns = [
        document.querySelector('[itemprop="jobTitle"]'),
        document.querySelector('.job-title, .title, [class*="job-title"]')
      ];

      for (const el of titlePatterns) {
        if (el) {
          data.headline = el.textContent.trim();
          break;
        }
      }
    } catch (e) {
      console.error("Error extracting generic data:", e);
    }

    return data;
  }

  // Main extraction function
  function extractContactData() {
    const site = detectSite();
    console.log("Detected site type:", site);

    switch (site) {
      case "linkedin":
        return extractLinkedInData();
      case "zoominfo":
        return extractZoomInfoData();
      default:
        return extractGenericData();
    }
  }

  // Get text selection for manual highlighting
  function getSelectedText() {
    const selection = window.getSelection();
    return selection ? selection.toString().trim() : "";
  }

  // Listen for messages from popup
  chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    console.log("Content script received message:", request.action);

    switch (request.action) {
      case "getContactData":
        const data = extractContactData();
        console.log("Extracted contact data:", data);
        sendResponse(data);
        break;

      case "getSelectedText":
        sendResponse({ text: getSelectedText() });
        break;

      case "getSiteType":
        sendResponse({ site: detectSite() });
        break;

      case "ping":
        sendResponse({ status: "ok" });
        break;
    }

    return true;
  });

  // Create floating action button for quick capture
  function createFloatingButton() {
    // Only show on supported sites initially
    const site = detectSite();
    if (site === "generic") return; // Don't show FAB on generic sites by default

    const existingBtn = document.getElementById("contact-importer-fab");
    if (existingBtn) return;

    const fab = document.createElement("div");
    fab.id = "contact-importer-fab";
    fab.innerHTML = "📋";
    fab.title = "Import to Salesforce";
    fab.style.cssText = `
      position: fixed;
      bottom: 20px;
      right: 20px;
      width: 56px;
      height: 56px;
      background: linear-gradient(135deg, #0176d3 0%, #014486 100%);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
      cursor: pointer;
      box-shadow: 0 4px 12px rgba(0,0,0,0.3);
      z-index: 999999;
      transition: transform 0.2s, box-shadow 0.2s;
    `;

    fab.addEventListener("mouseenter", () => {
      fab.style.transform = "scale(1.1)";
      fab.style.boxShadow = "0 6px 20px rgba(0,0,0,0.4)";
    });

    fab.addEventListener("mouseleave", () => {
      fab.style.transform = "scale(1)";
      fab.style.boxShadow = "0 4px 12px rgba(0,0,0,0.3)";
    });

    fab.addEventListener("click", () => {
      // Send message to open popup or show inline modal
      chrome.runtime.sendMessage({ action: "openPopup" });
    });

    document.body.appendChild(fab);
  }

  // Initialize
  if (document.readyState === "complete") {
    createFloatingButton();
  } else {
    window.addEventListener("load", createFloatingButton);
  }
})();
