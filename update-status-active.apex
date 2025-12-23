// Update all candidates to Active/In Process status
List<Candidate__c> candidates = [SELECT Id, Status__c FROM Candidate__c WHERE Status__c = 'New'];

for(Candidate__c c : candidates) {
    c.Status__c = 'Active/In Process';
}

update candidates;
System.debug('Updated ' + candidates.size() + ' candidates to Active/In Process');
