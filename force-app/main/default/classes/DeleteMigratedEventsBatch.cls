global class DeleteMigratedEventsBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query all Interview events created today
        return Database.getQueryLocator([
            SELECT Id 
            FROM Event 
            WHERE CreatedDate = TODAY
            AND RecordType.Name = 'Interview'
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Event> scope) {
        // Delete this batch of events
        delete scope;
        System.debug('Deleted ' + scope.size() + ' events in this batch');
    }
    
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];
        System.debug('=== DELETION BATCH COMPLETE ===');
        System.debug('Status: ' + job.Status);
        System.debug('Job Items Processed: ' + job.JobItemsProcessed);
        System.debug('Errors: ' + job.NumberOfErrors);
    }
}
