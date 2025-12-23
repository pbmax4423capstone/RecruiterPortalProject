// Create all opportunities from the report
// First, get all unique Soliciting Agents and ensure they have Candidates/Contacts

// All unique Soliciting Agents from the report
Set<String> allAgents = new Set<String>{
    'Michael Krupin', 'Jason Weiss', 'Justin Ricks', 'Douglas Gold', 'Shane Butler',
    'Rodney Sager', 'Eric Wilson', 'Erwin Espina Prieto', 'Robert Silberman', 'Brent Emch',
    'John Bradley', 'Jonathon Olivas', 'Steven Dark', 'Tom Maguire', 'Lauren Skrabonja',
    'Slava Palamarchuk', 'Vladimir Donets', 'Carmina Rodriguez', 'Nacole Light',
    'Jeremiah Goldenetz', 'Kerry Hendrix', 'Robert Perez', 'ANDREW Moore Sr', 'Scott Balboni',
    'Ethan Barnes', 'David Tsymbal', 'Linda Chen', 'Michael McKnight', 'Linh Ma',
    'Irina Tarasova', 'Matthew Collins', 'Erica Pu', 'Todd Frank', 'Woong (Eddie) Lee',
    'Jonny Campbell', 'Brian Barney', 'Edward Ricker', 'Beau Wendling', 'Craig Lytle',
    'Jonathan Weir', 'Kyle Annas', 'Matthew Rauen', 'Susan Kim Chow', 'Josh Wakefield',
    'Philip Bodine', 'Nick Morgan', 'Allen Cannon', 'Andre Coulombe', 'Brad Morgan',
    'Brett Longenecker', 'Carl Anthony Fletcher', 'Charles Showalter', 'Christopher Bissonnette',
    'David Guterman', 'Greg Clemensen', 'Greg Karis', 'Harry (Hank) W Frazee Iii',
    'Jacklin Bahramy', 'Joel Tremmel', 'John Grady Griffin', 'Jon Schaeffer',
    'Joseph Joe Brezden', 'Kenneth Tooke II', 'Lee Kitzenberg', 'Leopold PJ Pfeifenberger Jr',
    'Mark Quinlan', 'Matthew Sathe', 'Raymond Bell', 'Richard Bryan Sedway',
    'Robert Goggins', 'Rodney D Sager', 'Ryan A Lax', 'Sandra Colon-Williams'
};

System.debug('Total unique agents: ' + allAgents.size());

// Get existing contacts by name (case-insensitive)
Map<String, Id> existingContactsByName = new Map<String, Id>();
for (Contact c : [SELECT Id, Name FROM Contact WHERE Name IN :allAgents]) {
    existingContactsByName.put(c.Name.toLowerCase(), c.Id);
}
System.debug('Existing contacts found: ' + existingContactsByName.size());

// Get existing candidates by name
Map<String, Id> existingCandidatesByName = new Map<String, Id>();
for (Candidate__c cand : [SELECT Id, Name, Contact__c FROM Candidate__c WHERE Name IN :allAgents]) {
    existingCandidatesByName.put(cand.Name.toLowerCase(), cand.Id);
}
System.debug('Existing candidates found: ' + existingCandidatesByName.size());

// Get Capstone account
Account capstoneAccount = [SELECT Id FROM Account WHERE Name LIKE '%Capstone%' LIMIT 1];

// Find agents that need to be created
Set<String> agentsToCreate = new Set<String>();
for (String agent : allAgents) {
    if (!existingContactsByName.containsKey(agent.toLowerCase())) {
        agentsToCreate.add(agent);
    }
}
System.debug('Agents to create: ' + agentsToCreate.size());

// Create Contacts for missing agents
List<Contact> newContacts = new List<Contact>();
for (String agent : agentsToCreate) {
    String firstName = '';
    String lastName = agent;
    if (agent.contains(' ')) {
        Integer spaceIdx = agent.indexOf(' ');
        firstName = agent.substring(0, spaceIdx);
        lastName = agent.substring(spaceIdx + 1);
    }
    if (String.isBlank(lastName)) {
        lastName = agent;
    }
    newContacts.add(new Contact(
        FirstName = firstName,
        LastName = lastName,
        AccountId = capstoneAccount.Id
    ));
}

if (!newContacts.isEmpty()) {
    insert newContacts;
    System.debug('Created ' + newContacts.size() + ' contacts');
    
    // Add new contacts to the map
    for (Contact c : newContacts) {
        existingContactsByName.put(c.Name.toLowerCase(), c.Id);
    }
}

// Create Candidates for missing agents
List<Candidate__c> newCandidates = new List<Candidate__c>();
for (String agent : agentsToCreate) {
    String firstName = '';
    String lastName = agent;
    if (agent.contains(' ')) {
        Integer spaceIdx = agent.indexOf(' ');
        firstName = agent.substring(0, spaceIdx);
        lastName = agent.substring(spaceIdx + 1);
    }
    if (String.isBlank(lastName)) {
        lastName = agent;
    }
    
    Id contactId = existingContactsByName.get(agent.toLowerCase());
    
    newCandidates.add(new Candidate__c(
        Name = agent,
        First_Name__c = firstName,
        Last_Name__c = lastName,
        Contact__c = contactId,
        Status__c = 'Contracted- Contract B',
        Contract_Type__c = 'Contract B',
        Highest_Level_Achieved__c = '7-Contracted'
    ));
}

if (!newCandidates.isEmpty()) {
    insert newCandidates;
    System.debug('Created ' + newCandidates.size() + ' candidates');
}

// Also update existing candidates to link them to contacts if not already linked
List<Candidate__c> candidatesToUpdate = new List<Candidate__c>();
for (Candidate__c cand : [SELECT Id, Name, Contact__c FROM Candidate__c WHERE Name IN :allAgents AND Contact__c = null]) {
    Id contactId = existingContactsByName.get(cand.Name.toLowerCase());
    if (contactId != null) {
        cand.Contact__c = contactId;
        candidatesToUpdate.add(cand);
    }
}
if (!candidatesToUpdate.isEmpty()) {
    update candidatesToUpdate;
    System.debug('Updated ' + candidatesToUpdate.size() + ' candidates with contact links');
}

// Refresh contacts map
Map<String, Id> contactNameToId = new Map<String, Id>();
for (Contact c : [SELECT Id, Name FROM Contact]) {
    contactNameToId.put(c.Name.toLowerCase(), c.Id);
}

System.debug('Total contacts mapped: ' + contactNameToId.size());
System.debug('Ready to create opportunities in next script');
