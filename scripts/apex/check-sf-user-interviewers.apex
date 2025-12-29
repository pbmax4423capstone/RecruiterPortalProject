// Check how many interviewers are NOT Salesforce users
// This tells us how many events would be assigned to Pat Baker

// Get all unique interviewer names from Candidates with completed interviews
Set<String> allInterviewers = new Set<String>();

for (Candidate__c c : [
    SELECT Attraction_Interview_Conducted_By__c, Attraction_Conducted_by__c,
           AI_Conducted_By__c,
           SI_1_Interview_Conducted_by__c, SI_1_Conducted_By__c, SI1_Conducted_by__c,
           SI_2_Conducted_By__c, SI2_Conducted_by__c,
           SI_3_Conducted_By__c, SI3_Conducted_by__c,
           Career_Presentation_Conducted_By__c, Career_Conducted_by__c
    FROM Candidate__c
    LIMIT 10000
]) {
    if (c.Attraction_Interview_Conducted_By__c != null) allInterviewers.add(c.Attraction_Interview_Conducted_By__c.trim());
    if (c.Attraction_Conducted_by__c != null) allInterviewers.add(c.Attraction_Conducted_by__c.trim());
    if (c.AI_Conducted_By__c != null) allInterviewers.add(c.AI_Conducted_By__c.trim());
    if (c.SI_1_Interview_Conducted_by__c != null) allInterviewers.add(c.SI_1_Interview_Conducted_by__c.trim());
    if (c.SI_1_Conducted_By__c != null) allInterviewers.add(c.SI_1_Conducted_By__c.trim());
    if (c.SI1_Conducted_by__c != null) allInterviewers.add(c.SI1_Conducted_by__c.trim());
    if (c.SI_2_Conducted_By__c != null) allInterviewers.add(c.SI_2_Conducted_By__c.trim());
    if (c.SI2_Conducted_by__c != null) allInterviewers.add(c.SI2_Conducted_by__c.trim());
    if (c.SI_3_Conducted_By__c != null) allInterviewers.add(c.SI_3_Conducted_By__c.trim());
    if (c.SI3_Conducted_by__c != null) allInterviewers.add(c.SI3_Conducted_by__c.trim());
    if (c.Career_Presentation_Conducted_By__c != null) allInterviewers.add(c.Career_Presentation_Conducted_By__c.trim());
    if (c.Career_Conducted_by__c != null) allInterviewers.add(c.Career_Conducted_by__c.trim());
}

System.debug('Total unique interviewer names: ' + allInterviewers.size());
System.debug('');

// Get all active SF users
Map<String, User> userCache = new Map<String, User>();
for (User u : [SELECT Id, Name, FirstName, LastName FROM User WHERE IsActive = true]) {
    userCache.put(u.Name.toLowerCase(), u);
    if (u.FirstName != null && u.LastName != null) {
        userCache.put((u.FirstName + ' ' + u.LastName).toLowerCase(), u);
    }
}

System.debug('Active Salesforce users: ' + userCache.size());
System.debug('');

// Check which interviewers are NOT SF users
List<String> notSfUsers = new List<String>();
List<String> areSfUsers = new List<String>();

for (String interviewer : allInterviewers) {
    String normalized = interviewer.trim().toLowerCase();
    if (userCache.containsKey(normalized)) {
        areSfUsers.add(interviewer);
    } else {
        notSfUsers.add(interviewer);
    }
}

System.debug('=== SUMMARY ===');
System.debug('Interviewers who ARE SF users: ' + areSfUsers.size());
System.debug('Interviewers who are NOT SF users: ' + notSfUsers.size());
System.debug('');

System.debug('These ' + notSfUsers.size() + ' interviewers would result in events assigned to Pat Baker:');
notSfUsers.sort();
for (Integer i = 0; i < Math.min(30, notSfUsers.size()); i++) {
    System.debug((i+1) + '. "' + notSfUsers[i] + '"');
}
if (notSfUsers.size() > 30) {
    System.debug('... and ' + (notSfUsers.size() - 30) + ' more');
}

System.debug('');
System.debug('SF user interviewers (events will be assigned to them):');
areSfUsers.sort();
for (Integer i = 0; i < Math.min(20, areSfUsers.size()); i++) {
    System.debug((i+1) + '. "' + areSfUsers[i] + '"');
}
