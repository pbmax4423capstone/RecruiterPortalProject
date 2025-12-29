// Check date distribution of Interview__c records
List<AggregateResult> byMonth = [
    SELECT CALENDAR_MONTH(Date_Time_Scheduled__c) month, 
           CALENDAR_YEAR(Date_Time_Scheduled__c) year,
           COUNT(Id) cnt
    FROM Interview__c
    GROUP BY CALENDAR_YEAR(Date_Time_Scheduled__c), CALENDAR_MONTH(Date_Time_Scheduled__c)
    ORDER BY CALENDAR_YEAR(Date_Time_Scheduled__c) DESC, CALENDAR_MONTH(Date_Time_Scheduled__c) DESC
    LIMIT 20
];

System.debug('=== Interview__c Records by Month/Year ===');
for (AggregateResult ar : byMonth) {
    System.debug('Year: ' + ar.get('year') + ', Month: ' + ar.get('month') + ', Count: ' + ar.get('cnt'));
}

// Check November 2025 specifically
Integer nov2025 = [SELECT COUNT() FROM Interview__c 
                   WHERE CALENDAR_YEAR(Date_Time_Scheduled__c) = 2025 
                   AND CALENDAR_MONTH(Date_Time_Scheduled__c) = 11];
System.debug('\nNovember 2025 count: ' + nov2025);

// Check what THIS_MONTH returns (should be November 2025)
Integer thisMonth = [SELECT COUNT() FROM Interview__c WHERE Date_Time_Scheduled__c = THIS_MONTH];
System.debug('THIS_MONTH count: ' + thisMonth);
