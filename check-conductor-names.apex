// Check what names are stored in AI_Conducted_By__c
List<AggregateResult> conductors = [
    SELECT AI_Conducted_By__c, COUNT(Id) cnt
    FROM Candidate__c
    WHERE Attraction_Interview_Date_Completed__c != null
    AND AI_Conducted_By__c != null
    GROUP BY AI_Conducted_By__c
    ORDER BY COUNT(Id) DESC
];

System.debug('=== AI_Conducted_By__c values in Candidates ===');
for (AggregateResult ar : conductors) {
    System.debug((String)ar.get('AI_Conducted_By__c') + ': ' + ar.get('cnt'));
}

// Check User names in system
List<User> users = [SELECT Id, Name FROM User WHERE Name IN ('Andrew Moore', 'Bradley Sofonia', 'Brooke Ianni', 'Elizabeth Kagele', 'Rachyll Tenny', 'Tim Denton', 'Van Hess')];
System.debug('\n=== SF Sales Manager User.Names ===');
for (User u : users) {
    System.debug(u.Name + ' (' + u.Id + ')');
}
