public without sharing class ScheduledCallsController {
    
    @AuraEnabled
    public static List<Task> getScheduledCalls() {
        try {
            Id currentUserId = UserInfo.getUserId();
            System.debug('Current User ID: ' + currentUserId);
            
            List<Task> tasks = [
                SELECT Id, 
                       Subject,
                       WhoId,
                       Who.Name,
                       WhatId,
                       What.Name,
                       ActivityDate,
                       Status,
                       OwnerId,
                       Owner.Name
                FROM Task
                WHERE ActivityDate = TODAY
                  AND IsClosed = false
                  AND TaskSubtype != 'Email'
                ORDER BY ActivityDate ASC
            ];
            
            System.debug('Total tasks found: ' + tasks.size());
            
            // Filter by current user in code since cacheable methods have issues with UserInfo
            List<Task> userTasks = new List<Task>();
            for (Task t : tasks) {
                if (t.OwnerId == currentUserId) {
                    userTasks.add(t);
                }
            }
            
            System.debug('User tasks found: ' + userTasks.size());
            return userTasks;
        } catch (Exception e) {
            System.debug('Error in getScheduledCalls: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error retrieving scheduled calls: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteTask(Id taskId) {
        try {
            Task taskToDelete = [SELECT Id FROM Task WHERE Id = :taskId LIMIT 1];
            delete taskToDelete;
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting task: ' + e.getMessage());
        }
    }
}
