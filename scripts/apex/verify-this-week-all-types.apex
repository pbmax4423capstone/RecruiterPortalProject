// Verify ALL interview types for THIS_WEEK (Nov 17-23, 2025)

List<Interview__c> thisWeekInterviews = [
    SELECT Id, 
           Candidate__r.Name,
           Interview_Type__c,
           Interviewer_s__c,
           Date_Time_Scheduled__c
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_WEEK
    ORDER BY Interview_Type__c, Date_Time_Scheduled__c DESC
];

System.debug('=== ALL INTERVIEWS THIS WEEK (Nov 17-23, 2025) ===');
System.debug('Total Count: ' + thisWeekInterviews.size());
System.debug('');

// Group by type
Map<String, List<Interview__c>> byType = new Map<String, List<Interview__c>>();
for (Interview__c interview : thisWeekInterviews) {
    String type = interview.Interview_Type__c != null ? interview.Interview_Type__c : 'NULL';
    if (!byType.containsKey(type)) {
        byType.put(type, new List<Interview__c>());
    }
    byType.get(type).add(interview);
}

// Print by type
for (String type : byType.keySet()) {
    List<Interview__c> typeInterviews = byType.get(type);
    System.debug('');
    System.debug('--- ' + type + ' ---');
    System.debug('Count: ' + typeInterviews.size());
    System.debug('');
    
    for (Interview__c interview : typeInterviews) {
        String interviewers = String.isNotBlank(interview.Interviewer_s__c) ? 
            interview.Interviewer_s__c : 'Unassigned';
        System.debug(String.format('  • {0} | {1} | {2}',
            new List<String>{
                interview.Date_Time_Scheduled__c.format('MMM d, yyyy h:mm a'),
                interview.Candidate__r.Name,
                interviewers
            }
        ));
    }
}

System.debug('');
System.debug('=== SUMMARY ===');
for (String type : byType.keySet()) {
    System.debug(type + ': ' + byType.get(type).size());
}
System.debug('TOTAL: ' + thisWeekInterviews.size());
