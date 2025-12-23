// Batch 2: More agents from the report
List<String> agentsBatch2 = new List<String>{
    'Jonathan Weir', 'Kyle Annas', 'Matthew Rauen', 'Susan Kim Chow', 'Josh Wakefield',
    'Philip Bodine', 'Nick Morgan', 'Allen Cannon', 'Andre Coulombe', 'Brad Morgan',
    'Brett Longenecker', 'Carl Anthony Fletcher', 'Charles Showalter', 'Christopher Bissonnette',
    'David Guterman', 'Greg Clemensen', 'Greg Karis', 'Harry Hank W Frazee Iii',
    'Jacklin Bahramy', 'Joel Tremmel', 'John Grady Griffin', 'Jon Schaeffer',
    'Joseph Joe Brezden', 'Kenneth Tooke II', 'Lee Kitzenberg', 'Leopold PJ Pfeifenberger Jr',
    'Mark Quinlan', 'Matthew Sathe', 'Raymond Bell', 'Richard Bryan Sedway',
    'Robert Goggins', 'Rodney D Sager', 'Ryan A Lax', 'Sandra Colon-Williams'
};

System.debug('Processing batch 2: ' + agentsBatch2.size() + ' agents');

Account capstoneAccount = [SELECT Id FROM Account WHERE Name = 'Capstone' LIMIT 1];

Set<String> existingContactNames = new Set<String>();
for (Contact c : [SELECT Name FROM Contact]) {
    if (c.Name != null) {
        existingContactNames.add(c.Name.toLowerCase());
    }
}
System.debug('Existing contacts: ' + existingContactNames.size());

List<Contact> newContacts = new List<Contact>();
for (String agent : agentsBatch2) {
    if (!existingContactNames.contains(agent.toLowerCase())) {
        List<String> nameParts = agent.split(' ', 2);
        String firstName = nameParts.size() > 1 ? nameParts[0] : '';
        String lastName = nameParts.size() > 1 ? nameParts[1] : nameParts[0];
        
        newContacts.add(new Contact(
            FirstName = firstName,
            LastName = lastName,
            AccountId = capstoneAccount.Id
        ));
        System.debug('Will create contact: ' + agent);
    }
}

if (!newContacts.isEmpty()) {
    insert newContacts;
    System.debug('Created ' + newContacts.size() + ' contacts');
}

Map<String, Id> contactNameToId = new Map<String, Id>();
for (Contact c : [SELECT Id, Name FROM Contact]) {
    if (c.Name != null) {
        contactNameToId.put(c.Name.toLowerCase(), c.Id);
    }
}

Set<String> existingCandidateNames = new Set<String>();
for (Candidate__c cand : [SELECT Name FROM Candidate__c]) {
    if (cand.Name != null) {
        existingCandidateNames.add(cand.Name.toLowerCase());
    }
}
System.debug('Existing candidates: ' + existingCandidateNames.size());

List<Candidate__c> newCandidates = new List<Candidate__c>();
for (String agent : agentsBatch2) {
    if (!existingCandidateNames.contains(agent.toLowerCase())) {
        List<String> nameParts = agent.split(' ', 2);
        String firstName = nameParts.size() > 1 ? nameParts[0] : '';
        String lastName = nameParts.size() > 1 ? nameParts[1] : nameParts[0];
        Id contactId = contactNameToId.get(agent.toLowerCase());
        
        newCandidates.add(new Candidate__c(
            Name = agent,
            First_Name__c = firstName,
            Last_Name__c = lastName,
            Contact__c = contactId,
            Status__c = 'Contracted- Contract B',
            Contract_Type__c = 'Contract B',
            Highest_Level_Achieved__c = '7-Contracted'
        ));
        System.debug('Will create candidate: ' + agent);
    }
}

if (!newCandidates.isEmpty()) {
    insert newCandidates;
    System.debug('Created ' + newCandidates.size() + ' candidates');
}

System.debug('Batch 2 complete');
