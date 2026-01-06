// Find Alec Bucklen (note the spelling)
List<Candidate__c> candidates = [SELECT Id, Name, First_Name__c, Last_Name__c FROM Candidate__c WHERE First_Name__c = 'Alec' LIMIT 5];
System.debug('=== Found Alec candidates:');
for (Candidate__c c : candidates) {
    System.debug('Name: ' + c.Name + ' (' + c.First_Name__c + ' ' + c.Last_Name__c + '), Id: ' + c.Id);
}
