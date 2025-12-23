// Check what terminated users exist in Recruiting sandbox
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

System.debug('=== EXISTING CANDIDATES IN RECRUITING ===');
List<Candidate__c> existingCandidates = [
    SELECT Id, Name, Status__c, Contract_Type__c
    FROM Candidate__c
    WHERE Name IN :terminatedNames
];
Set<String> existingNames = new Set<String>();
for (Candidate__c c : existingCandidates) {
    existingNames.add(c.Name);
    System.debug('Found: ' + c.Name + ' | Status: ' + c.Status__c);
}
System.debug('Found ' + existingCandidates.size() + ' existing candidates');

System.debug('');
System.debug('=== CONTACTS IN RECRUITING ===');
List<Contact> existingContacts = [
    SELECT Id, Name, FirstName, LastName, AccountId
    FROM Contact
    WHERE Name IN :terminatedNames
];
Set<String> existingContactNames = new Set<String>();
for (Contact c : existingContacts) {
    existingContactNames.add(c.Name);
    System.debug('Found Contact: ' + c.Name);
}
System.debug('Found ' + existingContacts.size() + ' existing contacts');

System.debug('');
System.debug('=== MISSING (need to create) ===');
for (String name : terminatedNames) {
    if (!existingNames.contains(name)) {
        System.debug('Missing candidate: ' + name);
    }
}
