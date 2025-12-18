// Check Rachyll Tenny's user and profile access

// Get Rachyll's user info
List<User> rachyll = [
    SELECT Id, Name, Profile.Name, UserRole.Name, IsActive
    FROM User 
    WHERE Name = 'Rachyll Tenny'
    LIMIT 1
];

if (!rachyll.isEmpty()) {
    System.debug('User: ' + rachyll[0].Name);
    System.debug('Profile: ' + rachyll[0].Profile.Name);
    System.debug('Role: ' + rachyll[0].UserRole?.Name);
    System.debug('Active: ' + rachyll[0].IsActive);
    System.debug('User ID: ' + rachyll[0].Id);
    
    // Check if Rachyll can see candidates
    List<Candidate__c> candidates = [
        SELECT Id, Name, Status__c
        FROM Candidate__c
        LIMIT 1
    ];
    
    System.debug('\nCan query candidates: ' + (candidates.size() > 0));
    if (candidates.size() > 0) {
        System.debug('Sample candidate: ' + candidates[0].Name);
    }
} else {
    System.debug('Rachyll Tenny user not found');
}

// Check field accessibility for key fields
Schema.DescribeSObjectResult candidateDescribe = Candidate__c.SObjectType.getDescribe();
Map<String, Schema.SObjectField> fieldMap = candidateDescribe.fields.getMap();

List<String> fieldsToCheck = new List<String>{
    'Name', 'Status__c', 'Email__c', 'Phone__c', 'Contact__c',
    'Position__c', 'Sales_Manager__c', 'RecruiterPicklist__c',
    'Device_Inspection__c', 'Device_Inspection_Status__c',
    'Candidate_Summary__c', 'Recruiting_Source__c'
};

System.debug('\n=== Field Accessibility ===');
for (String fieldName : fieldsToCheck) {
    if (fieldMap.containsKey(fieldName.toLowerCase())) {
        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName.toLowerCase()).getDescribe();
        System.debug(fieldName + ': Accessible=' + fieldDescribe.isAccessible() + ', Updateable=' + fieldDescribe.isUpdateable());
    } else {
        System.debug(fieldName + ': FIELD NOT FOUND');
    }
}
