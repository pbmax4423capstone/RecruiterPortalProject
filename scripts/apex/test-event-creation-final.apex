// Test creating Interview__c and verify Event was created for Sales Manager
User timDenton = [SELECT Id, Name FROM User WHERE Id = '0055f0000081I14AAE'];
List<Candidate__c> cands = [SELECT Id FROM Candidate__c LIMIT 1];

System.debug('=== TEST: Creating Interview for Sales Manager ===');
System.debug('Sales Manager: ' + timDenton.Name);
System.debug('Candidate: ' + cands[0].Id);

// Count existing events for Tim
Integer eventsBefore = [SELECT COUNT() FROM Event WHERE OwnerId = :timDenton.Id AND ActivityDate = TODAY];
System.debug('Events for Tim before: ' + eventsBefore);

Interview__c testInt = new Interview__c(
    Candidate__c = cands[0].Id,
    Interview_Type__c = 'AI',
    Conducted_By__c = timDenton.Id,
    Interview_Status__c = 'Scheduled',
    Notes__c = 'Automation test interview'
);

System.debug('Creating Interview...');
insert testInt;
System.debug('✅ Interview created: ' + testInt.Id);

// Query Events owned by Tim Denton created today
List<Event> events = [
    SELECT Id, Subject, OwnerId, ActivityDate, Description 
    FROM Event 
    WHERE OwnerId = :timDenton.Id 
    AND ActivityDate = TODAY 
    ORDER BY CreatedDate DESC
];

System.debug('\n=== RESULTS ===');
System.debug('Total Events for Tim today: ' + events.size());
System.debug('Events before insert: ' + eventsBefore);
System.debug('New events created: ' + (events.size() - eventsBefore));

if (events.size() > eventsBefore) {
    System.debug('\n✅ SUCCESS! Event was created by trigger');
    Event newEvent = events[0];
    System.debug('  Event ID: ' + newEvent.Id);
    System.debug('  Subject: ' + newEvent.Subject);
    System.debug('  Owner: ' + newEvent.OwnerId);
    System.debug('  Date: ' + newEvent.ActivityDate);
    System.debug('  Description: ' + newEvent.Description);
} else {
    System.debug('\n❌ No new Event was created');
}
