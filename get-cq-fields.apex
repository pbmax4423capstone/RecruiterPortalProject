// Get all fields on Contract_Qualification__c
Map<String, Schema.SObjectField> fields = Schema.SObjectType.Contract_Qualification__c.fields.getMap();
for (String fieldName : fields.keySet()) {
    Schema.DescribeFieldResult f = fields.get(fieldName).getDescribe();
    System.debug(fieldName + ' (' + f.getType() + ') - ' + f.getLabel());
}
