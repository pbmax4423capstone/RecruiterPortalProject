// Query Candidate object for ALL SI3 interviews (SI_3_Completed__c populated)
List<Candidate__c> si3Candidates = [
    SELECT Id, Name, 
           SI_3_Completed__c,
           SI_3_Conducted_By__c
    FROM Candidate__c
    WHERE SI_3_Completed__c != null
    ORDER BY SI_3_Completed__c DESC
];

System.debug('=== ALL SI3 INTERVIEWS FROM CANDIDATE OBJECT ===');
System.debug('Total SI3 interviews found: ' + si3Candidates.size());
System.debug('Query: WHERE SI_3_Completed__c != null');
System.debug('\n');

System.debug('Date Completed | Conducted By | Candidate Name | Candidate ID');
System.debug('-------------------------------------------------------------------------');

for (Candidate__c candidate : si3Candidates) {
    String dateStr = candidate.SI_3_Completed__c != null 
        ? candidate.SI_3_Completed__c.format() 
        : 'NO DATE';
    
    String conductor = String.isBlank(candidate.SI_3_Conducted_By__c) 
        ? 'NOT SET' 
        : candidate.SI_3_Conducted_By__c;
    
    String candidateName = String.isBlank(candidate.Name) 
        ? 'NO NAME' 
        : candidate.Name;
    
    System.debug(dateStr + ' | ' + conductor + ' | ' + candidateName + ' | ' + candidate.Id);
}

// Count by conductor
Map<String, Integer> conductorCount = new Map<String, Integer>();
for (Candidate__c candidate : si3Candidates) {
    String conductor = String.isBlank(candidate.SI_3_Conducted_By__c) 
        ? 'NOT SET' 
        : candidate.SI_3_Conducted_By__c;
    
    if (!conductorCount.containsKey(conductor)) {
        conductorCount.put(conductor, 0);
    }
    conductorCount.put(conductor, conductorCount.get(conductor) + 1);
}

System.debug('\n=== SUMMARY BY CONDUCTOR ===');
for (String conductor : conductorCount.keySet()) {
    System.debug(conductor + ': ' + conductorCount.get(conductor));
}

System.debug('\nTOTAL SI3 INTERVIEWS: ' + si3Candidates.size());
