// Check what fields are available on Event object
Schema.DescribeSObjectResult eventDescribe = Event.getSObjectType().getDescribe();
Map<String, Schema.SObjectField> fieldMap = eventDescribe.fields.getMap();

System.debug('=== CHECKING EVENT CUSTOM FIELDS ===');
System.debug('');

// Look for interviewer-related fields
for (String fieldName : fieldMap.keySet()) {
    if (fieldName.toLowerCase().contains('interview')) {
        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
        System.debug('Field: ' + fieldDescribe.getName());
        System.debug('  Label: ' + fieldDescribe.getLabel());
        System.debug('  Type: ' + fieldDescribe.getType());
        if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
            System.debug('  References: ' + fieldDescribe.getReferenceTo());
        }
        System.debug('');
    }
}
