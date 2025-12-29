// Test the controller directly
try {
    List<InterviewLeaderboardNewController.LeaderboardEntry> results = 
        InterviewLeaderboardNewController.getCurrentMonthLeaderboard();
    
    System.debug('Success! Results count: ' + results.size());
    for (InterviewLeaderboardNewController.LeaderboardEntry entry : results) {
        System.debug(entry.userName + ': ' + entry.totalInterviews + ' interviews');
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
}
