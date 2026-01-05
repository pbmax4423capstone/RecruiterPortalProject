# Copilot Instructions for RecruiterPortal Project

## Project Overview

This is a Salesforce DX project for a Recruiter Portal application built on the Salesforce platform. The application manages candidate recruitment, interviews, and contract lifecycle tracking.

**Tech Stack:**
- Salesforce Lightning Web Components (LWC)
- Apex (Salesforce backend)
- JavaScript (Browser extensions)
- TypeScript (MCP server)

**Key Features:**
- Recruiter dashboards with interview statistics
- Candidate and interview management
- Contract B lifecycle tracking with FYC rollups
- Browser extensions (Chrome & Edge) for LinkedIn candidate importing
- Automated email workflows for candidate stage transitions

## Target Orgs

### Production (Primary)
- **Org Alias:** `ProductionCapstone` or `production`
- **Username:** `patrickbakeradmin2@financialguide.com`
- **Org Type:** Production - Live data org for daily work
- **Org-Wide Email:** help@capstonetechsupport.com
- **Set as Default:** `sf config set target-org=ProductionCapstone`

### ProdTest Sandbox (Testing)
- **Org Alias:** `ProdTest` or `prodtest`
- **Username:** `patrickbakeradmin2@financialguide.com.prodtest`
- **Org Type:** Partial Data Sandbox - For testing before production deployment
- **Use When:** Testing changes with subset of production data before deploying to production

## Build, Test & Deploy

### Linting
```bash
npm run lint              # Lint JavaScript/LWC files
npm run prettier         # Format all files
npm run prettier:verify  # Check formatting without changes
```

### Testing
```bash
npm run test                    # Run all unit tests
npm run test:unit:watch        # Run tests in watch mode
npm run test:unit:coverage     # Run tests with coverage report
```

### Deployment

**Note:** Production is set as the default target org, so `--target-org` flag is not required for production deployments.

#### Deploy to Production (Default)
```bash
# Deploy a single component
sf project deploy start --source-dir "force-app/main/default/lwc/COMPONENT_NAME"

# Deploy a folder (e.g., all classes)
sf project deploy start --source-dir "force-app/main/default/classes"

# Deploy everything (use caution)
sf project deploy start --source-dir force-app

# Retrieve changes from production
sf project retrieve start --source-dir "force-app/main/default/lwc/COMPONENT_NAME"
```

#### Test in ProdTest Sandbox
```bash
# Deploy to sandbox for testing (explicit target required)
sf project deploy start --source-dir "force-app/main/default/lwc/COMPONENT_NAME" --target-org ProdTest

# Retrieve from sandbox
sf project retrieve start --source-dir "force-app/main/default/lwc/COMPONENT_NAME" --target-org ProdTest
```

## Project Structure

```
force-app/main/default/
├── classes/              # Apex classes (controllers, services, schedulers)
├── lwc/                 # Lightning Web Components
├── objects/             # Custom objects (Candidate__c, Interview__c, ALC__c)
├── flows/               # Process automation flows
├── email/               # Email templates
├── connectedApps/       # OAuth configurations
├── applications/        # Salesforce apps
└── tabs/                # Custom tabs

chrome-extension-linkedin/   # Chrome extension for LinkedIn import
edge-extension-linkedin/     # Edge version of LinkedIn extension
docs/                        # Training and technical documentation
mcp-server/                  # Model Context Protocol server
scripts/                     # Utility scripts
```

## Key Components

### Lightning Web Components
- **recruiterDashboard** - Main dashboard with interview statistics
- **contractBPipelineDashboard** - Contract B lifecycle tracking with YTD metrics
- **candidateRecordView** - Candidate record page with auto-refresh functionality
- **scheduledCalls** - Scheduled calls management
- **serviceDashboard** - Service team dashboard

### Apex Classes
- **RecruiterDashboardController** - Data provider for recruiter dashboard
- **ContractBDashboardController** - Contract B pipeline and YTD recruiting metrics
- **CandidateFYCRollupService** - FYC and opportunity rollup calculations
- **ContractBDailyRollupScheduler** - Daily scheduled job for FYC updates
- **CandidateRecordViewController** - Data provider for candidate record view
- **CandidateNotesController** - Notes functionality

### Custom Objects
- **Candidate__c** - Main candidate profiles with contract lifecycle tracking
- **Interview__c** - Interview scheduling and tracking
- **ALC__c** - Agent Licensing & Contracting
- **Feedback__c** - User feedback from browser extensions

## Coding Conventions

### General Practices
- Follow existing code style and patterns in the repository
- Use Prettier for code formatting (configured in `.prettierrc`)
- Run linter before committing changes
- Test changes in the target org before committing
- Deploy incrementally - only deploy what you changed

### Salesforce/LWC Specific
- Use `@wire` decorators for reactive data fetching
- Implement `refreshApex` for manual data refresh when needed
- Follow LWC naming conventions: camelCase for properties/methods
- Use `@api` decorator for public properties/methods
- Properly handle errors with `try-catch` and user-friendly error messages

### Email Templates
- Use classic Salesforce merge field syntax: `{!Contact.FirstName}` ✅
- Do NOT use: `{{{Recipient.FirstName}}}` or `{{{Candidate__c.First_Name__c}}}` ❌
- All templates are in `force-app/main/default/email/Candidate_Outreach/`

### Browser Extensions
- Content scripts MUST be wrapped in IIFE with guard pattern:
  ```javascript
  (function() {
      if (window.__linkedinToSalesforceLoaded) return;
      window.__linkedinToSalesforceLoaded = true;
      // ... rest of code
  })();
  ```
- Maintain consistent OAuth configuration between Chrome and Edge versions
- Test in both Chrome and Edge after changes

## Important Files - Coordinate Before Modifying

These components are actively maintained and should be modified with coordination:

### LWC Components (Recently Updated)
- `candidateRecordView` - Has auto-refresh with CDC subscription, `@wire(getRecord)`, and `refreshApex`
- `recruiterDashboard` - Main dashboard interface
- `contractBPipelineDashboard` - Contract B tracking with complex metrics

### Email Templates (Candidate_Outreach folder)
All 7 templates use `{!Contact.FirstName}` merge field syntax:
- Candidate_Welcome_Initial_Outreach.email
- Candidate_Stage_Ci_First.email
- Candidate_Stage_Align_Second.email
- Candidate_Stage_Plan_Third.email
- Candidate_Stage_Present_Fourth.email
- Candidate_Stage_Offer_Accepted.email
- Candidate_Stage_Contracted.email

### Browser Extensions
- chrome-extension-linkedin/ (content.js, popup.js, background.js)
- edge-extension-linkedin/ (content.js, popup.js, background.js)

### Connected Apps
- LinkedIn_Import_Extension - OAuth for browser extensions

### Flows
- Candidate_Stage_Email_Automation - Sends emails on stage changes

## Development Workflow

### Before Starting Work
1. Pull latest changes: `git pull origin main`
2. Verify org connection: `sf org list` and `sf org display` (ensure ProductionCapstone is set as default)
3. Review recently modified files listed above

### Making Changes
1. Deploy incrementally to test changes
2. Test functionality in the org
3. Run linter: `npm run lint`
4. Format code: `npm run prettier`
5. Review git diff to ensure only intended files changed

### Committing Changes
1. Stage changes: `git add .`
2. Commit with clear message: `git commit -m "Description of changes"`
3. Push to remote: `git push origin main`
4. Verify deployment succeeded

## Common Issues & Solutions

### "Identifier already declared" errors in extensions
Don't remove the IIFE guard pattern in content scripts - it prevents duplicate declarations when scripts reload.

### Email merge fields showing raw code
Use classic Salesforce syntax `{!Contact.FirstName}` in text email templates, not Lightning syntax.

### LWC not refreshing after record edit
The `candidateRecordView` uses multiple refresh mechanisms:
- `@wire(getRecord)` for standard edit modal saves
- CDC subscription for real-time updates
- `refreshApex` for manual refresh
- Auto-refresh interval for notes

Don't remove these mechanisms when modifying the component.

### Deployment failures
- Check that you're deploying to the correct org (production by default, use `--target-org ProdTest` for sandbox)
- Verify all metadata dependencies are included
- Review deployment output for specific error messages

## Documentation

Comprehensive documentation is available in the `docs/` folder:
- **ATS-Training-Program.md** - Complete recruiter training
- **ATS-Quick-Start-Guide.md** - One-page reference
- **Sales-Manager-Dashboard-Guide.md** - Dashboard guide
- **Contract-B-Lifecycle-Training.md** - Contract B tracking system
- **LOXO-ATS-Design.md** - Technical design document

See also:
- **COLE_ARNOLD_DEVELOPMENT_GUIDE.md** - Developer-specific guide
- **MODAL_DESIGN_GUIDELINES.md** - Modal design standards
- **README.md** - Project overview

## Pre-commit Hooks

This project uses Husky for pre-commit hooks via `lint-staged`:
- Prettier automatically formats staged files
- ESLint checks JavaScript/LWC files
- LWC Jest tests run for related test files

If pre-commit checks fail, fix the issues before committing.

## Additional Notes

- The project uses Salesforce CLI (`sf` commands) rather than legacy `sfdx`
- Browser extensions require OAuth configuration via Connected App
- FYC rollups run daily via scheduled Apex job
- Interview statistics support Current Month / YTD toggle
- Contract B tracking includes multiple lifecycle stages and metrics
