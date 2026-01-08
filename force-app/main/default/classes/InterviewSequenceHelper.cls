/**
 * Helper class for Interview scheduling logic.
 * Provides methods to determine next interview type in sequence,
 * get current user information, and retrieve candidate interview history.
 */
public with sharing class InterviewSequenceHelper {
    
    // Define interview type sequence
    private static final List<String> INTERVIEW_SEQUENCE = new List<String>{
        'Ci-First',
        'Align-2nd',
        'Plan-3rd',
        'Present-4th',
        'Optional-5th'
    };
    
    /**
     * Returns the next suggested interview type based on completed interviews for a candidate.
     * @param candidateId The ID of the Candidate__c record
     * @return String The next interview type in sequence, or 'Ci-First' if none completed
     */
    @AuraEnabled(cacheable=false)
    public static String getNextInterviewType(Id candidateId) {
        if (candidateId == null) {
            return INTERVIEW_SEQUENCE[0]; // Default to first interview
        }
        
        // Query completed interviews for this candidate, ordered by type sequence
        List<Interview__c> completedInterviews = [
            SELECT Id, Interview_Type__c
            FROM Interview__c
            WHERE Candidate__c = :candidateId
            AND Interview_Status__c = 'Completed'
            ORDER BY CreatedDate DESC
        ];
        
        if (completedInterviews.isEmpty()) {
            return INTERVIEW_SEQUENCE[0]; // No completed interviews, start with first
        }
        
        // Find highest completed interview type in sequence
        Integer highestIndex = -1;
        for (Interview__c interview : completedInterviews) {
            Integer currentIndex = INTERVIEW_SEQUENCE.indexOf(interview.Interview_Type__c);
            if (currentIndex > highestIndex) {
                highestIndex = currentIndex;
            }
        }
        
        // Return next in sequence, or last type if all completed
        Integer nextIndex = highestIndex + 1;
        if (nextIndex >= INTERVIEW_SEQUENCE.size()) {
            return INTERVIEW_SEQUENCE[INTERVIEW_SEQUENCE.size() - 1]; // Suggest last type
        }
        
        return INTERVIEW_SEQUENCE[nextIndex];
    }
    
    /**
     * Returns the current user's full name.
     * @return String Current user's name in format "FirstName LastName"
     */
    @AuraEnabled(cacheable=false)
    public static String getCurrentUserName() {
        User currentUser = [
            SELECT Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        return currentUser.Name;
    }
    
    /**
     * Returns a summary of interviews for a candidate, showing completed types.
     * @param candidateId The ID of the Candidate__c record
     * @return InterviewSummary Wrapper containing summary information
     */
    @AuraEnabled(cacheable=false)
    public static InterviewSummary getCandidateInterviewSummary(Id candidateId) {
        InterviewSummary summary = new InterviewSummary();
        summary.hasCompletedInterviews = false;
        summary.completedTypes = new List<String>();
        summary.totalCompleted = 0;
        summary.summaryText = 'No interviews completed yet.';
        
        if (candidateId == null) {
            return summary;
        }
        
        // Query all completed interviews for this candidate
        List<Interview__c> completedInterviews = [
            SELECT Id, Interview_Type__c, Date_Time_Scheduled__c
            FROM Interview__c
            WHERE Candidate__c = :candidateId
            AND Interview_Status__c = 'Completed'
            ORDER BY Date_Time_Scheduled__c DESC
        ];
        
        if (!completedInterviews.isEmpty()) {
            summary.hasCompletedInterviews = true;
            summary.totalCompleted = completedInterviews.size();
            
            // Collect unique completed types
            Set<String> typeSet = new Set<String>();
            for (Interview__c interview : completedInterviews) {
                if (!typeSet.contains(interview.Interview_Type__c)) {
                    typeSet.add(interview.Interview_Type__c);
                    summary.completedTypes.add(interview.Interview_Type__c);
                }
            }
            
            // Build summary text
            if (summary.totalCompleted == 1) {
                summary.summaryText = '1 interview completed: ' + String.join(summary.completedTypes, ', ');
            } else {
                summary.summaryText = summary.totalCompleted + ' interviews completed: ' + String.join(summary.completedTypes, ', ');
            }
        }
        
        return summary;
    }
    
    /**
     * Wrapper class for interview summary information
     */
    public class InterviewSummary {
        @AuraEnabled public Boolean hasCompletedInterviews;
        @AuraEnabled public List<String> completedTypes;
        @AuraEnabled public Integer totalCompleted;
        @AuraEnabled public String summaryText;
    }
}
