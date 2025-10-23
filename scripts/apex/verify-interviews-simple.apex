// Check all Interview records and their fields
List<Interview__c> interviews = [
    SELECT Id, Interview_Status__c, Interview_Type__c, Conducted_By__r.Name, Outcome__c, Notes__c
    FROM Interview__c 
    LIMIT 5
];

System.debug('Sample Interview Records:');
for (Interview__c interview : interviews) {
    System.debug('ID: ' + interview.Id + ', Type: ' + interview.Interview_Type__c + ', Conductor: ' + interview.Conducted_By__r.Name);
}

// Get total count
Integer totalCount = [SELECT COUNT() FROM Interview__c];
System.debug('Total interviews: ' + totalCount);