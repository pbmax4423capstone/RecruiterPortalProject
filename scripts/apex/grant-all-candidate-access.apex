// Grant Recruiting Director profile access to all Candidate fields via Permission Set

// Create a permission set
PermissionSet ps = new PermissionSet();
ps.Name = 'Candidate_Full_Access';
ps.Label = 'Candidate Full Field Access';
insert ps;

System.debug('Created Permission Set: ' + ps.Id);

// Now assign this permission set to Rachyll and Brooke
List<User> users = [SELECT Id, Name FROM User WHERE Name IN ('Rachyll Tenny', 'Brooke Porter')];

List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
for (User u : users) {
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.PermissionSetId = ps.Id;
    psa.AssigneeId = u.Id;
    assignments.add(psa);
    System.debug('Assigning to: ' + u.Name);
}

insert assignments;
System.debug('Permission set assigned to ' + assignments.size() + ' users');
