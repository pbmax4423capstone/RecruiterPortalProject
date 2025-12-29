// Delete ALL Interview__c records
List<Interview__c> toDelete = [SELECT Id FROM Interview__c];
System.debug('Deleting ' + toDelete.size() + ' Interview__c records...');
delete toDelete;
System.debug('Deleted successfully!');

// Run migration again with NEW code
CandidateInterviewMigrationBatch2 batch = new CandidateInterviewMigrationBatch2();
Database.executeBatch(batch, 200);
System.debug('Migration batch re-started with UPDATED code');
