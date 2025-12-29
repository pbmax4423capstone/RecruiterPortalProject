// Migration script: SI1 interviews from Candidate to Interview object as 'Align-2nd'
// Uses SI_1_Date_Completed__c for Date_Time_Scheduled__c
// Checks SI_1_Conducted_By__c, SI_1_Interview_Conducted_by__c, SI1_Conducted_by__c for conductor

System.debug('=== Starting SI1 to Align-2nd Migration ===');

// Query all candidates with SI1 completed
List<Candidate__c> candidates = [
    SELECT Id, Name, 
           SI_1_Date_Completed__c,
           SI_1_Conducted_By__c,
           SI_1_Interview_Conducted_by__c,
           SI1_Conducted_by__c
    FROM Candidate__c
    WHERE SI_1_Date_Completed__c != null
    ORDER BY SI_1_Date_Completed__c ASC
];

System.debug('Found ' + candidates.size() + ' candidates with SI1 data');

// Get all Users for conductor mapping
Map<String, User> usersByName = new Map<String, User>();
for (User u : [SELECT Id, Name FROM User WHERE IsActive = true]) {
    usersByName.put(u.Name.toLowerCase(), u);
}

// Prepare Interview records for upsert
List<Interview__c> interviewsToUpsert = new List<Interview__c>();
Integer successCount = 0;
Integer missingConductorCount = 0;

for (Candidate__c cand : candidates) {
    // Determine conductor name from three possible fields
    String conductorName = null;
    if (String.isNotBlank(cand.SI_1_Conducted_By__c)) {
        conductorName = cand.SI_1_Conducted_By__c;
    } else if (String.isNotBlank(cand.SI_1_Interview_Conducted_by__c)) {
        conductorName = cand.SI_1_Interview_Conducted_by__c;
    } else if (String.isNotBlank(cand.SI1_Conducted_by__c)) {
        conductorName = cand.SI1_Conducted_by__c;
    }
    
    Interview__c interview = new Interview__c();
    interview.External_Id__c = cand.Id + '_Align-2nd';
    interview.Interview_Type__c = 'Align-2nd';
    interview.Candidate__c = cand.Id;
    interview.Date_Time_Scheduled__c = cand.SI_1_Date_Completed__c;
    
    // Map conductor name to User
    if (conductorName != null) {
        User conductor = usersByName.get(conductorName.toLowerCase());
        if (conductor != null) {
            interview.Conducted_By__c = conductor.Id;
            successCount++;
        } else {
            System.debug('WARNING: Conductor not found: ' + conductorName + ' for Candidate: ' + cand.Name);
            missingConductorCount++;
        }
    } else {
        missingConductorCount++;
    }
    
    interviewsToUpsert.add(interview);
}

System.debug('Prepared ' + interviewsToUpsert.size() + ' interviews for upsert');
System.debug('With conductor: ' + successCount);
System.debug('Missing conductor: ' + missingConductorCount);

// Upsert interviews using External_Id__c
try {
    Database.UpsertResult[] results = Database.upsert(interviewsToUpsert, Interview__c.External_Id__c, false);
    
    Integer upsertSuccess = 0;
    Integer upsertFailed = 0;
    
    for (Database.UpsertResult result : results) {
        if (result.isSuccess()) {
            upsertSuccess++;
        } else {
            upsertFailed++;
            for (Database.Error err : result.getErrors()) {
                System.debug('ERROR: ' + err.getMessage());
            }
        }
    }
    
    System.debug('');
    System.debug('=== MIGRATION COMPLETE ===');
    System.debug('Total SI1 records processed: ' + candidates.size());
    System.debug('Successfully upserted: ' + upsertSuccess);
    System.debug('Failed: ' + upsertFailed);
    System.debug('');
    
    // Query to verify
    List<AggregateResult> verifyResults = [
        SELECT COUNT(Id) cnt
        FROM Interview__c
        WHERE Interview_Type__c = 'Align-2nd'
    ];
    
    Integer alignSecondCount = (Integer)verifyResults[0].get('cnt');
    System.debug('Total Align-2nd interviews in system: ' + alignSecondCount);
    
} catch (Exception e) {
    System.debug('EXCEPTION: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
