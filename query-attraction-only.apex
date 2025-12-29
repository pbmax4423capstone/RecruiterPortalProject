// Query ONLY Interview_Type__c = 'Attraction' (CI-First)
List<AggregateResult> thisWeek = [
    SELECT Conducted_By__r.Name conductorName, COUNT(Id) cnt
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_WEEK
    AND Interview_Type__c = 'Attraction'
    GROUP BY Conducted_By__r.Name
    ORDER BY COUNT(Id) DESC
];

System.debug('=== ATTRACTION (CI-FIRST) THIS WEEK ===');
Integer total = 0;
for (AggregateResult ar : thisWeek) {
    String name = (String)ar.get('conductorName');
    Integer count = (Integer)ar.get('cnt');
    total += count;
    System.debug(name + ': ' + count);
}
System.debug('TOTAL THIS WEEK: ' + total);

// Query THIS MONTH
List<AggregateResult> thisMonth = [
    SELECT Conducted_By__r.Name conductorName, COUNT(Id) cnt
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_MONTH
    AND Interview_Type__c = 'Attraction'
    AND Conducted_By__c != null
    GROUP BY Conducted_By__r.Name
    ORDER BY COUNT(Id) DESC
];

System.debug('\n=== ATTRACTION (CI-FIRST) THIS MONTH ===');
total = 0;
for (AggregateResult ar : thisMonth) {
    String name = (String)ar.get('conductorName');
    Integer count = (Integer)ar.get('cnt');
    total += count;
    System.debug(name + ': ' + count);
}
System.debug('TOTAL THIS MONTH (with conductors): ' + total);

// Total including NULL
Integer totalWithNull = [SELECT COUNT() FROM Interview__c 
                         WHERE Date_Time_Scheduled__c = THIS_MONTH
                         AND Interview_Type__c = 'Attraction'];
System.debug('TOTAL THIS MONTH (including NULL): ' + totalWithNull);
