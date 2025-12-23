// First check what objects and fields are available for opportunities in Recruiting
// And find the Contract B candidates to link opportunities to

System.debug('=== CHECK OPPORTUNITY OBJECT ===');

// Check if standard Opportunity object exists and what fields we can use
Map<String, Schema.SObjectField> oppFields = Schema.SObjectType.Opportunity.fields.getMap();
System.debug('Opportunity fields available: ' + oppFields.size());

// Look for fields that might link to Candidate or Contact
for (String fieldName : oppFields.keySet()) {
    if (fieldName.containsIgnoreCase('candidate') || fieldName.containsIgnoreCase('contact') || 
        fieldName.containsIgnoreCase('agent') || fieldName.containsIgnoreCase('soliciting')) {
        Schema.DescribeFieldResult dfr = oppFields.get(fieldName).getDescribe();
        System.debug(dfr.getName() + ' - ' + dfr.getLabel() + ' (' + dfr.getType() + ')');
    }
}

// Get our Contract B candidates
System.debug('');
System.debug('=== CONTRACT B CANDIDATES ===');
List<Candidate__c> contractBCandidates = [
    SELECT Id, Name, Contact__c, Contact__r.Name
    FROM Candidate__c
    WHERE Status__c = 'Contracted- Contract B'
];

for (Candidate__c c : contractBCandidates) {
    System.debug(c.Name + ' | Contact: ' + c.Contact__c + ' | Contact Name: ' + c.Contact__r?.Name);
}

// Check if there's a custom Opportunity__c object on Candidate
System.debug('');
System.debug('=== CANDIDATE OBJECT RELATIONSHIPS ===');
for (Schema.ChildRelationship cr : Schema.SObjectType.Candidate__c.getChildRelationships()) {
    System.debug(cr.getRelationshipName() + ' -> ' + cr.getChildSObject());
}
