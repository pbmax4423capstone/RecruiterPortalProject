// Update Contract B candidates based on New Agent FYC report
// "I" = Terminated (set Status to Completed), "A" = Active

// First, find and mark terminated Contract B candidates (those with "I" status)
List<String> terminatedNames = new List<String>{
    'Marc Clark',
    'Elizabeth Kagele',
    'Jesse Israel',
    'Kevin Burdalski',
    'Alberto Martinez',
    'Brett Willis'
};

// Query candidates by name to mark as terminated/completed
List<Candidate__c> terminatedCandidates = [
    SELECT Id, Name, Status__c, Contract_Type__c
    FROM Candidate__c
    WHERE Name IN :terminatedNames
    AND Contract_Type__c = 'Contract B'
];

System.debug('Found ' + terminatedCandidates.size() + ' terminated Contract B candidates');
for (Candidate__c c : terminatedCandidates) {
    c.Status__c = 'Completed';
    c.Contract_Type__c = null; // Remove from Contract B pipeline
    System.debug('Marking as terminated: ' + c.Name);
}

if (!terminatedCandidates.isEmpty()) {
    update terminatedCandidates;
    System.debug('Updated ' + terminatedCandidates.size() + ' candidates as terminated');
}

// Verify active Contract B candidates (those with "A" status)
List<String> activeNames = new List<String>{
    'David Tsymbal',
    'Eduardo Diaz',
    'Mason Cohn',
    'Michael Acosta',
    'Brandon Arnett',
    'Nathan Buchan',
    'Eric Kim',
    'Jordyn Manrique',
    'Michelle Mayer',
    'Gee Na Park',
    'Enrique Santos',
    'Lofton Wirtz',
    'Fei Yu'
};

List<Candidate__c> activeCandidates = [
    SELECT Id, Name, Status__c, Contract_Type__c, Start_Date__c
    FROM Candidate__c
    WHERE Name IN :activeNames
];

System.debug('Found ' + activeCandidates.size() + ' candidates matching active names');
for (Candidate__c c : activeCandidates) {
    System.debug('Candidate: ' + c.Name + ' - Contract Type: ' + c.Contract_Type__c + ' - Status: ' + c.Status__c);
}

// Count current Contract B candidates
Integer contractBCount = [SELECT COUNT() FROM Candidate__c WHERE Contract_Type__c = 'Contract B' AND (Status__c = 'Contracted- Contract B' OR Highest_Level_Achieved__c = '7-Contracted')];
System.debug('=== SUMMARY ===');
System.debug('Terminated Contract B this year: ' + terminatedCandidates.size());
System.debug('Active Contract B remaining: ' + contractBCount);
