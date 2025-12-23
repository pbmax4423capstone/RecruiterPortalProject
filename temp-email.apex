Map<String,Schema.SObjectField> fields = Schema.SObjectType.Contact.fields.getMap();
System.debug('Email fields on Contact:');
for(String f : fields.keySet()) {
    if(f.containsIgnoreCase('email')) {
        System.debug('Found: ' + f);
    }
}
