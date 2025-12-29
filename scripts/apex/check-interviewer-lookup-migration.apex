// Check migration progress and verify Interviewer__c lookup is being set
String jobId = '707Vo00001YgNu7IAF';

AsyncApexJob job = [
    SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
    FROM AsyncApexJob
    WHERE Id = :jobId
];

System.debug('=== MIGRATION STATUS ===');
System.debug('Job ID: ' + job.Id);
System.debug('Status: ' + job.Status);
System.debug('Progress: ' + job.JobItemsProcessed + ' / ' + job.TotalJobItems);
System.debug('Errors: ' + job.NumberOfErrors);

// Check sample events with Sales_Manager_Interviewer__c lookup
List<Event> sampleEvents = [
    SELECT Id, Subject, Owner.Name, Sales_Manager_Interviewer__c, Sales_Manager_Interviewer__r.Name, ActivityDate, Description
    FROM Event
    WHERE CreatedDate = TODAY 
    AND RecordType.Name = 'Interview'
    ORDER BY CreatedDate DESC
    LIMIT 5
];

System.debug('');
System.debug('=== SAMPLE EVENTS WITH SALES MANAGER (INTERVIEWER) LOOKUP ===');
System.debug('Total events created today: ' + [SELECT COUNT() FROM Event WHERE CreatedDate = TODAY AND RecordType.Name = 'Interview']);

for (Event e : sampleEvents) {
    System.debug('');
    System.debug('Subject: ' + e.Subject);
    System.debug('Owner: ' + e.Owner.Name);
    System.debug('Activity Date: ' + e.ActivityDate);
    if (e.Sales_Manager_Interviewer__c != null) {
        System.debug('✓ Sales Manager (Interviewer): ' + e.Sales_Manager_Interviewer__r.Name);
    } else {
        System.debug('✗ NO Sales Manager Lookup Set');
    }
    System.debug('Description: ' + e.Description);
}
