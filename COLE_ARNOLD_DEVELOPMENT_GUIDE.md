# Development Guide for Cole Arnold

## 🤝 NEW: Collaborative Work Framework

**Before starting any work, check these coordination documents:**

1. **[QUICK_COORDINATION.md](QUICK_COORDINATION.md)** - ⚡ Fast reference guide
2. **[WORK_COORDINATION.md](WORK_COORDINATION.md)** - 🤝 Full coordination protocols
3. **[SHARED_PLANNING.md](SHARED_PLANNING.md)** - 📋 Current task board
4. **[AGENT_COORDINATION.md](AGENT_COORDINATION.md)** - 🤖 Agent handoff patterns

**Quick Coordination Check:**
```bash
# Check active work
cat SHARED_PLANNING.md | grep "🔵 In Progress"

# Check protected files
cat WORK_COORDINATION.md | grep -A 30 "Protected Files"

# Pull latest
git pull origin main
```

---

## Getting Started

### 1. Pull Latest Changes
Before starting any work, always pull the latest changes from the main branch:

```bash
git pull origin main
```

### 2. Target Orgs

**Production (Primary Working Org):**
- **Alias:** `ProductionCapstone` or `production`
- **Username:** `patrickbakeradmin2@financialguide.com`
- **Org Type:** Production - Live data org for daily work
- **Set as default:** `sf config set target-org=ProductionCapstone`

**ProdTest Sandbox (Testing Only):**
- **Alias:** `ProdTest` or `prodtest`
- **Username:** `patrickbakeradmin2@financialguide.com.prodtest`
- **Org Type:** Partial Data Sandbox - For testing before production deployment

Verify your connection:
```bash
sf org list
sf org display  # Should show 'ProductionCapstone' as target
```

---

## Recently Modified Components (DO NOT MODIFY WITHOUT COORDINATION)

The following components have been actively modified by Pat Baker. Coordinate before making changes:

### LWC Components
| Component | Description | Last Modified |
|-----------|-------------|---------------|
| `candidateRecordView` | Main candidate record page with auto-refresh | Dec 18, 2025 |
| `recruiterDashboard` | Main recruiter dashboard | Dec 2025 |
| `contractBPipelineDashboard` | Contract B lifecycle tracking & YTD metrics | Dec 19, 2025 |

### Email Templates (Candidate_Outreach folder)
All 7 templates were updated Dec 18, 2025 - merge fields changed to `{!Contact.FirstName}`:
- `Candidate_Welcome_Initial_Outreach.email`
- `Candidate_Stage_Ci_First.email`
- `Candidate_Stage_Align_Second.email`
- `Candidate_Stage_Plan_Third.email`
- `Candidate_Stage_Present_Fourth.email`
- `Candidate_Stage_Offer_Accepted.email`
- `Candidate_Stage_Contracted.email`

### Flows
| Flow | Description |
|------|-------------|
| `Candidate_Stage_Email_Automation` | Sends emails on stage changes |
| `Test_Welcome_Email_Only` | Test flow - can be deactivated |

### Browser Extensions
- `chrome-extension-linkedin/` - LinkedIn to Salesforce importer
- `edge-extension-linkedin/` - Edge version of above

### Connected Apps
- `LinkedIn_Import_Extension` - OAuth for browser extensions

---

## Deployment Commands

**Note:** Production is set as the default target org. Commands without `--target-org` flag deploy to production.

### Deploy to Production (Default)

#### Deploy a Single Component
```bash
sf project deploy start --source-dir "force-app/main/default/lwc/COMPONENT_NAME"
```

#### Deploy a Folder
```bash
sf project deploy start --source-dir "force-app/main/default/classes"
```

#### Deploy Everything (Use Caution)
```bash
sf project deploy start --source-dir force-app
```

#### Retrieve Changes from Production
```bash
sf project retrieve start --source-dir "force-app/main/default/lwc/COMPONENT_NAME"
```

### Test in ProdTest Sandbox (Before Production)

```bash
# Deploy to sandbox for testing (explicit target required)
sf project deploy start --source-dir "force-app/main/default/lwc/COMPONENT_NAME" --target-org ProdTest

# Retrieve from sandbox
sf project retrieve start --source-dir "force-app/main/default/lwc/COMPONENT_NAME" --target-org ProdTest
```

---

## Best Practices

### Before Making Changes
1. **Pull latest:** `git pull origin main`
2. **Check for conflicts:** Review recently modified files above
3. **Communicate:** Slack/message Pat if touching shared components

### When Making Changes
1. **Deploy incrementally:** Deploy only what you changed
2. **Test in org:** Verify functionality before committing
3. **Don't modify files you didn't change:** If a file appears in your git diff that you didn't intentionally edit, revert it

### After Making Changes
1. **Commit with clear messages:**
   ```bash
   git add .
   git commit -m "Cole: Description of what was changed"
   git push origin main
   ```

2. **Verify deployment succeeded:** Check the terminal output for errors

---

## Common Issues & Solutions

### "Identifier already declared" errors in extensions
The content scripts use an IIFE guard pattern. Don't remove:
```javascript
(function() {
    if (window.__linkedinToSalesforceLoaded) return;
    window.__linkedinToSalesforceLoaded = true;
    // ... rest of code
})();
```

### Email merge fields showing raw code
Use classic Salesforce syntax for text email templates:
- ✅ Correct: `{!Contact.FirstName}`
- ❌ Wrong: `{{{Recipient.FirstName}}}`

### LWC not refreshing after record edit
The `candidateRecordView` component uses:
- `@wire(getRecord)` for detecting standard edit saves
- CDC subscription for real-time updates
- `refreshApex` for manual refresh

---

## Key Files Reference

### Apex Controllers
- `CandidateRecordViewController.cls` - Data for candidate record view
- `RecruiterDashboardController.cls` - Dashboard data
- `CandidateNotesController.cls` - Notes functionality
- `ContractBDashboardController.cls` - Contract B pipeline & recruiting metrics
- `CandidateFYCRollupService.cls` - FYC rollup calculations

### Objects
- `Candidate__c` - Main candidate object
- `Interview__c` - Interview scheduling
- `Contact` - Linked contact records

### Permission Sets
- `Recruiter_Portal_User` - Main permissions for portal users

---

## Contact
If you have questions about recent changes, contact Pat Baker.

**Last Updated:** December 18, 2025
