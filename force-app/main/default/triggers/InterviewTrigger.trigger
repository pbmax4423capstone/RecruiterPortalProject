/**
 * Trigger on Interview__c object to update Candidate's Highest Level Achieved
 * when interviews are completed.
 */
trigger InterviewTrigger on Interview__c (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            InterviewTriggerHandler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            InterviewTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
