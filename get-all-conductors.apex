// Get all unique conductors across all interview types

Set<String> allConductors = new Set<String>();

System.debug('=== COLLECTING ALL UNIQUE CONDUCTORS ===\n');

// 1. AI Conductors
List<Candidate__c> aiList = [
    SELECT AI_Conducted_By__c
    FROM Candidate__c
    WHERE Attraction_Interview_Date_Completed__c != null
    AND AI_Conducted_By__c != null
];
for (Candidate__c c : aiList) {
    if (String.isNotBlank(c.AI_Conducted_By__c)) {
        allConductors.add(c.AI_Conducted_By__c.trim());
    }
}
System.debug('AI conductors collected: ' + aiList.size() + ' records');

// 2. SI1 Conductors
List<Candidate__c> si1List = [
    SELECT SI_1_Conducted_By__c
    FROM Candidate__c
    WHERE SI_1_Date_Completed__c != null
    AND SI_1_Conducted_By__c != null
];
for (Candidate__c c : si1List) {
    if (String.isNotBlank(c.SI_1_Conducted_By__c)) {
        allConductors.add(c.SI_1_Conducted_By__c.trim());
    }
}
System.debug('SI1 conductors collected: ' + si1List.size() + ' records');

// 3. SI2 Conductors
List<Candidate__c> si2List = [
    SELECT SI_2_Conducted_By__c
    FROM Candidate__c
    WHERE SI_2_Date_Completed__c != null
    AND SI_2_Conducted_By__c != null
];
for (Candidate__c c : si2List) {
    if (String.isNotBlank(c.SI_2_Conducted_By__c)) {
        allConductors.add(c.SI_2_Conducted_By__c.trim());
    }
}
System.debug('SI2 conductors collected: ' + si2List.size() + ' records');

// 4. SI3 Conductors
List<Candidate__c> si3List = [
    SELECT SI_3_Conducted_By__c
    FROM Candidate__c
    WHERE SI_3_Completed__c != null
    AND SI_3_Conducted_By__c != null
    AND (SI_3_Conducted_By__c = 'Brad Sofonia' 
         OR SI_3_Conducted_By__c = 'Tim Denton' 
         OR SI_3_Conducted_By__c = 'Bradley Sofonia')
];
for (Candidate__c c : si3List) {
    if (String.isNotBlank(c.SI_3_Conducted_By__c)) {
        allConductors.add(c.SI_3_Conducted_By__c.trim());
    }
}
System.debug('SI3 conductors collected: ' + si3List.size() + ' records');

// 5. Career Conductors
List<Candidate__c> cpList = [
    SELECT CP_Conducted_By__c
    FROM Candidate__c
    WHERE Career_Presentation_Date_Completed__c != null
    AND CP_Conducted_By__c != null
];
for (Candidate__c c : cpList) {
    if (String.isNotBlank(c.CP_Conducted_By__c)) {
        allConductors.add(c.CP_Conducted_By__c.trim());
    }
}
System.debug('Career conductors collected: ' + cpList.size() + ' records\n');

System.debug('=== ALL UNIQUE CONDUCTORS ===');
System.debug('Total unique conductor names: ' + allConductors.size() + '\n');

List<String> sortedConductors = new List<String>(allConductors);
sortedConductors.sort();

for (String conductor : sortedConductors) {
    System.debug(conductor);
}

System.debug('\n=== CURRENT VALID PICKLIST VALUES ===');
System.debug('Tim Denton');
System.debug('Bradley Sofonia');
System.debug('Elizabeth Kagele');
System.debug('Michael Yang');
System.debug('Rachyll Tenny');
System.debug('Scott Grove');
System.debug('Son Le');
System.debug('Van Hess');
