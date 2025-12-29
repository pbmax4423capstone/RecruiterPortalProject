// Verify event dates match Candidate completed dates
List<Event> events = [
    SELECT Id, Subject, ActivityDate, WhatId
    FROM Event
    WHERE CreatedDate = TODAY 
    AND RecordType.Name = 'Interview'
    AND WhatId != null
    LIMIT 5
];

System.debug('=== VERIFYING EVENT DATES MATCH CANDIDATE DATES ===');
System.debug('');

for (Event e : events) {
    // Get the Candidate record
    Candidate__c c = [
        SELECT Id, First_Name__c, Last_Name__c,
               Attraction_Interview_Date_Completed__c,
               SI_1_Date_Completed__c,
               SI_2_Date_Completed__c,
               SI_3_Completed__c,
               Career_Presentation_Date_Completed__c
        FROM Candidate__c
        WHERE Id = :e.WhatId
    ];
    
    System.debug('Event Subject: ' + e.Subject);
    System.debug('Event Date: ' + e.ActivityDate);
    System.debug('Candidate: ' + c.First_Name__c + ' ' + c.Last_Name__c);
    System.debug('AI Completed: ' + c.Attraction_Interview_Date_Completed__c);
    System.debug('SI1 Completed: ' + c.SI_1_Date_Completed__c);
    System.debug('SI2 Completed: ' + c.SI_2_Date_Completed__c);
    System.debug('SI3 Completed: ' + c.SI_3_Completed__c);
    System.debug('CP Completed: ' + c.Career_Presentation_Date_Completed__c);
    
    // Check if the event date matches the appropriate completed date
    Boolean dateMatches = false;
    if (e.Subject.contains('CI (First)') && e.ActivityDate == c.Attraction_Interview_Date_Completed__c) {
        dateMatches = true;
    } else if (e.Subject.contains('Align (2nd)') && e.ActivityDate == c.SI_1_Date_Completed__c) {
        dateMatches = true;
    } else if (e.Subject.contains('Plan (3rd)') && e.ActivityDate == c.SI_2_Date_Completed__c) {
        dateMatches = true;
    } else if (e.Subject.contains('Present (4th)') && e.ActivityDate == c.SI_3_Completed__c) {
        dateMatches = true;
    } else if (e.Subject.contains('Optional (5th)') && e.ActivityDate == c.Career_Presentation_Date_Completed__c) {
        dateMatches = true;
    }
    
    System.debug('✓ Date Matches: ' + dateMatches);
    System.debug('---');
}
