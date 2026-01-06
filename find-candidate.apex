// Find candidate from the screenshot
List<Candidate__c> candidates = [SELECT Id, Name, First_Name__c, Last_Name__c FROM Candidate__c WHERE Last_Name__c LIKE 'Buck%' LIMIT 5];
System.debug('=== Found candidates:');
for (Candidate__c c : candidates) {
    System.debug('Name: ' + c.Name + ' (' + c.First_Name__c + ' ' + c.Last_Name__c + '), Id: ' + c.Id);
}
