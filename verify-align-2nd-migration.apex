// Verification query: Align-2nd interviews from Interview object
// Compare with original SI1 data from Candidate object

System.debug('=== ALIGN-2ND MIGRATION VERIFICATION ===');
System.debug('');

// Get date ranges for comparison
Date thisWeekStart = Date.today().toStartOfWeek();
Date thisWeekEnd = thisWeekStart.addDays(6);
Date thisMonthStart = Date.newInstance(Date.today().year(), Date.today().month(), 1);
Date thisMonthEnd = Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));

System.debug('Date Ranges:');
System.debug('This Week: ' + thisWeekStart + ' to ' + thisWeekEnd);
System.debug('This Month: ' + thisMonthStart + ' to ' + thisMonthEnd);
System.debug('');

// Query ALL Align-2nd interviews
List<Interview__c> alignInterviews = [
    SELECT Id, Candidate__c, Interview_Type__c, 
           Date_Time_Scheduled__c, Conducted_By__r.Name,
           External_Id__c
    FROM Interview__c
    WHERE Interview_Type__c = 'Align-2nd'
    ORDER BY Date_Time_Scheduled__c DESC
];

System.debug('TOTAL ALIGN-2ND INTERVIEWS: ' + alignInterviews.size());
System.debug('');

// Count by week
Integer thisWeekCount = 0;
for (Interview__c interview : alignInterviews) {
    if (interview.Date_Time_Scheduled__c != null) {
        Date schedDate = interview.Date_Time_Scheduled__c.date();
        if (schedDate >= thisWeekStart && schedDate <= thisWeekEnd) {
            thisWeekCount++;
        }
    }
}

// Count by month
Integer thisMonthCount = 0;
for (Interview__c interview : alignInterviews) {
    if (interview.Date_Time_Scheduled__c != null) {
        Date schedDate = interview.Date_Time_Scheduled__c.date();
        if (schedDate >= thisMonthStart && schedDate <= thisMonthEnd) {
            thisMonthCount++;
        }
    }
}

System.debug('THIS WEEK (Nov 16-22, 2025): ' + thisWeekCount);
System.debug('THIS MONTH (Nov 1-30, 2025): ' + thisMonthCount);
System.debug('');

// Group November 2025 by conductor
Map<String, Integer> novemberConductorCount = new Map<String, Integer>();
List<Interview__c> novemberInterviews = new List<Interview__c>();

for (Interview__c interview : alignInterviews) {
    if (interview.Date_Time_Scheduled__c != null) {
        Date schedDate = interview.Date_Time_Scheduled__c.date();
        if (schedDate >= Date.newInstance(2025, 11, 1) && 
            schedDate <= Date.newInstance(2025, 11, 30)) {
            
            novemberInterviews.add(interview);
            
            String conductor = 'Unknown';
            if (interview.Conducted_By__r != null && String.isNotBlank(interview.Conducted_By__r.Name)) {
                conductor = interview.Conducted_By__r.Name;
            }
            
            if (!novemberConductorCount.containsKey(conductor)) {
                novemberConductorCount.put(conductor, 0);
            }
            novemberConductorCount.put(conductor, novemberConductorCount.get(conductor) + 1);
        }
    }
}

System.debug('=== NOVEMBER 2025 ALIGN-2ND BREAKDOWN ===');
System.debug('Total November Interviews: ' + novemberInterviews.size());
System.debug('');

System.debug('By Conductor:');
for (String conductor : novemberConductorCount.keySet()) {
    System.debug(conductor + ': ' + novemberConductorCount.get(conductor));
}
System.debug('');

// Show first 20 November interviews
System.debug('=== FIRST 20 NOVEMBER 2025 INTERVIEWS ===');
Integer displayCount = 0;
for (Interview__c interview : novemberInterviews) {
    if (displayCount >= 20) break;
    
    String conductor = 'Unknown';
    if (interview.Conducted_By__r != null && String.isNotBlank(interview.Conducted_By__r.Name)) {
        conductor = interview.Conducted_By__r.Name;
    }
    
    System.debug('Date: ' + interview.Date_Time_Scheduled__c + ' | Conductor: ' + conductor + ' | External ID: ' + interview.External_Id__c);
    displayCount++;
}
