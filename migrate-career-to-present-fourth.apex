// Delete the incorrect SI3 interviews that are showing as Present-4th
System.debug('=== DELETING INCORRECT SI3 AS PRESENT-4TH ===');

// Delete all interviews with External_Id ending in _Plan-3rd (these are SI3, not Career)
List<Interview__c> incorrectPresent4th = [
    SELECT Id, External_Id__c, Candidate__r.Name
    FROM Interview__c
    WHERE External_Id__c LIKE '%_Plan-3rd'
    AND Interview_Type__c = 'Present-4th'
];

System.debug('Found ' + incorrectPresent4th.size() + ' incorrect Present-4th records to delete');

if (incorrectPresent4th.size() > 0) {
    try {
        delete incorrectPresent4th;
        System.debug('Successfully deleted ' + incorrectPresent4th.size() + ' incorrect Present-4th records');
    } catch (Exception e) {
        System.debug('ERROR: ' + e.getMessage());
    }
}

// Now migrate Career Presentation interviews to Present-4th
System.debug('\n=== MIGRATING CAREER PRESENTATIONS TO PRESENT-4TH ===');

List<Candidate__c> careerCandidates = [
    SELECT Id, Name, 
           Career_Presentation_Date_Completed__c,
           CP_Conducted_By__c
    FROM Candidate__c
    WHERE Career_Presentation_Date_Completed__c != null
];

System.debug('Found ' + careerCandidates.size() + ' Career Presentation interviews to migrate');

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

for (Candidate__c candidate : careerCandidates) {
    Interview__c interview = new Interview__c();
    interview.Candidate__c = candidate.Id;
    interview.Interview_Type__c = 'Present-4th';
    interview.Date_Time_Scheduled__c = DateTime.newInstance(
        candidate.Career_Presentation_Date_Completed__c.year(),
        candidate.Career_Presentation_Date_Completed__c.month(),
        candidate.Career_Presentation_Date_Completed__c.day(),
        17, 0, 0
    );
    
    // Set External_Id for upsert safety
    interview.External_Id__c = candidate.Id + '_Present-4th';
    
    // Map conductor name
    String conductorName = candidate.CP_Conducted_By__c;
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
        
        // Report by month and sales manager
        System.debug('\n=== COMPLETE MIGRATION REPORT ===');
        
        Map<String, Map<String, List<String>>> monthManagerCandidates = new Map<String, Map<String, List<String>>>();
        
        for (Candidate__c candidate : careerCandidates) {
            String monthKey = String.valueOf(candidate.Career_Presentation_Date_Completed__c.year()) + '-' + 
                             String.valueOf(candidate.Career_Presentation_Date_Completed__c.month()).leftPad(2, '0');
            String manager = String.isBlank(candidate.CP_Conducted_By__c) ? 'UNASSIGNED' : candidate.CP_Conducted_By__c;
            
            if (!monthManagerCandidates.containsKey(monthKey)) {
                monthManagerCandidates.put(monthKey, new Map<String, List<String>>());
            }
            
            if (!monthManagerCandidates.get(monthKey).containsKey(manager)) {
                monthManagerCandidates.get(monthKey).put(manager, new List<String>());
            }
            
            String candidateInfo = candidate.Career_Presentation_Date_Completed__c.format() + ' | ' + candidate.Name;
            monthManagerCandidates.get(monthKey).get(manager).add(candidateInfo);
        }
        
        // Sort months
        List<String> sortedMonths = new List<String>(monthManagerCandidates.keySet());
        sortedMonths.sort();
        
        for (String month : sortedMonths) {
            System.debug('\n--- ' + month + ' ---');
            Map<String, List<String>> managerCandidates = monthManagerCandidates.get(month);
            
            for (String manager : managerCandidates.keySet()) {
                List<String> candidates = managerCandidates.get(manager);
                System.debug('\n' + manager + ' (' + candidates.size() + ' interviews):');
                for (String candidateInfo : candidates) {
                    System.debug('  ' + candidateInfo);
                }
            }
        }
        
    } catch (Exception e) {
        System.debug('EXCEPTION: ' + e.getMessage());
        System.debug('Line: ' + e.getLineNumber());
    }
}
