// Query and report Align-2nd interviews breakdown by sales manager
// THIS WEEK and THIS MONTH

// Get date ranges
Date today = Date.today();
Date weekStart = today.toStartOfWeek();
Date weekEnd = weekStart.addDays(6);
Date monthStart = Date.newInstance(today.year(), today.month(), 1);
Date monthEnd = monthStart.addMonths(1).addDays(-1);

System.debug('=== DATE RANGES ===');
System.debug('This Week: ' + weekStart + ' to ' + weekEnd);
System.debug('This Month: ' + monthStart + ' to ' + monthEnd);

// Query THIS MONTH Align-2nd interviews grouped by Conducted_By
System.debug('\n=== ALIGN-2ND INTERVIEWS THIS MONTH (by Sales Manager) ===');
List<AggregateResult> monthResults = [
    SELECT 
        Conducted_By__c conductedBy,
        Conducted_By__r.Name conductedByName,
        COUNT(Id) interviewCount
    FROM Interview__c
    WHERE Interview_Type__c = 'Align-2nd'
    AND Date_Time_Scheduled__c >= :monthStart
    AND Date_Time_Scheduled__c <= :monthEnd
    AND Conducted_By__c != null
    GROUP BY Conducted_By__c, Conducted_By__r.Name
    ORDER BY COUNT(Id) DESC
];

Integer monthTotal = 0;
for (AggregateResult ar : monthResults) {
    String conductedByName = (String)ar.get('conductedByName');
    Integer count = (Integer)ar.get('interviewCount');
    monthTotal += count;
    System.debug(conductedByName + ': ' + count + ' interviews');
}
System.debug('TOTAL THIS MONTH: ' + monthTotal);

// Query THIS WEEK Align-2nd interviews grouped by Conducted_By
System.debug('\n=== ALIGN-2ND INTERVIEWS THIS WEEK (by Sales Manager) ===');
List<AggregateResult> weekResults = [
    SELECT 
        Conducted_By__c conductedBy,
        Conducted_By__r.Name conductedByName,
        COUNT(Id) interviewCount
    FROM Interview__c
    WHERE Interview_Type__c = 'Align-2nd'
    AND Date_Time_Scheduled__c >= :weekStart
    AND Date_Time_Scheduled__c <= :weekEnd
    AND Conducted_By__c != null
    GROUP BY Conducted_By__c, Conducted_By__r.Name
    ORDER BY COUNT(Id) DESC
];

Integer weekTotal = 0;
for (AggregateResult ar : weekResults) {
    String conductedByName = (String)ar.get('conductedByName');
    Integer count = (Integer)ar.get('interviewCount');
    weekTotal += count;
    System.debug(conductedByName + ': ' + count + ' interviews');
}
System.debug('TOTAL THIS WEEK: ' + weekTotal);

// Show sample Align-2nd interviews for verification
System.debug('\n=== SAMPLE ALIGN-2ND INTERVIEWS (First 10) ===');
List<Interview__c> sampleInterviews = [
    SELECT Id, Name, Interview_Type__c, Conducted_By__r.Name, Date_Time_Scheduled__c
    FROM Interview__c
    WHERE Interview_Type__c = 'Align-2nd'
    AND Date_Time_Scheduled__c >= :monthStart
    AND Date_Time_Scheduled__c <= :monthEnd
    ORDER BY Date_Time_Scheduled__c DESC
    LIMIT 10
];

for (Interview__c i : sampleInterviews) {
    System.debug('Interview: ' + i.Name + ' | Conducted By: ' + i.Conducted_By__r.Name + ' | Date: ' + i.Date_Time_Scheduled__c);
}

// Compare with ALL Interview_Type values to show breakdown
System.debug('\n=== ALL INTERVIEW TYPES THIS MONTH (Summary) ===');
List<AggregateResult> allTypes = [
    SELECT 
        Interview_Type__c interviewType,
        COUNT(Id) interviewCount
    FROM Interview__c
    WHERE Date_Time_Scheduled__c >= :monthStart
    AND Date_Time_Scheduled__c <= :monthEnd
    GROUP BY Interview_Type__c
    ORDER BY COUNT(Id) DESC
];

for (AggregateResult ar : allTypes) {
    String type = (String)ar.get('interviewType');
    Integer count = (Integer)ar.get('interviewCount');
    System.debug(type + ': ' + count);
}
