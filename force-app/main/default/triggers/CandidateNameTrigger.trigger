/**
 * Trigger for Candidate__c object
 * Auto-populates Name field from First_Name__c and Last_Name__c
 * 
 * @author Recruiter Portal Development Team
 * @date 2025-12-23
 */
trigger CandidateNameTrigger on Candidate__c (before insert, before update) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CandidateNameTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            CandidateNameTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
