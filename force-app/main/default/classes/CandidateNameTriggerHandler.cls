/**
 * Trigger Handler for Candidate__c object
 * Handles auto-population of Name field from First_Name__c and Last_Name__c
 * 
 * @author Recruiter Portal Development Team
 * @date 2025-12-23
 */
public class CandidateNameTriggerHandler {
    
    /**
     * Sets the Name field for candidates based on First and Last name
     * Handles both insert and update operations
     * 
     * @param candidates List of Candidate__c records
     */
    public static void setNameField(List<Candidate__c> candidates) {
        for (Candidate__c candidate : candidates) {
            // Build name from First and Last name fields
            String firstName = candidate.First_Name__c != null ? candidate.First_Name__c.trim() : '';
            String lastName = candidate.Last_Name__c != null ? candidate.Last_Name__c.trim() : '';
            
            // Set Name field
            if (String.isNotBlank(firstName) && String.isNotBlank(lastName)) {
                candidate.Name = firstName + ' ' + lastName;
            } else if (String.isNotBlank(firstName)) {
                candidate.Name = firstName;
            } else if (String.isNotBlank(lastName)) {
                candidate.Name = lastName;
            }
            // If both are blank, Name will remain as set by user or default
        }
    }
    
    /**
     * Handles before insert event
     * 
     * @param newCandidates List of new Candidate__c records
     */
    public static void handleBeforeInsert(List<Candidate__c> newCandidates) {
        setNameField(newCandidates);
    }
    
    /**
     * Handles before update event
     * Only updates Name if First or Last name has changed
     * 
     * @param newCandidates List of updated Candidate__c records
     * @param oldCandidatesMap Map of old Candidate__c records
     */
    public static void handleBeforeUpdate(List<Candidate__c> newCandidates, Map<Id, Candidate__c> oldCandidatesMap) {
        List<Candidate__c> candidatesToUpdate = new List<Candidate__c>();
        
        for (Candidate__c candidate : newCandidates) {
            Candidate__c oldCandidate = oldCandidatesMap.get(candidate.Id);
            
            // Check if First or Last name changed
            if (candidate.First_Name__c != oldCandidate.First_Name__c || 
                candidate.Last_Name__c != oldCandidate.Last_Name__c) {
                candidatesToUpdate.add(candidate);
            }
        }
        
        if (!candidatesToUpdate.isEmpty()) {
            setNameField(candidatesToUpdate);
        }
    }
}