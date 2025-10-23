List<User> elizabeths = [SELECT Id, Name, Profile.Name, IsActive FROM User WHERE Name LIKE '%Elizabeth%' OR Name LIKE '%Kagele%'];
System.debug('Found users with Elizabeth/Kagele: ' + elizabeths.size());
for(User u : elizabeths) {
    System.debug('User: ' + u.Name + ' - Profile: ' + u.Profile.Name + ' - Active: ' + u.IsActive);
}

// Also check all Sales Managers
List<User> salesManagers = [SELECT Id, Name, Profile.Name, IsActive FROM User WHERE Profile.Name LIKE '%Sales%Manager%' AND IsActive = true];
System.debug('Found Sales Managers: ' + salesManagers.size());
for(User u : salesManagers) {
    System.debug('Sales Manager: ' + u.Name + ' - Profile: ' + u.Profile.Name + ' - Active: ' + u.IsActive);
}