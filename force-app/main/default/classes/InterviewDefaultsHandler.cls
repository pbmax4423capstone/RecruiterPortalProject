public class InterviewDefaultsHandler {
    
    // The 7 SF Sales Managers who conduct interviews
    private static final Set<Id> SF_SALES_MANAGER_IDS = new Set<Id>{
        '0055f00000EXvFGAA1',  // Andrew Moore
        '0055f00000EXakXAAT',  // Brooke Ianni
        '0055f00000DqpnpAAB',  // Rachyll Tenny
        '0055f0000081I14AAE',  // Tim Denton
        '0055f00000A7BFWAA3',  // Van Hess
        '005Vo00000ktgovIAA',  // Elizabeth Kagele
        '005Vo00000fcekpIAA'   // Bradley Sofonia
    };
    
    /**
     * Sets default values for Interview records before insert
     * - Sets Conducted_By__c to current user if empty and user is a SF Sales Manager
     * - Sets Interview_Type__c based on Candidate's Highest_Level_Achieved__c
     * - Sets Name by concatenating Candidate name and Interview Type
     */
    public static void setDefaultValues(List<Interview__c> newInterviews) {
        Id currentUserId = UserInfo.getUserId();
        
        // Collect Candidate IDs to query
        Set<Id> candidateIds = new Set<Id>();
        for (Interview__c interview : newInterviews) {
            if (interview.Candidate__c != null) {
                candidateIds.add(interview.Candidate__c);
            }
        }
        
        // Query Candidate records with necessary fields
        Map<Id, Candidate__c> candidateMap = new Map<Id, Candidate__c>();
        if (!candidateIds.isEmpty()) {
            candidateMap = new Map<Id, Candidate__c>([
                SELECT Id, First_Name__c, Last_Name__c, Highest_Level_Achieved__c
                FROM Candidate__c
                WHERE Id IN :candidateIds
            ]);
        }
        
        // Process each interview
        for (Interview__c interview : newInterviews) {
            // Set Conducted_By to current user if not already set and user is a SF Sales Manager
            if (SF_SALES_MANAGER_IDS.contains(currentUserId)) {
                if (interview.Conducted_By__c == null) {
                    interview.Conducted_By__c = currentUserId;
                }
            }
            
            // Set Interview_Type if not already set and candidate exists
            if (interview.Interview_Type__c == null && interview.Candidate__c != null) {
                Candidate__c candidate = candidateMap.get(interview.Candidate__c);
                if (candidate != null) {
                    interview.Interview_Type__c = getDefaultInterviewType(candidate.Highest_Level_Achieved__c);
                }
            }
            
            // Set Name if candidate exists
            if (interview.Candidate__c != null) {
                Candidate__c candidate = candidateMap.get(interview.Candidate__c);
                if (candidate != null && interview.Interview_Type__c != null) {
                    interview.Name = candidate.First_Name__c + ' ' + candidate.Last_Name__c + ' - ' + interview.Interview_Type__c;
                }
            }
        }
    }
    
    /**
     * Maps Candidate's Highest Level Achieved to the next appropriate Interview Type
     */
    private static String getDefaultInterviewType(String highestLevelAchieved) {
        if (String.isBlank(highestLevelAchieved)) {
            return 'SI1';  // Default to first interview
        }
        
        switch on highestLevelAchieved {
            when '0-Prequal' {
                return 'SI1';  // First interview
            }
            when 'Ci_1st' {
                return 'SI2';  // Second interview
            }
            when 'Align (2nd)' {
                return 'SI3';  // Third interview
            }
            when 'Plan_3rd', 'Present-4th' {
                return 'Career';  // Fourth/Fifth interview
            }
            when else {
                return 'SI1';  // Default
            }
        }
    }
}