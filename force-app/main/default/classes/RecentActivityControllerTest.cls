@isTest
public class RecentActivityControllerTest {
  @isTest
  static void testGetRecentActivity() {
    // Create test data
    Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
    insert testContact;

    // Create completed task with today's date
    Task completedTask = new Task(
      Subject = 'Completed Call',
      WhoId = testContact.Id,
      ActivityDate = Date.today(),
      Status = 'Not Started',
      Type = 'Call',
      OwnerId = UserInfo.getUserId()
    );
    insert completedTask;

    // Update to mark as completed (CompletedDateTime will be set to now)
    completedTask.Status = 'Completed';
    update completedTask;

    // Create open task (should not appear)
    Task openTask = new Task(
      Subject = 'Open Call',
      WhoId = testContact.Id,
      ActivityDate = Date.today(),
      Status = 'Not Started',
      Type = 'Call',
      OwnerId = UserInfo.getUserId()
    );
    insert openTask;

    // Create email task (should not appear)
    Task emailTask = new Task(
      Subject = 'Test Email',
      WhoId = testContact.Id,
      ActivityDate = Date.today(),
      Status = 'Completed',
      TaskSubtype = 'Email',
      OwnerId = UserInfo.getUserId()
    );
    insert emailTask;

    // Test the controller
    Test.startTest();
    List<Task> results = RecentActivityController.getRecentActivity();
    Test.stopTest();

    // Verify results
    System.assertNotEquals(null, results, 'Results should not be null');
    System.assert(
      results.size() > 0,
      'Should return at least one completed task'
    );

    Boolean foundCompletedTask = false;
    for (Task t : results) {
      if (t.Id == completedTask.Id) {
        foundCompletedTask = true;
        System.assertEquals(
          'Completed',
          t.Status,
          'Task status should be Completed'
        );
      }
      // Should not contain open task or email task
      System.assertNotEquals(openTask.Id, t.Id, 'Should not return open tasks');
      System.assertNotEquals(
        emailTask.Id,
        t.Id,
        'Should not return email tasks'
      );
    }
    System.assert(foundCompletedTask, 'Should find the completed task');
  }

  @isTest
  static void testGetRecentActivityNoResults() {
    // Test with no completed tasks
    Test.startTest();
    List<Task> results = RecentActivityController.getRecentActivity();
    Test.stopTest();

    // Should return empty list, not null
    System.assertNotEquals(null, results, 'Results should not be null');
  }

  @isTest
  static void testExcludeEmailTasks() {
    // Create email task (should be excluded)
    Task emailTask = new Task(
      Subject = 'Email: Test',
      TaskSubtype = 'Email',
      ActivityDate = Date.today().addDays(-1),
      Status = 'Completed',
      OwnerId = UserInfo.getUserId()
    );
    insert emailTask;

    Test.startTest();
    List<Task> results = RecentActivityController.getRecentActivity();
    Test.stopTest();

    // Verify email task is not in results
    for (Task t : results) {
      System.assertNotEquals(
        'Email',
        t.TaskSubtype,
        'Should not return email tasks'
      );
    }
  }
}
