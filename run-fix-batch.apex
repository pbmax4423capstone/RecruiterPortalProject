// Execute batch job to fix all interview names
Database.executeBatch(new FixInterviewNamesBatch(), 200);
System.debug('✓ Batch job started to fix all interview names');
