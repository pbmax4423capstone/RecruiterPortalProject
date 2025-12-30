/**
 * @description Comprehensive test class for TaskTriggerHandler
 */
@isTest
private class TaskTriggerHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test Candidate for task association
        Candidate__c testCandidate = new Candidate__c(
            First_Name__c = 'Task',
            Last_Name__c = 'Handler',
            Email__c = 'taskhandler@test.com',
            Status__c = 'Active/In Process',
            Sales_Manager__c = 'Tim Denton'
        );
        insert testCandidate;
        
        // Create test Account for task association
        Account testAccount = new Account(
            Name = 'Task Test Account'
        );
        insert testAccount;
    }
    
    @isTest
    static void testCreateNoteFromCall_InsertCompletedTask() {
        Candidate__c candidate = [SELECT Id FROM Candidate__c WHERE Email__c = 'taskhandler@test.com' LIMIT 1];
        
        Test.startTest();
        // Insert a completed call task with description
        Task completedTask = new Task(
            Status = 'Completed',
            Type = 'Call',
            Subject = 'Test Call with Client',
            Description = 'Discussed contract details and next steps. Client is interested in proceeding.',
            WhatId = candidate.Id
        );
        insert completedTask;
        Test.stopTest();
        
        // Verify ContentNote was created
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :candidate.Id
        ];
        
        System.assertNotEquals(0, links.size(), 'ContentDocumentLink should be created');
        System.assertEquals(candidate.Id, links[0].LinkedEntityId, 'Link should be to the candidate');
        
        // Verify ContentNote content
        List<ContentVersion> notes = [
            SELECT Title, TextPreview 
            FROM ContentVersion 
            WHERE ContentDocumentId = :links[0].ContentDocumentId 
            AND IsLatest = true
        ];
        
        System.assertEquals(1, notes.size(), 'Should have one ContentNote');
        System.assert(notes[0].Title.contains('Call Notes'), 'Title should contain "Call Notes"');
    }
    
    @isTest
    static void testCreateNoteFromCall_UpdateToCompleted() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Task Test Account' LIMIT 1];
        
        // Insert not completed task
        Task incompleteTask = new Task(
            Status = 'Not Started',
            Type = 'Call',
            Subject = 'Follow-up Call',
            Description = 'Need to discuss pricing and timeline',
            WhatId = account.Id
        );
        insert incompleteTask;
        
        // Verify no note created yet
        Integer linksBefore = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :account.Id];
        System.assertEquals(0, linksBefore, 'No links should exist before completion');
        
        Test.startTest();
        // Update task to completed
        incompleteTask.Status = 'Completed';
        update incompleteTask;
        Test.stopTest();
        
        // Verify ContentNote was created after update
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :account.Id
        ];
        
        System.assertEquals(1, links.size(), 'ContentDocumentLink should be created after completion');
    }
    
    @isTest
    static void testCreateNoteFromCall_NoDescription() {
        Candidate__c candidate = [SELECT Id FROM Candidate__c WHERE Email__c = 'taskhandler@test.com' LIMIT 1];
        
        Test.startTest();
        // Insert completed task without description
        Task taskNoDesc = new Task(
            Status = 'Completed',
            Type = 'Call',
            Subject = 'Call without notes',
            WhatId = candidate.Id
        );
        insert taskNoDesc;
        Test.stopTest();
        
        // Verify no ContentNote was created (description is blank)
        Integer linkCount = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :candidate.Id];
        System.assertEquals(0, linkCount, 'No link should be created without description');
    }
    
    @isTest
    static void testCreateNoteFromCall_NotCallType() {
        Candidate__c candidate = [SELECT Id FROM Candidate__c WHERE Email__c = 'taskhandler@test.com' LIMIT 1];
        
        Test.startTest();
        // Insert completed task that is not a Call type
        Task emailTask = new Task(
            Status = 'Completed',
            Type = 'Email',
            Subject = 'Sent Email',
            Description = 'Email content here',
            WhatId = candidate.Id
        );
        insert emailTask;
        Test.stopTest();
        
        // Verify no ContentNote was created (not a Call type)
        Integer linkCount = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :candidate.Id];
        System.assertEquals(0, linkCount, 'No link should be created for non-Call tasks');
    }
    
    @isTest
    static void testCreateNoteFromCall_NoWhatId() {
        Test.startTest();
        // Insert completed call without WhatId
        Task taskNoWhat = new Task(
            Status = 'Completed',
            Type = 'Call',
            Subject = 'Call without entity',
            Description = 'Some notes'
        );
        insert taskNoWhat;
        Test.stopTest();
        
        // Should not throw exception, but no note created
        System.assert(true, 'Should handle task without WhatId gracefully');
    }
    
    @isTest
    static void testCreateNoteFromCall_UpdateAlreadyCompleted() {
        Candidate__c candidate = [SELECT Id FROM Candidate__c WHERE Email__c = 'taskhandler@test.com' LIMIT 1];
        
        // Insert already completed task
        Task completedTask = new Task(
            Status = 'Completed',
            Type = 'Call',
            Subject = 'Initial Call',
            Description = 'Initial notes',
            WhatId = candidate.Id
        );
        insert completedTask;
        
        // Get count of links after insert
        Integer linksAfterInsert = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :candidate.Id];
        
        Test.startTest();
        // Update the already completed task (status remains Completed)
        completedTask.Subject = 'Updated Call Subject';
        update completedTask;
        Test.stopTest();
        
        // Verify no additional note was created
        Integer linksAfterUpdate = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :candidate.Id];
        System.assertEquals(linksAfterInsert, linksAfterUpdate, 'Should not create duplicate notes');
    }
    
    @isTest
    static void testCreateNoteFromCall_MultipleTasks() {
        Candidate__c candidate = [SELECT Id FROM Candidate__c WHERE Email__c = 'taskhandler@test.com' LIMIT 1];
        
        List<Task> tasks = new List<Task>();
        for (Integer i = 0; i < 3; i++) {
            tasks.add(new Task(
                Status = 'Completed',
                Type = 'Call',
                Subject = 'Call ' + i,
                Description = 'Call notes ' + i,
                WhatId = candidate.Id
            ));
        }
        
        Test.startTest();
        insert tasks;
        Test.stopTest();
        
        // Verify 3 ContentNotes were created
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :candidate.Id
        ];
        
        System.assertEquals(3, links.size(), 'Should create 3 ContentDocumentLinks for 3 tasks');
    }
    
    @isTest
    static void testCreateNoteFromCall_MixedStatusUpdate() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Task Test Account' LIMIT 1];
        
        // Create mix of tasks
        List<Task> tasks = new List<Task>();
        tasks.add(new Task(
            Status = 'Not Started',
            Type = 'Call',
            Subject = 'Call 1',
            Description = 'Notes 1',
            WhatId = account.Id
        ));
        tasks.add(new Task(
            Status = 'In Progress',
            Type = 'Call',
            Subject = 'Call 2',
            Description = 'Notes 2',
            WhatId = account.Id
        ));
        insert tasks;
        
        Test.startTest();
        // Update both to completed
        for (Task t : tasks) {
            t.Status = 'Completed';
        }
        update tasks;
        Test.stopTest();
        
        // Verify 2 notes created
        Integer linkCount = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :account.Id];
        System.assertEquals(2, linkCount, 'Should create 2 notes for 2 completed tasks');
    }
    
    @isTest
    static void testCreateNoteFromCall_WithBlankDescriptionString() {
        Candidate__c candidate = [SELECT Id FROM Candidate__c WHERE Email__c = 'taskhandler@test.com' LIMIT 1];
        
        Test.startTest();
        // Insert with empty string description
        Task task = new Task(
            Status = 'Completed',
            Type = 'Call',
            Subject = 'Call',
            Description = '   ',  // Just whitespace
            WhatId = candidate.Id
        );
        insert task;
        Test.stopTest();
        
        // Verify no note created (blank description)
        Integer linkCount = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :candidate.Id];
        System.assertEquals(0, linkCount, 'Should not create note for whitespace-only description');
    }
}
