/**
 * Script to assign Sales_Manager_Contracting_Dashboard_Access permission set
 * to Sales Manager users
 * 
 * Usage:
 * 1. Open Execute Anonymous Apex in Developer Console or VS Code
 * 2. Copy and paste this script
 * 3. Execute
 * 
 * This will assign the permission set to all users with "Sales Manager" in their profile name.
 * Adjust the WHERE clause if you need different criteria.
 */

// Get the permission set
PermissionSet ps = [
    SELECT Id, Name 
    FROM PermissionSet 
    WHERE Name = 'Sales_Manager_Contracting_Dashboard_Access' 
    LIMIT 1
];

System.debug('Found Permission Set: ' + ps.Name + ' (Id: ' + ps.Id + ')');

// Get all users with "Sales Manager" profile
List<User> salesManagerUsers = [
    SELECT Id, Name, Username, Profile.Name
    FROM User
    WHERE IsActive = true
    AND (
        Profile.Name LIKE '%Sales Manager%'
        OR Profile.Name LIKE '%Director%'
    )
];

System.debug('Found ' + salesManagerUsers.size() + ' users with Sales Manager or Director profiles');

// Get existing assignments to avoid duplicates
Set<Id> usersWithAssignment = new Set<Id>();
for (PermissionSetAssignment psa : [
    SELECT AssigneeId 
    FROM PermissionSetAssignment 
    WHERE PermissionSetId = :ps.Id
]) {
    usersWithAssignment.add(psa.AssigneeId);
}

System.debug('Already assigned to ' + usersWithAssignment.size() + ' users');

// Create new assignments
List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
for (User u : salesManagerUsers) {
    if (!usersWithAssignment.contains(u.Id)) {
        newAssignments.add(new PermissionSetAssignment(
            PermissionSetId = ps.Id,
            AssigneeId = u.Id
        ));
        System.debug('Will assign to: ' + u.Name + ' (' + u.Username + ')');
    } else {
        System.debug('Already assigned: ' + u.Name + ' (' + u.Username + ')');
    }
}

// Insert assignments
if (!newAssignments.isEmpty()) {
    insert newAssignments;
    System.debug('SUCCESS: Assigned permission set to ' + newAssignments.size() + ' users');
} else {
    System.debug('No new assignments needed - all users already have the permission set');
}

// OPTIONAL: To assign to a specific user by username, uncomment and modify:
/*
User specificUser = [SELECT Id FROM User WHERE Username = 'user@domain.com' LIMIT 1];
insert new PermissionSetAssignment(
    PermissionSetId = ps.Id,
    AssigneeId = specificUser.Id
);
System.debug('Assigned to specific user: ' + specificUser.Username);
*/
