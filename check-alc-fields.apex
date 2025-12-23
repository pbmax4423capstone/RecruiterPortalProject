// Find the ALC object and its relationship to Candidate
// First, find fields on ALC related to sales experience

// Check if there's an ALC__c object
Map<String, Schema.SObjectField> alcFieldMap = Schema.SObjectType.ALC__c.fields.getMap();

System.debug('ALC fields containing "experience" or "sales" or "ladl":');
for (String fieldName : alcFieldMap.keySet()) {
    String lowerName = fieldName.toLowerCase();
    if (lowerName.contains('experience') || lowerName.contains('sales') || lowerName.contains('ladl') || lowerName.contains('year')) {
        Schema.DescribeFieldResult dfr = alcFieldMap.get(fieldName).getDescribe();
        System.debug('  ' + fieldName + ' (' + dfr.getType() + ')');
    }
}

// Also check for relationship to Candidate
System.debug('');
System.debug('ALC fields that are relationships:');
for (String fieldName : alcFieldMap.keySet()) {
    Schema.DescribeFieldResult dfr = alcFieldMap.get(fieldName).getDescribe();
    if (dfr.getType() == Schema.DisplayType.REFERENCE) {
        System.debug('  ' + fieldName + ' -> ' + dfr.getReferenceTo());
    }
}
