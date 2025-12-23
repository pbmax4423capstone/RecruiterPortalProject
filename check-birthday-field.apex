Map<String,Schema.SObjectField> fields = Schema.SObjectType.Contact.fields.getMap();
System.debug('All Contact fields containing "birth":');
for(String f : fields.keySet()) {
    if(f.containsIgnoreCase('birth')) {
        System.debug('Found field: ' + f);
    }
}

// Also try to directly check
System.debug('Checking if Birthday__c exists:');
System.debug('Has Birthday__c: ' + fields.containsKey('birthday__c'));
System.debug('Has Birthdate: ' + fields.containsKey('birthdate'));
