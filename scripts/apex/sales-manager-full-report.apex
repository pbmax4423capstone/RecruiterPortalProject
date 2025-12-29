// Comprehensive Sales Manager/Recruiter Report

System.debug('===== SALES MANAGER / RECRUITER COMPREHENSIVE REPORT =====\n');

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
System.debug('Report Date: ' + System.today() + '\n');
System.debug('NAME                      ACTIVE   TOTAL   INT/MO  CALL/WK CALL/MO CALL/YR SUCCESS%');
System.debug('----------------------------------------------------------------------------------------');

Integer totalActiveCandidates = 0;
Integer totalCandidates = 0;
Integer totalInterviews = 0;
Integer totalCallsWeek = 0;
Integer totalCallsMonth = 0;
Integer totalCallsYear = 0;

for (User manager : salesManagers) {
    // Get candidates assigned to this manager
    Integer activeCandidates = [
        SELECT COUNT() 
        FROM Candidate__c 
        WHERE OwnerId = :manager.Id 
        AND Status__c = 'Active/In Process'
    ];
    
    Integer totalCands = [
        SELECT COUNT() 
        FROM Candidate__c 
        WHERE OwnerId = :manager.Id
    ];
    
    // Count completed interviews this month for this manager's candidates
    // CIT (1st) interviews
    Integer citMonth = [
        SELECT COUNT()
        FROM Candidate__c
        WHERE OwnerId = :manager.Id
        AND (AI_Completed_Date_Time__c = THIS_MONTH OR Attraction_Interview_Date_Completed__c = THIS_MONTH)
    ];
    
    // Align (2nd) interviews
    Integer alignMonth = [
        SELECT COUNT()
        FROM Candidate__c
        WHERE OwnerId = :manager.Id
        AND SI_1_Date_Completed__c = THIS_MONTH
    ];
    
    // Plan (3rd) interviews
    Integer planMonth = [
        SELECT COUNT()
        FROM Candidate__c
        WHERE OwnerId = :manager.Id
        AND SI_2_Date_Completed__c = THIS_MONTH
    ];
    
    // Present (4th) interviews
    Integer presentMonth = [
        SELECT COUNT()
        FROM Candidate__c
        WHERE OwnerId = :manager.Id
        AND SI_3_Completed__c = THIS_MONTH
    ];
    
    // Optional (5th) interviews
    Integer optionalMonth = [
        SELECT COUNT()
        FROM Candidate__c
        WHERE OwnerId = :manager.Id
        AND Career_Presentation_Date_Completed__c = THIS_MONTH
    ];
    
    Integer interviewsMonth = citMonth + alignMonth + planMonth + presentMonth + optionalMonth;
    
    // Get call counts for this manager
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
    
    // Calculate success rate
    Decimal successRate = totalCands > 0 ? (activeCandidates * 100.0 / totalCands) : 0;
    
    // Accumulate totals
    totalActiveCandidates += activeCandidates;
    totalCandidates += totalCands;
    totalInterviews += interviewsMonth;
    totalCallsWeek += callsWeek;
    totalCallsMonth += callsMonth;
    totalCallsYear += callsYear;
    
    // Display row
    String managerName = manager.Name;
    if (managerName.length() > 24) {
        managerName = managerName.substring(0, 21) + '...';
    }
    
    // Pad name to 25 characters
    while (managerName.length() < 25) {
        managerName += ' ';
    }
    
    System.debug(managerName + 
        String.valueOf(activeCandidates).leftPad(8) + 
        String.valueOf(totalCands).leftPad(8) + 
        String.valueOf(interviewsMonth).leftPad(8) + 
        String.valueOf(callsWeek).leftPad(8) + 
        String.valueOf(callsMonth).leftPad(8) + 
        String.valueOf(callsYear).leftPad(8) + 
        String.valueOf(successRate.setScale(1)).leftPad(7) + '%');
}

System.debug('----------------------------------------------------------------------------------------');
Decimal overallSuccessRate = totalCandidates > 0 ? (totalActiveCandidates * 100.0 / totalCandidates) : 0;
String totalsLine = 'TOTALS                   ';
totalsLine += String.valueOf(totalActiveCandidates).leftPad(8);
totalsLine += String.valueOf(totalCandidates).leftPad(8);
totalsLine += String.valueOf(totalInterviews).leftPad(8);
totalsLine += String.valueOf(totalCallsWeek).leftPad(8);
totalsLine += String.valueOf(totalCallsMonth).leftPad(8);
totalsLine += String.valueOf(totalCallsYear).leftPad(8);
totalsLine += String.valueOf(overallSuccessRate.setScale(1)).leftPad(7) + '%';
System.debug(totalsLine);

System.debug('\n\n===== DETAILED BREAKDOWN BY MANAGER =====\n');

for (User manager : salesManagers) {
    System.debug('==== ' + manager.Name + ' (' + manager.Profile.Name + ') ====');
    
    // Candidates
    Integer activeCandidates = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND Status__c = 'Active/In Process'];
    Integer totalCands = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id];
    System.debug('  Candidates: ' + activeCandidates + ' Active / ' + totalCands + ' Total');
    
    // Interviews - count all completed interviews across all types
    // This Week
    Integer citW = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND (AI_Completed_Date_Time__c = THIS_WEEK OR Attraction_Interview_Date_Completed__c = THIS_WEEK)];
    Integer alignW = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_1_Date_Completed__c = THIS_WEEK];
    Integer planW = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_2_Date_Completed__c = THIS_WEEK];
    Integer presentW = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_3_Completed__c = THIS_WEEK];
    Integer optionalW = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND Career_Presentation_Date_Completed__c = THIS_WEEK];
    Integer intWeek = citW + alignW + planW + presentW + optionalW;
    
    // This Month
    Integer citM = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND (AI_Completed_Date_Time__c = THIS_MONTH OR Attraction_Interview_Date_Completed__c = THIS_MONTH)];
    Integer alignM = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_1_Date_Completed__c = THIS_MONTH];
    Integer planM = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_2_Date_Completed__c = THIS_MONTH];
    Integer presentM = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_3_Completed__c = THIS_MONTH];
    Integer optionalM = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND Career_Presentation_Date_Completed__c = THIS_MONTH];
    Integer intMonth = citM + alignM + planM + presentM + optionalM;
    
    // This Year
    Integer citY = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND (AI_Completed_Date_Time__c = THIS_YEAR OR Attraction_Interview_Date_Completed__c = THIS_YEAR)];
    Integer alignY = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_1_Date_Completed__c = THIS_YEAR];
    Integer planY = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_2_Date_Completed__c = THIS_YEAR];
    Integer presentY = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_3_Completed__c = THIS_YEAR];
    Integer optionalY = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND Career_Presentation_Date_Completed__c = THIS_YEAR];
    Integer intYear = citY + alignY + planY + presentY + optionalY;
    
    System.debug('  Interviews: ' + intWeek + ' This Week, ' + intMonth + ' This Month, ' + intYear + ' This Year');
    System.debug('    - CIT (1st): ' + citW + ' / ' + citM + ' / ' + citY + '  |  Align (2nd): ' + alignW + ' / ' + alignM + ' / ' + alignY);
    System.debug('    - Plan (3rd): ' + planW + ' / ' + planM + ' / ' + planY + '  |  Present (4th): ' + presentW + ' / ' + presentM + ' / ' + presentY);
    System.debug('    - Optional (5th): ' + optionalW + ' / ' + optionalM + ' / ' + optionalY);
    
    // Calls
    Integer callsWeek = [SELECT COUNT() FROM Task WHERE OwnerId = :manager.Id AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND ActivityDate = THIS_WEEK];
    Integer callsMonth = [SELECT COUNT() FROM Task WHERE OwnerId = :manager.Id AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND ActivityDate = THIS_MONTH];
    Integer callsYear = [SELECT COUNT() FROM Task WHERE OwnerId = :manager.Id AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND ActivityDate = THIS_YEAR];
    System.debug('  Calls: ' + callsWeek + ' This Week, ' + callsMonth + ' This Month, ' + callsYear + ' This Year');
    
    // Success Rate
    Decimal successRate = totalCands > 0 ? (activeCandidates * 100.0 / totalCands) : 0;
    System.debug('  Success Rate: ' + successRate.setScale(1) + '%');
    System.debug('');
}
