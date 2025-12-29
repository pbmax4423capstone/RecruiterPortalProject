// Query CI-First interviews (Attraction OR SI1) from Interview__c
List<AggregateResult> thisWeek = [
    SELECT Conducted_By__r.Name conductorName, COUNT(Id) cnt
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_WEEK
    AND (Interview_Type__c = 'Attraction' OR Interview_Type__c = 'SI1')
    GROUP BY Conducted_By__r.Name
    ORDER BY COUNT(Id) DESC
];

System.debug('=== CI-FIRST THIS WEEK ===');
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
    AND (Interview_Type__c = 'Attraction' OR Interview_Type__c = 'SI1')
    GROUP BY Conducted_By__r.Name
    ORDER BY COUNT(Id) DESC
];

System.debug('\n=== CI-FIRST THIS MONTH ===');
total = 0;
for (AggregateResult ar : thisMonth) {
    String name = (String)ar.get('conductorName');
    Integer count = (Integer)ar.get('cnt');
    total += count;
    System.debug(name + ': ' + count);
}
System.debug('TOTAL THIS MONTH: ' + total);

// Check NULL
Integer nullCount = [SELECT COUNT() FROM Interview__c 
                     WHERE Conducted_By__c = null 
                     AND Date_Time_Scheduled__c = THIS_MONTH
                     AND (Interview_Type__c = 'Attraction' OR Interview_Type__c = 'SI1')];
System.debug('\nNULL conductors THIS MONTH: ' + nullCount);
