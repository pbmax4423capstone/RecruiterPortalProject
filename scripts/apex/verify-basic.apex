// Simple verification of Interview records
List<Interview__c> interviews = [SELECT Id, Name, Conducted_By__c FROM Interview__c LIMIT 10];

System.debug('Total interviews found: ' + interviews.size());
for (Interview__c interview : interviews) {
    System.debug('Interview: ' + interview.Name + ', Conducted By ID: ' + interview.Conducted_By__c);
}