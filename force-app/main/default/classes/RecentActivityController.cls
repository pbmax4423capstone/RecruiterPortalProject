public without sharing class RecentActivityController {
    @AuraEnabled(cacheable=false)
    public static List<Task> getRecentActivity() {
        Id currentUserId = UserInfo.getUserId();
        
        // Get today's date range to handle timezone differences
        DateTime startOfToday = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        DateTime endOfToday = DateTime.newInstance(Date.today(), Time.newInstance(23, 59, 59, 999));
        
        System.debug('=== Recent Activity Query ===');
        System.debug('Current User: ' + currentUserId);
        System.debug('Today date: ' + Date.today());
        System.debug('Start of today: ' + startOfToday);
        System.debug('End of today: ' + endOfToday);
        
        // Query all closed tasks for today, we'll filter Type in code to handle nulls
        List<Task> allTasks = [
            SELECT Id, Subject, WhoId, Who.Name, WhatId, What.Name, 
                   ActivityDate, Status, CompletedDateTime, OwnerId, Description, Type, TaskSubtype
            FROM Task
            WHERE OwnerId = :currentUserId
              AND IsClosed = true
              AND TaskSubtype != 'Email'
              AND CompletedDateTime >= :startOfToday
              AND CompletedDateTime <= :endOfToday
            ORDER BY CompletedDateTime DESC NULLS LAST
            LIMIT 100
        ];
        
        System.debug('Found ' + allTasks.size() + ' total closed tasks (non-email) for today');
        
        // Filter to only Call or Task types (or null Type which defaults to Task)
        List<Task> filteredTasks = new List<Task>();
        for (Task t : allTasks) {
            System.debug('Task: ' + t.Subject + ', Type: ' + t.Type + ', Status: ' + t.Status + ', CompletedDateTime: ' + t.CompletedDateTime);
            // Include if Type is Call, Task, or null (null defaults to Task)
            if (t.Type == 'Call' || t.Type == 'Task' || t.Type == null) {
                filteredTasks.add(t);
            }
        }
        
        System.debug('Returning ' + filteredTasks.size() + ' tasks after type filtering');
        return filteredTasks;
    }
}
