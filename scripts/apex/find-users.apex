// Query to find Brad Sofronia and Van Hess user records
List<User> users = [SELECT Id, Name, Username, Email, IsActive 
                    FROM User 
                    WHERE (Name LIKE '%Brad%' OR Name LIKE '%Sofronia%' OR Name LIKE '%Van%' OR Name LIKE '%Hess%')
                    AND IsActive = true
                    ORDER BY Name];

System.debug('===== USERS FOUND =====');
for (User u : users) {
    System.debug('Name: ' + u.Name + ' | Username: ' + u.Username + ' | Email: ' + u.Email);
}
System.debug('=======================');
