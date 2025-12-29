// Run the new migration batch
CandidateInterviewMigrationBatch2 batch = new CandidateInterviewMigrationBatch2();
Id jobId = Database.executeBatch(batch, 200);

System.debug('=== STARTING NEW INTERVIEW MIGRATION ===');
System.debug('This migration will:');
System.debug('  1. Create Interview__c records for ALL interviews (reporting)');
System.debug('  2. Create Event records ONLY for SF Sales Managers:');
System.debug('     - Andrew Moore');
System.debug('     - Brooke Ianni');
System.debug('     - Rachyll Tenny');
System.debug('     - Tim Denton');
System.debug('     - Van Hess');
System.debug('     - Elizabeth Kagele');
System.debug('     - Bradley Sofonia');
System.debug('  3. Skip Event creation for non-SF users (no calendar clutter for Pat Baker)');
System.debug('');
System.debug('Batch Job ID: ' + jobId);
