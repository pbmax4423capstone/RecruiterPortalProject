// Find AI field name
List<Candidate__c> test = [
    SELECT Id, Name, 
           Attraction_Date_Completed__c,
           Attraction_Conducted_By__c
    FROM Candidate__c
    WHERE Attraction_Date_Completed__c != null
    LIMIT 1
];

System.debug('AI field test: ' + test.size());
if (test.size() > 0) {
    System.debug('Attraction Date: ' + test[0].Attraction_Date_Completed__c);
    System.debug('Attraction Conductor: ' + test[0].Attraction_Conducted_By__c);
}
