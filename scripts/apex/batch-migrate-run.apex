/**
 * Launch the batch migration in REAL RUN mode.
 * This will process all candidates with completed interviews and CREATE Event records.
 * Batch size: 200 candidates per batch (safe for governor limits)
 * 
 * Expected runtime: ~10-15 minutes for 27,247 candidates
 * 
 * WARNING: This will create Event records in Production!
 * Make sure you've run the dry-run first and reviewed the results.
 */

CandidateInterviewMigrationBatch batch = new CandidateInterviewMigrationBatch(false); // false = real run
Id jobId = Database.executeBatch(batch, 200);

System.debug('========================================');
System.debug('BATCH JOB STARTED (REAL RUN)');
System.debug('Job Id: ' + jobId);
System.debug('Batch Size: 200 candidates per batch');
System.debug('Mode: REAL RUN (Events WILL be created)');
System.debug('========================================');
System.debug('');
System.debug('To monitor progress:');
System.debug('1. Go to Setup > Environments > Jobs > Apex Jobs');
System.debug('2. Look for job ID: ' + jobId);
System.debug('');
System.debug('To check debug logs after completion:');
System.debug('Setup > Environments > Logs > Debug Logs');
System.debug('');
System.debug('Estimated completion: ' + System.now().addMinutes(15));
