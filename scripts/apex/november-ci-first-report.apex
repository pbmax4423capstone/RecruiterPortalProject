// Report: Ci-First Interviews for November 2025
// Purpose: Compare with hover modal showing "THIS_WEEK" interviews

List<Interview__c> novemberInterviews = [
    SELECT Id, 
           Candidate__r.Name,
           Interview_Type__c,
           Interviewer_s__c,
           Date_Time_Scheduled__c
    FROM Interview__c
    WHERE Interview_Type__c = 'Ci-First'
    AND Date_Time_Scheduled__c >= 2025-11-01T00:00:00Z
    AND Date_Time_Scheduled__c < 2025-12-01T00:00:00Z
    ORDER BY Date_Time_Scheduled__c DESC
];

System.debug('=== CI-FIRST INTERVIEWS FOR NOVEMBER 2025 ===');
System.debug('Total Count: ' + novemberInterviews.size());
System.debug('');

// Group by week for comparison
Map<String, List<Interview__c>> byWeek = new Map<String, List<Interview__c>>();
for (Interview__c interview : novemberInterviews) {
    DateTime dt = interview.Date_Time_Scheduled__c;
    String weekKey;
    
    // November 2025 week boundaries
    if (dt >= DateTime.newInstance(2025, 11, 1) && dt < DateTime.newInstance(2025, 11, 3)) {
        weekKey = 'Week 1 (Nov 1-2)';
    } else if (dt >= DateTime.newInstance(2025, 11, 3) && dt < DateTime.newInstance(2025, 11, 10)) {
        weekKey = 'Week 2 (Nov 3-9)';
    } else if (dt >= DateTime.newInstance(2025, 11, 10) && dt < DateTime.newInstance(2025, 11, 17)) {
        weekKey = 'Week 3 (Nov 10-16)';
    } else if (dt >= DateTime.newInstance(2025, 11, 17) && dt < DateTime.newInstance(2025, 11, 24)) {
        weekKey = 'Week 4 (Nov 17-23) - CURRENT WEEK';
    } else if (dt >= DateTime.newInstance(2025, 11, 24) && dt < DateTime.newInstance(2025, 12, 1)) {
        weekKey = 'Week 5 (Nov 24-30)';
    } else {
        weekKey = 'Other';
    }
    
    if (!byWeek.containsKey(weekKey)) {
        byWeek.put(weekKey, new List<Interview__c>());
    }
    byWeek.get(weekKey).add(interview);
}

// Print by week
List<String> weekOrder = new List<String>{
    'Week 1 (Nov 1-2)',
    'Week 2 (Nov 3-9)',
    'Week 3 (Nov 10-16)',
    'Week 4 (Nov 17-23) - CURRENT WEEK',
    'Week 5 (Nov 24-30)',
    'Other'
};

for (String week : weekOrder) {
    if (byWeek.containsKey(week)) {
        List<Interview__c> weekInterviews = byWeek.get(week);
        System.debug('');
        System.debug('--- ' + week + ' ---');
        System.debug('Count: ' + weekInterviews.size());
        System.debug('');
        
        for (Interview__c interview : weekInterviews) {
            String interviewers = String.isNotBlank(interview.Interviewer_s__c) ? 
                interview.Interviewer_s__c : 'Unassigned';
            System.debug(String.format('  • {0} | {1} | {2} | {3}',
                new List<String>{
                    interview.Date_Time_Scheduled__c.format('MMM d, yyyy h:mm a'),
                    interview.Candidate__r.Name,
                    interview.Interview_Type__c,
                    interviewers
                }
            ));
        }
    }
}

System.debug('');
System.debug('=== END REPORT ===');
