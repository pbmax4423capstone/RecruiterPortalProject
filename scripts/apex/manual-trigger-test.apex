// Manual test to see if trigger fires
User timDenton = [SELECT Id, Name FROM User WHERE Id = '0055f0000081I14AAE'];
List<Candidate__c> cands = [SELECT Id FROM Candidate__c LIMIT 1];

System.debug('Tim Denton: ' + timDenton.Name);
System.debug('Candidate: ' + cands[0].Id);

Interview__c testInt = new Interview__c(
    Interview_Type__c = 'AI',
    Conducted_By__c = timDenton.Id,
    Interview_Status__c = 'Scheduled',
    Notes__c = 'Manual trigger test'
);

System.debug('Inserting Interview...');
insert testInt;
System.debug('Interview inserted: ' + testInt.Id);

// Wait a moment and query
List<Event> events = [SELECT Id, Subject, OwnerId FROM Event WHERE WhatId = :testInt.Id];
System.debug('Events found: ' + events.size());
if (!events.isEmpty()) {
    System.debug('Event created! Owner: ' + events[0].OwnerId + ', Subject: ' + events[0].Subject);
} else {
    System.debug('No events created. Checking if trigger exists...');
}

// Query all active triggers
List<ApexTrigger> triggers = [SELECT Name, Status, TableEnumOrId FROM ApexTrigger WHERE TableEnumOrId = 'Interview__c'];
System.debug('Triggers on Interview__c: ' + triggers.size());
for (ApexTrigger t : triggers) {
    System.debug('Trigger: ' + t.Name + ', Status: ' + t.Status);
}
