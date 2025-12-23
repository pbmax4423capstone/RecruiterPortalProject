// Fix the names of the newly created candidates
List<Candidate__c> newCandidates = [SELECT Id, Name, First_Name__c, Last_Name__c FROM Candidate__c WHERE Id IN ('a02dh00000AoLBZ', 'a02dh00000AoLBa')];
for (Candidate__c c : newCandidates) {
    System.debug(c.Id + ' | Name: ' + c.Name + ' | First: ' + c.First_Name__c + ' | Last: ' + c.Last_Name__c);
}

// Fix the names for display (should auto-populate from First_Name__c + Last_Name__c)
System.debug('');
System.debug('=== ALL CONTRACT B CONTRACTED ===');
for (Candidate__c c : [SELECT Id, Name, First_Name__c, Last_Name__c, Status__c 
                       FROM Candidate__c 
                       WHERE Status__c = 'Contracted- Contract B']) {
    System.debug(c.First_Name__c + ' ' + c.Last_Name__c + ' | Status: ' + c.Status__c);
}
