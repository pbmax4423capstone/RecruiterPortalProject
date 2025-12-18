@isTest
public class ScheduledCallsControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test contact
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert contact;
        
        // Create task for today (current user)
        Task task = new Task(
            Subject = 'Call',
            WhoId = contact.Id,
            ActivityDate = Date.today(),
            Status = 'Open',
            OwnerId = UserInfo.getUserId(),
            TaskSubtype = 'Call'
        );
        insert task;
        
        // Create task for different date (should not appear)
        Task futureTask = new Task(
            Subject = 'Future Call',
            WhoId = contact.Id,
            ActivityDate = Date.today().addDays(1),
            Status = 'Open',
            OwnerId = UserInfo.getUserId()
        );
        insert futureTask;
        
        // Create completed task (should not appear)
        Task completedTask = new Task(
            Subject = 'Completed Call',
            WhoId = contact.Id,
            ActivityDate = Date.today(),
            Status = 'Completed',
            OwnerId = UserInfo.getUserId()
        );
        insert completedTask;
    }
    
    @isTest
    static void testGetScheduledCalls() {
        Test.startTest();
        Map<String, List<Task>> result = ScheduledCallsController.getScheduledCalls();
        Test.stopTest();
        
        List<Task> scheduledCalls = result.get('scheduled');
        List<Task> pastDueCalls = result.get('pastDue');
        
        // Should only return 1 task in scheduled - today's open task for current user
        System.assertEquals(1, scheduledCalls.size(), 'Should return exactly 1 scheduled call');
        System.assertEquals(UserInfo.getUserId(), scheduledCalls[0].OwnerId, 'Should be for current user');
        System.assertEquals(Date.today(), scheduledCalls[0].ActivityDate, 'Should be scheduled for today');
        
        // Should have no past due calls
        System.assertEquals(0, pastDueCalls.size(), 'Should have no past due calls');
    }
    
    @isTest
    static void testGetScheduledCallsNoResults() {
        // Delete all test tasks
        delete [SELECT Id FROM Task];
        
        Test.startTest();
        Map<String, List<Task>> result = ScheduledCallsController.getScheduledCalls();
        Test.stopTest();
        
        List<Task> scheduledCalls = result.get('scheduled');
        List<Task> pastDueCalls = result.get('pastDue');
        
        System.assertEquals(0, scheduledCalls.size(), 'Should return no scheduled calls');
        System.assertEquals(0, pastDueCalls.size(), 'Should return no past due calls');
    }
    
    @isTest
    static void testDeleteTask() {
        // Get the test task
        Task testTask = [SELECT Id, Subject FROM Task WHERE Subject = 'Call' LIMIT 1];
        
        Test.startTest();
        ScheduledCallsController.deleteTask(testTask.Id);
        Test.stopTest();
        
        // Verify task was deleted
        List<Task> remainingTasks = [SELECT Id FROM Task WHERE Id = :testTask.Id];
        System.assertEquals(0, remainingTasks.size(), 'Task should be deleted');
    }
    
    @isTest
    static void testDeleteTaskError() {
        // Create a task and then delete it to get a valid but non-existent ID
        Task tempTask = new Task(
            Subject = 'Temp Task',
            ActivityDate = Date.today(),
            Status = 'Open'
        );
        insert tempTask;
        Id deletedTaskId = tempTask.Id;
        delete tempTask;
        
        Test.startTest();
        try {
            ScheduledCallsController.deleteTask(deletedTaskId);
            System.assert(false, 'Should have thrown an exception');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Should throw AuraHandledException');
        }
        Test.stopTest();
    }
}