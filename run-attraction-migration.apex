// Run Attraction Interview Migration
CandidateInterviewMigrationBatch2 batch = new CandidateInterviewMigrationBatch2();
Database.executeBatch(batch, 200);
System.debug('Migration batch started');
