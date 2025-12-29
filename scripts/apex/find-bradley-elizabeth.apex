// Find Bradley and Elizabeth users
List<User> users = [
    SELECT Id, Name, FirstName, LastName, IsActive, Profile.Name
    FROM User
    WHERE (FirstName LIKE 'Bradley%' OR FirstName LIKE 'Elizabeth%' OR Name LIKE '%Bradley%' OR Name LIKE '%Elizabeth%')
    AND IsActive = true
];

System.debug('=== BRADLEY AND ELIZABETH USERS ===');
for (User u : users) {
    System.debug('Name: ' + u.Name);
    System.debug('  First: ' + u.FirstName + ', Last: ' + u.LastName);
    System.debug('  ID: ' + u.Id);
    System.debug('  Profile: ' + u.Profile.Name);
    System.debug('');
}

// Also check all active SF users to see the full list
System.debug('=== ALL ACTIVE SALESFORCE USERS (for reference) ===');
List<User> allUsers = [
    SELECT Id, Name, FirstName, LastName 
    FROM User 
    WHERE IsActive = true
    ORDER BY Name
];
for (User u : allUsers) {
    System.debug(u.Name + ' (ID: ' + u.Id + ')');
}
