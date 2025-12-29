// Migrate SI3 interviews to Optional-5th type (ONLY Brad Sofonia and Tim Denton)
System.debug('=== MIGRATING SI3 TO OPTIONAL-5TH (Brad & Tim only) ===');

// Query candidates with SI3 completed
List<Candidate__c> si3Candidates = [
    SELECT Id, Name, SI_3_Completed__c, SI_3_Conducted_By__c
    FROM Candidate__c
    WHERE SI_3_Completed__c != null
    AND (SI_3_Conducted_By__c = 'Brad Sofonia' 
         OR SI_3_Conducted_By__c = 'Tim Denton'
         OR SI_3_Conducted_By__c = 'Bradley Sofonia')
];

System.debug('Found ' + si3Candidates.size() + ' SI3 interviews conducted by Brad or Tim');

// Valid conductor names in picklist
Set<String> validConductors = new Set<String>{
    'Tim Denton', 'Bradley Sofonia', 'Elizabeth Kagele', 
    'Michael Yang', 'Rachyll Tenny', 'Scott Grove', 
    'Son Le', 'Van Hess'
};

// Normalize conductor names
Map<String, String> conductorMap = new Map<String, String>{
    'Brad Sofonia' => 'Bradley Sofonia',
    'Bradley Sofonia' => 'Bradley Sofonia',
    'Tim Denton' => 'Tim Denton'
};

List<Interview__c> interviewsToInsert = new List<Interview__c>();
Integer withConductor = 0;
Integer withoutConductor = 0;

for (Candidate__c candidate : si3Candidates) {
    Interview__c interview = new Interview__c();
    interview.Candidate__c = candidate.Id;
    interview.Interview_Type__c = 'Optional-5th';
    interview.Date_Time_Scheduled__c = DateTime.newInstance(
        candidate.SI_3_Completed__c.year(),
        candidate.SI_3_Completed__c.month(),
        candidate.SI_3_Completed__c.day(),
        17, 0, 0
    );
    
    // Set External_Id for upsert safety
    interview.External_Id__c = candidate.Id + '_Optional-5th';
    
    // Map conductor name
    String conductorName = candidate.SI_3_Conducted_By__c;
    if (conductorMap.containsKey(conductorName)) {
        conductorName = conductorMap.get(conductorName);
    }
    
    // Only set if valid
    if (validConductors.contains(conductorName)) {
        interview.Interviewer_s__c = conductorName;
        withConductor++;
    } else {
        withoutConductor++;
    }
    
    interviewsToInsert.add(interview);
}

System.debug('Interviews with valid conductor: ' + withConductor);
System.debug('Interviews without conductor: ' + withoutConductor);
System.debug('Total to insert: ' + interviewsToInsert.size());

if (interviewsToInsert.size() > 0) {
    try {
        Database.UpsertResult[] results = Database.upsert(interviewsToInsert, Interview__c.External_Id__c, false);
        
        Integer successCount = 0;
        Integer failCount = 0;
        
        for (Database.UpsertResult result : results) {
            if (result.isSuccess()) {
                successCount++;
            } else {
                failCount++;
                for (Database.Error error : result.getErrors()) {
                    System.debug('ERROR: ' + error.getMessage());
                }
            }
        }
        
        System.debug('\n=== MIGRATION RESULTS ===');
        System.debug('Successfully migrated: ' + successCount);
        System.debug('Failed: ' + failCount);
        
        // Show November migrations
        System.debug('\n=== NOVEMBER 2025 SI3 MIGRATIONS ===');
        Integer novCount = 0;
        for (Candidate__c candidate : si3Candidates) {
            if (candidate.SI_3_Completed__c.month() == 11 && 
                candidate.SI_3_Completed__c.year() == 2025) {
                novCount++;
                System.debug(candidate.SI_3_Completed__c.format() + ' | ' + 
                           candidate.SI_3_Conducted_By__c + ' | ' + 
                           candidate.Name);
            }
        }
        System.debug('November count: ' + novCount);
        
    } catch (Exception e) {
        System.debug('EXCEPTION: ' + e.getMessage());
        System.debug('Line: ' + e.getLineNumber());
    }
}
