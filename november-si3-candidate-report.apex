// Query CANDIDATE object for SI3 completed interviews in November 2025
List<Candidate__c> si3Candidates = [
    SELECT Id, Name, 
           SI_3_Completed__c,
           SI_3_Conducted_By__c,
           SI3_Conducted_by__c,
           SI_3_Interviewer__c
    FROM Candidate__c
    WHERE SI_3_Completed__c >= 2025-11-01
    AND SI_3_Completed__c <= 2025-11-30
    ORDER BY SI_3_Completed__c ASC
];

System.debug('=== SI3 INTERVIEWS FROM CANDIDATE OBJECT - NOVEMBER 2025 ===');
System.debug('Total SI3 interviews in November 2025: ' + si3Candidates.size());
System.debug('Report generated: ' + DateTime.now().format());
System.debug('Source: Candidate__c.SI_3_Completed__c (date field)');
System.debug('Conductor: SI_3_Conducted_By__c field');
System.debug('\n');

if (si3Candidates.size() == 0) {
    System.debug('NO SI3 INTERVIEWS FOUND IN NOVEMBER 2025');
} else {
    System.debug('--- COMPLETE LIST ---');
    System.debug('Date Completed | Conducted By | Candidate Name | Candidate ID');
    System.debug('---------------------------------------------------------------');
    
    for (Candidate__c candidate : si3Candidates) {
        String dateStr = candidate.SI_3_Completed__c != null 
            ? candidate.SI_3_Completed__c.format() 
            : 'NO DATE';
        
        // Get conductor from available fields
        String conductor = candidate.SI_3_Conducted_By__c;
        if (String.isBlank(conductor)) {
            conductor = candidate.SI3_Conducted_by__c;
        }
        if (String.isBlank(conductor)) {
            conductor = candidate.SI_3_Interviewer__c;
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
for (Candidate__c candidate : si3Candidates) {
    String conductor = candidate.SI_3_Conducted_By__c;
    if (String.isBlank(conductor)) {
        conductor = candidate.SI3_Conducted_by__c;
    }
    if (String.isBlank(conductor)) {
        conductor = candidate.SI_3_Interviewer__c;
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
System.debug('\nTOTAL: ' + si3Candidates.size());
