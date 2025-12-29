// Simple test to verify trigger fires
Candidate__c testCand = [SELECT Id FROM Candidate__c LIMIT 1];
User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

System.debug('=== BEFORE INSERT ===');
System.debug('Test User ID: ' + testUser.Id);
System.debug('isSalesManager test: ' + InterviewEventHandler.testSalesManagerIds.contains(testUser.Id));

// Add test user to test sales manager IDs
InterviewEventHandler.testSalesManagerIds.add(testUser.Id);

System.debug('After adding to set: ' + InterviewEventHandler.testSalesManagerIds.contains(testUser.Id));

Interview__c testInterview = new Interview__c(
    Candidate__c = testCand.Id,
    Interview_Type__c = 'AI',
    Conducted_By__c = testUser.Id,
    Interview_Status__c = 'Scheduled'
);

insert testInterview;

System.debug('=== AFTER INSERT ===');
System.debug('Interview created: ' + testInterview.Id);

List<Event> events = [SELECT Id, Subject, OwnerId FROM Event WHERE WhatId = :testInterview.Id];
System.debug('Events found: ' + events.size());
if (!events.isEmpty()) {
    System.debug('Event Owner: ' + events[0].OwnerId);
}
