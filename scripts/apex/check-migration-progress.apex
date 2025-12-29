// Monitor migration batch progress
String jobId = '707Vo00001Yf927IAB';

AsyncApexJob job = [
    SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,
           CreatedDate, CompletedDate
    FROM AsyncApexJob
    WHERE Id = :jobId
];

System.debug('=== MIGRATION BATCH STATUS ===');
System.debug('Job ID: ' + job.Id);
System.debug('Status: ' + job.Status);
System.debug('Progress: ' + job.JobItemsProcessed + ' / ' + job.TotalJobItems);
System.debug('Errors: ' + job.NumberOfErrors);
System.debug('Created: ' + job.CreatedDate);
if (job.CompletedDate != null) {
    System.debug('Completed: ' + job.CompletedDate);
}

// Also check events created
Integer eventCount = [SELECT COUNT() FROM Event WHERE CreatedDate = TODAY AND RecordType.Name = 'Interview'];
System.debug('');
System.debug('Interview events created today: ' + eventCount);

// Sample event to verify ownership
List<Event> sampleEvents = [
    SELECT Id, Subject, OwnerId, Owner.Name, Description
    FROM Event
    WHERE CreatedDate = TODAY AND RecordType.Name = 'Interview'
    ORDER BY CreatedDate DESC
    LIMIT 5
];

System.debug('');
System.debug('=== SAMPLE EVENTS ===');
for (Event e : sampleEvents) {
    System.debug('Subject: ' + e.Subject);
    System.debug('Owner: ' + e.Owner.Name);
    System.debug('Description: ' + e.Description);
    System.debug('---');
}
