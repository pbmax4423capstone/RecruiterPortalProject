# Copilot Instructions for Cole Arnold - RecruiterPortal Project

## 🤝 Collaborative Work Notice

**IMPORTANT:** This repository is shared between Patrick Baker and Cole Arnold with their respective Copilot agents.

**Before starting any work:**
1. Check [WORK_COORDINATION.md](../WORK_COORDINATION.md) for active work and protected files
2. Review [SHARED_PLANNING.md](../SHARED_PLANNING.md) for current tasks
3. See [AGENT_COORDINATION.md](../AGENT_COORDINATION.md) for agent handoff patterns

**When handing off work:**
- Create handoff documentation using templates in WORK_COORDINATION.md
- Update task status in SHARED_PLANNING.md
- Provide full context for the next agent/person

## NEW: Unified Dark Mode Implementation (December 29, 2025)
- **Lightning Message Service:** Created `DarkModeChannel__c` for centralized dark mode state management across all Recruiter Portal components
- **Publisher:** `portalHeaderNew` has dark mode toggle button (sun/moon icons) that publishes dark mode state via LMS
- **Subscribers:** All components subscribe to `DarkModeChannel__c`: candidateFunnelDashboard, candidateKanban, recentActivity, candidatesInContractingReadOnly, interviewLeaderboard, scheduledCallsModal
- **Color Scheme:** Consistent across all components:
  - Backgrounds: `#16325c`, `#1a3a52`, `#243649`, `#2c4460`
  - Text: `#ffffff` (headings), `#e8f4fd` (body), `#b0c4de` (secondary)
  - Borders: `#3e5771`, Accents: `#5ea3f2`
- **Pattern:** Each component has `@wire(MessageContext)`, `subscribeToMessageChannel()`, `handleDarkModeChange()`, and `containerClass` getter
- **Lightning Base Components:** Cannot style `<lightning-card>` directly - use wrapper divs with dark mode classes instead
- **Testing Org:** All dark mode changes deployed to `choujifan90@gmail.com.prodtest`

## Dashboard Metrics + Extension Sync (December 29, 2025)
- Review the shared overview at `docs/dashboard-metrics-and-extension-overview.md` before touching recruiter metrics or the LinkedIn extensions so code + docs stay aligned for Patrick and Cole.
- Personal briefing: `docs/Cole-Arnold-Dashboard-Extension-Notes.md` explains the rationale, deployment steps, and talking points you'll use with stakeholders.
- **Interview Leaderboard:** Located at `docs/cole-dashboard-extension.html` - now linked from training-center.html under "Cole Resources" section
- All `InterviewLeaderboard*` Apex methods must continue filtering on **completed** interviews (Status = Completed and Date_Completed__c within the requested window).
- When updating Chrome/Edge extensions, edit both folders in lockstep and keep the IIFE guard (`window.__linkedinToSalesforceLoaded`) intact.
- Keep this file dedicated to Cole-specific guidance; Patrick’s base rules live in `.github/copilot-instructions.md`. Load both instruction files in Copilot so neither set overrides the other.

## CRITICAL: Recent Changes (December 18, 2025)

Before making any modifications, be aware of these recent updates that MUST be preserved:

### 1. candidateRecordView LWC Component
**File:** `force-app/main/default/lwc/candidateRecordView/candidateRecordView.js`

This component was updated to include auto-refresh functionality. The imports MUST include:
```javascript
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import getCandidateData from '@salesforce/apex/CandidateRecordViewController.getCandidateData';
import getNotes from '@salesforce/apex/CandidateNotesController.getNotes';
import ID_FIELD from '@salesforce/schema/Candidate__c.Id';
```

The component includes:
- `@wire(getRecord)` for detecting standard edit modal saves
- CDC subscription methods: `subscribeToChangeEvents()`, `unsubscribeFromChangeEvents()`
- `@api refreshData()` public method
- Auto-refresh interval for notes

DO NOT remove or modify these refresh mechanisms.

### 2. Email Templates - Merge Field Syntax
**Folder:** `force-app/main/default/email/Candidate_Outreach/`

All email templates use classic Salesforce merge field syntax:
- ✅ CORRECT: `{!Contact.FirstName}`
- ❌ WRONG: `{{{Candidate__c.First_Name__c}}}` or `{{{Recipient.FirstName}}}`

Templates updated:
- Candidate_Welcome_Initial_Outreach.email
- Candidate_Stage_Ci_First.email
- Candidate_Stage_Align_Second.email
- Candidate_Stage_Plan_Third.email
- Candidate_Stage_Present_Fourth.email
- Candidate_Stage_Offer_Accepted.email
- Candidate_Stage_Contracted.email

### 3. Chrome/Edge Extension - Content Script Guard
**Files:** 
- `chrome-extension-linkedin/content.js`
- `edge-extension-linkedin/content.js`

These files MUST be wrapped in an IIFE with a guard pattern:
```javascript
(function() {
    if (window.__linkedinToSalesforceLoaded) return;
    window.__linkedinToSalesforceLoaded = true;
    // ... rest of code
})();
```

DO NOT remove this wrapper or the guard check.

### 4. Extension popup.js - Recruiter ID and Contact Creation
**Files:**
- `chrome-extension-linkedin/popup.js`
- `edge-extension-linkedin/popup.js`

The CONFIG object includes:
```javascript
const CONFIG = {
    clientId: '3MVG9AR068fT4usyVQdDlbJ3XVwtPbfdsuFVEcup3mEwR.dQlnrkDltgNCeCXb6bRrC.uTfLjhvHaFkrn7bWd',
    redirectUri: chrome.identity.getRedirectURL(),
    loginUrl: 'https://test.salesforce.com',
    testRecruiterId: '0055f00000DqpnpAAB'
};
```

The candidate creation flow:
1. Creates Contact first
2. Then creates Candidate__c linked to Contact via Contact__c field
3. Uses Type__c: 'Candidate'

### 5. Connected App - Edge Extension Callback URL
**File:** `force-app/main/default/connectedApps/LinkedIn_Import_Extension.connectedApp-meta.xml`

Must include both Chrome and Edge callback URLs in oauthConfig.

## Target Org
- **Org:** patrickbakeradmin2@financialguide.com.prodtest (ProdTest Sandbox)
- **Org-Wide Email:** help@capstonetechsupport.com (display name may show "New Case Email")

## Deployment Command
```bash
sf project deploy start --source-dir "PATH" --target-org patrickbakeradmin2@financialguide.com.prodtest
```

## DO NOT MODIFY Without Coordination
- candidateRecordView (LWC)
- recruiterDashboard (LWC)
- Email templates in Candidate_Outreach folder
- Browser extension files
- LinkedIn_Import_Extension connected app
- Candidate_Stage_Email_Automation flow
