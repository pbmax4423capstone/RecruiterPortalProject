// Query Interview__c records to see what data we have
List<Interview__c> interviews = [SELECT Id, Name, CreatedDate FROM Interview__c WHERE CreatedDate = TODAY LIMIT 5];
System.debug('Interviews created today: ' + interviews.size());
for (Interview__c i : interviews) {
    System.debug('Interview: ' + i);
}

// Try to query with custom fields to see what fails
try {
    List<Interview__c> intWithCustomFields = [SELECT Id, Candidate__c FROM Interview__c LIMIT 1];
    System.debug('Query with Candidate__c succeeded');
} catch (Exception e) {
    System.debug('Query with Candidate__c failed: ' + e.getMessage());
}

try {
    List<Interview__c> intWithConductedBy = [SELECT Id, Conducted_By__c FROM Interview__c LIMIT 1];
    System.debug('Query with Conducted_By__c succeeded');
} catch (Exception e) {
    System.debug('Query with Conducted_By__c failed: ' + e.getMessage());
}
