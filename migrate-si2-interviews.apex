// Query all candidates with SI2 Date Completed populated
List<Candidate__c> si2Candidates = [
    SELECT Id, Name, 
           SI_2_Date_Completed__c,
           SI_2_Conducted_By__c,
           SI2_Conducted_by__c,
           SI_2_Interviewer__c
    FROM Candidate__c
    WHERE SI_2_Date_Completed__c != null
];

System.debug('=== MIGRATING SI2 INTERVIEWS ===');
System.debug('Found ' + si2Candidates.size() + ' SI2 interviews to migrate');

// Map to valid picklist values for Interviewer_s__c
Map<String, String> conductorMapping = new Map<String, String>{
    'Tim Denton' => 'Tim Denton',
    'Bradley Sofonia' => 'Bradley Sofonia',
    'Brad Sofonia' => 'Bradley Sofonia',
    'Elizabeth Kagele' => 'Elizabeth Kagele',
    'Michael Yang' => 'Michael Yang',
    'Rachyll Tenny' => 'Rachyll Tenny',
    'Scott Grove' => 'Scott Grove',
    'Son Le' => 'Son Le',
    'Van Hess' => 'Van Hess'
};

List<Interview__c> interviewsToUpsert = new List<Interview__c>();
Integer withConductor = 0;
Integer withoutConductor = 0;

for (Candidate__c candidate : si2Candidates) {
    // Get conductor name (check all possible fields)
    String conductorRaw = candidate.SI_2_Conducted_By__c;
    if (String.isBlank(conductorRaw)) {
        conductorRaw = candidate.SI2_Conducted_by__c;
    }
    if (String.isBlank(conductorRaw)) {
        conductorRaw = candidate.SI_2_Interviewer__c;
    }
    
    // Map to valid picklist value
    String conductor = null;
    if (!String.isBlank(conductorRaw)) {
        conductor = conductorMapping.get(conductorRaw.trim());
        if (conductor != null) {
            withConductor++;
        } else {
            // Check if raw name contains part of valid name
            for (String key : conductorMapping.keySet()) {
                if (conductorRaw.containsIgnoreCase(key) || key.containsIgnoreCase(conductorRaw)) {
                    conductor = conductorMapping.get(key);
                    withConductor++;
                    break;
                }
            }
        }
    }
    
    if (conductor == null) {
        withoutConductor++;
    }
    
    // Create Interview record
    Interview__c interview = new Interview__c(
        External_Id__c = candidate.Id + '_SI2-Align-2nd',
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Align-2nd',
        Date_Time_Scheduled__c = candidate.SI_2_Date_Completed__c,
        Interview_Status__c = 'Completed',
        Interviewer_s__c = conductor
    );
    
    interviewsToUpsert.add(interview);
}

System.debug('Interviews with valid conductor: ' + withConductor);
System.debug('Interviews without conductor: ' + withoutConductor);
System.debug('Upserting ' + interviewsToUpsert.size() + ' interviews...');

// Upsert using External_Id__c
Database.UpsertResult[] results = Database.upsert(interviewsToUpsert, Interview__c.External_Id__c, false);

Integer successCount = 0;
Integer failCount = 0;

for (Database.UpsertResult result : results) {
    if (result.isSuccess()) {
        successCount++;
    } else {
        failCount++;
        for (Database.Error error : result.getErrors()) {
            System.debug('Error: ' + error.getMessage());
        }
    }
}

System.debug('\n=== MIGRATION RESULTS ===');
System.debug('Successfully migrated: ' + successCount);
System.debug('Failed: ' + failCount);
System.debug('Total processed: ' + si2Candidates.size());
