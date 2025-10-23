public without sharing class RecruiterRescheduleHelper {
    
    @AuraEnabled
    public static String rescheduleCalls(List<String> taskIds, String newDate, String newTime, String notes) {
        try {
            // Validate inputs
            if (taskIds == null || taskIds.isEmpty()) {
                return 'ERROR: No tasks selected for rescheduling';
            }
            
            if (String.isBlank(newDate)) {
                return 'ERROR: New date is required';
            }
            
            // Parse the new date
            Date scheduledDate = Date.valueOf(newDate);
            
            // Get the tasks to reschedule - using without sharing to bypass restrictions
            List<Task> tasksToUpdate = [
                SELECT Id, Subject, Description, ActivityDate, Status, OwnerId, WhatId, WhoId
                FROM Task 
                WHERE Id IN :taskIds
            ];
            
            if (tasksToUpdate.isEmpty()) {
                return 'ERROR: No tasks found with the provided IDs';
            }
            
            // Update each task
            for (Task task : tasksToUpdate) {
                task.ActivityDate = scheduledDate;
                task.Status = 'Not Started'; // Reset status for rescheduled calls
                
                // Add reschedule note to description
                String rescheduleNote = 'RESCHEDULED: ' + DateTime.now().format('MM/dd/yyyy hh:mm a');
                if (String.isNotBlank(newTime)) {
                    rescheduleNote += ' - New time: ' + newTime;
                }
                if (String.isNotBlank(notes)) {
                    rescheduleNote += ' - Notes: ' + notes;
                }
                
                task.Description = (String.isNotBlank(task.Description) ? 
                    task.Description + '\n\n' : '') + rescheduleNote;
            }
            
            // Update the tasks using without sharing
            update tasksToUpdate;
            
            return 'SUCCESS: Rescheduled ' + tasksToUpdate.size() + ' call(s) to ' + 
                   scheduledDate.format() + 
                   (String.isNotBlank(newTime) ? ' at ' + newTime : '');
                   
        } catch (Exception e) {
            System.debug('Error rescheduling calls: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            return 'ERROR: ' + e.getMessage();
        }
    }
}