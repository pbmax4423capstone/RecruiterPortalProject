// Create Contacts for Contract B candidates, then create Opportunities from report
// Link opportunities via Soliciting_Agent__c field

// Step 1: Get Contract B candidates who need contacts
List<Candidate__c> contractBCandidates = [
    SELECT Id, Name, First_Name__c, Last_Name__c, Contact__c
    FROM Candidate__c
    WHERE Status__c = 'Contracted- Contract B'
];

System.debug('Contract B candidates: ' + contractBCandidates.size());

// Build map of candidate names to IDs
Map<String, Id> candidateNameToId = new Map<String, Id>();
Map<String, Candidate__c> candidatesByName = new Map<String, Candidate__c>();
for (Candidate__c c : contractBCandidates) {
    candidateNameToId.put(c.Name.toLowerCase(), c.Id);
    candidatesByName.put(c.Name.toLowerCase(), c);
    System.debug('Candidate: ' + c.Name);
}

// Step 2: Create contacts for candidates that don't have them
// First get the default Account
List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name LIKE '%Capstone%' LIMIT 1];
Id accountId;
if (accounts.isEmpty()) {
    // Create a default account
    Account acc = new Account(Name = 'Capstone');
    insert acc;
    accountId = acc.Id;
} else {
    accountId = accounts[0].Id;
}

System.debug('Using Account: ' + accountId);

// Create contacts for candidates without them
List<Contact> contactsToCreate = new List<Contact>();
for (Candidate__c cand : contractBCandidates) {
    if (cand.Contact__c == null) {
        Contact con = new Contact();
        con.FirstName = cand.First_Name__c;
        con.LastName = cand.Last_Name__c != null ? cand.Last_Name__c : cand.Name;
        con.AccountId = accountId;
        contactsToCreate.add(con);
    }
}

if (!contactsToCreate.isEmpty()) {
    insert contactsToCreate;
    System.debug('Created ' + contactsToCreate.size() + ' contacts');
}

// Query all contacts that match our candidates
Set<String> candidateNames = new Set<String>();
for (Candidate__c c : contractBCandidates) {
    candidateNames.add(c.Name);
}

List<Contact> matchingContacts = [
    SELECT Id, Name, FirstName, LastName
    FROM Contact
    WHERE Name IN :candidateNames
];

// Build contact name to ID map
Map<String, Id> contactNameToId = new Map<String, Id>();
for (Contact con : matchingContacts) {
    contactNameToId.put(con.Name.toLowerCase(), con.Id);
    System.debug('Contact matched: ' + con.Name + ' -> ' + con.Id);
}

// Also query by first+last name pattern
for (Candidate__c cand : contractBCandidates) {
    String fullName = (cand.First_Name__c + ' ' + cand.Last_Name__c).toLowerCase();
    if (!contactNameToId.containsKey(fullName)) {
        // Try to find contact
        List<Contact> cons = [SELECT Id, Name FROM Contact WHERE FirstName = :cand.First_Name__c AND LastName = :cand.Last_Name__c LIMIT 1];
        if (!cons.isEmpty()) {
            contactNameToId.put(fullName, cons[0].Id);
            contactNameToId.put(cand.Name.toLowerCase(), cons[0].Id);
        }
    }
}

System.debug('Total contacts mapped: ' + contactNameToId.size());

// Update candidates with their contacts
List<Candidate__c> candidatesToUpdate = new List<Candidate__c>();
for (Candidate__c cand : contractBCandidates) {
    String nameKey = cand.Name.toLowerCase();
    if (cand.Contact__c == null && contactNameToId.containsKey(nameKey)) {
        cand.Contact__c = contactNameToId.get(nameKey);
        candidatesToUpdate.add(cand);
    }
}

if (!candidatesToUpdate.isEmpty()) {
    update candidatesToUpdate;
    System.debug('Updated ' + candidatesToUpdate.size() + ' candidates with contacts');
}

// Verification
System.debug('');
System.debug('=== VERIFICATION ===');
for (Candidate__c c : [SELECT Id, Name, Contact__c, Contact__r.Name FROM Candidate__c WHERE Status__c = 'Contracted- Contract B']) {
    System.debug(c.Name + ' -> Contact: ' + c.Contact__r?.Name);
}
