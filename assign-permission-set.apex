// Check if Tim Denton has the Recruiter Portal User permission set
User tim = [SELECT Id, Name, Username FROM User WHERE Username = 'tdenton@financialguide.com.recruiting' LIMIT 1];
System.debug('Found user: ' + tim.Name);

PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Recruiter_Portal_User' LIMIT 1];
System.debug('Found permission set: ' + ps.Name);

// Check if already assigned
List<PermissionSetAssignment> existing = [
    SELECT Id 
    FROM PermissionSetAssignment 
    WHERE PermissionSetId = :ps.Id 
    AND AssigneeId = :tim.Id
];

if (existing.isEmpty()) {
    // Assign the permission set
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.PermissionSetId = ps.Id;
    psa.AssigneeId = tim.Id;
    insert psa;
    System.debug('SUCCESS: Assigned Recruiter Portal User permission set to Tim Denton');
} else {
    System.debug('ALREADY ASSIGNED: Tim Denton already has the permission set');
}
