@isTest
public class RecruiterDashboardTaskMethodsTest {
  @isTest
  static void testGetTaskDetails() {
    // Create a simple task without any related objects
    Task testTask = new Task(
      Subject = 'Test Call',
      Status = 'Not Started',
      Priority = 'Normal',
      ActivityDate = Date.today(),
      Description = 'Test description'
    );
    insert testTask;

    Test.startTest();
    Task result = RecruiterDashboardController.getTaskDetails(testTask.Id);
    Test.stopTest();

    System.assertNotEquals(null, result, 'Task should be retrieved');
    System.assertEquals('Test Call', result.Subject);
    System.assertEquals('Not Started', result.Status);
    System.assertEquals('Normal', result.Priority);
    System.assertEquals('Test description', result.Description);
  }

  @isTest
  static void testUpdateTaskRecord() {
    // Create a simple task without any related objects
    Task testTask = new Task(
      Subject = 'Original Subject',
      Status = 'Not Started',
      Priority = 'Normal',
      ActivityDate = Date.today()
    );
    insert testTask;

    Test.startTest();
    RecruiterDashboardController.updateTaskRecord(
      testTask.Id,
      'Updated Subject',
      'In Progress',
      Date.today().addDays(1),
      'High',
      'Updated description'
    );
    Test.stopTest();

    Task updated = [
      SELECT Subject, Status, Priority, ActivityDate, Description
      FROM Task
      WHERE Id = :testTask.Id
    ];
    System.assertEquals('Updated Subject', updated.Subject);
    System.assertEquals('In Progress', updated.Status);
    System.assertEquals('High', updated.Priority);
    System.assertEquals(Date.today().addDays(1), updated.ActivityDate);
    System.assertEquals('Updated description', updated.Description);
  }

  @isTest
  static void testUpdateTaskRecordNullDescription() {
    // Test updating with null description
    Task testTask = new Task(
      Subject = 'Original',
      Status = 'Not Started',
      Priority = 'Normal',
      ActivityDate = Date.today(),
      Description = 'Original description'
    );
    insert testTask;

    Test.startTest();
    RecruiterDashboardController.updateTaskRecord(
      testTask.Id,
      'Updated Subject',
      'Completed',
      Date.today(),
      'Low',
      null // Null description
    );
    Test.stopTest();

    Task updated = [
      SELECT Subject, Status, Description
      FROM Task
      WHERE Id = :testTask.Id
    ];
    System.assertEquals('Updated Subject', updated.Subject);
    System.assertEquals('Completed', updated.Status);
    System.assertEquals(null, updated.Description);
  }

  @isTest
  static void testUpdateTaskRecordPartialUpdate() {
    // Test updating only some fields
    Task testTask = new Task(
      Subject = 'Original',
      Status = 'Not Started',
      Priority = 'Normal',
      ActivityDate = Date.today()
    );
    insert testTask;

    Test.startTest();
    RecruiterDashboardController.updateTaskRecord(
      testTask.Id,
      'New Subject',
      null, // Don't update status
      null, // Don't update date
      null, // Don't update priority
      'New description'
    );
    Test.stopTest();

    Task updated = [
      SELECT Subject, Status, Priority
      FROM Task
      WHERE Id = :testTask.Id
    ];
    System.assertEquals('New Subject', updated.Subject);
    // Status and Priority should remain as original since we passed null
    System.assertEquals('Not Started', updated.Status);
  }

  @isTest
  static void testGetTaskDetailsError() {
    Test.startTest();
    try {
      // Try to get a task with invalid ID format
      RecruiterDashboardController.getTaskDetails('00T000000000000');
      System.assert(false, 'Should have thrown exception');
    } catch (Exception e) {
      // Should throw AuraHandledException wrapping SOQL exception
      System.assert(
        e instanceof AuraHandledException,
        'Should throw AuraHandledException'
      );
      System.assertNotEquals(null, e.getMessage(), 'Should have error message');
    }
    Test.stopTest();
  }

  @isTest
  static void testUpdateTaskRecordError() {
    Test.startTest();
    try {
      // Try to update a task with invalid ID
      RecruiterDashboardController.updateTaskRecord(
        '00T000000000000',
        'Subject',
        'Status',
        Date.today(),
        'Normal',
        'Description'
      );
      System.assert(false, 'Should have thrown exception');
    } catch (Exception e) {
      // Should throw AuraHandledException wrapping DML exception
      System.assert(
        e instanceof AuraHandledException,
        'Should throw AuraHandledException'
      );
      System.assertNotEquals(null, e.getMessage(), 'Should have error message');
    }
    Test.stopTest();
  }

  @isTest
  static void testGetTaskDetailsWithAllFields() {
    // Create task with all fields populated
    Task testTask = new Task(
      Subject = 'Complete Call',
      Status = 'Completed',
      Priority = 'High',
      ActivityDate = Date.today().addDays(7),
      Description = 'Detailed notes about the call'
    );
    insert testTask;

    Test.startTest();
    Task result = RecruiterDashboardController.getTaskDetails(testTask.Id);
    Test.stopTest();

    System.assertNotEquals(null, result);
    System.assertEquals('Complete Call', result.Subject);
    System.assertEquals('Completed', result.Status);
    System.assertEquals('High', result.Priority);
    System.assertEquals(Date.today().addDays(7), result.ActivityDate);
    System.assertEquals('Detailed notes about the call', result.Description);
  }

  @isTest
  static void testUpdateTaskMultipleTimes() {
    // Test updating the same task multiple times
    Task testTask = new Task(
      Subject = 'Original',
      Status = 'Not Started',
      Priority = 'Normal'
    );
    insert testTask;

    Test.startTest();

    // First update
    RecruiterDashboardController.updateTaskRecord(
      testTask.Id,
      'First Update',
      'In Progress',
      Date.today(),
      'Normal',
      'First description'
    );

    // Second update
    RecruiterDashboardController.updateTaskRecord(
      testTask.Id,
      'Second Update',
      'Completed',
      Date.today().addDays(1),
      'High',
      'Second description'
    );

    Test.stopTest();

    Task updated = [
      SELECT Subject, Status, Priority, Description
      FROM Task
      WHERE Id = :testTask.Id
    ];
    System.assertEquals('Second Update', updated.Subject);
    System.assertEquals('Completed', updated.Status);
    System.assertEquals('High', updated.Priority);
    System.assertEquals('Second description', updated.Description);
  }
}
