// STEP 1: Delete all existing Interviews
List<Interview__c> allInterviews = [SELECT Id FROM Interview__c];
System.debug('Deleting ' + allInterviews.size() + ' interviews');
if (!allInterviews.isEmpty()) {
    delete allInterviews;
}

// STEP 2: Delete all existing Candidates
List<Candidate__c> allCandidates = [SELECT Id FROM Candidate__c];
System.debug('Deleting ' + allCandidates.size() + ' candidates');
if (!allCandidates.isEmpty()) {
    delete allCandidates;
}

System.debug('Cleanup complete - all interviews and candidates deleted');
