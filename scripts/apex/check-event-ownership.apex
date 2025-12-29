// Check distribution of event owners
AggregateResult[] ownerStats = [
    SELECT Owner.Name, COUNT(Id) eventCount
    FROM Event
    WHERE CreatedDate = TODAY AND RecordType.Name = 'Interview'
    GROUP BY Owner.Name
    ORDER BY COUNT(Id) DESC
];

System.debug('=== EVENT OWNERSHIP DISTRIBUTION ===');
for (AggregateResult ar : ownerStats) {
    System.debug(ar.get('Name') + ': ' + ar.get('eventCount') + ' events');
}

// Check for events with specific interviewers who ARE Salesforce users
List<Event> userOwnedEvents = [
    SELECT Id, Subject, Owner.Name, Description
    FROM Event
    WHERE CreatedDate = TODAY 
    AND RecordType.Name = 'Interview'
    AND Owner.Name != 'Pat Baker'
    LIMIT 10
];

System.debug('');
System.debug('=== EVENTS OWNED BY OTHER USERS ===');
if (userOwnedEvents.isEmpty()) {
    System.debug('No events assigned to other users yet');
} else {
    for (Event e : userOwnedEvents) {
        System.debug('Subject: ' + e.Subject);
        System.debug('Owner: ' + e.Owner.Name);
        System.debug('Description: ' + e.Description);
        System.debug('---');
    }
}
