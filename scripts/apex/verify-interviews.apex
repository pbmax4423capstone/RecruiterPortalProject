// Check interview distribution by type and conductor
List<AggregateResult> interviewStats = [
    SELECT Interview_Type__c, Conducted_By__r.Name, COUNT(Id) total
    FROM Interview__c 
    WHERE Conducted_By__c != null
    GROUP BY Interview_Type__c, Conducted_By__r.Name
    ORDER BY Interview_Type__c, Conducted_By__r.Name
];

System.debug('Interview Distribution:');
for (AggregateResult ar : interviewStats) {
    System.debug(ar.get('Interview_Type__c') + ' - ' + ar.get('Name') + ': ' + ar.get('total'));
}

// Also get total count by type
List<AggregateResult> typeStats = [
    SELECT Interview_Type__c, COUNT(Id) total
    FROM Interview__c 
    GROUP BY Interview_Type__c
    ORDER BY Interview_Type__c
];

System.debug('\nTotal by Type:');
for (AggregateResult ar : typeStats) {
    System.debug(ar.get('Interview_Type__c') + ': ' + ar.get('total'));
}