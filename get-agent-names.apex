// Query Production for ALC records for our agents
// First, get the names of candidates without contract type

List<String> agentNames = new List<String>();

for (Candidate__c c : [
    SELECT Name
    FROM Candidate__c
    WHERE Contract_Type__c = null
    AND Status__c = 'Completed'
]) {
    agentNames.add(c.Name);
    System.debug(c.Name);
}

System.debug('Total agents to look up: ' + agentNames.size());
