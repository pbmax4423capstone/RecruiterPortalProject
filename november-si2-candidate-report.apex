// Query CANDIDATE object for SI2 completed interviews in November 2025
List<Candidate__c> si2Candidates = [
    SELECT Id, Name, 
           SI_2_Date_Completed__c,
           SI_2_Conducted_By__c,
           SI2_Conducted_by__c,
           SI_2_Interviewer__c
    FROM Candidate__c
    WHERE SI_2_Date_Completed__c >= 2025-11-01
    AND SI_2_Date_Completed__c <= 2025-11-30
    ORDER BY SI_2_Date_Completed__c ASC
];

System.debug('=== SI2 INTERVIEWS FROM CANDIDATE OBJECT - NOVEMBER 2025 ===');
System.debug('Total SI2 interviews in November 2025: ' + si2Candidates.size());
System.debug('Report generated: ' + DateTime.now().format());
System.debug('Source: Candidate__c.SI_2_Date_Completed__c (date field)');
System.debug('Conductor Field: SI_2_Conducted_By__c');
System.debug('\n');

if (si2Candidates.size() == 0) {
    System.debug('NO SI2 INTERVIEWS FOUND IN NOVEMBER 2025');
} else {
    System.debug('--- COMPLETE LIST ---');
    System.debug('Date Completed | Conducted By | Candidate Name | Candidate ID');
    System.debug('---------------------------------------------------------------');
    
    for (Candidate__c candidate : si2Candidates) {
        String dateStr = candidate.SI_2_Date_Completed__c != null 
            ? candidate.SI_2_Date_Completed__c.format() 
            : 'NO DATE';
        
        // Get conductor from available fields
        String conductor = candidate.SI_2_Conducted_By__c;
        if (String.isBlank(conductor)) {
            conductor = candidate.SI2_Conducted_by__c;
        }
        if (String.isBlank(conductor)) {
            conductor = candidate.SI_2_Interviewer__c;
        }
        if (String.isBlank(conductor)) {
            conductor = 'NOT SET';
        }
        
        String candidateName = candidate.Name != null 
            ? candidate.Name 
            : 'NO NAME';
        
        System.debug(dateStr + ' | ' + conductor + ' | ' + candidateName + ' | ' + candidate.Id);
    }
}

// Count by conductor
Map<String, Integer> conductorCount = new Map<String, Integer>();
for (Candidate__c candidate : si2Candidates) {
    String conductor = candidate.SI_2_Conducted_By__c;
    if (String.isBlank(conductor)) {
        conductor = candidate.SI2_Conducted_by__c;
    }
    if (String.isBlank(conductor)) {
        conductor = candidate.SI_2_Interviewer__c;
    }
    if (String.isBlank(conductor)) {
        conductor = 'NOT SET';
    }
    
    if (!conductorCount.containsKey(conductor)) {
        conductorCount.put(conductor, 0);
    }
    conductorCount.put(conductor, conductorCount.get(conductor) + 1);
}

System.debug('\n--- SUMMARY BY CONDUCTOR ---');
for (String conductor : conductorCount.keySet()) {
    System.debug(conductor + ': ' + conductorCount.get(conductor));
}
System.debug('\nTOTAL: ' + si2Candidates.size());
