Map<String,Schema.SObjectField> fields = Schema.SObjectType.Candidate__c.fields.getMap();
System.debug('LinkedIn fields on Candidate__c:');
for(String f : fields.keySet()) {
    if(f.containsIgnoreCase('linked')) {
        System.debug('Found: ' + f);
    }
}
