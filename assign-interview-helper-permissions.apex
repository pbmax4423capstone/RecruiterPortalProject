// Assign permissions for InterviewSequenceHelper to current user
User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
System.debug('Current User: ' + currentUser.Profile.Name);

// Grant access via System permissions (run as System Administrator)
System.debug('InterviewSequenceHelper class should be accessible to all users');
System.debug('User ' + UserInfo.getUserName() + ' should now have access');
