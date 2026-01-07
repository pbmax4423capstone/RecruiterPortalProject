/**
 * Preview historical interview migration (DRY RUN - No database changes)
 * 
 * This script analyzes what would be migrated without actually creating Interview__c records.
 * Use this to validate data quality and migration logic before running the actual migration.
 * 
 * Usage:
 * 1. Open this file in VS Code
 * 2. Execute in Anonymous Apex (Ctrl+Shift+P -> "SFDX: Execute Anonymous Apex with Currently Selected Text")
 * 3. Review debug log output for statistics and warnings
 */

System.debug('========================================');
System.debug('PREVIEW MODE - DRY RUN (No Database Changes)');
System.debug('========================================');
System.debug('');

// Query a sample of candidates with interview data
List<Candidate__c> candidates = [
    SELECT Id, Name, 
        // Attraction/AI fields
        Attraction_Interview_Date_Scheduled__c,
        AI_Completed_Date_Time__c,
        Attraction_Interview_Date_Completed__c,
        AI_Conducted_By__c,
        Attraction_Interview_Conducted_By__c,
        Attraction_Conducted_by__c,
        // SI1/Align-2nd fields
        SI_1_Date_Scheduled__c,
        SI_1_Date_Completed__c,
        SI_1_Conducted_By__c,
        SI_1_Interview_Conducted_by__c,
        SI1_Conducted_by__c,
        // SI2/Plan-3rd fields
        SI_2_Date_Scheduled__c,
        SI_2_Date_Completed__c,
        SI_2_Conducted_By__c,
        SI2_Conducted_by__c,
        SI_2_Interviewer__c,
        // Career/Present-4th fields
        Career_Presentation_Date_Scheduled__c,
        Career_Presentation_Date_Completed__c,
        CP_Conducted_By__c,
        Career_Presentation_Conducted_By__c,
        // SI3/Optional-5th fields
        SI_3_Scheduled__c,
        SI_3_Completed__c,
        SI_3_Conducted_By__c,
        SI3_Conducted_by__c,
        SI_3_Interviewer__c
    FROM Candidate__c 
    WHERE Active__c = true
    ORDER BY CreatedDate DESC
    LIMIT 100
];

System.debug('Analyzing ' + candidates.size() + ' candidates...');
System.debug('');

// Statistics
Integer candidatesWithInterviews = 0;
Integer totalInterviews = 0;
Map<String, Integer> interviewsByType = new Map<String, Integer>{
    'Ci-First' => 0,
    'Align-2nd' => 0,
    'Plan-3rd' => 0,
    'Present-4th' => 0,
    'Optional-5th' => 0
};
Map<String, Integer> scheduledVsCompleted = new Map<String, Integer>{
    'Scheduled' => 0,
    'Completed' => 0
};
Integer withOutcome = 0;
Integer withoutConductor = 0;
List<String> missingConductors = new List<String>();

// Analyze each candidate
for (Candidate__c cand : candidates) {
    Boolean hasAnyInterview = false;
    
    // Check Ci-First
    if (cand.AI_Completed_Date_Time__c != null || 
        cand.Attraction_Interview_Date_Completed__c != null ||
        cand.Attraction_Interview_Date_Scheduled__c != null) {
        hasAnyInterview = true;
        totalInterviews++;
        interviewsByType.put('Ci-First', interviewsByType.get('Ci-First') + 1);
        
        if (cand.AI_Completed_Date_Time__c != null || cand.Attraction_Interview_Date_Completed__c != null) {
            scheduledVsCompleted.put('Completed', scheduledVsCompleted.get('Completed') + 1);
            // Check for subsequent interviews to determine outcome
            if (cand.SI_1_Date_Completed__c != null || cand.SI_2_Date_Completed__c != null ||
                cand.Career_Presentation_Date_Completed__c != null || cand.SI_3_Completed__c != null) {
                withOutcome++;
            }
        } else {
            scheduledVsCompleted.put('Scheduled', scheduledVsCompleted.get('Scheduled') + 1);
        }
        
        // Check conductor
        if (String.isBlank(cand.AI_Conducted_By__c) && 
            String.isBlank(cand.Attraction_Interview_Conducted_By__c) &&
            String.isBlank(cand.Attraction_Conducted_by__c)) {
            withoutConductor++;
            missingConductors.add(cand.Name + ' - Ci-First');
        }
    }
    
    // Check Align-2nd
    if (cand.SI_1_Date_Completed__c != null || cand.SI_1_Date_Scheduled__c != null) {
        hasAnyInterview = true;
        totalInterviews++;
        interviewsByType.put('Align-2nd', interviewsByType.get('Align-2nd') + 1);
        
        if (cand.SI_1_Date_Completed__c != null) {
            scheduledVsCompleted.put('Completed', scheduledVsCompleted.get('Completed') + 1);
            if (cand.SI_2_Date_Completed__c != null || 
                cand.Career_Presentation_Date_Completed__c != null || 
                cand.SI_3_Completed__c != null) {
                withOutcome++;
            }
        } else {
            scheduledVsCompleted.put('Scheduled', scheduledVsCompleted.get('Scheduled') + 1);
        }
        
        if (String.isBlank(cand.SI_1_Conducted_By__c) && 
            String.isBlank(cand.SI_1_Interview_Conducted_by__c) &&
            String.isBlank(cand.SI1_Conducted_by__c)) {
            withoutConductor++;
            missingConductors.add(cand.Name + ' - Align-2nd');
        }
    }
    
    // Check Plan-3rd
    if (cand.SI_2_Date_Completed__c != null || cand.SI_2_Date_Scheduled__c != null) {
        hasAnyInterview = true;
        totalInterviews++;
        interviewsByType.put('Plan-3rd', interviewsByType.get('Plan-3rd') + 1);
        
        if (cand.SI_2_Date_Completed__c != null) {
            scheduledVsCompleted.put('Completed', scheduledVsCompleted.get('Completed') + 1);
            if (cand.Career_Presentation_Date_Completed__c != null || cand.SI_3_Completed__c != null) {
                withOutcome++;
            }
        } else {
            scheduledVsCompleted.put('Scheduled', scheduledVsCompleted.get('Scheduled') + 1);
        }
        
        if (String.isBlank(cand.SI_2_Conducted_By__c) && 
            String.isBlank(cand.SI2_Conducted_by__c) &&
            String.isBlank(cand.SI_2_Interviewer__c)) {
            withoutConductor++;
            missingConductors.add(cand.Name + ' - Plan-3rd');
        }
    }
    
    // Check Present-4th
    if (cand.Career_Presentation_Date_Completed__c != null || cand.Career_Presentation_Date_Scheduled__c != null) {
        hasAnyInterview = true;
        totalInterviews++;
        interviewsByType.put('Present-4th', interviewsByType.get('Present-4th') + 1);
        
        if (cand.Career_Presentation_Date_Completed__c != null) {
            scheduledVsCompleted.put('Completed', scheduledVsCompleted.get('Completed') + 1);
            if (cand.SI_3_Completed__c != null) {
                withOutcome++;
            }
        } else {
            scheduledVsCompleted.put('Scheduled', scheduledVsCompleted.get('Scheduled') + 1);
        }
        
        if (String.isBlank(cand.CP_Conducted_By__c) && 
            String.isBlank(cand.Career_Presentation_Conducted_By__c)) {
            withoutConductor++;
            missingConductors.add(cand.Name + ' - Present-4th');
        }
    }
    
    // Check Optional-5th
    if (cand.SI_3_Completed__c != null || cand.SI_3_Scheduled__c != null) {
        hasAnyInterview = true;
        totalInterviews++;
        interviewsByType.put('Optional-5th', interviewsByType.get('Optional-5th') + 1);
        
        if (cand.SI_3_Completed__c != null) {
            scheduledVsCompleted.put('Completed', scheduledVsCompleted.get('Completed') + 1);
            // SI3 is always last, never has outcome
        } else {
            scheduledVsCompleted.put('Scheduled', scheduledVsCompleted.get('Scheduled') + 1);
        }
        
        if (String.isBlank(cand.SI_3_Conducted_By__c) && 
            String.isBlank(cand.SI3_Conducted_by__c) &&
            String.isBlank(cand.SI_3_Interviewer__c)) {
            withoutConductor++;
            missingConductors.add(cand.Name + ' - Optional-5th');
        }
    }
    
    if (hasAnyInterview) {
        candidatesWithInterviews++;
    }
}

// Display results
System.debug('========================================');
System.debug('PREVIEW RESULTS');
System.debug('========================================');
System.debug('');
System.debug('Candidates Analyzed: ' + candidates.size());
System.debug('Candidates with Interviews: ' + candidatesWithInterviews);
System.debug('Total Interviews to Create: ' + totalInterviews);
System.debug('');
System.debug('Interviews by Type:');
for (String type : interviewsByType.keySet()) {
    System.debug('  ' + type + ': ' + interviewsByType.get(type));
}
System.debug('');
System.debug('Interview Status:');
System.debug('  Scheduled: ' + scheduledVsCompleted.get('Scheduled'));
System.debug('  Completed: ' + scheduledVsCompleted.get('Completed'));
System.debug('');
System.debug('Outcomes:');
System.debug('  Interviews with "Proceed" outcome: ' + withOutcome);
System.debug('  Interviews with null outcome (last interview): ' + (scheduledVsCompleted.get('Completed') - withOutcome));
System.debug('');
System.debug('Data Quality:');
System.debug('  Interviews without conductor: ' + withoutConductor);
if (withoutConductor > 0 && missingConductors.size() <= 20) {
    System.debug('  Missing conductors:');
    for (String missing : missingConductors) {
        System.debug('    - ' + missing);
    }
}
System.debug('');
System.debug('========================================');
System.debug('This was a DRY RUN - No records were created.');
System.debug('To execute actual migration, run: execute-interview-migration.apex');
System.debug('========================================');
