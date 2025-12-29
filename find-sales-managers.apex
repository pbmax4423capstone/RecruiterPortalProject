// Find sales managers
List<User> salesManagers = [
    SELECT Id, Name, Username 
    FROM User 
    WHERE Profile.Name = 'Sales Manager' 
    AND IsActive = true
    LIMIT 10
];

System.debug('=== SALES MANAGERS ===');
for (User u : salesManagers) {
    System.debug(u.Name + ' (' + u.Username + ')');
}
