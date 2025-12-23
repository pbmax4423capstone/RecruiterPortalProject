# RecruiterPortalProject

A Salesforce DX project for the Recruiter Portal application, featuring Lightning Web Component dashboards for managing interviews, candidates, and Contract B lifecycle tracking.

## Project Overview

This project includes:
- **Lightning Web Components**: Interactive recruiter dashboards and candidate management
- **Apex Classes**: Controllers for dashboards, FYC rollups, and test data generators
- **Custom Objects**: Interview and candidate management system
- **Flows**: Automated contract lifecycle tracking
- **MCP Server**: TypeScript-based Model Context Protocol server
- **Browser Extensions**: LinkedIn to Salesforce candidate importer (Chrome & Edge)

## Key Components

### Lightning Web Components
- `recruiterDashboard`: Main dashboard with interview statistics and candidate management
- `contractBPipelineDashboard`: Contract B lifecycle tracking with:
  - Summary cards (Active, Requirements Met, At Risk, Total FYC)
  - Interview statistics with Current Month / YTD toggle
  - YTD Recruiting Metrics (Contract A/B recruited, transitions, terminations)
  - Contract A Progress section
  - Pipeline details table with progress bars
- `candidateRecordView`: Candidate record page with auto-refresh

### Apex Classes
- `RecruiterDashboardController`: Main recruiter dashboard data
- `ContractBDashboardController`: Contract B pipeline and YTD metrics
- `CandidateFYCRollupService`: FYC and opportunity rollup calculations
- `ContractBDailyRollupScheduler`: Daily scheduled job for FYC updates
- `CandidateRecordViewController`: Candidate record view data
- `InterviewTestDataGenerator`: Test data generation utilities

### Custom Objects
- `Candidate__c`: Main candidate profiles with contract lifecycle fields
- `Interview__c`: Interview scheduling and tracking
- `ALC__c`: Agent Licensing & Contracting

## Documentation

### Training Materials
- **[ATS Training Program](docs/ATS-Training-Program.md)**: Complete guided training for recruiters and sales managers
- **[Quick Start Guide](docs/ATS-Quick-Start-Guide.md)**: One-page reference card for daily use
- **[Sales Manager Guide](docs/Sales-Manager-Dashboard-Guide.md)**: Dashboard guide for sales managers

### Technical Documentation
- **[Contract B Lifecycle Training](docs/Contract-B-Lifecycle-Training.md)**: Detailed Contract B tracking system guide
- **[System Design Document](docs/LOXO-ATS-Design.md)**: Technical design and implementation details
- **[Development Guide](COLE_ARNOLD_DEVELOPMENT_GUIDE.md)**: Guide for developers working on this project
- **[LinkedIn Extension](chrome-extension-linkedin/README.md)**: Setup for Chrome/Edge LinkedIn importer

## Salesforce DX Setup

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Development Resources

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)