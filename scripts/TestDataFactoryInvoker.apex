/**
 * Anonymous Apex Script for Test Data Factory Execution
 * 
 * HOW TO USE IN SANDBOX:
 * ----------------------
 * 1. Open Developer Console in your sandbox
 * 2. Go to Debug → Open Execute Anonymous Window
 * 3. Paste the code from this file
 * 4. Check "Open Log" option
 * 5. Click Execute
 * 
 * OR use Salesforce CLI:
 * ----------------------
 * sf apex run --target-org ProdTest --file scripts/TestDataFactoryInvoker.apex
 * 
 * WHAT IT DOES:
 * -------------
 * - Creates 500 Candidates with linked Contacts
 * - Creates 800 Interviews (500 Ci-First, 150 Plan-3rd, 100 Present-4th, 50 Optional-5th)
 * - Creates 300 ALC records for contracting candidates
 * - Creates 1000 Opportunities linked to agent Contacts (for FYC rollup)
 * - All linked to "Capstone Partners" account
 * 
 * Can be run multiple times - adds incremental data with unique identifiers
 * 
 * TO CLEAN UP DATA:
 * -----------------
 * Uncomment the cleanup line below and comment out the generate line
 */

// === GENERATE TEST DATA ===
// Uncomment ONE of the lines below:

// Option 1: Standard generation (may trigger flow automation)
// TestDataFactory.generateCompleteTestData();

// Option 2: Sandbox-safe generation (bypasses flow issues with partial success)
TestDataFactory.generateSandboxSafeTestData();

// === CLEAN UP TEST DATA ===
// Uncomment the line below to delete all test data:
// TestDataFactory.deleteAllTestData();

System.debug('=== Check Debug Logs for detailed execution results ===');
