// Query all candidates with SI3 Completed populated
List<Candidate__c> si3Candidates = [
    SELECT Id, Name, 
           SI_3_Completed__c,
           SI_3_Conducted_By__c,
           SI3_Conducted_by__c,
           SI_3_Interviewer__c
    FROM Candidate__c
    WHERE SI_3_Completed__c != null
];

System.debug('=== MIGRATING SI3 INTERVIEWS TO PLAN-3RD ===');
System.debug('Found ' + si3Candidates.size() + ' SI3 interviews to migrate');

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

for (Candidate__c candidate : si3Candidates) {
    // Get conductor name (check all possible fields)
    String conductorRaw = candidate.SI_3_Conducted_By__c;
    if (String.isBlank(conductorRaw)) {
        conductorRaw = candidate.SI3_Conducted_by__c;
    }
    if (String.isBlank(conductorRaw)) {
        conductorRaw = candidate.SI_3_Interviewer__c;
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
    
    // Create Interview record as Plan-3rd
    Interview__c interview = new Interview__c(
        External_Id__c = candidate.Id + '_Plan-3rd',
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Plan-3rd',
        Date_Time_Scheduled__c = candidate.SI_3_Completed__c,
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
System.debug('Total processed: ' + si3Candidates.size());

// Verify November counts
Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

Integer novemberCount = 0;
Map<String, Integer> novemberConductors = new Map<String, Integer>();

for (Candidate__c c : si3Candidates) {
    if (c.SI_3_Completed__c >= novemberStart && c.SI_3_Completed__c <= novemberEnd) {
        novemberCount++;
        
        String cond = c.SI_3_Conducted_By__c;
        if (String.isBlank(cond)) cond = c.SI3_Conducted_by__c;
        if (String.isBlank(cond)) cond = c.SI_3_Interviewer__c;
        if (String.isBlank(cond)) cond = 'Unknown';
        
        if (!novemberConductors.containsKey(cond)) {
            novemberConductors.put(cond, 0);
        }
        novemberConductors.put(cond, novemberConductors.get(cond) + 1);
    }
}

if (novemberCount > 0) {
    System.debug('\n--- NOVEMBER 2025 SI3/PLAN-3RD ---');
    System.debug('Total: ' + novemberCount);
    for (String cond : novemberConductors.keySet()) {
        System.debug(cond + ': ' + novemberConductors.get(cond));
    }
}
