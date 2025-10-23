# RecruiterPortalProject

A Salesforce DX project for the Recruiter Portal application, featuring a Lightning Web Component dashboard for managing interviews and candidates.

## Project Overview

This project includes:
- **Lightning Web Components**: Interactive recruiter dashboard
- **Apex Classes**: Controllers and test data generators
- **Custom Objects**: Interview management system
- **MCP Server**: TypeScript-based Model Context Protocol server
- **Test Data Scripts**: Apex scripts for generating test interview data

## Key Components

### Lightning Web Components
- `recruiterDashboard`: Main dashboard component with interview statistics and candidate management

### Apex Classes
- `RecruiterDashboardController`: Main controller for dashboard data
- `InterviewTestDataGenerator`: Generates test interview data
- `TestDataGenerator`: General test data utilities
- `RecruiterRescheduleHelper`: Helper for interview rescheduling

### Custom Objects
- `Interview__c`: Custom object for managing interview records

## Salesforce DX Setup

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Development Resources

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)