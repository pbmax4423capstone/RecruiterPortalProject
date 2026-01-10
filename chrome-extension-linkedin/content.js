// Content script - runs on LinkedIn profile pages
// Extracts profile data from the page
// Wrapped in IIFE to prevent variable redeclaration errors

(function () {
  // Guard against multiple injections (LinkedIn SPA can cause this)
  if (window.__linkedinToSalesforceLoaded) {
    console.log("LinkedIn to Salesforce extension already loaded, skipping...");
    return;
  }
  window.__linkedinToSalesforceLoaded = true;

  console.log(
    "LinkedIn to Salesforce extension loaded on:",
    window.location.href
  );

  function extractProfileData() {
    console.log("Extracting profile data...");

    const data = {
      firstName: "",
      lastName: "",
      email: "",
      phone: "",
      birthday: "",
      headline: "",
      company: "",
      location: "",
      profileUrl: window.location.href.split("?")[0]
    };

    try {
      // Method 1: Try multiple h1 selectors for the name
      let nameElement = document.querySelector("h1.text-heading-xlarge");

      if (!nameElement) {
        // Try other common selectors
        const h1Elements = document.querySelectorAll("h1");
        for (const h1 of h1Elements) {
          const text = h1.textContent.trim();
          // Skip if it looks like a company name or section header
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
        let fullName = nameElement.textContent.trim();
        console.log("Found raw name:", fullName);

        // Remove designations/credentials after comma (e.g., "CFP®, AIF®, MBA")
        // Also handles designations without comma but with ® or common credential patterns
        if (fullName.includes(",")) {
          fullName = fullName.split(",")[0].trim();
        }
        // Remove any remaining credentials that might be space-separated (MBA, PhD, CPA, CFP, etc.)
        fullName = fullName
          .replace(
            /\s+(MBA|PhD|CPA|CFP|AIF|CFA|ChFC|CLU|CRPC|JD|MD|Esq|RIA|CFP®|AIF®|CFA®|ChFC®|CLU®|CRPC®)(\s|$)/gi,
            " "
          )
          .trim();

        console.log("Cleaned name:", fullName);
        const nameParts = fullName.split(" ").filter((p) => p.length > 0);

        if (nameParts.length >= 2) {
          data.firstName = nameParts[0];
          data.lastName = nameParts.slice(1).join(" ");
        } else if (nameParts.length === 1) {
          data.firstName = nameParts[0];
        }
      }

      // Method 2: Get headline - it's usually the div after the name
      const headlineElement =
        document.querySelector(".text-body-medium.break-words") ||
        document.querySelector("div.text-body-medium");

      if (headlineElement) {
        data.headline = headlineElement.textContent.trim();
        console.log("Found headline:", data.headline);
      }

      // Method 3: Get location
      const locationElement =
        document.querySelector(
          ".text-body-small.inline.t-black--light.break-words"
        ) || document.querySelector("span.text-body-small.inline");

      if (locationElement) {
        data.location = locationElement.textContent.trim();
        console.log("Found location:", data.location);
      }

      // Extract email from mailto: links
      const emailLinks = document.querySelectorAll('a[href^="mailto:"]');
      for (const link of emailLinks) {
        const href = link.getAttribute("href");
        if (href) {
          const email = href.replace("mailto:", "").split("?")[0].trim();
          if (
            email &&
            email.includes("@") &&
            !email.toLowerCase().includes("linkedin")
          ) {
            data.email = email;
            console.log("Found email:", data.email);
            break;
          }
        }
      }

      // Extract phone from tel: links
      const phoneLinks = document.querySelectorAll('a[href^="tel:"]');
      for (const link of phoneLinks) {
        const href = link.getAttribute("href");
        if (href) {
          data.phone = href.replace("tel:", "").trim();
          console.log("Found phone from tel link:", data.phone);
          break;
        }
      }

      // Get page text for fallback searches
      const pageText = document.body.innerText || "";

      // Fallback: look for phone in modal area specifically
      if (!data.phone) {
        // Try to find the modal and search within it
        const modal = document.querySelector('.artdeco-modal, [role="dialog"]');
        if (modal) {
          const modalText = modal.innerText || "";
          // Look near "Phone" label in modal
          const phoneIdx = modalText.toLowerCase().indexOf("phone");
          if (phoneIdx !== -1) {
            const nearbyText = modalText.substring(phoneIdx, phoneIdx + 50);
            // Match phone with parentheses format like (719) 210-0399 or regular format
            const phoneMatch = nearbyText.match(
              /\(?(\d{3})\)?[-.\s]?(\d{3})[-.\s]?(\d{4})/
            );
            if (phoneMatch) {
              data.phone = phoneMatch[0].trim();
              console.log(
                "Found phone from modal near Phone label:",
                data.phone
              );
            }
          }
        }

        // If still not found, try page text near "Phone" label (but NOT 800 numbers which are usually ads)
        if (!data.phone) {
          const phoneIdx = pageText.toLowerCase().indexOf("phone");
          if (phoneIdx !== -1) {
            const nearbyText = pageText.substring(phoneIdx, phoneIdx + 50);
            const phoneMatch = nearbyText.match(
              /\(?(\d{3})\)?[-.\s]?(\d{3})[-.\s]?(\d{4})/
            );
            if (
              phoneMatch &&
              !phoneMatch[0].startsWith("800") &&
              !phoneMatch[0].startsWith("(800")
            ) {
              data.phone = phoneMatch[0].trim();
              console.log(
                "Found phone from text near Phone label:",
                data.phone
              );
            }
          }
        }
      }

      // Extract birthday - look for text near "Birthday" label
      const birthdayIdx = pageText.toLowerCase().indexOf("birthday");
      if (birthdayIdx !== -1) {
        const nearbyText = pageText.substring(birthdayIdx, birthdayIdx + 50);
        const months = [
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December"
        ];
        for (const month of months) {
          const pattern = new RegExp(`(${month})\\s+(\\d{1,2})`, "i");
          const match = nearbyText.match(pattern);
          if (match) {
            data.birthday = match[0];
            console.log("Found birthday:", data.birthday);
            break;
          }
        }
      }

      console.log("Extracted data:", data);
    } catch (e) {
      console.error("Error extracting profile data:", e);
    }

    return data;
  }

  // Listen for messages from popup
  chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === "getProfileData") {
      const data = extractProfileData();
      sendResponse(data);
    }
    return true;
  });

  // Add a visual indicator that the extension is active
  function addSaveButton() {
    // Check if button already exists
    if (document.getElementById("sf-save-btn")) return;

    // Find the action buttons area
    const actionsArea =
      document.querySelector(".pv-top-card-v2-ctas") ||
      document.querySelector(".pvs-profile-actions") ||
      document.querySelector(".ph5.pb5");

    if (actionsArea) {
      const btn = document.createElement("button");
      btn.id = "sf-save-btn";
      btn.innerHTML = "☁️ Save to Salesforce";
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

      btn.addEventListener("mouseenter", () => {
        btn.style.transform = "translateY(-2px)";
        btn.style.boxShadow = "0 4px 12px rgba(1, 118, 211, 0.3)";
      });

      btn.addEventListener("mouseleave", () => {
        btn.style.transform = "translateY(0)";
        btn.style.boxShadow = "none";
      });

      btn.addEventListener("click", async () => {
        // First, try to open the Contact Info modal to get email/phone/birthday
        const contactInfoLink =
          document.querySelector('a[href*="/overlay/contact-info"]') ||
          document.querySelector("#top-card-text-details-contact-info") ||
          document.querySelector('a[data-control-name="contact_see_more"]');

        if (contactInfoLink) {
          // Click to open the contact info modal
          contactInfoLink.click();

          // Wait for modal to fully load
          await new Promise((resolve) => setTimeout(resolve, 2500));
        }

        // Now extract data (modal should be open if link was found)
        const data = extractProfileData();

        // Close the modal if we opened it (click the X or press escape)
        const closeBtn =
          document.querySelector('button[aria-label="Dismiss"]') ||
          document.querySelector(".artdeco-modal__dismiss");
        if (closeBtn) {
          closeBtn.click();
        }

        // Send data to background to open popup
        chrome.runtime.sendMessage({
          action: "openPopup",
          profileData: data
        });
      });

      actionsArea.appendChild(btn);
    }
  }

  // Run when page loads
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", addSaveButton);
  } else {
    addSaveButton();
  }

  // Also run when LinkedIn navigates (it's a SPA)
  const observer = new MutationObserver(() => {
    if (window.location.href.includes("/in/")) {
      setTimeout(addSaveButton, 1000);
    }
  });

  if (document.body) {
    observer.observe(document.body, { childList: true, subtree: true });
  }
})();
