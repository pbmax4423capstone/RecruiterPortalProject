// Delete all candidates from recruiting sandbox
List<Candidate__c> allCandidates = [SELECT Id FROM Candidate__c];
System.debug('Found ' + allCandidates.size() + ' candidates to delete');

if (!allCandidates.isEmpty()) {
    delete allCandidates;
    System.debug('Deleted all candidates');
}

System.debug('Remaining count: ' + [SELECT COUNT() FROM Candidate__c]);
