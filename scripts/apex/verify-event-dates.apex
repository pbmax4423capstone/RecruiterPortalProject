// Check if events are using correct historical dates
List<Event> sampleEvents = [
    SELECT Id, Subject, ActivityDate, Owner.Name, WhatId
    FROM Event
    WHERE Subject LIKE '%Alonso Maciel%'
    OR Subject LIKE '%Nichole Brown%'
    OR Subject LIKE '%Dante Sanchez%'
    OR Subject LIKE '%Sabrina Moya%'
    OR Subject LIKE '%Michael Madsen%'
    LIMIT 5
];

System.debug('=== CHECKING EVENT DATES ===');
for (Event e : sampleEvents) {
    System.debug('Subject: ' + e.Subject);
    System.debug('ActivityDate: ' + e.ActivityDate);
    System.debug('Owner: ' + e.Owner.Name);
    System.debug('---');
}

// Now check the source Candidate records to see what dates SHOULD have been used
List<Candidate__c> candidates = [
    SELECT Id, Last_Name__c, First_Name__c,
           Attraction_Interview_Date_Completed__c,
           SI_1_Date_Completed__c,
           SI_2_Date_Completed__c,
           SI_3_Completed__c,
           Career_Presentation_Date_Completed__c
    FROM Candidate__c
    WHERE Last_Name__c IN ('Maciel', 'Brown', 'Sanchez', 'Moya', 'Madsen')
    LIMIT 5
];

System.debug('');
System.debug('=== SOURCE CANDIDATE DATES ===');
for (Candidate__c c : candidates) {
    System.debug('Name: ' + c.First_Name__c + ' ' + c.Last_Name__c);
    System.debug('AI Completed: ' + c.Attraction_Interview_Date_Completed__c);
    System.debug('SI1 Completed: ' + c.SI_1_Date_Completed__c);
    System.debug('SI2 Completed: ' + c.SI_2_Date_Completed__c);
    System.debug('SI3 Completed: ' + c.SI_3_Completed__c);
    System.debug('CP Completed: ' + c.Career_Presentation_Date_Completed__c);
    System.debug('---');
}
