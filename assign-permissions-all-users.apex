// Assign Recruiter Portal User permission set to ALL active users

// Get the permission set
PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Recruiter_Portal_User' LIMIT 1];
System.debug('Found permission set: ' + ps.Name + ' (ID: ' + ps.Id + ')');

// Get all active standard users with Salesforce license
List<User> activeUsers = [
    SELECT Id, Name, Username, Profile.Name 
    FROM User 
    WHERE IsActive = true 
    AND UserType = 'Standard'
    AND Profile.UserLicense.Name = 'Salesforce'
    ORDER BY Name
];
System.debug('Found ' + activeUsers.size() + ' active Salesforce-licensed users');

// Get existing assignments
Set<Id> alreadyAssignedUserIds = new Set<Id>();
List<PermissionSetAssignment> existingAssignments = [
    SELECT AssigneeId 
    FROM PermissionSetAssignment 
    WHERE PermissionSetId = :ps.Id
];
for (PermissionSetAssignment psa : existingAssignments) {
    alreadyAssignedUserIds.add(psa.AssigneeId);
}
System.debug('Already assigned to ' + alreadyAssignedUserIds.size() + ' users');

// Create new assignments for users who don't have it
List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
Integer assignedCount = 0;
Integer skippedCount = 0;

for (User u : activeUsers) {
    if (alreadyAssignedUserIds.contains(u.Id)) {
        System.debug('SKIP: ' + u.Name + ' already has permission');
        skippedCount++;
    } else {
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = ps.Id;
        psa.AssigneeId = u.Id;
        newAssignments.add(psa);
        System.debug('ASSIGN: ' + u.Name + ' (' + u.Profile.Name + ')');
        assignedCount++;
    }
}

if (!newAssignments.isEmpty()) {
    insert newAssignments;
    System.debug('SUCCESS: Assigned permission set to ' + assignedCount + ' new users');
} else {
    System.debug('No new assignments needed - all users already have the permission set');
}

System.debug('=== SUMMARY ===');
System.debug('Total active users: ' + activeUsers.size());
System.debug('Already assigned: ' + skippedCount);
System.debug('Newly assigned: ' + assignedCount);
System.debug('Total with permission: ' + (skippedCount + assignedCount));
