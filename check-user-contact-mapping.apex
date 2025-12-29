// Check Pat Baker's User record and Contact_ID__c value
User patUser = [SELECT Id, Name, Email, Contact_ID__c FROM User WHERE Id = '0055f000007zsZ6AAI' LIMIT 1];
System.debug('=== PAT BAKER USER RECORD ===');
System.debug('User ID: ' + patUser.Id);
System.debug('User Name: ' + patUser.Name);
System.debug('User Email: ' + patUser.Email);
System.debug('Contact_ID__c: ' + patUser.Contact_ID__c);

// Check if this Contact_ID__c points to the correct Contact
if (patUser.Contact_ID__c != null) {
    Contact patContact = [SELECT Id, Name, Personal_Email__c, Financialguide_Email__c FROM Contact WHERE Id = :patUser.Contact_ID__c LIMIT 1];
    System.debug('\n=== CONTACT FROM Contact_ID__c ===');
    System.debug('Contact ID: ' + patContact.Id);
    System.debug('Contact Name: ' + patContact.Name);
    System.debug('Personal Email: ' + patContact.Personal_Email__c);
    System.debug('FinancialGuide Email: ' + patContact.Financialguide_Email__c);
}

// Check Brian Darzev's Contact
Contact brianContact = [SELECT Id, Name, Personal_Email__c, Financialguide_Email__c FROM Contact WHERE Id = '0035f000023HJL7AAO' LIMIT 1];
System.debug('\n=== BRIAN DARZEV CONTACT ===');
System.debug('Contact ID: ' + brianContact.Id);
System.debug('Contact Name: ' + brianContact.Name);
System.debug('Personal Email: ' + brianContact.Personal_Email__c);
System.debug('FinancialGuide Email: ' + brianContact.Financialguide_Email__c);

// Check Service User metadata records
List<Service_User__mdt> serviceUsers = [SELECT Label, ContactId__c, DeveloperName FROM Service_User__mdt];
System.debug('\n=== SERVICE USER METADATA ===');
for (Service_User__mdt su : serviceUsers) {
    System.debug('Service User: ' + su.Label + ' (ContactId: ' + su.ContactId__c + ')');
}
