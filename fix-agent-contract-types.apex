// Fix the new agents - they are NOT Contract B candidates
// They're established agents, so remove Contract Type altogether

// Original 14 Contract B candidates that SHOULD stay in the Contract B pipeline:
Set<String> originalContractBCandidates = new Set<String>{
    'Salina Bouasangouane', 'Alicia Johnson', 'Samuel Fenstermacher', 'Malarie Martin',
    'Alexzander Gonzales', 'Aaron Diaz', 'Jordyn Manrique', 'Gee Na Park',
    'Brandon Arnett', 'Marc Clark', 'Stone Sinek', 'Anthony Balzano',
    'Michelle Mayer', 'Rodrigo Gonzalez'
};

// Get the agents we created that are NOT the original Contract B candidates
// These should have NO contract type - they're just agents for opportunity linking
List<Candidate__c> agentsToFix = [
    SELECT Id, Name, Status__c, Contract_Type__c, Highest_Level_Achieved__c
    FROM Candidate__c
    WHERE Name NOT IN :originalContractBCandidates
    AND (Contract_Type__c = 'Contract B' OR Status__c = 'Completed')
];

System.debug('Found ' + agentsToFix.size() + ' agents to fix');

for (Candidate__c agent : agentsToFix) {
    // These are NOT Contract B candidates - clear the contract type
    agent.Contract_Type__c = null;
    agent.Status__c = 'Completed';  // They're not being recruited
    agent.Highest_Level_Achieved__c = null;
    System.debug('Fixing: ' + agent.Name);
}

if (!agentsToFix.isEmpty()) {
    update agentsToFix;
    System.debug('Fixed ' + agentsToFix.size() + ' agents - removed Contract B designation');
}

// Verify the Contract B pipeline only shows the original 14
System.debug('');
System.debug('=== CONTRACT B PIPELINE (should be 14) ===');
for (Candidate__c c : [
    SELECT Id, Name, Status__c, Contract_Type__c, Start_Date__c
    FROM Candidate__c
    WHERE Contract_Type__c = 'Contract B'
    AND (Status__c = 'Contracted- Contract B' OR Highest_Level_Achieved__c = '7-Contracted')
    ORDER BY Start_Date__c
]) {
    System.debug(c.Name + ' | ' + c.Status__c + ' | Start: ' + c.Start_Date__c);
}
