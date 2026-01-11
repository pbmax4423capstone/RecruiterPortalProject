// Find potential matching Contacts for a given ALC by Name
String alcName = 'Giovahn Barboza';
ALC__c alc = [SELECT Id, Name, First_Name__c, Last_Name__c, Mobile__c, Personal_Email_Address__c, Contact__c, Candidate__c
              FROM ALC__c WHERE Name = :alcName LIMIT 1];
System.debug('ALC: ' + alc.Name + ' (Contact__c=' + alc.Contact__c + ', Candidate__c=' + alc.Candidate__c + ')');
// Simple matching: by last name and email
List<Contact> contacts = [
    SELECT Id, FirstName, LastName, Email, Personal_Email__c, MobilePhone
    FROM Contact
    WHERE LastName LIKE :('%' + String.escapeSingleQuotes(alc.Last_Name__c) + '%')
       OR Email = :alc.Personal_Email_Address__c
       OR Personal_Email__c = :alc.Personal_Email_Address__c
    LIMIT 20
];
Integer i = 0;
for (Contact c : contacts) {
    i++;
    System.debug(i + ') Contact=' + c.Id + ' ' + c.FirstName + ' ' + c.LastName + ' email=' + c.Email + ' personal=' + c.Personal_Email__c + ' mobile=' + c.MobilePhone);
}
if (contacts.isEmpty()) {
    System.debug('No matches found');
}
