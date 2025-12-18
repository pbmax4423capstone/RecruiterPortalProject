System.debug('Testing getCurrentUserCallDetails - Past Due');
List<Map<String, Object>> result = RecruiterDashboardController.getCurrentUserCallDetails('pastdue');
System.debug('Past Due results count: ' + result.size());

// Also query directly to see what TaskSubtype these tasks actually have
List<Task> allPastDueTasks = [
    SELECT Id, Subject, TaskSubtype, Type, ActivityDate, Description
    FROM Task 
    WHERE OwnerId = :UserInfo.getUserId()
    AND IsClosed = false 
    AND ActivityDate < TODAY
    ORDER BY ActivityDate ASC
    LIMIT 20
];
System.debug('Total past due open tasks (all types): ' + allPastDueTasks.size());
for(Task t : allPastDueTasks) {
    System.debug('Task: ' + t.Subject);
    System.debug('  TaskSubtype: ' + t.TaskSubtype);
    System.debug('  Type: ' + t.Type);
    System.debug('  Description starts with: ' + (t.Description != null ? t.Description.left(50) : 'null'));
    System.debug('---');
}
