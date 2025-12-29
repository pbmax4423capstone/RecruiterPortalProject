// Query SI2 migrated interviews without conductor in Interviewer_s__c
// and show what conductor data exists in the source Candidate fields
List<Interview__c> si2InterviewsNoConductor = [
    SELECT Id, External_Id__c, Interview_Type__c, 
           Date_Time_Scheduled__c, Interviewer_s__c,
           Candidate__r.Name, Candidate__c,
           Candidate__r.SI_2_Conducted_By__c,
           Candidate__r.SI2_Conducted_by__c,
           Candidate__r.SI_2_Interviewer__c
    FROM Interview__c
    WHERE External_Id__c LIKE '%_SI2-Align-2nd'
    AND Interviewer_s__c = null
    ORDER BY Date_Time_Scheduled__c DESC
];

System.debug('=== SI2 MIGRATED INTERVIEWS WITHOUT VALID CONDUCTOR ===');
System.debug('Total SI2 interviews without conductor: ' + si2InterviewsNoConductor.size());

// Count by conductor name (regardless of validity)
Map<String, Integer> conductorCount = new Map<String, Integer>();
Integer blankCount = 0;

for (Interview__c interview : si2InterviewsNoConductor) {
    // Get conductor name from any available field
    String conductor = interview.Candidate__r.SI_2_Conducted_By__c;
    if (String.isBlank(conductor)) {
        conductor = interview.Candidate__r.SI2_Conducted_by__c;
    }
    if (String.isBlank(conductor)) {
        conductor = interview.Candidate__r.SI_2_Interviewer__c;
    }
    
    if (String.isBlank(conductor)) {
        blankCount++;
        conductor = '(BLANK)';
    }
    
    if (!conductorCount.containsKey(conductor)) {
        conductorCount.put(conductor, 0);
    }
    conductorCount.put(conductor, conductorCount.get(conductor) + 1);
}

System.debug('\n--- CONDUCTOR NAMES IN SOURCE DATA ---');
System.debug('Blank/Null conductor: ' + blankCount);
for (String conductor : conductorCount.keySet()) {
    if (conductor != '(BLANK)') {
        System.debug(conductor + ': ' + conductorCount.get(conductor));
    }
}

// Show first 100 interviews with their conductor values
System.debug('\n--- FIRST 100 SI2 INTERVIEWS: CONDUCTOR VALUES ---');
Integer count = 0;
for (Interview__c interview : si2InterviewsNoConductor) {
    if (count >= 100) break;
    
    String dateStr = interview.Date_Time_Scheduled__c != null 
        ? interview.Date_Time_Scheduled__c.format() 
        : 'No Date';
    String candidateName = interview.Candidate__r.Name != null 
        ? interview.Candidate__r.Name 
        : 'Unknown';
    
    // Get conductor from all fields
    String conductor1 = interview.Candidate__r.SI_2_Conducted_By__c;
    String conductor2 = interview.Candidate__r.SI2_Conducted_by__c;
    String conductor3 = interview.Candidate__r.SI_2_Interviewer__c;
    
    String conductorDisplay = '';
    if (!String.isBlank(conductor1)) {
        conductorDisplay = conductor1;
    } else if (!String.isBlank(conductor2)) {
        conductorDisplay = conductor2;
    } else if (!String.isBlank(conductor3)) {
        conductorDisplay = conductor3;
    } else {
        conductorDisplay = '(BLANK)';
    }
    
    System.debug(dateStr + ' | ' + candidateName + ' | Conductor: ' + conductorDisplay);
    count++;
}

System.debug('\n=== SUMMARY ===');
System.debug('Total SI2 interviews without valid conductor: ' + si2InterviewsNoConductor.size());
System.debug('With blank conductor in source: ' + blankCount);
System.debug('With non-blank conductor (not matching picklist): ' + (si2InterviewsNoConductor.size() - blankCount));
