// Step 1: Create contacts and candidates for all agents from the report
// Split into batch to avoid limits

// Agent names batch 1
List<String> agentsBatch1 = new List<String>{
    'Michael Krupin', 'Jason Weiss', 'Justin Ricks', 'Douglas Gold', 'Shane Butler',
    'Rodney Sager', 'Eric Wilson', 'Erwin Espina Prieto', 'Robert Silberman', 'Brent Emch',
    'John Bradley', 'Jonathon Olivas', 'Steven Dark', 'Tom Maguire', 'Lauren Skrabonja',
    'Slava Palamarchuk', 'Vladimir Donets', 'Carmina Rodriguez', 'Nacole Light',
    'Jeremiah Goldenetz', 'Kerry Hendrix', 'Robert Perez', 'ANDREW Moore Sr', 'Scott Balboni',
    'Ethan Barnes', 'David Tsymbal', 'Linda Chen', 'Michael McKnight', 'Linh Ma',
    'Irina Tarasova', 'Matthew Collins', 'Erica Pu', 'Todd Frank', 'Woong Eddie Lee',
    'Jonny Campbell', 'Brian Barney', 'Edward Ricker', 'Beau Wendling', 'Craig Lytle'
};

System.debug('Processing batch 1: ' + agentsBatch1.size() + ' agents');

// Get Capstone account
Account capstoneAccount = [SELECT Id FROM Account WHERE Name = 'Capstone' LIMIT 1];
System.debug('Capstone Account: ' + capstoneAccount.Id);

// Get existing contacts
Set<String> existingContactNames = new Set<String>();
for (Contact c : [SELECT Name FROM Contact]) {
    if (c.Name != null) {
        existingContactNames.add(c.Name.toLowerCase());
    }
}
System.debug('Existing contacts: ' + existingContactNames.size());

// Create contacts for agents that don't exist
List<Contact> newContacts = new List<Contact>();
for (String agent : agentsBatch1) {
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

// Refresh contact map
Map<String, Id> contactNameToId = new Map<String, Id>();
for (Contact c : [SELECT Id, Name FROM Contact]) {
    if (c.Name != null) {
        contactNameToId.put(c.Name.toLowerCase(), c.Id);
    }
}

// Get existing candidates
Set<String> existingCandidateNames = new Set<String>();
for (Candidate__c cand : [SELECT Name FROM Candidate__c]) {
    if (cand.Name != null) {
        existingCandidateNames.add(cand.Name.toLowerCase());
    }
}
System.debug('Existing candidates: ' + existingCandidateNames.size());

// Create candidates for agents that don't exist
List<Candidate__c> newCandidates = new List<Candidate__c>();
for (String agent : agentsBatch1) {
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

System.debug('Batch 1 complete');
