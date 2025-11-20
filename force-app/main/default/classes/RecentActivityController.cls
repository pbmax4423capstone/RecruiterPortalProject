public without sharing class RecentActivityController {
    @AuraEnabled
    public static List<Task> getRecentActivity() {
        Id currentUserId = UserInfo.getUserId();
        
        List<Task> tasks = [
            SELECT Id, Subject, WhoId, Who.Name, WhatId, What.Name, 
                   ActivityDate, Status, CompletedDateTime, OwnerId
            FROM Task
            WHERE IsClosed = true
              AND TaskSubtype != 'Email'
            ORDER BY CompletedDateTime DESC NULLS LAST, ActivityDate DESC
            LIMIT 50
        ];
        
        List<Task> userTasks = new List<Task>();
        for (Task t : tasks) {
            if (t.OwnerId == currentUserId) {
                userTasks.add(t);
            }
        }
        return userTasks;
    }
}
