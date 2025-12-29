// Check what the leaderboard query is actually returning
List<AggregateResult> results = [
    SELECT 
        Conducted_By__c conductedBy,
        Conducted_By__r.Name userName,
        Interview_Type__c interviewType,
        COUNT(Id) interviewCount
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_MONTH
    GROUP BY Conducted_By__c, Conducted_By__r.Name, Interview_Type__c
    ORDER BY COUNT(Id) DESC
    LIMIT 10
];

System.debug('=== Top 10 Aggregate Results ===');
for (AggregateResult ar : results) {
    System.debug('Conductor: ' + ar.get('userName') + 
                 ', Type: ' + ar.get('interviewType') + 
                 ', Count: ' + ar.get('interviewCount'));
}

// Check total by Conducted_By
List<AggregateResult> byUser = [
    SELECT 
        Conducted_By__r.Name userName,
        COUNT(Id) cnt
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_MONTH
    AND Conducted_By__c != null
    GROUP BY Conducted_By__r.Name
    ORDER BY COUNT(Id) DESC
];

System.debug('\n=== By User (non-null only) ===');
for (AggregateResult ar : byUser) {
    System.debug(ar.get('userName') + ': ' + ar.get('cnt'));
}
