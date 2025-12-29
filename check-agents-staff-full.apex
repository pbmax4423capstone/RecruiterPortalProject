// Find Agents_Staff records related to Brian Darzev or Pat Baker
System.debug('=== AGENTS_STAFF for Pat Baker Contact ===');
List<Agents_Staff__c> patStaff = [SELECT Id, Name, Contact__c, Contact__r.Name FROM Agents_Staff__c WHERE Contact__c = '0035f000023HJU8AAO'];
for (Agents_Staff__c agentStaff : patStaff) {
    System.debug('ID: ' + agentStaff.Id + ', Name: ' + agentStaff.Name + ', Contact: ' + agentStaff.Contact__r.Name);
}

System.debug('\n=== AGENTS_STAFF for Brian Darzev Contact ===');
List<Agents_Staff__c> brianStaff = [SELECT Id, Name, Contact__c, Contact__r.Name FROM Agents_Staff__c WHERE Contact__c = '0035f000023HJL7AAO'];
for (Agents_Staff__c agentStaff2 : brianStaff) {
    System.debug('ID: ' + agentStaff2.Id + ', Name: ' + agentStaff2.Name + ', Contact: ' + agentStaff2.Contact__r.Name);
}

// Check Contacts with Personal Email = null or matching descriptions
System.debug('\n=== CHECK IF Brian Darzev has email matching description patterns ===');
Contact brian = [SELECT Id, Name, Personal_Email__c, Email FROM Contact WHERE Id = '0035f000023HJL7AAO'];
System.debug('Brian Personal_Email__c: ' + brian.Personal_Email__c);
System.debug('Brian Email: ' + brian.Email);

// Check if there's a Contact with Personal_Email matching what might be in description
List<Contact> contactsWithTest = [SELECT Id, Name, Personal_Email__c FROM Contact WHERE Personal_Email__c LIKE '%test%' LIMIT 5];
System.debug('\n=== Contacts with test in Personal_Email__c ===');
for (Contact c : contactsWithTest) {
    System.debug(c.Name + ' - ' + c.Personal_Email__c);
}
