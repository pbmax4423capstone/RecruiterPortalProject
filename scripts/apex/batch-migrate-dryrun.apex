/**
 * Launch the batch migration in DRY RUN mode.
 * This will process all candidates with completed interviews but won't create any Event records.
 * Batch size: 200 candidates per batch (safe for governor limits)
 * 
 * Expected runtime: ~10-15 minutes for 27,247 candidates
 */

CandidateInterviewMigrationBatch batch = new CandidateInterviewMigrationBatch(true); // true = dry run
Id jobId = Database.executeBatch(batch, 200);

System.debug('========================================');
System.debug('BATCH JOB STARTED (DRY RUN)');
System.debug('Job Id: ' + jobId);
System.debug('Batch Size: 200 candidates per batch');
System.debug('Mode: DRY RUN (no Events will be created)');
System.debug('========================================');
System.debug('');
System.debug('To monitor progress:');
System.debug('1. Go to Setup > Environments > Jobs > Apex Jobs');
System.debug('2. Look for job ID: ' + jobId);
System.debug('');
System.debug('To check debug logs after completion:');
System.debug('Setup > Environments > Logs > Debug Logs');
