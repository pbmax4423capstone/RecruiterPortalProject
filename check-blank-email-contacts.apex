// Check if there are Contacts with blank or null Personal_Email__c
List<Contact> blankEmailContacts = [
    SELECT Id, Name, Personal_Email__c, Email 
    FROM Contact 
    WHERE Personal_Email__c = '' OR Personal_Email__c = null
    ORDER BY LastModifiedDate DESC
    LIMIT 10
];

System.debug('=== Contacts with blank/null Personal_Email__c ===');
for (Contact c : blankEmailContacts) {
    System.debug(c.Name + ' (ID: ' + c.Id + ') - Personal_Email__c: "' + c.Personal_Email__c + '" | Email: ' + c.Email);
    if (c.Id == '0035f000023HJL7AAO') {
        System.debug('*** THIS IS BRIAN DARZEV ***');
    }
}

// Check if Brian Darzev's ID would be returned by query with empty string
List<Contact> testQuery = [
    SELECT Id, Name FROM Contact 
    WHERE Personal_Email__c = ''
    LIMIT 1
];
System.debug('\n=== Query result for Personal_Email__c = "" ===');
if (testQuery.size() > 0) {
    System.debug('Found: ' + testQuery[0].Name + ' (ID: ' + testQuery[0].Id + ')');
} else {
    System.debug('No results');
}
