// First check Interview object fields
Schema.SObjectType interviewType = Schema.getGlobalDescribe().get('Interview__c');
Schema.DescribeSObjectResult interviewDescribe = interviewType.getDescribe();
Map<String, Schema.SObjectField> fieldsMap = interviewDescribe.fields.getMap();

System.debug('Interview__c fields:');
for(String fieldName : fieldsMap.keySet()) {
    if(fieldName.contains('conduct') || fieldName.contains('by') || fieldName.contains('user')) {
        Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
        System.debug('Field: ' + fieldName + ' - Type: ' + fieldDescribe.getType() + ' - Label: ' + fieldDescribe.getLabel());
    }
}

// Also check all fields to see what's available
System.debug('All Interview__c fields:');
for(String fieldName : fieldsMap.keySet()) {
    Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
    System.debug('Field: ' + fieldName + ' - Label: ' + fieldDescribe.getLabel());
}