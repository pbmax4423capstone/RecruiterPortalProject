// Find the NEW migrated events (created today) for those candidates
List<Event> newEvents = [
    SELECT Id, Subject, ActivityDate, Owner.Name, Description, CreatedDate
    FROM Event
    WHERE CreatedDate = TODAY
    AND RecordType.Name = 'Interview'
    AND (Subject LIKE '%Alonso Maciel%'
         OR Subject LIKE '%Nichole Brown%'
         OR Subject LIKE '%Dante Sanchez%'
         OR Subject LIKE '%Sabrina Moya%'
         OR Subject LIKE '%Michael Madsen%')
    ORDER BY Subject
];

System.debug('=== NEW MIGRATED EVENTS (Created Today) ===');
System.debug('Total found: ' + newEvents.size());
System.debug('');

for (Event e : newEvents) {
    System.debug('Subject: ' + e.Subject);
    System.debug('ActivityDate: ' + e.ActivityDate);
    System.debug('Owner: ' + e.Owner.Name);
    System.debug('Description: ' + e.Description);
    System.debug('---');
}

// Get the candidate source data
List<Candidate__c> candidates = [
    SELECT Id, Last_Name__c, First_Name__c,
           Attraction_Interview_Date_Completed__c,
           SI_1_Date_Completed__c,
           SI_2_Date_Completed__c,
           SI_3_Completed__c,
           Career_Presentation_Date_Completed__c
    FROM Candidate__c
    WHERE (First_Name__c = 'Alonso' AND Last_Name__c = 'Maciel')
    OR (First_Name__c = 'Nichole' AND Last_Name__c = 'Brown')
    OR (First_Name__c = 'Dante' AND Last_Name__c = 'Sanchez')
    OR (First_Name__c = 'Sabrina' AND Last_Name__c = 'Moya')
    OR (First_Name__c = 'Michael' AND Last_Name__c = 'Madsen')
];

System.debug('');
System.debug('=== SOURCE CANDIDATE RECORDS ===');
for (Candidate__c c : candidates) {
    System.debug('Name: ' + c.First_Name__c + ' ' + c.Last_Name__c);
    System.debug('AI Completed: ' + c.Attraction_Interview_Date_Completed__c);
    System.debug('SI1 Completed: ' + c.SI_1_Date_Completed__c);
    System.debug('SI2 Completed: ' + c.SI_2_Date_Completed__c);
    System.debug('SI3 Completed: ' + c.SI_3_Completed__c);
    System.debug('CP Completed: ' + c.Career_Presentation_Date_Completed__c);
    System.debug('---');
}
