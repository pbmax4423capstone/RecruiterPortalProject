// Check migration status
AsyncApexJob job = [
    SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems,
           CreatedDate, CompletedDate, ExtendedStatus
    FROM AsyncApexJob
    WHERE Id = '707Vo00001Yj7ZKIAZ'
];

System.debug('=== NEW MIGRATION STATUS ===');
System.debug('Job ID: ' + job.Id);
System.debug('Status: ' + job.Status);
System.debug('Progress: ' + job.JobItemsProcessed + ' / ' + job.TotalJobItems + ' batches');
System.debug('Errors: ' + job.NumberOfErrors);
if (job.ExtendedStatus != null) {
    System.debug('Extended Status: ' + job.ExtendedStatus);
}
System.debug('Started: ' + job.CreatedDate);
if (job.CompletedDate != null) {
    System.debug('Completed: ' + job.CompletedDate);
}
System.debug('');

// Check Interview__c records created
Integer interviewCount = [SELECT COUNT() FROM Interview__c WHERE CreatedDate = TODAY];
System.debug('Interview__c records created today: ' + interviewCount);

// Check Event records created
Integer eventCount = [SELECT COUNT() FROM Event WHERE CreatedDate = TODAY AND RecordType.Name = 'Interview'];
System.debug('Event records created today: ' + eventCount);
