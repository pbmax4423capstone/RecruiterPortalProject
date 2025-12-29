// Delete old migrated events created today
// These are the events from the previous migration runs
Date today = Date.today();

// Get count first
Integer totalEvents = [
    SELECT COUNT() 
    FROM Event 
    WHERE CreatedDate = TODAY 
    AND RecordType.Name = 'Interview'
];
System.debug('Total Interview events created today: ' + totalEvents);

// Delete in chunks of 9,000 (safe under 10,000 DML limit)
Integer batchSize = 9000;
Integer deleted = 0;

while (true) {
    List<Event> eventsToDelete = [
        SELECT Id 
        FROM Event 
        WHERE CreatedDate = TODAY
        AND RecordType.Name = 'Interview'
        LIMIT :batchSize
    ];
    
    if (eventsToDelete.isEmpty()) {
        break;
    }
    
    delete eventsToDelete;
    deleted += eventsToDelete.size();
    System.debug('Deleted ' + deleted + ' of ' + totalEvents + ' events');
    
    if (eventsToDelete.size() < batchSize) {
        break; // Last batch
    }
}

System.debug('Deletion complete. Total deleted: ' + deleted);
