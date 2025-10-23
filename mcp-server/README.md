# Recruiting Context MCP Server

This is an MCP (Model Context Protocol) server that provides Agentforce with tools to interact with your Salesforce recruiting data.

## Features

- **Get Candidates**: Retrieve candidate information from Interview__c records
- **Schedule Interview**: Schedule new interviews for candidates  
- **Update Interview Outcome**: Update the outcome of completed interviews
- **Get Dashboard Data**: Retrieve recruiter dashboard statistics
- **Reschedule Interview**: Reschedule existing interviews

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Copy the environment file and configure:
   ```bash
   copy .env.example .env
   ```

3. Edit the `.env` file with your Salesforce credentials:
   ```
   SALESFORCE_USERNAME=your-username@company.com
   SALESFORCE_LOGIN_URL=https://login.salesforce.com
   SALESFORCE_INSTANCE_URL=https://your-org.my.salesforce.com
   MCP_SERVER_PORT=3928
   ```

4. Build the server:
   ```bash
   npm run build
   ```

5. Start the server:
   ```bash
   npm start
   ```

## Development

- Run in development mode: `npm run dev`
- Build: `npm run build`
- Clean build files: `npm run clean`

## Configuration

The server is configured to run on port 3928 by default. Update your MCP client configuration to connect to:
- URL: `http://localhost:3928/mcp` (for HTTP transport)
- Or use stdio transport with the built server

## Salesforce Authentication

This server uses the Salesforce CLI authentication. Make sure you're logged in with:
```bash
sf org login web --alias recruiting-sbx
```

For sandbox orgs, use:
```bash
sf org login web --alias recruiting-sbx --instance-url https://test.salesforce.com
```

## Quick Start Scripts

Use the provided scripts to start the server easily:

**PowerShell:**
```powershell
.\start-server.ps1
```

**Batch file:**
```cmd
start-server.bat
```

## Troubleshooting

### Connection Issues
1. Ensure you're authenticated with Salesforce CLI: `sf org list`
2. Check that the recruiting-sbx org is connected
3. Verify the .env file has the correct username and instance URL
4. Make sure the MCP server is built: `npm run build`

### MCP Client Connection
1. Check the MCP settings in VS Code are pointing to the correct path
2. Restart VS Code after updating MCP settings
3. Check VS Code logs for MCP connection errors

## Tools Available

### get_candidates
Retrieve candidate interview records with optional filtering by status.

### schedule_interview  
Create a new interview record for a candidate.

### update_interview_outcome
Update the outcome of a completed interview.

### get_recruiter_dashboard_data
Get aggregated dashboard data for recruiters.

### reschedule_interview
Reschedule an existing interview with a new date/time.