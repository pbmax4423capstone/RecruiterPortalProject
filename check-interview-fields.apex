Map<String, Schema.SObjectField> fieldMap = Interview__c.SObjectType.getDescribe().fields.getMap();
for (String fieldName : fieldMap.keySet()) {
    System.debug('Field: ' + fieldName);
}
System.debug('Total fields: ' + fieldMap.size());
