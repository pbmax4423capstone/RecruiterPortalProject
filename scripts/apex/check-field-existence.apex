// Check which fields actually exist on Candidate__c

Schema.DescribeSObjectResult candidateDescribe = Candidate__c.SObjectType.getDescribe();
Map<String, Schema.SObjectField> fieldMap = candidateDescribe.fields.getMap();

List<String> fieldsToCheck = new List<String>{
    'Device_Inspection__c',
    'Device_Inspection_Status__c',
    'Highest_Level_Achieved__c',
    'Target_Market__c',
    'Recruiting_Sub_Source__c',
    'Gender__c',
    'Website__c',
    'MDE200__c',
    'MS_10__c',
    'Career_Presentation_ppt__c',
    'Studying_for_Life_Health__c',
    'Registered__c',
    'Insurance_Licensed__c',
    'RELATIONSHIPS__c',
    'Offer_Accepted__c'
};

System.debug('=== Checking Field Existence ===');
for (String fieldName : fieldsToCheck) {
    Boolean exists = fieldMap.containsKey(fieldName.toLowerCase());
    System.debug(fieldName + ': ' + (exists ? 'EXISTS' : 'DOES NOT EXIST'));
}
