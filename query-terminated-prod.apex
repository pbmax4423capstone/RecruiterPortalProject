// Query Production for terminated users - find their Contact, Candidate, and ALC data
List<String> terminatedNames = new List<String>{
    'Herbert Franco',
    'Phong Nguyen',
    'Kinley Yann',
    'James Farden',
    'Christina Lee',
    'Timothy Johnson',
    'Lisa Paras',
    'Syncere Cumpian',
    'Constance Hammonds',
    'Scott Primm',
    'Richard Stribling',
    'Gregory Poulton',
    'Gregory Smith',
    'Kimberley Schkade-hill',
    'Thomas Thorkelson',
    'Tyler Parcell',
    'Ryan Atchley',
    'Cory Smith',
    'Thomas Spink',
    'Patricia Moulton',
    'Wilson Skinner',
    'Amy Corpron',
    'Craig Simmerman',
    'Erica Neal',
    'Diljeet Masuda'
};

System.debug('=== CONTACTS ===');
List<Contact> contacts = [
    SELECT Id, Name, FirstName, LastName, Email, AccountId, Account.Name
    FROM Contact
    WHERE Name IN :terminatedNames
];
for (Contact c : contacts) {
    System.debug('Contact: ' + c.Name + ' | Id: ' + c.Id + ' | Account: ' + c.Account.Name);
}
System.debug('Found ' + contacts.size() + ' contacts');

System.debug('');
System.debug('=== CANDIDATES ===');
List<Candidate__c> candidates = [
    SELECT Id, Name, Contact__c, Contact__r.Name, Status__c, Contract_Type__c, Start_Date__c
    FROM Candidate__c
    WHERE Name IN :terminatedNames
];
for (Candidate__c cand : candidates) {
    System.debug('Candidate: ' + cand.Name + ' | Status: ' + cand.Status__c + ' | Contract: ' + cand.Contract_Type__c);
}
System.debug('Found ' + candidates.size() + ' candidates');

System.debug('');
System.debug('=== ALC RECORDS ===');
Set<Id> contactIds = new Set<Id>();
for (Contact c : contacts) {
    contactIds.add(c.Id);
}
List<ALC__c> alcRecords = [
    SELECT Id, Name, Contact__c, Contact__r.Name, Contract_Effective__c, LADL_Sales_Experience__c, Contract_Type__c
    FROM ALC__c
    WHERE Contact__c IN :contactIds
];
for (ALC__c alc : alcRecords) {
    System.debug('ALC: ' + alc.Contact__r.Name + ' | Contract Date: ' + alc.Contract_Effective__c + ' | Type: ' + alc.Contract_Type__c + ' | LADL: ' + alc.LADL_Sales_Experience__c);
}
System.debug('Found ' + alcRecords.size() + ' ALC records');
