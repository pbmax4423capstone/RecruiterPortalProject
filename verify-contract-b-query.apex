// Verify the query will return the correct results
List<Candidate__c> contractBCandidates = [
    SELECT Id, Name, Contract_Type__c,
           Start_Date__c,
           Sales_Manager__c, Status__c, Highest_Level_Achieved__c
    FROM Candidate__c
    WHERE Contract_Type__c = 'Contract B'
    AND (Status__c = 'Contracted- Contract B' OR Highest_Level_Achieved__c = '7-Contracted')
    ORDER BY Start_Date__c ASC NULLS LAST
];

System.debug('=== CONTRACT B CONTRACTED CANDIDATES (Component Query) ===');
System.debug('Total candidates found: ' + contractBCandidates.size());

for (Candidate__c c : contractBCandidates) {
    System.debug(c.Name + ' | Status: ' + c.Status__c + ' | HLA: ' + c.Highest_Level_Achieved__c + ' | Start: ' + c.Start_Date__c);
}
