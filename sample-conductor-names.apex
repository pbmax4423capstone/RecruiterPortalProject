// Sample AI_Conducted_By__c values
List<Candidate__c> cands = [
    SELECT AI_Conducted_By__c, Attraction_Interview_Date_Completed__c
    FROM Candidate__c
    WHERE Attraction_Interview_Date_Completed__c = THIS_MONTH
    AND AI_Conducted_By__c != null
    LIMIT 50
];

System.debug('=== Sample AI_Conducted_By__c values ===');
Set<String> uniqueNames = new Set<String>();
for (Candidate__c c : cands) {
    uniqueNames.add(c.AI_Conducted_By__c);
}
for (String name : uniqueNames) {
    System.debug('  "' + name + '"');
}

// Check User names
List<User> users = [SELECT Id, Name FROM User WHERE Name LIKE '%Sofonia%' OR Name LIKE '%Tenny%' OR Name LIKE '%Denton%'];
System.debug('\n=== User.Name values (sample) ===');
for (User u : users) {
    System.debug('  "' + u.Name + '" (' + u.Id + ')');
}
