public without sharing class ScheduledCallsController {
    
    @AuraEnabled(cacheable=false)
    public static Map<String, List<Task>> getScheduledCalls() {
        try {
            Id currentUserId = UserInfo.getUserId();
            System.debug('Current User ID: ' + currentUserId);
            
            List<Task> allTasks = [
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
                WHERE ActivityDate <= TODAY
                  AND IsClosed = false
                  AND TaskSubtype = 'Call'
                  AND OwnerId = :currentUserId
                ORDER BY ActivityDate ASC
            ];
            
            System.debug('Total tasks found: ' + allTasks.size());
            
            // Split into scheduled (today) and past due (before today)
            List<Task> scheduledCalls = new List<Task>();
            List<Task> pastDueCalls = new List<Task>();
            
            for (Task t : allTasks) {
                if (t.ActivityDate == Date.today()) {
                    scheduledCalls.add(t);
                } else if (t.ActivityDate < Date.today()) {
                    pastDueCalls.add(t);
                }
            }
            
            System.debug('Scheduled calls (today): ' + scheduledCalls.size());
            System.debug('Past due calls: ' + pastDueCalls.size());
            
            Map<String, List<Task>> result = new Map<String, List<Task>>();
            result.put('scheduled', scheduledCalls);
            result.put('pastDue', pastDueCalls);
            
            return result;
        } catch (Exception e) {
            System.debug('Error in getScheduledCalls: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error retrieving scheduled calls: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, List<Task>> getAllScheduledTasks() {
        try {
            Id currentUserId = UserInfo.getUserId();
            System.debug('Current User ID: ' + currentUserId);
            
            List<Task> allTasks = [
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
                WHERE ActivityDate <= TODAY
                  AND IsClosed = false
                  AND OwnerId = :currentUserId
                  AND TaskSubtype != 'Email'
                  AND TaskSubtype != 'Call'
                ORDER BY ActivityDate ASC
            ];
            
            System.debug('Total tasks found: ' + allTasks.size());
            
            // Split into scheduled (today) and past due (before today)
            List<Task> scheduledTasks = new List<Task>();
            List<Task> pastDueTasks = new List<Task>();
            
            for (Task t : allTasks) {
                if (t.ActivityDate == Date.today()) {
                    scheduledTasks.add(t);
                } else if (t.ActivityDate < Date.today()) {
                    pastDueTasks.add(t);
                }
            }
            
            System.debug('Scheduled tasks (today): ' + scheduledTasks.size());
            System.debug('Past due tasks: ' + pastDueTasks.size());
            
            Map<String, List<Task>> result = new Map<String, List<Task>>();
            result.put('scheduled', scheduledTasks);
            result.put('pastDue', pastDueTasks);
            
            return result;
        } catch (Exception e) {
            System.debug('Error in getAllScheduledTasks: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error retrieving scheduled tasks: ' + e.getMessage());
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
    
    @AuraEnabled
    public static String createTask(String subject, Date activityDate, String priority, String status, String description) {
        try {
            Task newTask = new Task();
            newTask.Subject = subject;
            newTask.Priority = priority;
            newTask.Status = status;
            newTask.OwnerId = UserInfo.getUserId();
            
            if (activityDate != null) {
                newTask.ActivityDate = activityDate;
            }
            
            if (String.isNotBlank(description)) {
                newTask.Description = description;
            }
            
            insert newTask;
            return newTask.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating task: ' + e.getMessage());
        }
    }
}