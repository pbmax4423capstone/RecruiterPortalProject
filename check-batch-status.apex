// Check latest batch job status
AsyncApexJob job = [
    SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedDate
    FROM AsyncApexJob 
    WHERE ApexClass.Name = 'CandidateInterviewMigrationBatch2'
    ORDER BY CreatedDate DESC
    LIMIT 1
];

System.debug('Batch Status: ' + job.Status);
System.debug('Items Processed: ' + job.JobItemsProcessed + ' / ' + job.TotalJobItems);
System.debug('Errors: ' + job.NumberOfErrors);
System.debug('Started: ' + job.CreatedDate);

// Check total Interview__c records created
Integer totalInterviews = [SELECT COUNT() FROM Interview__c];
System.debug('Total Interview__c records: ' + totalInterviews);
