// Check if Termination_Date__c exists on Candidate__c
Map<String, Schema.SObjectField> candidateFields = Schema.SObjectType.Candidate__c.fields.getMap();
System.debug('=== CHECKING FOR TERMINATION DATE FIELDS ===');
for (String fieldName : candidateFields.keySet()) {
    if (fieldName.toLowerCase().contains('termin') || fieldName.toLowerCase().contains('date')) {
        System.debug(fieldName);
    }
}

// Count terminated candidates
Integer terminatedCount = [SELECT COUNT() FROM Candidate__c WHERE Status__c = 'Terminated'];
System.debug('');
System.debug('Total candidates with Status=Terminated: ' + terminatedCount);

// Try querying with Termination_Date__c if it exists
try {
    List<Candidate__c> withTermDate = Database.query('SELECT Id, Name, Termination_Date__c FROM Candidate__c WHERE Status__c = \'Terminated\' LIMIT 5');
    System.debug('');
    System.debug('Sample terminated candidates with Termination_Date__c:');
    for (Candidate__c c : withTermDate) {
        System.debug(c.Name + ' | Termination_Date: ' + c.get('Termination_Date__c'));
    }
} catch (Exception e) {
    System.debug('Error: Termination_Date__c field does not exist - ' + e.getMessage());
}
