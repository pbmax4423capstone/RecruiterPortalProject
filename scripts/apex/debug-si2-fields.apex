// Debug SI 2 fields to find which one is actually populated
Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

List<Candidate__c> candidates = [
    SELECT Id, Name,
        SI_2_Date_Completed__c,
        SI_2_Interviewer__c,
        SI2_Conducted_by__c,
        SI_2_Conducted_By__c
    FROM Candidate__c
    WHERE SI_2_Date_Completed__c >= :novemberStart 
    AND SI_2_Date_Completed__c <= :novemberEnd
];

System.debug('Found ' + candidates.size() + ' SI 2 interviews completed in November');

for (Candidate__c cand : candidates) {
    System.debug('\nCandidate: ' + cand.Name);
    System.debug('  SI_2_Date_Completed__c: ' + cand.SI_2_Date_Completed__c);
    System.debug('  SI_2_Interviewer__c: ' + cand.SI_2_Interviewer__c);
    System.debug('  SI2_Conducted_by__c: ' + cand.SI2_Conducted_by__c);
    System.debug('  SI_2_Conducted_By__c: ' + cand.SI_2_Conducted_By__c);
}
