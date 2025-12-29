// Comprehensive Sales Manager/Recruiter Report - Optimized

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

// Get all manager IDs
Set<Id> managerIds = new Set<Id>();
for (User mgr : salesManagers) {
    managerIds.add(mgr.Id);
}

// Build maps to store counts by manager
Map<Id, Integer> activeCandidatesMap = new Map<Id, Integer>();
Map<Id, Integer> totalCandidatesMap = new Map<Id, Integer>();
Map<Id, Integer> interviewsMonthMap = new Map<Id, Integer>();
Map<Id, Integer> callsWeekMap = new Map<Id, Integer>();
Map<Id, Integer> callsMonthMap = new Map<Id, Integer>();
Map<Id, Integer> callsYearMap = new Map<Id, Integer>();

// Initialize maps
for (Id mgrId : managerIds) {
    activeCandidatesMap.put(mgrId, 0);
    totalCandidatesMap.put(mgrId, 0);
    interviewsMonthMap.put(mgrId, 0);
    callsWeekMap.put(mgrId, 0);
    callsMonthMap.put(mgrId, 0);
    callsYearMap.put(mgrId, 0);
}

// Get all candidates for these managers
for (Candidate__c c : [SELECT OwnerId, Status__c, 
    AI_Completed_Date_Time__c, Attraction_Interview_Date_Completed__c,
    SI_1_Date_Completed__c, SI_2_Date_Completed__c, SI_3_Completed__c, Career_Presentation_Date_Completed__c
    FROM Candidate__c WHERE OwnerId IN :managerIds]) {
    
    // Total candidates
    totalCandidatesMap.put(c.OwnerId, totalCandidatesMap.get(c.OwnerId) + 1);
    
    // Active candidates
    if (c.Status__c == 'Active/In Process') {
        activeCandidatesMap.put(c.OwnerId, activeCandidatesMap.get(c.OwnerId) + 1);
    }
    
    // Interviews this month
    if ((c.AI_Completed_Date_Time__c != null && c.AI_Completed_Date_Time__c.date() >= Date.today().toStartOfMonth()) ||
        (c.Attraction_Interview_Date_Completed__c != null && c.Attraction_Interview_Date_Completed__c >= Date.today().toStartOfMonth())) {
        interviewsMonthMap.put(c.OwnerId, interviewsMonthMap.get(c.OwnerId) + 1);
    }
    if (c.SI_1_Date_Completed__c != null && c.SI_1_Date_Completed__c >= Date.today().toStartOfMonth()) {
        interviewsMonthMap.put(c.OwnerId, interviewsMonthMap.get(c.OwnerId) + 1);
    }
    if (c.SI_2_Date_Completed__c != null && c.SI_2_Date_Completed__c >= Date.today().toStartOfMonth()) {
        interviewsMonthMap.put(c.OwnerId, interviewsMonthMap.get(c.OwnerId) + 1);
    }
    if (c.SI_3_Completed__c != null && c.SI_3_Completed__c >= Date.today().toStartOfMonth()) {
        interviewsMonthMap.put(c.OwnerId, interviewsMonthMap.get(c.OwnerId) + 1);
    }
    if (c.Career_Presentation_Date_Completed__c != null && c.Career_Presentation_Date_Completed__c >= Date.today().toStartOfMonth()) {
        interviewsMonthMap.put(c.OwnerId, interviewsMonthMap.get(c.OwnerId) + 1);
    }
}

// Get call counts
Date startOfWeek = Date.today().toStartOfWeek();
Date startOfMonth = Date.today().toStartOfMonth();
Date startOfYear = Date.newInstance(Date.today().year(), 1, 1);

for (Task t : [SELECT OwnerId, ActivityDate FROM Task 
    WHERE OwnerId IN :managerIds 
    AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
    AND IsClosed = true
    AND ActivityDate >= :startOfYear]) {
    
    if (t.ActivityDate >= startOfWeek) {
        callsWeekMap.put(t.OwnerId, callsWeekMap.get(t.OwnerId) + 1);
    }
    if (t.ActivityDate >= startOfMonth) {
        callsMonthMap.put(t.OwnerId, callsMonthMap.get(t.OwnerId) + 1);
    }
    callsYearMap.put(t.OwnerId, callsYearMap.get(t.OwnerId) + 1);
}

// Display summary table
System.debug('NAME                      ACTIVE   TOTAL   INT/MO  CALL/WK CALL/MO CALL/YR SUCCESS%');
System.debug('----------------------------------------------------------------------------------------');

Integer totalActive = 0;
Integer totalTotal = 0;
Integer totalIntMo = 0;
Integer totalCallWk = 0;
Integer totalCallMo = 0;
Integer totalCallYr = 0;

for (User manager : salesManagers) {
    Integer active = activeCandidatesMap.get(manager.Id);
    Integer total = totalCandidatesMap.get(manager.Id);
    Integer intMo = interviewsMonthMap.get(manager.Id);
    Integer callWk = callsWeekMap.get(manager.Id);
    Integer callMo = callsMonthMap.get(manager.Id);
    Integer callYr = callsYearMap.get(manager.Id);
    Decimal successRate = total > 0 ? (active * 100.0 / total) : 0;
    
    totalActive += active;
    totalTotal += total;
    totalIntMo += intMo;
    totalCallWk += callWk;
    totalCallMo += callMo;
    totalCallYr += callYr;
    
    String managerName = manager.Name;
    if (managerName.length() > 24) {
        managerName = managerName.substring(0, 21) + '...';
    }
    while (managerName.length() < 25) {
        managerName += ' ';
    }
    
    System.debug(managerName + 
        String.valueOf(active).leftPad(8) + 
        String.valueOf(total).leftPad(8) + 
        String.valueOf(intMo).leftPad(8) + 
        String.valueOf(callWk).leftPad(8) + 
        String.valueOf(callMo).leftPad(8) + 
        String.valueOf(callYr).leftPad(8) + 
        String.valueOf(successRate.setScale(1)).leftPad(7) + '%');
}

System.debug('----------------------------------------------------------------------------------------');
Decimal overallSuccessRate = totalTotal > 0 ? (totalActive * 100.0 / totalTotal) : 0;
String totalsLine = 'TOTALS                   ';
totalsLine += String.valueOf(totalActive).leftPad(8);
totalsLine += String.valueOf(totalTotal).leftPad(8);
totalsLine += String.valueOf(totalIntMo).leftPad(8);
totalsLine += String.valueOf(totalCallWk).leftPad(8);
totalsLine += String.valueOf(totalCallMo).leftPad(8);
totalsLine += String.valueOf(totalCallYr).leftPad(8);
totalsLine += String.valueOf(overallSuccessRate.setScale(1)).leftPad(7) + '%';
System.debug(totalsLine);

System.debug('\n===== LEGEND =====');
System.debug('ACTIVE   = Active/In Process candidates');
System.debug('TOTAL    = Total candidates owned');
System.debug('INT/MO   = Total interviews completed this month (all types)');
System.debug('CALL/WK  = Completed calls logged this week');
System.debug('CALL/MO  = Completed calls logged this month');
System.debug('CALL/YR  = Completed calls logged this year');
System.debug('SUCCESS% = Active candidates / Total candidates');
