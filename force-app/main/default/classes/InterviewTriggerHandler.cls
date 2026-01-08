/**
 * Trigger handler for Interview__c object.
 * Updates Candidate's Highest Level Achieved when interviews are completed.
 */
public with sharing class InterviewTriggerHandler {
    
    /**
     * Order of interview stages for comparison
     */
    private static final List<String> HIGHEST_LEVEL_ORDER = new List<String>{
        '0-Prequal',
        'Ci-First',
        'Align-2nd',
        'Plan-3rd',
        'Present-4th',
        'Optional-5th',
        '6-Offer Acc',
        '7-Contracted'
    };
    
    /**
     * Handle after update trigger event.
     * Updates Candidate's Highest Level Achieved when interview status changes to Completed.
     * @param newInterviews List of new Interview records
     * @param oldInterviewsMap Map of old Interview records by Id
     */
    public static void handleAfterUpdate(List<Interview__c> newInterviews, Map<Id, Interview__c> oldInterviewsMap) {
        Set<Id> candidateIds = new Set<Id>();
        
        // Find interviews that just changed to Completed status
        for (Interview__c interview : newInterviews) {
            Interview__c oldInterview = oldInterviewsMap.get(interview.Id);
            
            // Check if status changed to Completed and has a candidate
            if (interview.Interview_Status__c == 'Completed' 
                && oldInterview.Interview_Status__c != 'Completed'
                && interview.Candidate__c != null) {
                candidateIds.add(interview.Candidate__c);
            }
        }
        
        if (!candidateIds.isEmpty()) {
            updateCandidateHighestLevel(candidateIds);
        }
    }
    
    /**
     * Handle after insert trigger event.
     * Updates Candidate's Highest Level Achieved for newly inserted completed interviews.
     * @param newInterviews List of new Interview records
     */
    public static void handleAfterInsert(List<Interview__c> newInterviews) {
        Set<Id> candidateIds = new Set<Id>();
        
        // Find interviews that are already Completed on insert
        for (Interview__c interview : newInterviews) {
            if (interview.Interview_Status__c == 'Completed' && interview.Candidate__c != null) {
                candidateIds.add(interview.Candidate__c);
            }
        }
        
        if (!candidateIds.isEmpty()) {
            updateCandidateHighestLevel(candidateIds);
        }
    }
    
    /**
     * Update Candidate's Highest Level Achieved based on completed interviews.
     * Only updates if the new level is higher than the current level.
     * @param candidateIds Set of Candidate IDs to update
     */
    private static void updateCandidateHighestLevel(Set<Id> candidateIds) {
        // Query all completed interviews for these candidates
        Map<Id, List<Interview__c>> interviewsByCandidateId = new Map<Id, List<Interview__c>>();
        
        for (Interview__c interview : [
            SELECT Id, Candidate__c, Interview_Type__c, Interview_Status__c
            FROM Interview__c
            WHERE Candidate__c IN :candidateIds
            AND Interview_Status__c = 'Completed'
            AND Interview_Type__c != null
            ORDER BY CreatedDate DESC
        ]) {
            if (!interviewsByCandidateId.containsKey(interview.Candidate__c)) {
                interviewsByCandidateId.put(interview.Candidate__c, new List<Interview__c>());
            }
            interviewsByCandidateId.get(interview.Candidate__c).add(interview);
        }
        
        // Query current Candidate records
        Map<Id, Candidate__c> candidatesToUpdate = new Map<Id, Candidate__c>([
            SELECT Id, Highest_Level_Achieved__c
            FROM Candidate__c
            WHERE Id IN :candidateIds
        ]);
        
        // Determine highest level for each candidate
        List<Candidate__c> candidatesNeedingUpdate = new List<Candidate__c>();
        
        for (Id candidateId : candidateIds) {
            Candidate__c candidate = candidatesToUpdate.get(candidateId);
            if (candidate == null) continue;
            
            List<Interview__c> completedInterviews = interviewsByCandidateId.get(candidateId);
            if (completedInterviews == null || completedInterviews.isEmpty()) continue;
            
            // Find the highest interview level completed
            String highestInterviewLevel = null;
            Integer highestIndex = -1;
            
            for (Interview__c interview : completedInterviews) {
                // Interview_Type__c now matches Highest_Level_Achieved__c values exactly
                String interviewType = interview.Interview_Type__c;
                if (interviewType != null) {
                    Integer levelIndex = HIGHEST_LEVEL_ORDER.indexOf(interviewType);
                    if (levelIndex > highestIndex) {
                        highestIndex = levelIndex;
                        highestInterviewLevel = interviewType;
                    }
                }
            }
            
            // Only update if we found a level and it's higher than current
            if (highestInterviewLevel != null) {
                Integer currentIndex = HIGHEST_LEVEL_ORDER.indexOf(candidate.Highest_Level_Achieved__c);
                if (currentIndex == -1) currentIndex = -1; // Treat null/unknown as lowest
                
                if (highestIndex > currentIndex) {
                    candidate.Highest_Level_Achieved__c = highestInterviewLevel;
                    candidatesNeedingUpdate.add(candidate);
                }
            }
        }
        
        // Update candidates
        if (!candidatesNeedingUpdate.isEmpty()) {
            update candidatesNeedingUpdate;
        }
    }
}
