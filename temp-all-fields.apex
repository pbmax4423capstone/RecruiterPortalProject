Map<String,Schema.SObjectField> fields = Schema.SObjectType.Candidate__c.fields.getMap();
System.debug('All Candidate__c fields:');
for(String f : fields.keySet()) {
    System.debug(f);
}
