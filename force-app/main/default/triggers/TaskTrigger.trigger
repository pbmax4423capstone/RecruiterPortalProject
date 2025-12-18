trigger TaskTrigger on Task (after insert, after update) {
    TaskTriggerHandler.createNoteFromCall(Trigger.new, Trigger.oldMap);
}