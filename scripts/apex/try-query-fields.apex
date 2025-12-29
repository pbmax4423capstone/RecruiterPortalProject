// Try to actually query with the fields
try {
    List<Interview__c> interviews = [
        SELECT Id, Name, Candidate__c, Conducted_By__c, Interview_Type__c
        FROM Interview__c
        LIMIT 1
    ];
    System.debug('SUCCESS! Query worked. Records found: ' + interviews.size());
    if (!interviews.isEmpty()) {
        System.debug('Interview: ' + interviews[0]);
    }
} catch (Exception e) {
    System.debug('Query FAILED: ' + e.getMessage());
    System.debug('Exception type: ' + e.getTypeName());
}
