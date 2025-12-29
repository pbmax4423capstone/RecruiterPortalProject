// Debug script to see what conductor names are actually in the November CIT interviews

Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

// Query a sample of CIT interviews from November
List<Candidate__c> citInterviews = [
    SELECT Id, Name,
        Attraction_Interview_Date_Scheduled__c,
        AI_Conducted_By__c,
        Attraction_Conducted_by__c,
        Attraction_Interview_Conducted_By__c
    FROM Candidate__c
    WHERE Attraction_Interview_Date_Scheduled__c >= :novemberStart
    AND Attraction_Interview_Date_Scheduled__c <= :novemberEnd
    LIMIT 20
];

System.debug('===== SAMPLE CIT INTERVIEWS IN NOVEMBER =====');
System.debug('Total found: ' + citInterviews.size());
System.debug('');

for (Candidate__c cand : citInterviews) {
    System.debug('Candidate: ' + cand.Name);
    System.debug('  Scheduled: ' + cand.Attraction_Interview_Date_Scheduled__c);
    System.debug('  AI_Conducted_By__c: [' + cand.AI_Conducted_By__c + ']');
    System.debug('  Attraction_Conducted_by__c: [' + cand.Attraction_Conducted_by__c + ']');
    System.debug('  Attraction_Interview_Conducted_By__c: [' + cand.Attraction_Interview_Conducted_By__c + ']');
    System.debug('');
}

// Also check user names
List<User> managers = [
    SELECT Id, Name
    FROM User
    WHERE Name LIKE '%Tenny%' OR Name LIKE '%Denton%' OR Name LIKE '%Sofonia%'
];

System.debug('===== USER NAMES =====');
for (User u : managers) {
    System.debug('User: [' + u.Name + '] ID: ' + u.Id);
}
