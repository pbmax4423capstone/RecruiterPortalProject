public with sharing class CandidateActivityController {
    
    @AuraEnabled(cacheable=true)
    public static List<ActivityWrapper> getActivities(Id candidateId) {
        List<ActivityWrapper> activities = new List<ActivityWrapper>();
        
        if (candidateId == null) {
            return activities;
        }
        
        // Get Tasks
        for (Task t : [
            SELECT Id, Subject, Status, Priority, ActivityDate, Owner.Name, Type
            FROM Task
            WHERE WhatId = :candidateId
            ORDER BY ActivityDate DESC NULLS LAST, CreatedDate DESC
            LIMIT 100
        ]) {
            activities.add(new ActivityWrapper(
                t.Id,
                t.Subject,
                'Task',
                t.Status,
                t.Priority,
                t.ActivityDate,
                t.Owner.Name
            ));
        }
        
        // Get Events
        for (Event e : [
            SELECT Id, Subject, Type, StartDateTime, Owner.Name
            FROM Event
            WHERE WhatId = :candidateId
            ORDER BY StartDateTime DESC
            LIMIT 100
        ]) {
            activities.add(new ActivityWrapper(
                e.Id,
                e.Subject,
                'Event',
                null,
                null,
                Date.valueOf(e.StartDateTime),
                e.Owner.Name
            ));
        }
        
        return activities;
    }
    
    @AuraEnabled
    public static void completeTask(Id taskId) {
        try {
            Task t = [SELECT Id, Status FROM Task WHERE Id = :taskId LIMIT 1];
            t.Status = 'Completed';
            update t;
        } catch (Exception e) {
            throw new AuraHandledException('Error completing task: ' + e.getMessage());
        }
    }
    
    public class ActivityWrapper {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String Subject { get; set; }
        @AuraEnabled public String ActivityType { get; set; }
        @AuraEnabled public String Status { get; set; }
        @AuraEnabled public String Priority { get; set; }
        @AuraEnabled public Date ActivityDate { get; set; }
        @AuraEnabled public String OwnerName { get; set; }
        
        public ActivityWrapper(Id id, String subject, String activityType, 
                             String status, String priority, Date activityDate, String ownerName) {
            this.Id = id;
            this.Subject = subject;
            this.ActivityType = activityType;
            this.Status = status;
            this.Priority = priority;
            this.ActivityDate = activityDate;
            this.OwnerName = ownerName;
        }
    }
}
