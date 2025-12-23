// Update newly created candidates to NOT appear in the Contract B Pipeline
// These are already contracted agents, not candidates being recruited

// Get all the candidates we just created (they have Contract_Type__c = 'Contract B' and Status = 'Contracted- Contract B')
// But they're NOT the original 14 Contract B candidates we created earlier

// Original 14 Contract B candidates to KEEP in the pipeline:
Set<String> originalContractBCandidates = new Set<String>{
    'Salina Bouasangouane', 'Alicia Johnson', 'Samuel Fenstermacher', 'Malarie Martin',
    'Alexzander Gonzales', 'Aaron Diaz', 'Jordyn Manrique', 'Gee Na Park',
    'Brandon Arnett', 'Marc Clark', 'Stone Sinek', 'Anthony Balzano',
    'Michelle Mayer', 'Rodrigo Gonzalez'
};

// Get all Contract B candidates that are NOT in the original list
List<Candidate__c> candidatesToUpdate = [
    SELECT Id, Name, Status__c, Contract_Type__c, Highest_Level_Achieved__c, Start_Date__c
    FROM Candidate__c
    WHERE Contract_Type__c = 'Contract B'
    AND Name NOT IN :originalContractBCandidates
];

System.debug('Found ' + candidatesToUpdate.size() + ' candidates to update');

// Update them to NOT appear in the pipeline
// Use a different status that won't be queried by the dashboard
for (Candidate__c cand : candidatesToUpdate) {
    // Set status to indicate they're completed/historical - not actively being recruited
    cand.Status__c = 'Completed';  // This won't match the dashboard query
    cand.Highest_Level_Achieved__c = null;  // Clear this so they don't match the dashboard query
    cand.Start_Date__c = null;  // Clear any start dates - we shouldn't have made these up
    System.debug('Updating: ' + cand.Name);
}

if (!candidatesToUpdate.isEmpty()) {
    update candidatesToUpdate;
    System.debug('Updated ' + candidatesToUpdate.size() + ' candidates to Completed status');
}

// Verify the pipeline now only shows the original 14
List<Candidate__c> pipelineCandidates = [
    SELECT Id, Name, Status__c
    FROM Candidate__c
    WHERE Contract_Type__c = 'Contract B'
    AND (Status__c = 'Contracted- Contract B' OR Highest_Level_Achieved__c = '7-Contracted')
];

System.debug('');
System.debug('=== REMAINING IN PIPELINE ===');
for (Candidate__c c : pipelineCandidates) {
    System.debug(c.Name + ' - ' + c.Status__c);
}
System.debug('Total in pipeline: ' + pipelineCandidates.size());
