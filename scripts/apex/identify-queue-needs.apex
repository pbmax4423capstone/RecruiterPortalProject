// Identify which interviewers need queues (not Salesforce users)
List<Candidate__c> candidates = [
    SELECT Id, 
           AI_Conducted_By__c, SI1_Conducted_By__c, SI2_Conducted_By__c, 
           SI3_Conducted_By__c, CP_Conducted_By__c
    FROM Candidate__c 
    WHERE (Attraction_Interview_Date_Completed__c != null OR SI_1_Date_Completed__c != null 
           OR SI_2_Date_Completed__c != null OR SI_3_Completed__c != null 
           OR Career_Presentation_Date_Completed__c != null)
    LIMIT 5000
];

Set<String> allInterviewers = new Set<String>();
for (Candidate__c c : candidates) {
    if (c.AI_Conducted_By__c != null) allInterviewers.add(c.AI_Conducted_By__c);
    if (c.SI1_Conducted_By__c != null) allInterviewers.add(c.SI1_Conducted_By__c);
    if (c.SI2_Conducted_By__c != null) allInterviewers.add(c.SI2_Conducted_By__c);
    if (c.SI3_Conducted_By__c != null) allInterviewers.add(c.SI3_Conducted_By__c);
    if (c.CP_Conducted_By__c != null) allInterviewers.add(c.CP_Conducted_By__c);
}

// Check which ones are active users
Map<String, Id> userMap = new Map<String, Id>();
List<User> users = [SELECT Id, Name FROM User WHERE IsActive = true];
for (User u : users) {
    userMap.put(u.Name.toLowerCase(), u.Id);
}

// Check which ones already have queues
Map<String, Id> queueMap = new Map<String, Id>();
List<Group> queues = [SELECT Id, Name FROM Group WHERE Type = 'Queue'];
for (Group q : queues) {
    queueMap.put(q.Name.toLowerCase(), q.Id);
}

// Identify who needs queues
Set<String> needsQueue = new Set<String>();
for (String interviewer : allInterviewers) {
    String lowerName = interviewer.toLowerCase();
    if (!userMap.containsKey(lowerName) && !queueMap.containsKey(lowerName)) {
        needsQueue.add(interviewer);
    }
}

System.debug('=== INTERVIEWERS NEEDING QUEUES ===');
System.debug('Total unique interviewers: ' + allInterviewers.size());
System.debug('Active users: ' + userMap.size());
System.debug('Existing queues: ' + queueMap.size());
System.debug('Need new queues: ' + needsQueue.size());
System.debug('');

List<String> sortedNeeds = new List<String>(needsQueue);
sortedNeeds.sort();
for (String name : sortedNeeds) {
    System.debug('  - ' + name);
}
