// Query all Candidates with SI_1_Date_Completed__c populated
List<Candidate__c> candidates = [
    SELECT 
        Id, 
        Name,
        SI_1_Date_Completed__c,
        SI_1_Conducted_By__c,
        SI_1_Interview_Conducted_by__c,
        SI1_Conducted_by__c
    FROM Candidate__c
    WHERE SI_1_Date_Completed__c != null
    ORDER BY SI_1_Date_Completed__c DESC
];

System.debug('=== ALL SI1 INTERVIEWS FROM CANDIDATE OBJECT ===');
System.debug('Total Found: ' + candidates.size());
System.debug('');

// Group by month for summary
Map<String, Integer> monthCount = new Map<String, Integer>();
Map<String, Integer> conductorCount = new Map<String, Integer>();

for (Candidate__c cand : candidates) {
    String monthKey = String.valueOf(cand.SI_1_Date_Completed__c.year()) + '-' + 
                      String.valueOf(cand.SI_1_Date_Completed__c.month()).leftPad(2, '0');
    
    // Determine conductor name
    String conductor = 'Unknown';
    if (cand.SI_1_Conducted_By__c != null) {
        conductor = cand.SI_1_Conducted_By__c;
    } else if (cand.SI_1_Interview_Conducted_by__c != null) {
        conductor = cand.SI_1_Interview_Conducted_by__c;
    } else if (cand.SI1_Conducted_by__c != null) {
        conductor = cand.SI1_Conducted_by__c;
    }
    
    // Count by month
    if (!monthCount.containsKey(monthKey)) {
        monthCount.put(monthKey, 0);
    }
    monthCount.put(monthKey, monthCount.get(monthKey) + 1);
    
    // Count by conductor
    if (!conductorCount.containsKey(conductor)) {
        conductorCount.put(conductor, 0);
    }
    conductorCount.put(conductor, conductorCount.get(conductor) + 1);
    
    System.debug('Candidate: ' + cand.Name + 
                 ' | Date: ' + cand.SI_1_Date_Completed__c + 
                 ' | Conducted By: ' + conductor);
}

System.debug('');
System.debug('=== SUMMARY BY MONTH ===');
List<String> months = new List<String>(monthCount.keySet());
months.sort();
for (String month : months) {
    System.debug(month + ': ' + monthCount.get(month) + ' interviews');
}

System.debug('');
System.debug('=== SUMMARY BY CONDUCTOR ===');
for (String conductor : conductorCount.keySet()) {
    System.debug(conductor + ': ' + conductorCount.get(conductor) + ' interviews');
}

// November 2025 specific
System.debug('');
System.debug('=== NOVEMBER 2025 SI1 INTERVIEWS ===');
List<Candidate__c> novemberCandidates = [
    SELECT 
        Id, 
        Name,
        SI_1_Date_Completed__c,
        SI_1_Conducted_By__c,
        SI_1_Interview_Conducted_by__c,
        SI1_Conducted_by__c
    FROM Candidate__c
    WHERE SI_1_Date_Completed__c >= 2025-11-01
    AND SI_1_Date_Completed__c <= 2025-11-30
    ORDER BY SI_1_Date_Completed__c DESC
];

System.debug('Total in November 2025: ' + novemberCandidates.size());
for (Candidate__c cand : novemberCandidates) {
    String conductor = 'Unknown';
    if (cand.SI_1_Conducted_By__c != null) {
        conductor = cand.SI_1_Conducted_By__c;
    } else if (cand.SI_1_Interview_Conducted_by__c != null) {
        conductor = cand.SI_1_Interview_Conducted_by__c;
    } else if (cand.SI1_Conducted_by__c != null) {
        conductor = cand.SI1_Conducted_by__c;
    }
    
    System.debug('Candidate: ' + cand.Name + 
                 ' | Date: ' + cand.SI_1_Date_Completed__c + 
                 ' | Conducted By: ' + conductor);
}
