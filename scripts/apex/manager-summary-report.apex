// Comprehensive Sales Manager/Recruiter Report - Using Aggregates

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
    LIMIT 20
];

System.debug('Found ' + salesManagers.size() + ' Sales Managers/Recruiters\n');
System.debug('Report Date: ' + System.today() + '\n');
System.debug('NAME                      ACTIVE   TOTAL   INT/MO  CALL/WK CALL/MO CALL/YR');
System.debug('------------------------------------------------------------------------');

Integer totalActive = 0;
Integer totalTotal = 0;
Integer totalIntMo = 0;
Integer totalCallWk = 0;
Integer totalCallMo = 0;
Integer totalCallYr = 0;

for (User manager : salesManagers) {
    // Get candidate counts
    Integer active = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND Status__c = 'Active/In Process'];
    Integer total = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id];
    
    // Count interviews this month (all 5 types)
    Integer citMo = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND (AI_Completed_Date_Time__c = THIS_MONTH OR Attraction_Interview_Date_Completed__c = THIS_MONTH)];
    Integer alignMo = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_1_Date_Completed__c = THIS_MONTH];
    Integer planMo = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_2_Date_Completed__c = THIS_MONTH];
    Integer presentMo = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND SI_3_Completed__c = THIS_MONTH];
    Integer optMo = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :manager.Id AND Career_Presentation_Date_Completed__c = THIS_MONTH];
    Integer intMo = citMo + alignMo + planMo + presentMo + optMo;
    
    // Get call counts
    Integer callWk = [SELECT COUNT() FROM Task WHERE OwnerId = :manager.Id AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND ActivityDate = THIS_WEEK];
    Integer callMo = [SELECT COUNT() FROM Task WHERE OwnerId = :manager.Id AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND ActivityDate = THIS_MONTH];
    Integer callYr = [SELECT COUNT() FROM Task WHERE OwnerId = :manager.Id AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND ActivityDate = THIS_YEAR];
    
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
        String.valueOf(callYr).leftPad(8));
}

System.debug('------------------------------------------------------------------------');
String totalsLine = 'TOTALS                   ';
totalsLine += String.valueOf(totalActive).leftPad(8);
totalsLine += String.valueOf(totalTotal).leftPad(8);
totalsLine += String.valueOf(totalIntMo).leftPad(8);
totalsLine += String.valueOf(totalCallWk).leftPad(8);
totalsLine += String.valueOf(totalCallMo).leftPad(8);
totalsLine += String.valueOf(totalCallYr).leftPad(8);
System.debug(totalsLine);

System.debug('\n===== LEGEND =====');
System.debug('ACTIVE   = Active/In Process candidates');
System.debug('TOTAL    = Total candidates owned');
System.debug('INT/MO   = Total interviews completed this month (all 5 types)');
System.debug('CALL/WK  = Completed calls logged this week');
System.debug('CALL/MO  = Completed calls logged this month');
System.debug('CALL/YR  = Completed calls logged this year');
