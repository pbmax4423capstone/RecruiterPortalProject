// Test that Interview Type picklist now recognizes new values
// Query for interviews with new picklist values
List<Interview__c> newInterviews = [
    SELECT Id, Name, Interview_Type__c, Conducted_By__r.Name, Date_Time_Scheduled__c
    FROM Interview__c
    WHERE Interview_Type__c IN ('Ci-First', 'Align-2nd', 'Plan-3rd', 'Present-4th', 'Optional-5th')
    LIMIT 10
];

System.debug('=== INTERVIEWS WITH NEW PICKLIST VALUES ===');
System.debug('Total found: ' + newInterviews.size());
for (Interview__c i : newInterviews) {
    System.debug('Interview: ' + i.Name + ' | Type: ' + i.Interview_Type__c + ' | Conducted By: ' + i.Conducted_By__r.Name);
}

// Query for interviews with old picklist values (if any remain)
List<Interview__c> oldInterviews = [
    SELECT Id, Name, Interview_Type__c, Conducted_By__r.Name, Date_Time_Scheduled__c
    FROM Interview__c
    WHERE Interview_Type__c IN ('Attraction', 'SI1', 'SI2', 'SI3', 'Career')
    LIMIT 10
];

System.debug('\n=== INTERVIEWS WITH OLD PICKLIST VALUES ===');
System.debug('Total found: ' + oldInterviews.size());
for (Interview__c i : oldInterviews) {
    System.debug('Interview: ' + i.Name + ' | Type: ' + i.Interview_Type__c + ' | Conducted By: ' + i.Conducted_By__r.Name);
}

// Test the leaderboard with current data
System.debug('\n=== TESTING LEADERBOARD CONTROLLER ===');
try {
    List<InterviewLeaderboardNewController.LeaderboardEntry> leaderboard = InterviewLeaderboardNewController.getCurrentMonthLeaderboard();
    System.debug('Leaderboard entries: ' + leaderboard.size());
    for (InterviewLeaderboardNewController.LeaderboardEntry entry : leaderboard) {
        System.debug('Recruiter: ' + entry.userName);
        System.debug('  CI-First: ' + entry.ciFirstCount);
        System.debug('  Align-2nd: ' + entry.alignSecondCount);
        System.debug('  Plan-3rd: ' + entry.planThirdCount);
        System.debug('  Present-4th: ' + entry.presentFourthCount);
        System.debug('  Optional-5th: ' + entry.optionalFifthCount);
        System.debug('  Total: ' + entry.totalInterviews);
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
