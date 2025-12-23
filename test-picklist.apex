// Test picklist update
Candidate__c testCandidate = [SELECT Id, Name, Contract_Type__c FROM Candidate__c LIMIT 1];
System.debug('Before: ' + testCandidate.Name + ' - ' + testCandidate.Contract_Type__c);

// Try the new value
testCandidate.Contract_Type__c = 'Contract A';
update testCandidate;

System.debug('After: ' + testCandidate.Name + ' - ' + testCandidate.Contract_Type__c);
