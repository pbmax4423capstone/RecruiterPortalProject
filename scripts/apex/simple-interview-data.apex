// Simple test data creation for Integrated Sandbox
List<User> activeUsers = [SELECT Id, Name FROM User WHERE IsActive = true LIMIT 3];
System.debug('Found ' + activeUsers.size() + ' active users');

if (activeUsers.size() > 0) {
    List<Interview__c> interviews = new List<Interview__c>();
    
    // Create basic interviews
    for (Integer i = 0; i < 10; i++) {
        Interview__c interview = new Interview__c();
        interview.Name = 'Test Interview ' + (i + 1);
        interview.Conducted_By__c = activeUsers[Math.mod(i, activeUsers.size())].Id;
        interviews.add(interview);
    }
    
    try {
        insert interviews;
        System.debug('Successfully created ' + interviews.size() + ' test interviews');
    } catch (Exception e) {
        System.debug('Error creating interviews: ' + e.getMessage());
    }
    
    // Verify count
    Integer count = [SELECT COUNT() FROM Interview__c];
    System.debug('Total interviews in org: ' + count);
} else {
    System.debug('No active users found');
}