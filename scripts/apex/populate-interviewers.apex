// Populate Interviewer__c records from unique Candidate interviewers

// Get all unique interviewer names from Candidates
Set<String> interviewerNames = new Set<String>();

// Query all candidates with completed interviews using dynamic SOQL to handle various field names
List<Candidate__c> candidates = [
    SELECT Attraction_Interview_Conducted_By__c, Attraction_Conducted_by__c, AI_Conducted_By__c,
           SI_1_Interview_Conducted_by__c, SI_1_Conducted_By__c, SI1_Conducted_by__c,
           SI_2_Conducted_By__c, SI2_Conducted_by__c,
           SI_3_Conducted_By__c, SI3_Conducted_by__c,
           Career_Presentation_Conducted_By__c, Career_Conducted_by__c
    FROM Candidate__c
    WHERE (Attraction_Interview_Date_Completed__c != null
           OR AI_Completed_Date_Time__c != null
           OR SI_1_Date_Completed__c != null
           OR SI_2_Date_Completed__c != null
           OR SI_3_Completed__c != null
           OR Career_Presentation_Date_Completed__c != null)
];

System.debug('=== EXTRACTING UNIQUE INTERVIEWERS ===');
System.debug('Processing ' + candidates.size() + ' candidates');

for (Candidate__c c : candidates) {
    // AI/Attraction Interview
    String aiConducted = String.valueOf(c.get('Attraction_Interview_Conducted_By__c'));
    if (aiConducted != null && aiConducted != 'null' && aiConducted.trim() != '') {
        interviewerNames.add(aiConducted.trim());
    }
    aiConducted = String.valueOf(c.get('Attraction_Conducted_by__c'));
    if (aiConducted != null && aiConducted != 'null' && aiConducted.trim() != '') {
        interviewerNames.add(aiConducted.trim());
    }
    aiConducted = String.valueOf(c.get('AI_Conducted_By__c'));
    if (aiConducted != null && aiConducted != 'null' && aiConducted.trim() != '') {
        interviewerNames.add(aiConducted.trim());
    }
    
    // SI1
    String si1Conducted = String.valueOf(c.get('SI_1_Interview_Conducted_by__c'));
    if (si1Conducted != null && si1Conducted != 'null' && si1Conducted.trim() != '') {
        interviewerNames.add(si1Conducted.trim());
    }
    si1Conducted = String.valueOf(c.get('SI_1_Conducted_By__c'));
    if (si1Conducted != null && si1Conducted != 'null' && si1Conducted.trim() != '') {
        interviewerNames.add(si1Conducted.trim());
    }
    si1Conducted = String.valueOf(c.get('SI1_Conducted_by__c'));
    if (si1Conducted != null && si1Conducted != 'null' && si1Conducted.trim() != '') {
        interviewerNames.add(si1Conducted.trim());
    }
    
    // SI2
    String si2Conducted = String.valueOf(c.get('SI_2_Conducted_By__c'));
    if (si2Conducted != null && si2Conducted != 'null' && si2Conducted.trim() != '') {
        interviewerNames.add(si2Conducted.trim());
    }
    si2Conducted = String.valueOf(c.get('SI2_Conducted_by__c'));
    if (si2Conducted != null && si2Conducted != 'null' && si2Conducted.trim() != '') {
        interviewerNames.add(si2Conducted.trim());
    }
    
    // SI3
    String si3Conducted = String.valueOf(c.get('SI_3_Conducted_By__c'));
    if (si3Conducted != null && si3Conducted != 'null' && si3Conducted.trim() != '') {
        interviewerNames.add(si3Conducted.trim());
    }
    si3Conducted = String.valueOf(c.get('SI3_Conducted_by__c'));
    if (si3Conducted != null && si3Conducted != 'null' && si3Conducted.trim() != '') {
        interviewerNames.add(si3Conducted.trim());
    }
    
    // Career Presentation
    String cpConducted = String.valueOf(c.get('Career_Presentation_Conducted_By__c'));
    if (cpConducted != null && cpConducted != 'null' && cpConducted.trim() != '') {
        interviewerNames.add(cpConducted.trim());
    }
    cpConducted = String.valueOf(c.get('Career_Conducted_by__c'));
    if (cpConducted != null && cpConducted != 'null' && cpConducted.trim() != '') {
        interviewerNames.add(cpConducted.trim());
    }
}

System.debug('Found ' + interviewerNames.size() + ' unique interviewers');

// Check which interviewers already exist
Map<String, Id> existingInterviewers = new Map<String, Id>();
for (Interviewer__c interviewer : [SELECT Id, Name FROM Interviewer__c]) {
    existingInterviewers.put(interviewer.Name, interviewer.Id);
}

System.debug('Already have ' + existingInterviewers.size() + ' Interviewer records');

// Create new Interviewer records for names we don't have yet
List<Interviewer__c> newInterviewers = new List<Interviewer__c>();
for (String name : interviewerNames) {
    if (!existingInterviewers.containsKey(name)) {
        newInterviewers.add(new Interviewer__c(Name = name));
    }
}

System.debug('Creating ' + newInterviewers.size() + ' new Interviewer records');

if (!newInterviewers.isEmpty()) {
    insert newInterviewers;
    System.debug('✓ Successfully created ' + newInterviewers.size() + ' Interviewer records');
}

// Show sample of created interviewers
List<Interviewer__c> allInterviewers = [SELECT Id, Name FROM Interviewer__c ORDER BY Name LIMIT 20];
System.debug('');
System.debug('=== SAMPLE INTERVIEWERS (first 20) ===');
for (Interviewer__c i : allInterviewers) {
    System.debug(i.Name);
}
