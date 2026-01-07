/**
 * Execute historical interview migration batch
 * 
 * This script launches the batch job to migrate all historical interview data
 * from Candidate__c fields to Interview__c records.
 * 
 * Usage:
 * 1. Open this file in VS Code
 * 2. Execute in Anonymous Apex (Ctrl+Shift+P -> "SFDX: Execute Anonymous Apex with Currently Selected Text")
 * 3. Monitor progress: Setup > Apex Jobs > Apex Jobs
 * 
 * Safe to re-run - uses External_Id__c for idempotent upserts (no duplicates)
 */

System.debug('========================================');
System.debug('Starting Historical Interview Migration');
System.debug('========================================');
System.debug('');

// Execute batch with 200 records per batch
InterviewHistoricalMigrationBatch batch = new InterviewHistoricalMigrationBatch();
Id batchId = Database.executeBatch(batch, 200);

System.debug('Batch job started successfully!');
System.debug('Batch Job ID: ' + batchId);
System.debug('');
System.debug('Monitor progress:');
System.debug('1. Go to Setup > Apex Jobs > Apex Jobs');
System.debug('2. Find job: "InterviewHistoricalMigrationBatch"');
System.debug('3. Check status and view debug logs');
System.debug('');
System.debug('Batch will process all active candidates and create Interview__c records for:');
System.debug('  - Ci-First (Attraction Interview)');
System.debug('  - Align-2nd (SI1)');
System.debug('  - Plan-3rd (SI2)');
System.debug('  - Present-4th (Career Presentation)');
System.debug('  - Optional-5th (SI3)');
System.debug('');
System.debug('Interview status will be set based on:');
System.debug('  - "Completed" if completed date exists');
System.debug('  - "Scheduled" if only scheduled date exists');
System.debug('');
System.debug('Interview outcome will be:');
System.debug('  - "Proceed" if subsequent interview is completed');
System.debug('  - null if this is the last interview');
System.debug('');
System.debug('========================================');
