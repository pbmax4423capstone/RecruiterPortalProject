// Debug SI 2 (PLAN) interviews - check all possible date fields

Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

// Check SI_2_Date_Scheduled__c
Integer si2Scheduled = [
    SELECT COUNT()
    FROM Candidate__c
    WHERE SI_2_Date_Scheduled__c >= :novemberStart
    AND SI_2_Date_Scheduled__c <= :novemberEnd
];

// Check SI_2_Date_Completed__c
Integer si2Completed = [
    SELECT COUNT()
    FROM Candidate__c
    WHERE SI_2_Date_Completed__c >= :novemberStart
    AND SI_2_Date_Completed__c <= :novemberEnd
];

System.debug('SI 2 (PLAN) interviews in November:');
System.debug('  By Scheduled Date: ' + si2Scheduled);
System.debug('  By Completed Date: ' + si2Completed);
System.debug('');

// Get some examples
List<Candidate__c> si2Examples = [
    SELECT Name, SI_2_Date_Scheduled__c, SI_2_Date_Completed__c, 
           SI_2_Interviewer__c, SI2_Conducted_by__c
    FROM Candidate__c
    WHERE SI_2_Date_Scheduled__c >= :novemberStart
    AND SI_2_Date_Scheduled__c <= :novemberEnd
    LIMIT 10
];

System.debug('Sample SI 2 interviews (by scheduled date):');
for (Candidate__c cand : si2Examples) {
    System.debug('  ' + cand.Name);
    System.debug('    Scheduled: ' + cand.SI_2_Date_Scheduled__c);
    System.debug('    Completed: ' + cand.SI_2_Date_Completed__c);
    System.debug('    Interviewer: ' + cand.SI_2_Interviewer__c);
    System.debug('    Conducted by: ' + cand.SI2_Conducted_by__c);
}
