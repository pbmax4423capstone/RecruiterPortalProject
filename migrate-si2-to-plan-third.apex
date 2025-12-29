// Migrate SI2 interviews to Plan-3rd
System.debug('=== MIGRATING SI2 → Plan-3rd ===');

List<Candidate__c> candidates = [
    SELECT Id, Name, SI_2_Date_Completed__c, SI_2_Conducted_By__c
    FROM Candidate__c
    WHERE SI_2_Date_Completed__c != null
    AND SI_2_Conducted_By__c != null
    AND SI_2_Conducted_By__c != ''
];

System.debug('Total SI2 candidates found: ' + candidates.size());

List<Interview__c> interviews = new List<Interview__c>();

for (Candidate__c cand : candidates) {
    String conductor = cand.SI_2_Conducted_By__c.trim();
    
    // Normalize Brad to Bradley
    conductor = conductor.replace('Brad Sofonia', 'Bradley Sofonia');
    
    Interview__c interview = new Interview__c(
        Candidate__c = cand.Id,
        Interview_Type__c = 'Plan-3rd',
        Date_Time_Scheduled__c = DateTime.newInstance(cand.SI_2_Date_Completed__c, Time.newInstance(17, 0, 0, 0)),
        Interviewer_s__c = conductor,
        External_Id__c = cand.Id + '_Plan-3rd'
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

System.debug('=== SI2 MIGRATION COMPLETE ===');
System.debug('Success: ' + successCount);
System.debug('Failed: ' + failCount);
