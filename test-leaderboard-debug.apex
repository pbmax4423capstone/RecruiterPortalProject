List<InterviewLeaderboardNewController.LeaderboardEntry> results = InterviewLeaderboardNewController.getCurrentMonthLeaderboard();
System.debug('Number of entries: ' + results.size());
for (InterviewLeaderboardNewController.LeaderboardEntry entry : results) {
    System.debug('User: ' + entry.userName + ', Total: ' + entry.totalInterviews);
}
