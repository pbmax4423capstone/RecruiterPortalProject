// Force refresh schema and check fields again
Schema.getGlobalDescribe();  // Force refresh

Schema.SObjectType interviewType = Schema.getGlobalDescribe().get('Interview__c');
if (interviewType == null) {
    System.debug('ERROR: Interview__c does not exist!');
} else {
    Map<String, Schema.SObjectField> fieldsMap = interviewType.getDescribe().fields.getMap();
    
    System.debug('Total fields: ' + fieldsMap.size());
    System.debug('Checking for custom fields:');
    System.debug('  - Candidate__c exists: ' + fieldsMap.containsKey('candidate__c'));
    System.debug('  - Conducted_By__c exists: ' + fieldsMap.containsKey('conducted_by__c'));
    System.debug('  - Interview_Type__c exists: ' + fieldsMap.containsKey('interview_type__c'));
    System.debug('  - Interview_Status__c exists: ' + fieldsMap.containsKey('interview_status__c'));
    System.debug('  - Notes__c exists: ' + fieldsMap.containsKey('notes__c'));
    
    System.debug('\nAll field API names:');
    for (String fieldName : fieldsMap.keySet()) {
        System.debug('  ' + fieldName);
    }
}
