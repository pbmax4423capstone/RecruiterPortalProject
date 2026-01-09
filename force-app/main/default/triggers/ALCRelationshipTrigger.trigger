/**
 * Trigger for ALC__c object
 * Delegates to ALCRelationshipTriggerHandler for Contact/Candidate creation
 * 
 * @group ALC Automation
 * @date 2026-01-08
 */
trigger ALCRelationshipTrigger on ALC__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ALCRelationshipTriggerHandler.handleBeforeInsert(Trigger.new);
    }
}
