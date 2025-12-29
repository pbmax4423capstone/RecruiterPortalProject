// Verify Elizabeth has the permission set

User elizabeth = [SELECT Id, Name, Username FROM User WHERE Username = 'ekagele@financialguide.com.recruiting' LIMIT 1];
System.debug('User: ' + elizabeth.Name);

List<PermissionSetAssignment> assignments = [
    SELECT PermissionSet.Name 
    FROM PermissionSetAssignment 
    WHERE AssigneeId = :elizabeth.Id 
    AND PermissionSet.Name = 'Recruiter_Portal_User'
];

if (!assignments.isEmpty()) {
    System.debug('✓ SUCCESS: Elizabeth has Recruiter_Portal_User permission set');
    System.debug('She can now access SummaryCardMetricsController');
} else {
    System.debug('✗ ERROR: Elizabeth does not have the permission set');
}
