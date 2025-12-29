// Assign Recruiter_Dashboard_Access permission set to Rachyll Tenny
// This will restore her access to RecruiterDashboardController

PermissionSetAssignment psa = new PermissionSetAssignment();
psa.AssigneeId = '0055f00000DqpnpAAB'; // Rachyll Tenny
psa.PermissionSetId = '0PSVo0000006sddOAA'; // Recruiter_Dashboard_Access

try {
    insert psa;
    System.debug('SUCCESS: Assigned Recruiter_Dashboard_Access to Rachyll Tenny');
    System.debug('Permission Set Assignment ID: ' + psa.Id);
} catch (DmlException e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Details: ' + e.getDmlMessage(0));
}
