// Delete old events in chunks of 10,000
Integer totalDeleted = 0;
Boolean moreRecords = true;

while (moreRecords) {
    List<Event> eventsToDelete = [
        SELECT Id 
        FROM Event 
        WHERE CreatedDate = TODAY 
        AND Subject LIKE 'Interview%'
        LIMIT 10000
    ];
    
    if (eventsToDelete.isEmpty()) {
        moreRecords = false;
    } else {
        delete eventsToDelete;
        totalDeleted += eventsToDelete.size();
        System.debug('Deleted ' + eventsToDelete.size() + ' events. Total: ' + totalDeleted);
    }
}

System.debug('===================================');
System.debug('DELETION COMPLETE');
System.debug('Total events deleted: ' + totalDeleted);
System.debug('===================================');
