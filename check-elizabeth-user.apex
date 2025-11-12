// Simple test to check Elizabeth's user record
// Run this while logged in as Elizabeth

System.debug('=== Current User Check ===');
System.debug('User ID: ' + UserInfo.getUserId());
System.debug('User Name: ' + UserInfo.getName());
System.debug('User FirstName: ' + UserInfo.getFirstName());
System.debug('User LastName: ' + UserInfo.getLastName());
System.debug('User Email: ' + UserInfo.getUserEmail());

// Query the user record
User currentUser = [SELECT Id, Name, FirstName, LastName, Email, Profile.Name, UserRole.Name 
                    FROM User 
                    WHERE Id = :UserInfo.getUserId() 
                    LIMIT 1];

System.debug('=== User Record Query ===');
System.debug('User.Id: ' + currentUser.Id);
System.debug('User.Name: ' + currentUser.Name);
System.debug('User.FirstName: ' + currentUser.FirstName);
System.debug('User.LastName: ' + currentUser.LastName);
System.debug('User.Email: ' + currentUser.Email);
System.debug('User.Profile.Name: ' + currentUser.Profile?.Name);
System.debug('User.UserRole.Name: ' + currentUser.UserRole?.Name);

// Test if FirstName is null or empty
if (String.isBlank(currentUser.FirstName)) {
    System.debug('WARNING: FirstName is blank or null!');
} else {
    System.debug('FirstName is populated: ' + currentUser.FirstName);
}
