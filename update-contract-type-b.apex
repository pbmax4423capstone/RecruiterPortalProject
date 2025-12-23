// Update all Active/In Process candidates to Contract Type B
List<Candidate__c> candidatesToUpdate = [
    SELECT Id, Name, Contract_Type__c 
    FROM Candidate__c 
    WHERE Status__c = 'Active/In Process'
    AND Contract_Type__c = null
];

System.debug('Found ' + candidatesToUpdate.size() + ' candidates to update to Contract B');

for (Candidate__c c : candidatesToUpdate) {
    c.Contract_Type__c = 'Contract B';
}

if (!candidatesToUpdate.isEmpty()) {
    update candidatesToUpdate;
    System.debug('Updated ' + candidatesToUpdate.size() + ' candidates to Contract Type B');
}

// Verification
System.debug('');
System.debug('=== VERIFICATION ===');
for (AggregateResult ar : [SELECT Contract_Type__c, COUNT(Id) cnt FROM Candidate__c GROUP BY Contract_Type__c]) {
    System.debug(ar.get('Contract_Type__c') + ': ' + ar.get('cnt'));
}

Integer contractBCount = [SELECT COUNT() FROM Candidate__c WHERE Contract_Type__c = 'Contract B' AND Status__c = 'Active/In Process'];
System.debug('Active Contract B Candidates: ' + contractBCount);
