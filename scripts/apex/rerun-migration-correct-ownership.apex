// Re-run migration with correct ownership logic
// This will assign events to actual Salesforce users where possible

// Query how many candidates need migration
Integer candidateCount = [
    SELECT COUNT() 
    FROM Candidate__c 
    WHERE (Attraction_Interview_Date_Completed__c != null 
           OR SI_1_Date_Completed__c != null 
           OR SI_2_Date_Completed__c != null 
           OR SI_3_Completed__c != null 
           OR Career_Presentation_Date_Completed__c != null)
];

System.debug('=== RE-RUNNING MIGRATION WITH CORRECT OWNERSHIP ===');
System.debug('Total candidates to process: ' + candidateCount);
System.debug('');

// Launch the batch job
CandidateInterviewMigrationBatch batch = new CandidateInterviewMigrationBatch(false); // false = real run
Id jobId = Database.executeBatch(batch, 200);

System.debug('Batch job started: ' + jobId);
System.debug('This will assign events to:');
System.debug('  1. Actual interviewer if they are a Salesforce user');
System.debug('  2. Current user if interviewer is not a Salesforce user');
System.debug('  3. Interviewer name will be tracked in Description field');
