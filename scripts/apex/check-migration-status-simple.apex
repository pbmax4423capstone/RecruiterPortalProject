// Check migration status for job 707Vo00001YgKueIAF
AsyncApexJob job = [
    SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems,
           CreatedDate, CompletedDate, ExtendedStatus
    FROM AsyncApexJob
    WHERE Id = '707Vo00001YgKueIAF'
];

System.debug('=== MIGRATION STATUS ===');
System.debug('Job ID: ' + job.Id);
System.debug('Status: ' + job.Status);
System.debug('Progress: ' + job.JobItemsProcessed + ' / ' + job.TotalJobItems);
System.debug('Errors: ' + job.NumberOfErrors);
if (job.ExtendedStatus != null) {
    System.debug('Extended Status: ' + job.ExtendedStatus);
}
System.debug('Started: ' + job.CreatedDate);
if (job.CompletedDate != null) {
    System.debug('Completed: ' + job.CompletedDate);
}
