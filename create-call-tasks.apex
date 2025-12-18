// Script to create 602 call tasks using the createScheduledCall method
// This ensures TaskSubtype is set to 'Call' properly

List<Task> tasksToInsert = new List<Task>();

// First batch of tasks (you'll need to run this in chunks due to heap size limits)
// Each task will be created with the proper fields set

Task t1 = new Task(
    Subject = 'Call',
    WhoId = '003Vo00000ktSBEIA2',
    ActivityDate = Date.valueOf('2025-03-21'),
    Status = 'Not Started',
    Priority = 'Normal',
    OwnerId = '0055f00000DqpnpAAB',
    TaskSubtype = 'Call'
);
tasksToInsert.add(t1);

// Insert the tasks
try {
    insert tasksToInsert;
    System.debug('Successfully created ' + tasksToInsert.size() + ' tasks');
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}

// Query to verify
List<Task> verifyTasks = [SELECT Id, Subject, TaskSubtype FROM Task WHERE Id IN :tasksToInsert LIMIT 5];
for (Task t : verifyTasks) {
    System.debug('Task: ' + t.Subject + ' - TaskSubtype: ' + t.TaskSubtype);
}
