List<Interview__c> interviews = [
    SELECT Id, Name, Interview_Status__c, Date_Completed__c,
           Interview_Type__c, Interviewer_s__c
    FROM Interview__c
    WHERE Date_Completed__c = THIS_MONTH
    AND Interview_Status__c = 'Completed'
    AND Interview_Type__c != null
];
System.debug('Total completed interviews this month: ' + interviews.size());

try {
    List<InterviewLeaderboardNewController.LeaderboardEntry> results =
        InterviewLeaderboardNewController.getCurrentMonthLeaderboard();
    System.debug('Success! Results count: ' + results.size());
    for (InterviewLeaderboardNewController.LeaderboardEntry entry : results) {
        System.debug('User: ' + entry.userName + ', Total: ' + entry.totalInterviews);
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Type: ' + e.getTypeName());
    System.debug('Line: ' + e.getLineNumber());
    System.debug('Stack: ' + e.getStackTraceString());
}
