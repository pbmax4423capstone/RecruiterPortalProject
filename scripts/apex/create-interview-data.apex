// Create test interview data for Integrated Sandbox
List<User> activeUsers = [SELECT Id, Name FROM User WHERE IsActive = true AND Profile.Name != 'System Administrator' LIMIT 5];
System.debug('Found ' + activeUsers.size() + ' active users');

if (activeUsers.size() > 0) {
    List<Interview__c> interviews = new List<Interview__c>();
    
    String[] interviewTypes = new String[]{'Attraction', 'SI1', 'SI2', 'SI3', 'Career'};
    String[] statuses = new String[]{'Scheduled', 'Completed', 'Cancelled'};
    String[] outcomes = new String[]{'Pass', 'Fail', 'Pending'};
    
    // Create 20 interviews
    for (Integer i = 0; i < 20; i++) {
        Interview__c interview = new Interview__c();
        interview.Name = interviewTypes[Math.mod(i, 5)] + ' Interview - Test ' + (i + 1);
        interview.Interview_Type__c = interviewTypes[Math.mod(i, 5)];
        interview.Interview_Status__c = statuses[Math.mod(i, 3)];
        interview.Outcome__c = outcomes[Math.mod(i, 3)];
        interview.Conducted_By__c = activeUsers[Math.mod(i, activeUsers.size())].Id;
        interview.Notes__c = 'Test interview created for demo purposes';
        interviews.add(interview);
    }
    
    insert interviews;
    System.debug('Created ' + interviews.size() + ' test interviews');
    
    // Verify data
    Integer count = [SELECT COUNT() FROM Interview__c];
    System.debug('Total interviews in org: ' + count);
} else {
    System.debug('No active users found to assign interviews to');
}