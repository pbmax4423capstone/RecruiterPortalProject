// Check current Contract B pipeline and show terminated count
// Show all Contract B candidates (active and terminated this year)

System.debug('=== ACTIVE CONTRACT B CANDIDATES ===');
List<Candidate__c> activeContractB = [
    SELECT Id, Name, Status__c, Contract_Type__c, Start_Date__c, Highest_Level_Achieved__c
    FROM Candidate__c
    WHERE Contract_Type__c = 'Contract B'
    AND (Status__c = 'Contracted- Contract B' OR Highest_Level_Achieved__c = '7-Contracted')
    ORDER BY Name
];

for (Candidate__c c : activeContractB) {
    System.debug('Active: ' + c.Name + ' - Start: ' + c.Start_Date__c);
}
System.debug('Total Active Contract B: ' + activeContractB.size());

// Check for recently completed/terminated Contract B (those we just updated)
System.debug('');
System.debug('=== TERMINATED CONTRACT B (Completed status, no Contract Type) ===');
List<Candidate__c> terminatedContractB = [
    SELECT Id, Name, Status__c, Contract_Type__c, Start_Date__c
    FROM Candidate__c
    WHERE Status__c = 'Completed'
    AND Contract_Type__c = null
    AND Name IN ('Marc Clark', 'Elizabeth Kagele', 'Jesse Israel', 'Kevin Burdalski', 'Alberto Martinez', 'Brett Willis')
];

for (Candidate__c c : terminatedContractB) {
    System.debug('Terminated: ' + c.Name);
}
System.debug('Total Terminated Contract B: ' + terminatedContractB.size());
