// Re-run migration with fixed code
List<Id> allCandidateIds = new List<Id>();
for (Candidate__c c : [SELECT Id FROM Candidate__c LIMIT 10000]) {
    allCandidateIds.add(c.Id);
}

CandidateInterviewDataMigration.Result result = CandidateInterviewDataMigration.migrateInterviews(allCandidateIds);
System.debug('Migration completed!');
System.debug('Candidates processed: ' + result.candidatesProcessed);
System.debug('Interview records created: ' + result.interviewRecordsCreated);
System.debug('Event records created: ' + result.eventRecordsCreated);
System.debug('Events skipped: ' + result.eventsSkipped);
System.debug('Warnings: ' + result.warnings.size());
System.debug('Errors: ' + result.errors.size());
for (String error : result.errors) {
    System.debug('ERROR: ' + error);
}
