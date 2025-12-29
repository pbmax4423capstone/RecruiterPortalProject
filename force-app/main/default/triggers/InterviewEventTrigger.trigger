trigger InterviewEventTrigger on Interview__c (after insert, after update) {
    InterviewEventHandler.handleInterviewChanges(Trigger.new, Trigger.oldMap);
}
