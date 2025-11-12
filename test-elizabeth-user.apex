// Test script to verify getCurrentUserInfo works for Elizabeth Kagele
// Run this as Elizabeth to see what data is returned

Map<String, String> result = RecruiterDashboardController.getCurrentUserInfo();

System.debug('=== getCurrentUserInfo Result ===');
System.debug('ID: ' + result.get('id'));
System.debug('Name: ' + result.get('name'));
System.debug('FirstName: ' + result.get('firstName'));
System.debug('Email: ' + result.get('email'));
System.debug('Profile: ' + result.get('profileName'));
System.debug('Role: ' + result.get('roleName'));
System.debug('UserType: ' + result.get('userType'));
System.debug('=== End Result ===');

// Also check if Elizabeth has any call tasks
List<Task> elizabethTasks = [
    SELECT Id, Subject, ActivityDate, Status, IsClosed
    FROM Task 
    WHERE OwnerId = :UserInfo.getUserId()
    AND IsClosed = false
    LIMIT 10
];

System.debug('=== Elizabeth\'s Call Tasks ===');
System.debug('Number of call tasks: ' + elizabethTasks.size());
for (Task t : elizabethTasks) {
    System.debug('Task: ' + t.Subject + ' - Due: ' + t.ActivityDate + ' - Status: ' + t.Status);
}

// Check if Elizabeth has any candidates in her pipeline
List<Candidate__c> elizabethCandidates = [
    SELECT Id, Name, Status__c, Sales_Manager__c
    FROM Candidate__c
    WHERE Sales_Manager__c = :UserInfo.getName()
    LIMIT 10
];

System.debug('=== Elizabeth\'s Candidates ===');
System.debug('Number of candidates: ' + elizabethCandidates.size());
for (Candidate__c c : elizabethCandidates) {
    System.debug('Candidate: ' + c.Name + ' - Status: ' + c.Status__c);
}
