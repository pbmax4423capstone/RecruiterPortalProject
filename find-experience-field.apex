// Find fields related to sales experience on Candidate object
Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Candidate__c.fields.getMap();

System.debug('Fields containing "experience" or "sales" or "ladl":');
for (String fieldName : fieldMap.keySet()) {
    String lowerName = fieldName.toLowerCase();
    if (lowerName.contains('experience') || lowerName.contains('sales') || lowerName.contains('ladl') || lowerName.contains('year')) {
        Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
        System.debug('  ' + fieldName + ' (' + dfr.getType() + ')');
    }
}
