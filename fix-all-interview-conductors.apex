// Fix ALL migrated interviews to use Interviewer_s__c multipicklist instead of Conducted_By__c lookup
System.debug('=== Fixing Interview Conductor Fields ===');
System.debug('Updating ALL Ci-First and Align-2nd interviews to use Interviewer_s__c multipicklist');
System.debug('');

// Get ALL Ci-First and Align-2nd interviews
List<Interview__c> allInterviews = [
    SELECT Id, Interview_Type__c, Candidate__c, Date_Time_Scheduled__c,
           Conducted_By__c, Conducted_By__r.Name, Interviewer_s__c,
           Candidate__r.AI_Conducted_By__c, Candidate__r.SI_1_Conducted_By__c,
           Candidate__r.SI_1_Interview_Conducted_by__c, Candidate__r.SI1_Conducted_by__c
    FROM Interview__c
    WHERE Interview_Type__c IN ('Ci-First', 'Align-2nd')
    ORDER BY Interview_Type__c, Date_Time_Scheduled__c DESC
];

System.debug('Found ' + allInterviews.size() + ' interviews to fix');

Integer ciFirstCount = 0;
Integer alignSecondCount = 0;
Integer fixedCount = 0;

for (Interview__c interview : allInterviews) {
    String conductorName = null;
    
    if (interview.Interview_Type__c == 'Ci-First') {
        ciFirstCount++;
        // Get from Candidate AI_Conducted_By__c
        conductorName = interview.Candidate__r.AI_Conducted_By__c;
    } else if (interview.Interview_Type__c == 'Align-2nd') {
        alignSecondCount++;
        // Get from Candidate SI1 fields (priority order)
        if (String.isNotBlank(interview.Candidate__r.SI_1_Conducted_By__c)) {
            conductorName = interview.Candidate__r.SI_1_Conducted_By__c;
        } else if (String.isNotBlank(interview.Candidate__r.SI_1_Interview_Conducted_by__c)) {
            conductorName = interview.Candidate__r.SI_1_Interview_Conducted_by__c;
        } else if (String.isNotBlank(interview.Candidate__r.SI1_Conducted_by__c)) {
            conductorName = interview.Candidate__r.SI1_Conducted_by__c;
        }
    }
    
    // Map conductor names to correct picklist values - ONLY valid picklist values
    if (String.isNotBlank(conductorName)) {
        String mappedName = null;
        
        // Handle name variations and map to valid picklist values
        if (conductorName.contains('Brad') && conductorName.contains('Sof')) {
            mappedName = 'Bradley Sofonia';
        } else if (conductorName == 'Son Le') {
            mappedName = 'Son Le';
        } else if (conductorName == 'Tim Denton') {
            mappedName = 'Tim Denton';
        } else if (conductorName == 'Rachyll Tenny') {
            mappedName = 'Rachyll Tenny';
        } else if (conductorName == 'Elizabeth Kagele') {
            mappedName = 'Elizabeth Kagele';
        } else if (conductorName == 'Michael Yang') {
            mappedName = 'Michael Yang';
        } else if (conductorName == 'Scott Grove') {
            mappedName = 'Scott Grove';
        } else if (conductorName == 'Van Hess') {
            mappedName = 'Van Hess';
        }
        // If conductor not in picklist, leave as null
        
        // Only set if we have a valid picklist value
        if (String.isNotBlank(mappedName)) {
            interview.Interviewer_s__c = mappedName;
            fixedCount++;
        }
        
        // Always clear Conducted_By__c lookup (we don't use this)
        interview.Conducted_By__c = null;
    }
}

System.debug('');
System.debug('Updating ' + fixedCount + ' interviews...');
update allInterviews;

System.debug('');
System.debug('=== Fix Complete ===');
System.debug('Ci-First interviews: ' + ciFirstCount);
System.debug('Align-2nd interviews: ' + alignSecondCount);
System.debug('Total fixed: ' + fixedCount);
System.debug('');

// Verify the fix
System.debug('=== Verification: November 2025 Interviews ===');
List<Interview__c> novemberInterviews = [
    SELECT Id, Interview_Type__c, Date_Time_Scheduled__c, Interviewer_s__c, Candidate__r.Name
    FROM Interview__c
    WHERE Interview_Type__c IN ('Ci-First', 'Align-2nd')
    AND Date_Time_Scheduled__c >= 2025-11-01T00:00:00Z
    AND Date_Time_Scheduled__c <= 2025-11-30T23:59:59Z
    ORDER BY Interview_Type__c, Date_Time_Scheduled__c DESC
];

Map<String, Map<String, Integer>> typeBreakdown = new Map<String, Map<String, Integer>>();
typeBreakdown.put('Ci-First', new Map<String, Integer>());
typeBreakdown.put('Align-2nd', new Map<String, Integer>());

for (Interview__c interview : novemberInterviews) {
    String conductor = interview.Interviewer_s__c != null ? interview.Interviewer_s__c : 'Unknown';
    Map<String, Integer> breakdown = typeBreakdown.get(interview.Interview_Type__c);
    
    if (!breakdown.containsKey(conductor)) {
        breakdown.put(conductor, 0);
    }
    breakdown.put(conductor, breakdown.get(conductor) + 1);
}

System.debug('');
System.debug('CI-FIRST (November 2025):');
System.debug('Total: ' + novemberInterviews.size());
for (String conductor : typeBreakdown.get('Ci-First').keySet()) {
    System.debug('  ' + conductor + ': ' + typeBreakdown.get('Ci-First').get(conductor));
}

System.debug('');
System.debug('ALIGN-2ND (November 2025):');
for (String conductor : typeBreakdown.get('Align-2nd').keySet()) {
    System.debug('  ' + conductor + ': ' + typeBreakdown.get('Align-2nd').get(conductor));
}
