// Assign ContentNote Access permission set to Sales Manager users
PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ContentNote_Access' LIMIT 1];
System.debug('Permission Set ID: ' + ps.Id);

// Get Bradley Sofonia
List<User> bradley = [SELECT Id, Name, Profile.Name FROM User WHERE FirstName = 'Bradley' AND LastName = 'Sofonia' LIMIT 1];
if (!bradley.isEmpty()) {
    System.debug('Found Bradley: ' + bradley[0].Name + ' (' + bradley[0].Profile.Name + ')');
    
    // Check if already assigned
    List<PermissionSetAssignment> existing = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId = :bradley[0].Id];
    if (existing.isEmpty()) {
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = ps.Id;
        psa.AssigneeId = bradley[0].Id;
        insert psa;
        System.debug('✓ Assigned to Bradley');
    } else {
        System.debug('Already assigned to Bradley');
    }
}

// Get Elizabeth Cagle
List<User> elizabeth = [SELECT Id, Name, Profile.Name FROM User WHERE FirstName = 'Elizabeth' AND LastName = 'Cagle' LIMIT 1];
if (!elizabeth.isEmpty()) {
    System.debug('Found Elizabeth: ' + elizabeth[0].Name + ' (' + elizabeth[0].Profile.Name + ')');
    
    // Check if already assigned
    List<PermissionSetAssignment> existing = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId = :elizabeth[0].Id];
    if (existing.isEmpty()) {
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = ps.Id;
        psa.AssigneeId = elizabeth[0].Id;
        insert psa;
        System.debug('✓ Assigned to Elizabeth');
    } else {
        System.debug('Already assigned to Elizabeth');
    }
}

// Get all Sales Manager users
List<User> salesManagers = [SELECT Id, Name FROM User WHERE Profile.Name = 'Sales Manager' AND IsActive = true];
System.debug('Found ' + salesManagers.size() + ' active Sales Manager users');

for (User u : salesManagers) {
    List<PermissionSetAssignment> existing = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId = :u.Id];
    if (existing.isEmpty()) {
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = ps.Id;
        psa.AssigneeId = u.Id;
        insert psa;
        System.debug('✓ Assigned to: ' + u.Name);
    }
}

System.debug('=== DONE ===');
