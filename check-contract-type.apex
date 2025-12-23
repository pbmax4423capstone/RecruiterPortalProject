// Check Contract_Type__c on Candidates
System.debug('=== CANDIDATE CONTRACT TYPES ===');
for (AggregateResult ar : [SELECT Contract_Type__c, COUNT(Id) cnt FROM Candidate__c GROUP BY Contract_Type__c]) {
    System.debug(ar.get('Contract_Type__c') + ': ' + ar.get('cnt'));
}

System.debug('');
System.debug('=== CANDIDATES WITH Contract B STATUS ===');
for (Candidate__c c : [SELECT Name, Status__c, Contract_Type__c FROM Candidate__c WHERE Contract_Type__c = 'Contract B' LIMIT 20]) {
    System.debug(c.Name + ' | Status: ' + c.Status__c);
}

// Check field existence
System.debug('');
System.debug('=== CHECK FIELD EXISTS ===');
try {
    List<Candidate__c> test = [SELECT Id, Contract_Type__c FROM Candidate__c LIMIT 1];
    System.debug('Contract_Type__c field exists on Candidate__c');
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}

// Check all Candidate statuses
System.debug('');
System.debug('=== CANDIDATE STATUSES ===');
for (AggregateResult ar : [SELECT Status__c, COUNT(Id) cnt FROM Candidate__c GROUP BY Status__c]) {
    System.debug(ar.get('Status__c') + ': ' + ar.get('cnt'));
}
