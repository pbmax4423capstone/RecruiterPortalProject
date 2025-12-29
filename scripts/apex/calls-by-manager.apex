// Calls Logged by Sales Manager/Recruiter Report

System.debug('===== CALLS LOGGED BY SALES MANAGER/RECRUITER =====\n');

// Get all active users who are Sales Managers or Recruiters
List<User> salesManagers = [
    SELECT Id, Name, Profile.Name 
    FROM User 
    WHERE IsActive = true 
    AND (
        Profile.Name LIKE '%Sales%Manager%' OR 
        Profile.Name LIKE '%Recruiting%Manager%' OR 
        Profile.Name LIKE '%Recruiter%' OR
        Name LIKE '%Manager%'
    )
    ORDER BY Name
];

System.debug('Found ' + salesManagers.size() + ' Sales Managers/Recruiters\n');

for (User manager : salesManagers) {
    // Get call counts for this manager - using Subject containing 'Call' or TaskSubtype
    Integer callsWeek = [
        SELECT COUNT()
        FROM Task
        WHERE OwnerId = :manager.Id
        AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
        AND IsClosed = true
        AND ActivityDate = THIS_WEEK
    ];
    
    Integer callsMonth = [
        SELECT COUNT()
        FROM Task
        WHERE OwnerId = :manager.Id
        AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
        AND IsClosed = true
        AND ActivityDate = THIS_MONTH
    ];
    
    Integer callsYear = [
        SELECT COUNT()
        FROM Task
        WHERE OwnerId = :manager.Id
        AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
        AND IsClosed = true
        AND ActivityDate = THIS_YEAR
    ];
    
    // Only show users with calls
    if (callsWeek > 0 || callsMonth > 0 || callsYear > 0) {
        System.debug('==== ' + manager.Name + ' (' + manager.Profile.Name + ') ====');
        System.debug('  This Week:  ' + callsWeek);
        System.debug('  This Month: ' + callsMonth);
        System.debug('  This Year:  ' + callsYear);
        System.debug('');
    }
}

System.debug('\n===== TOTAL CALLS SUMMARY =====');
Integer totalWeek = [SELECT COUNT() FROM Task WHERE (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND ActivityDate = THIS_WEEK];
Integer totalMonth = [SELECT COUNT() FROM Task WHERE (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND ActivityDate = THIS_MONTH];
Integer totalYear = [SELECT COUNT() FROM Task WHERE (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND ActivityDate = THIS_YEAR];

System.debug('Total Calls This Week:  ' + totalWeek);
System.debug('Total Calls This Month: ' + totalMonth);
System.debug('Total Calls This Year:  ' + totalYear);
