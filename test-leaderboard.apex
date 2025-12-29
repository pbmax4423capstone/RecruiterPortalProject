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
