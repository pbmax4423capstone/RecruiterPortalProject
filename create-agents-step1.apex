// Step 1: Create contacts and candidates for all agents
// Debug version

// All unique Soliciting Agents from the report
List<String> allAgentsList = new List<String>{
    'Michael Krupin', 'Jason Weiss', 'Justin Ricks', 'Douglas Gold', 'Shane Butler',
    'Rodney Sager', 'Eric Wilson', 'Erwin Espina Prieto', 'Robert Silberman', 'Brent Emch',
    'John Bradley', 'Jonathon Olivas', 'Steven Dark', 'Tom Maguire', 'Lauren Skrabonja',
    'Slava Palamarchuk', 'Vladimir Donets', 'Carmina Rodriguez', 'Nacole Light',
    'Jeremiah Goldenetz', 'Kerry Hendrix', 'Robert Perez', 'ANDREW Moore Sr', 'Scott Balboni',
    'Ethan Barnes', 'David Tsymbal', 'Linda Chen', 'Michael McKnight', 'Linh Ma',
    'Irina Tarasova', 'Matthew Collins', 'Erica Pu', 'Todd Frank', 'Woong Eddie Lee',
    'Jonny Campbell', 'Brian Barney', 'Edward Ricker', 'Beau Wendling', 'Craig Lytle',
    'Jonathan Weir', 'Kyle Annas', 'Matthew Rauen', 'Susan Kim Chow', 'Josh Wakefield',
    'Philip Bodine', 'Nick Morgan', 'Allen Cannon', 'Andre Coulombe', 'Brad Morgan',
    'Brett Longenecker', 'Carl Anthony Fletcher', 'Charles Showalter', 'Christopher Bissonnette',
    'David Guterman', 'Greg Clemensen', 'Greg Karis', 'Harry Hank W Frazee Iii',
    'Jacklin Bahramy', 'Joel Tremmel', 'John Grady Griffin', 'Jon Schaeffer',
    'Joseph Joe Brezden', 'Kenneth Tooke II', 'Lee Kitzenberg', 'Leopold PJ Pfeifenberger Jr',
    'Mark Quinlan', 'Matthew Sathe', 'Raymond Bell', 'Richard Bryan Sedway',
    'Robert Goggins', 'Rodney D Sager', 'Ryan A Lax', 'Sandra Colon-Williams'
};

Set<String> allAgents = new Set<String>(allAgentsList);
System.debug('Total unique agents: ' + allAgents.size());

// Get existing contacts by name
Map<String, Id> existingContactsByName = new Map<String, Id>();
List<Contact> existingContacts = [SELECT Id, Name FROM Contact];
for (Contact c : existingContacts) {
    if (c.Name != null) {
        existingContactsByName.put(c.Name.toLowerCase(), c.Id);
    }
}
System.debug('Total existing contacts: ' + existingContactsByName.size());

// Check which agents exist
Integer foundCount = 0;
for (String agent : allAgents) {
    if (existingContactsByName.containsKey(agent.toLowerCase())) {
        foundCount++;
    }
}
System.debug('Agents already as contacts: ' + foundCount);

// Get Capstone account
List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name LIKE '%Capstone%' LIMIT 1];
if (accounts.isEmpty()) {
    System.debug('ERROR: No Capstone account found!');
} else {
    Account capstoneAccount = accounts[0];
    System.debug('Capstone account: ' + capstoneAccount.Name + ' (' + capstoneAccount.Id + ')');
    
    // Find agents that need contacts created
    List<String> agentsToCreate = new List<String>();
    for (String agent : allAgents) {
        if (!existingContactsByName.containsKey(agent.toLowerCase())) {
            agentsToCreate.add(agent);
        }
    }
    System.debug('Agents needing contacts: ' + agentsToCreate.size());
    
    // Create contacts
    List<Contact> newContacts = new List<Contact>();
    for (String agent : agentsToCreate) {
        String firstName = '';
        String lastName = agent;
        if (agent.contains(' ')) {
            Integer spaceIdx = agent.indexOf(' ');
            firstName = agent.substring(0, spaceIdx);
            lastName = agent.substring(spaceIdx + 1);
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
        
        // Update the map with new contacts
        for (Contact c : newContacts) {
            existingContactsByName.put(c.Name.toLowerCase(), c.Id);
        }
    }
    
    // Now create candidates for agents that don't have them
    Map<String, Id> existingCandidatesByName = new Map<String, Id>();
    for (Candidate__c cand : [SELECT Id, Name FROM Candidate__c]) {
        if (cand.Name != null) {
            existingCandidatesByName.put(cand.Name.toLowerCase(), cand.Id);
        }
    }
    System.debug('Existing candidates: ' + existingCandidatesByName.size());
    
    List<Candidate__c> newCandidates = new List<Candidate__c>();
    for (String agent : agentsToCreate) {
        if (!existingCandidatesByName.containsKey(agent.toLowerCase())) {
            String firstName = '';
            String lastName = agent;
            if (agent.contains(' ')) {
                Integer spaceIdx = agent.indexOf(' ');
                firstName = agent.substring(0, spaceIdx);
                lastName = agent.substring(spaceIdx + 1);
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
    }
    
    if (!newCandidates.isEmpty()) {
        insert newCandidates;
        System.debug('Created ' + newCandidates.size() + ' candidates');
    }
}

// Final count
Integer totalContacts = [SELECT COUNT() FROM Contact];
Integer totalCandidates = [SELECT COUNT() FROM Candidate__c];
System.debug('Final totals - Contacts: ' + totalContacts + ', Candidates: ' + totalCandidates);
