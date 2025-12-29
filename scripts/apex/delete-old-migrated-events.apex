// Delete all Events created today with old Subject format
List<Event> eventsToDelete = [
    SELECT Id 
    FROM Event 
    WHERE CreatedDate = TODAY 
    AND Subject LIKE 'Interview%'
];

System.debug('Deleting ' + eventsToDelete.size() + ' events...');
delete eventsToDelete;
System.debug('Deletion complete!');
