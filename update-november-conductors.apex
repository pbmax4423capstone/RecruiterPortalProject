// Update November 2025 Align-2nd interviews with correct conductors
System.debug('=== Updating November Interview Conductors ===');

// Bradley Sofonia User ID
Id bradleyId = '005Vo00000fcekpIAA';

// Get the 6 November interviews with null conductor
List<Interview__c> interviewsToUpdate = [
    SELECT Id, Candidate__r.Name, Candidate__r.SI_1_Conducted_By__c, 
           AI_Conducted_By__c, Conducted_By__c
    FROM Interview__c
    WHERE Interview_Type__c = 'Align-2nd'
    AND Date_Time_Scheduled__c >= 2025-11-01T00:00:00Z
    AND Date_Time_Scheduled__c <= 2025-11-30T23:59:59Z
    AND Conducted_By__c = null
];

System.debug('Found ' + interviewsToUpdate.size() + ' interviews to update');

for (Interview__c interview : interviewsToUpdate) {
    String conductorName = interview.Candidate__r.SI_1_Conducted_By__c;
    System.debug('Processing: ' + interview.Candidate__r.Name + ' - Conductor: ' + conductorName);
    
    if (conductorName == 'Brad Sofonia') {
        interview.Conducted_By__c = bradleyId;
        interview.AI_Conducted_By__c = 'Bradley Sofonia';
        System.debug('  → Updated to Bradley Sofonia (User lookup + picklist)');
    } else if (conductorName == 'Son Le') {
        // Son Le is not a Salesforce user, so only set picklist value
        interview.AI_Conducted_By__c = 'Son Le';
        System.debug('  → Updated to Son Le (picklist only - not a Salesforce user)');
    }
}

// Update the interviews
update interviewsToUpdate;

System.debug('');
System.debug('=== Update Complete ===');
System.debug('Updated ' + interviewsToUpdate.size() + ' interviews');

// Verify the updates
List<Interview__c> verifyInterviews = [
    SELECT Id, Candidate__r.Name, Date_Time_Scheduled__c, 
           Conducted_By__r.Name, AI_Conducted_By__c
    FROM Interview__c
    WHERE Interview_Type__c = 'Align-2nd'
    AND Date_Time_Scheduled__c >= 2025-11-01T00:00:00Z
    AND Date_Time_Scheduled__c <= 2025-11-30T23:59:59Z
    ORDER BY Date_Time_Scheduled__c DESC
];

System.debug('');
System.debug('=== Verification: All November 2025 Align-2nd Interviews ===');
for (Interview__c interview : verifyInterviews) {
    String conductorDisplay = interview.Conducted_By__r != null ? interview.Conducted_By__r.Name : interview.AI_Conducted_By__c;
    if (conductorDisplay == null) {
        conductorDisplay = 'Unknown';
    }
    System.debug(interview.Date_Time_Scheduled__c.format('yyyy-MM-dd') + ' | ' + 
                 interview.Candidate__r.Name + ' | Conductor: ' + conductorDisplay);
}
