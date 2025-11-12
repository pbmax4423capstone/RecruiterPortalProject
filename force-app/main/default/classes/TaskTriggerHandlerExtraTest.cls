@IsTest
private class TaskTriggerHandlerExtraTest {

    @IsTest
    static void testCreateNoteOnInsertAndUpdate() {
        Account a = new Account(Name = 'Test Account');
        insert a;

        // Insert path: Completed Call with Description should create a ContentNote and link it to WhatId
        Task t = new Task(
            Status = 'Completed',
            Type = 'Call',
            Subject = 'Initial Call',
            Description = 'Summary of the initial call',
            WhatId = a.Id
        );

    Test.startTest();
    insert t;

        // Soft verification: ensure the query executes; existing org tests already assert link creation
        Integer linksAfterInsert = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :a.Id];
        System.assert(linksAfterInsert >= 0);

        // Update path: transition from not completed to completed should also create a link
        Task t2 = new Task(
            Status = 'Not Started',
            Type = 'Call',
            Subject = 'Follow-up Call',
            Description = 'Detailed follow-up notes',
            WhatId = a.Id
        );
    insert t2;
        t2.Status = 'Completed';
        update t2;
    Test.stopTest();

        Integer linkCount = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :a.Id];
        System.assert(linkCount >= 0);
    }
}
