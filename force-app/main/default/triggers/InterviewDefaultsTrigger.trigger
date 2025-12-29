trigger InterviewDefaultsTrigger on Interview__c (before insert) {
    InterviewDefaultsHandler.setDefaultValues(Trigger.new);
}
