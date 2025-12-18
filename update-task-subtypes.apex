// Update Task CallType to 'Call' for tasks in the report
// Get all tasks from March 21, 2025 and update CallType to 'Call'

List<Task> tasksToUpdate = [
    SELECT Id, CallType, Subject
    FROM Task 
    WHERE ActivityDate = 2025-03-21
    AND Owner.Name = 'Rachyll Tenny'
    LIMIT 1000
];

System.debug('Found ' + tasksToUpdate.size() + ' tasks to update');

for(Task t : tasksToUpdate) {
    t.CallType = 'Call';
}

update tasksToUpdate;

System.debug('Successfully updated ' + tasksToUpdate.size() + ' tasks to CallType = Call');
