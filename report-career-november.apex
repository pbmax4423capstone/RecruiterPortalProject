// Query Candidate object for Career Presentation interviews in November 2025
List<Candidate__c> careerCandidates = [
    SELECT Id, Name, 
           Career_Presentation_Date_Completed__c,
           Career_Presentation_Conducted_By__c
    FROM Candidate__c
    WHERE Career_Presentation_Date_Completed__c >= 2025-11-01
    AND Career_Presentation_Date_Completed__c <= 2025-11-30
    ORDER BY Career_Presentation_Date_Completed__c ASC
];

System.debug('=== CAREER PRESENTATION INTERVIEWS - NOVEMBER 2025 ===');
System.debug('Total Career interviews in November 2025: ' + careerCandidates.size());
System.debug('Source: Candidate__c.Career_Presentation_Date_Completed__c');
System.debug('Conductor Field: Career_Presentation_Conducted_By__c');
System.debug('\n');

System.debug('Date Completed | Sales Manager | Candidate Name | Candidate ID');
System.debug('-------------------------------------------------------------------------');

for (Candidate__c candidate : careerCandidates) {
    String dateStr = candidate.Career_Presentation_Date_Completed__c != null 
        ? candidate.Career_Presentation_Date_Completed__c.format() 
        : 'NO DATE';
    
    String salesManager = String.isBlank(candidate.Career_Presentation_Conducted_By__c) 
        ? 'NOT SET' 
        : candidate.Career_Presentation_Conducted_By__c;
    
    String candidateName = String.isBlank(candidate.Name) 
        ? 'NO NAME' 
        : candidate.Name;
    
    System.debug(dateStr + ' | ' + salesManager + ' | ' + candidateName + ' | ' + candidate.Id);
}

// Count by sales manager
Map<String, Integer> managerCount = new Map<String, Integer>();
for (Candidate__c candidate : careerCandidates) {
    String manager = String.isBlank(candidate.Career_Presentation_Conducted_By__c) 
        ? 'NOT SET' 
        : candidate.Career_Presentation_Conducted_By__c;
    
    if (!managerCount.containsKey(manager)) {
        managerCount.put(manager, 0);
    }
    managerCount.put(manager, managerCount.get(manager) + 1);
}

System.debug('\n=== SUMMARY BY SALES MANAGER ===');
for (String manager : managerCount.keySet()) {
    System.debug(manager + ': ' + managerCount.get(manager));
}

System.debug('\nTOTAL CAREER INTERVIEWS (NOVEMBER 2025): ' + careerCandidates.size());
