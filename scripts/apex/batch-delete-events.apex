// Delete old Events in batches
Database.executeBatch(new Database.BatchableContext() {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id 
            FROM Event 
            WHERE CreatedDate = TODAY 
            AND Subject LIKE 'Interview%'
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Event> events) {
        delete events;
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Deletion complete');
    }
}, 10000);
