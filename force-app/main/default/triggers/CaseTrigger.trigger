trigger CaseTrigger on Case (after update) {
    CaseTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
}