// November 2025 Align-2nd Interview Report
// Display interviews by week and month, broken down by sales manager

System.debug('=== NOVEMBER 2025 ALIGN-2ND INTERVIEW REPORT ===');
System.debug('');

// Get date ranges
Date thisWeekStart = Date.today().toStartOfWeek();
Date thisWeekEnd = thisWeekStart.addDays(6);
Date thisMonthStart = Date.newInstance(2025, 11, 1);
Date thisMonthEnd = Date.newInstance(2025, 11, 30);

System.debug('Report Date: November 20, 2025');
System.debug('This Week: ' + thisWeekStart.format() + ' to ' + thisWeekEnd.format());
System.debug('This Month: ' + thisMonthStart.format() + ' to ' + thisMonthEnd.format());
System.debug('');

// Query all Align-2nd interviews for November
List<Interview__c> alignInterviews = [
    SELECT Id, Candidate__r.Name, Interview_Type__c, 
           Date_Time_Scheduled__c, Interviewer_s__c
    FROM Interview__c
    WHERE Interview_Type__c = 'Align-2nd'
    AND Date_Time_Scheduled__c >= 2025-11-01T00:00:00Z
    AND Date_Time_Scheduled__c <= 2025-11-30T23:59:59Z
    ORDER BY Date_Time_Scheduled__c DESC
];

// Count by week and month
Map<String, Integer> weekConductorCount = new Map<String, Integer>();
Map<String, Integer> monthConductorCount = new Map<String, Integer>();

Integer thisWeekTotal = 0;
Integer thisMonthTotal = 0;

for (Interview__c interview : alignInterviews) {
    Date schedDate = interview.Date_Time_Scheduled__c.date();
    String conductor = interview.Interviewer_s__c != null ? interview.Interviewer_s__c : 'Unknown';
    
    // Count for month
    thisMonthTotal++;
    if (!monthConductorCount.containsKey(conductor)) {
        monthConductorCount.put(conductor, 0);
    }
    monthConductorCount.put(conductor, monthConductorCount.get(conductor) + 1);
    
    // Count for week
    if (schedDate >= thisWeekStart && schedDate <= thisWeekEnd) {
        thisWeekTotal++;
        if (!weekConductorCount.containsKey(conductor)) {
            weekConductorCount.put(conductor, 0);
        }
        weekConductorCount.put(conductor, weekConductorCount.get(conductor) + 1);
    }
}

System.debug('=== THIS WEEK (Nov 16-22, 2025) ===');
System.debug('Total Align-2nd Interviews: ' + thisWeekTotal);
System.debug('');
System.debug('By Sales Manager:');
for (String conductor : weekConductorCount.keySet()) {
    System.debug('  ' + conductor + ': ' + weekConductorCount.get(conductor));
}

System.debug('');
System.debug('=== THIS MONTH (November 2025) ===');
System.debug('Total Align-2nd Interviews: ' + thisMonthTotal);
System.debug('');
System.debug('By Sales Manager:');
for (String conductor : monthConductorCount.keySet()) {
    System.debug('  ' + conductor + ': ' + monthConductorCount.get(conductor));
}

System.debug('');
System.debug('=== ALL NOVEMBER INTERVIEWS (Detail) ===');
for (Interview__c interview : alignInterviews) {
    String conductor = interview.Interviewer_s__c != null ? interview.Interviewer_s__c : 'Unknown';
    System.debug(interview.Date_Time_Scheduled__c.format('yyyy-MM-dd') + ' | ' + 
                 conductor + ' | ' + interview.Candidate__r.Name);
}
