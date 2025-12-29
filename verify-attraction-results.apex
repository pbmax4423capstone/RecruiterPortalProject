// Query Interview__c records for THIS WEEK
List<AggregateResult> thisWeek = [
    SELECT Conducted_By__r.Name conductorName, COUNT(Id) cnt
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_WEEK
    AND Interview_Type__c = 'Attraction'
    GROUP BY Conducted_By__r.Name
    ORDER BY COUNT(Id) DESC
];

System.debug('=== THIS WEEK (Nov 17-20) ===');
Integer total = 0;
for (AggregateResult ar : thisWeek) {
    String name = (String)ar.get('conductorName');
    Integer count = (Integer)ar.get('cnt');
    total += count;
    System.debug(name + ': ' + count);
}
System.debug('TOTAL THIS WEEK: ' + total);

// Query Interview__c records for THIS MONTH
List<AggregateResult> thisMonth = [
    SELECT Conducted_By__r.Name conductorName, COUNT(Id) cnt
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_MONTH
    AND Interview_Type__c = 'Attraction'
    GROUP BY Conducted_By__r.Name
    ORDER BY COUNT(Id) DESC
];

System.debug('\\n=== THIS MONTH (November) ===');
total = 0;
for (AggregateResult ar : thisMonth) {
    String name = (String)ar.get('conductorName');
    Integer count = (Integer)ar.get('cnt');
    total += count;
    System.debug(name + ': ' + count);
}
System.debug('TOTAL THIS MONTH: ' + total);

// Check for NULL conductors
Integer nullCount = [SELECT COUNT() FROM Interview__c WHERE Conducted_By__c = null AND Interview_Type__c = 'Attraction'];
System.debug('\\nAttr interviews with NULL conductor: ' + nullCount);
