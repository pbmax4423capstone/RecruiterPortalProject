// Migrate SI1 interviews to Align-2nd
System.debug('=== MIGRATING SI1 → Align-2nd ===');

List<Candidate__c> candidates = [
    SELECT Id, Name, SI_1_Date_Completed__c, SI_1_Conducted_By__c
    FROM Candidate__c
    WHERE SI_1_Date_Completed__c != null
    AND SI_1_Conducted_By__c != null
];

System.debug('Total SI1 candidates found: ' + candidates.size());

List<Interview__c> interviews = new List<Interview__c>();
Integer skipped = 0;

for (Candidate__c cand : candidates) {
    String conductor = cand.SI_1_Conducted_By__c.trim();
    
    // Normalize Brad to Bradley
    conductor = conductor.replace('Brad Sofonia', 'Bradley Sofonia');
    
    Interview__c interview = new Interview__c(
        Candidate__c = cand.Id,
        Interview_Type__c = 'Align-2nd',
        Date_Time_Scheduled__c = DateTime.newInstance(cand.SI_1_Date_Completed__c, Time.newInstance(17, 0, 0, 0)),
        Interviewer_s__c = conductor,
        External_Id__c = cand.Id + '_Align-2nd'
    );
    
    interviews.add(interview);
}

System.debug('Interviews to upsert: ' + interviews.size());
System.debug('Skipped (no conductor): ' + skipped);

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

System.debug('=== SI1 MIGRATION COMPLETE ===');
System.debug('Success: ' + successCount);
System.debug('Failed: ' + failCount);
