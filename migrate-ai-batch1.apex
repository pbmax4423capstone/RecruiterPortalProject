// Migrate AI interviews to Ci-First (BATCH 1 of 3 - records 1-10000)
System.debug('=== MIGRATING AI → Ci-First (BATCH 1/3) ===');

List<Candidate__c> candidates = [
    SELECT Id, Name, Attraction_Interview_Date_Completed__c, AI_Conducted_By__c
    FROM Candidate__c
    WHERE Attraction_Interview_Date_Completed__c != null
    AND AI_Conducted_By__c != null
    AND AI_Conducted_By__c != ''
    LIMIT 10000
];

System.debug('Total AI candidates in batch 1: ' + candidates.size());

List<Interview__c> interviews = new List<Interview__c>();

for (Candidate__c cand : candidates) {
    String conductor = cand.AI_Conducted_By__c.trim();
    
    // Normalize Brad to Bradley
    conductor = conductor.replace('Brad Sofonia', 'Bradley Sofonia');
    
    Interview__c interview = new Interview__c(
        Candidate__c = cand.Id,
        Interview_Type__c = 'Ci-First',
        Date_Time_Scheduled__c = DateTime.newInstance(cand.Attraction_Interview_Date_Completed__c, Time.newInstance(17, 0, 0, 0)),
        Interviewer_s__c = conductor,
        External_Id__c = cand.Id + '_Ci-First'
    );
    
    interviews.add(interview);
}

System.debug('Interviews to upsert: ' + interviews.size());

Database.UpsertResult[] results = Database.upsert(interviews, Interview__c.External_Id__c, false);

Integer successCount = 0;
Integer failCount = 0;

for (Database.UpsertResult result : results) {
    if (result.isSuccess()) {
        successCount++;
    } else {
        failCount++;
        for (Database.Error err : result.getErrors()) {
            System.debug('ERROR: ' + err.getMessage());
        }
    }
}

System.debug('=== AI BATCH 1 MIGRATION COMPLETE ===');
System.debug('Success: ' + successCount);
System.debug('Failed: ' + failCount);
