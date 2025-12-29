// CORRECT MIGRATION: Migrate ALL interview types from Candidate to Interview object
// AI → Ci-First
// SI1 → Align-2nd
// SI2 → Plan-3rd
// SI3 → Optional-5th (only Brad/Tim)
// Career Presentation → Present-4th

System.debug('=== STARTING CORRECT MIGRATION ===');

// Valid conductor names
Set<String> validConductors = new Set<String>{
    'Tim Denton', 'Bradley Sofonia', 'Elizabeth Kagele', 
    'Michael Yang', 'Rachyll Tenny', 'Scott Grove', 
    'Son Le', 'Van Hess'
};

Map<String, String> conductorMap = new Map<String, String>{
    'Brad Sofonia' => 'Bradley Sofonia',
    'Bradley Sofonia' => 'Bradley Sofonia',
    'Tim Denton' => 'Tim Denton'
};

List<Interview__c> allInterviews = new List<Interview__c>();
Integer aiCount = 0, si1Count = 0, si2Count = 0, si3Count = 0, cpCount = 0;

// 1. AI Interviews → Ci-First
List<Candidate__c> aiCandidates = [
    SELECT Id, Name, Attraction_Interview_Date_Completed__c, AI_Conducted_By__c
    FROM Candidate__c
    WHERE Attraction_Interview_Date_Completed__c != null
];
System.debug('Found ' + aiCandidates.size() + ' AI interviews');

for (Candidate__c c : aiCandidates) {
    Interview__c i = new Interview__c();
    i.Candidate__c = c.Id;
    i.Interview_Type__c = 'Ci-First';
    i.Date_Time_Scheduled__c = DateTime.newInstance(c.Attraction_Interview_Date_Completed__c.year(), c.Attraction_Interview_Date_Completed__c.month(), c.Attraction_Interview_Date_Completed__c.day(), 17, 0, 0);
    i.External_Id__c = c.Id + '_Ci-First';
    String conductor = c.AI_Conducted_By__c;
    if (conductorMap.containsKey(conductor)) conductor = conductorMap.get(conductor);
    if (validConductors.contains(conductor)) i.Interviewer_s__c = conductor;
    allInterviews.add(i);
    aiCount++;
}

// 2. SI1 Interviews → Align-2nd
List<Candidate__c> si1Candidates = [
    SELECT Id, Name, SI_1_Date_Completed__c, SI_1_Conducted_By__c
    FROM Candidate__c
    WHERE SI_1_Date_Completed__c != null
];
System.debug('Found ' + si1Candidates.size() + ' SI1 interviews');

for (Candidate__c c : si1Candidates) {
    Interview__c i = new Interview__c();
    i.Candidate__c = c.Id;
    i.Interview_Type__c = 'Align-2nd';
    i.Date_Time_Scheduled__c = DateTime.newInstance(c.SI_1_Date_Completed__c.year(), c.SI_1_Date_Completed__c.month(), c.SI_1_Date_Completed__c.day(), 17, 0, 0);
    i.External_Id__c = c.Id + '_Align-2nd';
    String conductor = c.SI_1_Conducted_By__c;
    if (conductorMap.containsKey(conductor)) conductor = conductorMap.get(conductor);
    if (validConductors.contains(conductor)) i.Interviewer_s__c = conductor;
    allInterviews.add(i);
    si1Count++;
}

// 3. SI2 Interviews → Plan-3rd
List<Candidate__c> si2Candidates = [
    SELECT Id, Name, SI_2_Date_Completed__c, SI_2_Conducted_By__c
    FROM Candidate__c
    WHERE SI_2_Date_Completed__c != null
];
System.debug('Found ' + si2Candidates.size() + ' SI2 interviews');

for (Candidate__c c : si2Candidates) {
    Interview__c i = new Interview__c();
    i.Candidate__c = c.Id;
    i.Interview_Type__c = 'Plan-3rd';
    i.Date_Time_Scheduled__c = DateTime.newInstance(c.SI_2_Date_Completed__c.year(), c.SI_2_Date_Completed__c.month(), c.SI_2_Date_Completed__c.day(), 17, 0, 0);
    i.External_Id__c = c.Id + '_Plan-3rd';
    String conductor = c.SI_2_Conducted_By__c;
    if (conductorMap.containsKey(conductor)) conductor = conductorMap.get(conductor);
    if (validConductors.contains(conductor)) i.Interviewer_s__c = conductor;
    allInterviews.add(i);
    si2Count++;
}

// 4. SI3 Interviews → Optional-5th (ONLY Brad/Tim)
List<Candidate__c> si3Candidates = [
    SELECT Id, Name, SI_3_Completed__c, SI_3_Conducted_By__c
    FROM Candidate__c
    WHERE SI_3_Completed__c != null
    AND (SI_3_Conducted_By__c = 'Brad Sofonia' OR SI_3_Conducted_By__c = 'Tim Denton' OR SI_3_Conducted_By__c = 'Bradley Sofonia')
];
System.debug('Found ' + si3Candidates.size() + ' SI3 interviews (Brad/Tim only)');

for (Candidate__c c : si3Candidates) {
    Interview__c i = new Interview__c();
    i.Candidate__c = c.Id;
    i.Interview_Type__c = 'Optional-5th';
    i.Date_Time_Scheduled__c = DateTime.newInstance(c.SI_3_Completed__c.year(), c.SI_3_Completed__c.month(), c.SI_3_Completed__c.day(), 17, 0, 0);
    i.External_Id__c = c.Id + '_Optional-5th';
    String conductor = c.SI_3_Conducted_By__c;
    if (conductorMap.containsKey(conductor)) conductor = conductorMap.get(conductor);
    if (validConductors.contains(conductor)) i.Interviewer_s__c = conductor;
    allInterviews.add(i);
    si3Count++;
}

// 5. Career Presentation → Present-4th
List<Candidate__c> cpCandidates = [
    SELECT Id, Name, Career_Presentation_Date_Completed__c, CP_Conducted_By__c
    FROM Candidate__c
    WHERE Career_Presentation_Date_Completed__c != null
];
System.debug('Found ' + cpCandidates.size() + ' Career Presentation interviews');

for (Candidate__c c : cpCandidates) {
    Interview__c i = new Interview__c();
    i.Candidate__c = c.Id;
    i.Interview_Type__c = 'Present-4th';
    i.Date_Time_Scheduled__c = DateTime.newInstance(c.Career_Presentation_Date_Completed__c.year(), c.Career_Presentation_Date_Completed__c.month(), c.Career_Presentation_Date_Completed__c.day(), 17, 0, 0);
    i.External_Id__c = c.Id + '_Present-4th';
    String conductor = c.CP_Conducted_By__c;
    if (conductorMap.containsKey(conductor)) conductor = conductorMap.get(conductor);
    if (validConductors.contains(conductor)) i.Interviewer_s__c = conductor;
    allInterviews.add(i);
    cpCount++;
}

System.debug('\n=== MIGRATION SUMMARY ===');
System.debug('AI → Ci-First: ' + aiCount);
System.debug('SI1 → Align-2nd: ' + si1Count);
System.debug('SI2 → Plan-3rd: ' + si2Count);
System.debug('SI3 → Optional-5th: ' + si3Count);
System.debug('Career → Present-4th: ' + cpCount);
System.debug('TOTAL: ' + allInterviews.size());

// Insert all
try {
    Database.UpsertResult[] results = Database.upsert(allInterviews, Interview__c.External_Id__c, false);
    Integer success = 0, fail = 0;
    for (Database.UpsertResult r : results) {
        if (r.isSuccess()) success++; else fail++;
    }
    System.debug('\n=== RESULTS ===');
    System.debug('Success: ' + success);
    System.debug('Failed: ' + fail);
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
