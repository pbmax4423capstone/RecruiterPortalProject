// Assign RecruiterPortal_Contact_Read permission set to all active users who need Contact visibility
// Criteria: Active users with Recruiter, Sales Manager, Director profiles
// Safe-guards: Skip users who already have the assignment

PermissionSet ps = [
    SELECT Id, Name FROM PermissionSet WHERE Name = 'RecruiterPortal_Contact_Read' LIMIT 1
];

System.debug('Found Permission Set: ' + ps.Name + ' (Id: ' + ps.Id + ')');

List<User> targetUsers = [
    SELECT Id, Name, Username, Profile.Name
    FROM User
    WHERE IsActive = true
    AND (
        Profile.Name LIKE '%Recruiter%'
        OR Profile.Name LIKE '%Sales Manager%'
        OR Profile.Name LIKE '%Director%'
        OR Profile.Name LIKE '%ALC%'
    )
];

System.debug('Found ' + targetUsers.size() + ' target users');

Set<Id> usersWithAssignment = new Set<Id>();
for (PermissionSetAssignment psa : [
    SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id
]) {
    usersWithAssignment.add(psa.AssigneeId);
}

List<PermissionSetAssignment> toInsert = new List<PermissionSetAssignment>();
for (User u : targetUsers) {
    if (!usersWithAssignment.contains(u.Id)) {
        toInsert.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = u.Id));
        System.debug('Assigning to: ' + u.Name + ' (' + u.Username + ')');
    }
}

if (!toInsert.isEmpty()) {
    insert toInsert;
    System.debug('Assigned permission set to ' + toInsert.size() + ' users');
} else {
    System.debug('No new assignments required');
}
