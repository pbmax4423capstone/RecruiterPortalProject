// Very simple test - just verify trigger fires
User timDenton = [SELECT Id, Name FROM User WHERE Id = '0055f0000081I14AAE'];
Candidate__c cand = [SELECT Id FROM Candidate__c LIMIT 1];

System.debug('Tim Denton: ' + timDenton);
System.debug('Candidate: ' + cand.Id);
System.debug('Interview RecordType check starting...');

// Check Event RecordType
try {
    Id rtId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName()
        .get('Interview').getRecordTypeId();
    System.debug('Interview RecordType ID: ' + rtId);
} catch (Exception e) {
    System.debug('ERROR getting RecordType: ' + e.getMessage());
}

System.debug('Creating Interview__c...');
Interview__c testInt = new Interview__c(
    Candidate__c = cand.Id,
    Interview_Type__c = 'AI',
    Conducted_By__c = timDenton.Id,
    Interview_Status__c = 'Scheduled',
    Notes__c = 'Test interview'
);

insert testInt;
System.debug('Interview created: ' + testInt.Id);

// Query for events
List<Event> events = [SELECT Id, Subject, OwnerId, WhatId FROM Event WHERE WhatId = :testInt.Id];
System.debug('Events found: ' + events.size());
for (Event e : events) {
    System.debug('Event: ' + e);
}

// Query for all recent events
List<Event> recentEvents = [SELECT Id, Subject, WhatId, CreatedDate FROM Event WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT 5];
System.debug('Recent events today: ' + recentEvents.size());
for (Event re : recentEvents) {
    System.debug('Recent Event: ' + re.Subject + ' - WhatId: ' + re.WhatId);
}
