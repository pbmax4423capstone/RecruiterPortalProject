// Get ALC__c fields
Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.ALC__c.fields.getMap();
for (String fieldName : fieldMap.keySet()) {
    System.debug(fieldName + ' : ' + fieldMap.get(fieldName).getDescribe().getType());
}
