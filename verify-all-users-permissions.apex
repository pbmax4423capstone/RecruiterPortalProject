// Verify all active users have the Recruiter_Portal_User permission set

PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Recruiter_Portal_User' LIMIT 1];
System.debug('Permission Set: ' + ps.Name);

List<User> allActiveUsers = [
    SELECT Id, Name, Username, Profile.UserLicense.Name
    FROM User 
    WHERE IsActive = true 
    AND UserType = 'Standard'
    AND Profile.UserLicense.Name = 'Salesforce'
];
System.debug('Total active Salesforce-licensed users: ' + allActiveUsers.size());

List<PermissionSetAssignment> assignments = [
    SELECT AssigneeId, Assignee.Name
    FROM PermissionSetAssignment 
    WHERE PermissionSetId = :ps.Id
];
System.debug('Users with permission set: ' + assignments.size());

Set<Id> assignedUserIds = new Set<Id>();
for (PermissionSetAssignment psa : assignments) {
    assignedUserIds.add(psa.AssigneeId);
}

Integer missingCount = 0;
for (User u : allActiveUsers) {
    if (!assignedUserIds.contains(u.Id)) {
        System.debug('MISSING: ' + u.Name + ' (' + u.Username + ')');
        missingCount++;
    }
}

if (missingCount == 0) {
    System.debug('✓ SUCCESS: All ' + allActiveUsers.size() + ' active users have the permission set');
} else {
    System.debug('⚠ WARNING: ' + missingCount + ' users are missing the permission set');
}
