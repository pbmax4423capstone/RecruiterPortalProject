// Verify terminated candidates
List<Candidate__c> terminated = [
    SELECT Id, Name, Status__c, Contract_Type__c 
    FROM Candidate__c 
    WHERE Status__c = 'Terminated'
    ORDER BY Name
]; 
System.debug('Total Terminated Candidates: ' + terminated.size()); 
for (Candidate__c c : terminated) { 
    System.debug(c.Name + ' | ' + c.Contract_Type__c + ' | ' + c.Status__c); 
}

// Check ALC records
List<ALC__c> terminatedAlcs = [
    SELECT Id, Candidate_Name__c, Contract_Type__c, Stage__c
    FROM ALC__c
    WHERE Stage__c = 'TERMINATED'
    ORDER BY Candidate_Name__c
];
System.debug('');
System.debug('Total Terminated ALCs: ' + terminatedAlcs.size());
for (ALC__c a : terminatedAlcs) {
    System.debug(a.Candidate_Name__c + ' | ' + a.Contract_Type__c + ' | ' + a.Stage__c);
}
