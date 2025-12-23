// Check ALC records with candidates
List<ALC__c> alcs = [SELECT Id, Name, Stage__c, Candidate__c, Candidate__r.Name, Contract_Type__c 
                     FROM ALC__c 
                     WHERE Candidate__c != null 
                     LIMIT 50];
System.debug('Total ALC with Candidates: ' + alcs.size());
for (ALC__c a : alcs) { 
    System.debug(a.Candidate__r.Name + ' | Stage: ' + a.Stage__c + ' | Type: ' + a.Contract_Type__c); 
}

// Check all unique stages
System.debug('');
System.debug('=== ALL UNIQUE STAGES ===');
for (AggregateResult ar : [SELECT Stage__c, COUNT(Id) cnt FROM ALC__c GROUP BY Stage__c]) {
    System.debug(ar.get('Stage__c') + ': ' + ar.get('cnt'));
}

// Check Contract Types
System.debug('');
System.debug('=== CONTRACT TYPES ===');
for (AggregateResult ar : [SELECT Contract_Type__c, COUNT(Id) cnt FROM ALC__c GROUP BY Contract_Type__c]) {
    System.debug(ar.get('Contract_Type__c') + ': ' + ar.get('cnt'));
}
