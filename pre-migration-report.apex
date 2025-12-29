// PRE-MIGRATION REPORT: Count all interviews by type from Candidate object

System.debug('=== PRE-MIGRATION REPORT ===');
System.debug('Counting all interview types before migration\n');

// 1. AI (Attraction) Interviews
List<Candidate__c> aiList = [
    SELECT Id, Name, Attraction_Interview_Date_Completed__c, AI_Conducted_By__c
    FROM Candidate__c
    WHERE Attraction_Interview_Date_Completed__c != null
];
System.debug('AI (Attraction) Interviews → Ci-First');
System.debug('Total AI interviews: ' + aiList.size());
System.debug('Field: Attraction_Interview_Date_Completed__c');
System.debug('Conductor Field: AI_Conducted_By__c\n');

// 2. SI1 Interviews
List<Candidate__c> si1List = [
    SELECT Id, Name, SI_1_Date_Completed__c, SI_1_Conducted_By__c
    FROM Candidate__c
    WHERE SI_1_Date_Completed__c != null
];
System.debug('SI1 Interviews → Align-2nd');
System.debug('Total SI1 interviews: ' + si1List.size());
System.debug('Field: SI_1_Date_Completed__c');
System.debug('Conductor Field: SI_1_Conducted_By__c\n');

// 3. SI2 Interviews
List<Candidate__c> si2List = [
    SELECT Id, Name, SI_2_Date_Completed__c, SI_2_Conducted_By__c
    FROM Candidate__c
    WHERE SI_2_Date_Completed__c != null
];
System.debug('SI2 Interviews → Plan-3rd');
System.debug('Total SI2 interviews: ' + si2List.size());
System.debug('Field: SI_2_Date_Completed__c');
System.debug('Conductor Field: SI_2_Conducted_By__c\n');

// 4. SI3 Interviews (Brad/Tim only)
List<Candidate__c> si3List = [
    SELECT Id, Name, SI_3_Completed__c, SI_3_Conducted_By__c
    FROM Candidate__c
    WHERE SI_3_Completed__c != null
    AND (SI_3_Conducted_By__c = 'Brad Sofonia' 
         OR SI_3_Conducted_By__c = 'Tim Denton' 
         OR SI_3_Conducted_By__c = 'Bradley Sofonia')
];
System.debug('SI3 Interviews (Brad/Tim only) → Optional-5th');
System.debug('Total SI3 interviews: ' + si3List.size());
System.debug('Field: SI_3_Completed__c');
System.debug('Conductor Field: SI_3_Conducted_By__c\n');

// 5. Career Presentation Interviews
List<Candidate__c> cpList = [
    SELECT Id, Name, Career_Presentation_Date_Completed__c, CP_Conducted_By__c
    FROM Candidate__c
    WHERE Career_Presentation_Date_Completed__c != null
];
System.debug('Career Presentation Interviews → Present-4th');
System.debug('Total Career Presentation interviews: ' + cpList.size());
System.debug('Field: Career_Presentation_Date_Completed__c');
System.debug('Conductor Field: CP_Conducted_By__c\n');

Integer totalToMigrate = aiList.size() + si1List.size() + si2List.size() + si3List.size() + cpList.size();

System.debug('=== SUMMARY ===');
System.debug('AI → Ci-First: ' + aiList.size());
System.debug('SI1 → Align-2nd: ' + si1List.size());
System.debug('SI2 → Plan-3rd: ' + si2List.size());
System.debug('SI3 → Optional-5th: ' + si3List.size() + ' (Brad/Tim only)');
System.debug('Career → Present-4th: ' + cpList.size());
System.debug('TOTAL TO MIGRATE: ' + totalToMigrate);
