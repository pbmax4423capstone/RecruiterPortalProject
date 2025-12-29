@SuppressWarnings('PMD.AvoidHardcodingId')
public with sharing class InterviewEventHandler {
    
    // SF Sales Managers who should have Events created
    private static final Set<String> SF_SALES_MANAGER_NAMES = new Set<String>{
        'Andrew Moore', 'Brooke Ianni', 'Rachyll Tenny', 'Tim Denton', 'Van Hess',
        'Elizabeth Kagele', 'Bradley Sofonia'
    };
    
    private static final Set<Id> SF_SALES_MANAGER_IDS = new Set<Id>{
        '0055f00000EXvFGAA1', // Andrew Moore
        '0055f00000EXakXAAT', // Brooke Ianni
        '0055f00000DqpnpAAB', // Rachyll Tenny
        '0055f0000081I14AAE', // Tim Denton
        '0055f00000A7BFWAA3', // Van Hess
        '005Vo00000ktgovIAA', // Elizabeth Kagele
        '005Vo00000fcekpIAA'  // Bradley Sofonia
    };
    
    public static void handleInterviewChanges(List<Interview__c> newInterviews, Map<Id, Interview__c> oldMap) {
        // Get Interview RecordType for Events
        Id interviewRecordTypeId;
        try {
            interviewRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName()
                .get('Interview').getRecordTypeId();
        } catch (Exception e) {
            System.debug('Warning: Interview RecordType not found for Event');
        }
        
        List<Event> eventsToInsert = new List<Event>();
        List<Event> eventsToUpdate = new List<Event>();
        Set<Id> interviewIds = new Set<Id>();
        
        // Collect Interview IDs that need Event processing
        for (Interview__c interview : newInterviews) {
            Interview__c oldInterview = (oldMap != null) ? oldMap.get(interview.Id) : null;
            
            // Check if this is a new interview OR if Conducted_By changed
            if (oldInterview == null || interview.Conducted_By__c != oldInterview.Conducted_By__c) {
                interviewIds.add(interview.Id);
            }
        }
        
        if (interviewIds.isEmpty()) {
            return;
        }
        
        // Query existing Events - we'll match them by checking Description for Interview ID
        // This is a workaround since Event.WhatId can't link to custom objects
        Map<Id, Event> existingEventsByInterviewId = new Map<Id, Event>();
        List<Event> potentialEvents = [
            SELECT Id, Description, OwnerId, ActivityDate 
            FROM Event 
            WHERE OwnerId IN :SF_SALES_MANAGER_IDS 
            AND ActivityDate = TODAY
            LIMIT 1000
        ];
        for (Event evt : potentialEvents) {
            if (evt.Description != null && evt.Description.contains('Interview ID: ')) {
                // Extract Interview ID from description
                String interviewIdStr = evt.Description.substringAfter('Interview ID: ').substringBefore('\n').trim();
                if (interviewIds.contains(interviewIdStr)) {
                    existingEventsByInterviewId.put((Id)interviewIdStr, evt);
                }
            }
        }
        
        // Query full Interview__c records with Candidate relationship
        Map<Id, Interview__c> interviewMap = new Map<Id, Interview__c>([
            SELECT Id, Candidate__c, Candidate__r.First_Name__c, Candidate__r.Last_Name__c,
                   Interview_Type__c, Conducted_By__c, Interview_Status__c, Notes__c, CreatedDate
            FROM Interview__c
            WHERE Id IN :interviewIds
        ]);
        
        for (Id interviewId : interviewIds) {
            Interview__c interview = interviewMap.get(interviewId);
            
            // Only create/update Event if Conducted_By is a SF Sales Manager
            if (interview.Conducted_By__c != null && 
                SF_SALES_MANAGER_IDS.contains(interview.Conducted_By__c)) {
                
                Event existingEvent = existingEventsByInterviewId.get(interviewId);
                
                if (existingEvent != null) {
                    // Update existing Event
                    existingEvent.OwnerId = interview.Conducted_By__c;
                    existingEvent.Subject = getEventSubject(interview);
                    existingEvent.Description = getEventDescription(interview);
                    eventsToUpdate.add(existingEvent);
                } else {
                    // Create new Event
                    Event newEvent = new Event(
                        Subject = getEventSubject(interview),
                        ActivityDate = getEventDate(interview),
                        OwnerId = interview.Conducted_By__c,
                        RecordTypeId = interviewRecordTypeId,
                        Type = interview.Interview_Type__c + ' Interview',
                        Description = getEventDescription(interview) + '\n\nInterview ID: ' + interviewId,
                        IsAllDayEvent = true
                    );
                    eventsToInsert.add(newEvent);
                }
            } else if (existingEventsByInterviewId.containsKey(interviewId)) {
                // Conducted_By changed to non-SF user or null - could delete Event
                // For now, leaving existing Events alone to preserve history
                System.debug('Interview ' + interviewId + ' no longer has SF Sales Manager - Event preserved');
            }
        }
        
        // Bulk DML operations
        if (!eventsToInsert.isEmpty()) {
            try {
                insert eventsToInsert;
                System.debug('Created ' + eventsToInsert.size() + ' Event records');
            } catch (Exception e) {
                System.debug('Error creating Events: ' + e.getMessage());
            }
        }
        
        if (!eventsToUpdate.isEmpty()) {
            try {
                update eventsToUpdate;
                System.debug('Updated ' + eventsToUpdate.size() + ' Event records');
            } catch (Exception e) {
                System.debug('Error updating Events: ' + e.getMessage());
            }
        }
    }
    
    private static String getEventSubject(Interview__c interview) {
        String candidateName = '';
        if (interview.Candidate__r != null) {
            candidateName = interview.Candidate__r.First_Name__c + ' ' + 
                           interview.Candidate__r.Last_Name__c;
        }
        return interview.Interview_Type__c + ' Interview - ' + candidateName;
    }
    
    private static String getEventDescription(Interview__c interview) {
        List<String> parts = new List<String>();
        parts.add('Interview Type: ' + interview.Interview_Type__c);
        parts.add('Status: ' + interview.Interview_Status__c);
        if (interview.Notes__c != null) {
            parts.add('Notes: ' + interview.Notes__c);
        }
        return String.join(parts, '\n');
    }
    
    private static Date getEventDate(Interview__c interview) {
        // Use CreatedDate as the event date (can be customized if Interview__c has a date field)
        return interview.CreatedDate.date();
    }
}
