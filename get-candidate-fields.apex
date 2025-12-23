// Get Candidate__c fields
Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Candidate__c.fields.getMap();
for (String fieldName : fieldMap.keySet()) {
    if (fieldName.toLowerCase().contains('status') || fieldName.toLowerCase().contains('termin')) {
        System.debug(fieldName + ' : ' + fieldMap.get(fieldName).getDescribe().getType());
    }
}
