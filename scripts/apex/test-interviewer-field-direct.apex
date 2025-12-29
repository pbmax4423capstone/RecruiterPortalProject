// Try to create an event with the Sales_Manager_Interviewer__c field directly
// This will tell us if the field exists or not

try {
    // Get a sample Interviewer__c record
    List<Interviewer__c> interviewers = [SELECT Id, Name FROM Interviewer__c LIMIT 1];
    
    if (interviewers.isEmpty()) {
        System.debug('ERROR: No Interviewer__c records found');
        return;
    }
    
    Interviewer__c testInterviewer = interviewers[0];
    System.debug('Using interviewer: ' + testInterviewer.Name + ' (ID: ' + testInterviewer.Id + ')');
    
    // Try to create event with the lookup field
    Event testEvent = new Event(
        Subject = 'Test Event for Field Verification',
        ActivityDate = Date.today(),
        DurationInMinutes = 30
    );
    
    // Try to set the field using put()
    testEvent.put('Sales_Manager_Interviewer__c', testInterviewer.Id);
    
    insert testEvent;
    
    System.debug('SUCCESS: Event created with ID: ' + testEvent.Id);
    
    // Query it back to verify
    Event verifyEvent = [
        SELECT Id, Subject, Sales_Manager_Interviewer__c, Sales_Manager_Interviewer__r.Name 
        FROM Event 
        WHERE Id = :testEvent.Id
    ];
    
    System.debug('Verified Sales_Manager_Interviewer__c: ' + verifyEvent.Sales_Manager_Interviewer__r.Name);
    
    // Clean up
    delete testEvent;
    System.debug('Test event deleted');
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
}
