// Debug - find the null issue

// Test basic query
List<Contact> contacts = [SELECT Id, Name FROM Contact LIMIT 10];
System.debug('Found ' + contacts.size() + ' contacts');

for (Contact c : contacts) {
    System.debug('Contact: ' + c.Id + ' - ' + c.Name);
}

// Test account query
List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 5];
System.debug('Found ' + accounts.size() + ' accounts');

for (Account a : accounts) {
    System.debug('Account: ' + a.Id + ' - ' + a.Name);
}

// Test candidate query
List<Candidate__c> candidates = [SELECT Id, Name, Contact__c FROM Candidate__c LIMIT 10];
System.debug('Found ' + candidates.size() + ' candidates');

for (Candidate__c cand : candidates) {
    System.debug('Candidate: ' + cand.Id + ' - ' + cand.Name + ' - Contact: ' + cand.Contact__c);
}
