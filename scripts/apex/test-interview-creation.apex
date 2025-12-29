// Test creating Interview__c with accessible fields
User timDenton = [SELECT Id, Name FROM User WHERE Id = '0055f0000081I14AAE'];
List<Candidate__c> cands = [SELECT Id FROM Candidate__c LIMIT 1];

System.debug('Tim Denton: ' + timDenton.Name);
System.debug('Candidate: ' + cands[0].Id);

Interview__c testInt = new Interview__c(
    Candidate__c = cands[0].Id,
    Interview_Type__c = 'AI',
    Conducted_By__c = timDenton.Id
);

System.debug('Creating Interview...');
insert testInt;
System.debug('Interview created: ' + testInt.Id);

// Check if trigger fired and Event was created
List<Event> events = [SELECT Id, Subject, OwnerId, WhatId FROM Event WHERE WhatId = :testInt.Id];
System.debug('Events found: ' + events.size());
if (!events.isEmpty()) {
    System.debug('SUCCESS! Event created!');
    System.debug('  Event ID: ' + events[0].Id);
    System.debug('  Subject: ' + events[0].Subject);
    System.debug('  Owner: ' + events[0].OwnerId);
} else {
    System.debug('No Event created - trigger may not have fired');
}

// Check if trigger is deployed
List<ApexTrigger> triggers = [SELECT Name, Status FROM ApexTrigger WHERE TableEnumOrId = 'Interview__c'];
System.debug('Triggers on Interview__c: ' + triggers.size());
for (ApexTrigger t : triggers) {
    System.debug('  Trigger: ' + t.Name + ', Status: ' + t.Status);
}
