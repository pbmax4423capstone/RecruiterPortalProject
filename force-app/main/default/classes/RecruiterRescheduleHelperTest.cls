@isTest
public class RecruiterRescheduleHelperTest {
  @TestSetup
  static void setupTestData() {
    // Create test account
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Create test contact
    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'Contact',
      Email = 'test@test.com',
      AccountId = testAccount.Id
    );
    insert testContact;

    // Create test tasks
    List<Task> testTasks = new List<Task>();
    for (Integer i = 0; i < 5; i++) {
      testTasks.add(
        new Task(
          Subject = 'Test Call ' + i,
          Status = 'Not Started',
          Priority = 'Normal',
          ActivityDate = Date.today().addDays(i + 1),
          WhoId = testContact.Id,
          Description = 'Test task description ' + i
        )
      );
    }
    insert testTasks;
  }

  @isTest
  static void testRescheduleCalls_Success() {
    List<Task> testTasks = [SELECT Id FROM Task LIMIT 3];
    List<String> taskIds = new List<String>();
    for (Task t : testTasks) {
      taskIds.add(t.Id);
    }

    String newDate = String.valueOf(Date.today().addDays(10));
    String newTime = '14:00';
    String notes = 'Rescheduled due to conflict';

    Test.startTest();
    String result = RecruiterRescheduleHelper.rescheduleCalls(
      taskIds,
      newDate,
      newTime,
      notes
    );
    Test.stopTest();

    System.assert(
      result.startsWith('SUCCESS'),
      'Rescheduling should be successful: ' + result
    );

    // Verify tasks were updated
    List<Task> updatedTasks = [
      SELECT Id, ActivityDate, Description
      FROM Task
      WHERE Id IN :taskIds
    ];
    for (Task t : updatedTasks) {
      System.assertEquals(
        Date.today().addDays(10),
        t.ActivityDate,
        'Task date should be updated'
      );
      System.assert(
        t.Description.contains(notes),
        'Task description should contain reschedule notes'
      );
    }
  }

  @isTest
  static void testRescheduleCalls_EmptyTaskIds() {
    List<String> emptyTaskIds = new List<String>();
    String newDate = String.valueOf(Date.today().addDays(5));

    Test.startTest();
    String result = RecruiterRescheduleHelper.rescheduleCalls(
      emptyTaskIds,
      newDate,
      '10:00',
      'Test notes'
    );
    Test.stopTest();

    System.assert(
      result.startsWith('ERROR'),
      'Should return error for empty task IDs'
    );
    System.assert(
      result.contains('No tasks selected'),
      'Should contain appropriate error message'
    );
  }

  @isTest
  static void testRescheduleCalls_NullTaskIds() {
    String newDate = String.valueOf(Date.today().addDays(5));

    Test.startTest();
    String result = RecruiterRescheduleHelper.rescheduleCalls(
      null,
      newDate,
      '10:00',
      'Test notes'
    );
    Test.stopTest();

    System.assert(
      result.startsWith('ERROR'),
      'Should return error for null task IDs'
    );
    System.assert(
      result.contains('No tasks selected'),
      'Should contain appropriate error message'
    );
  }

  @isTest
  static void testRescheduleCalls_BlankDate() {
    List<Task> testTasks = [SELECT Id FROM Task LIMIT 1];
    List<String> taskIds = new List<String>{ testTasks[0].Id };

    Test.startTest();
    String result = RecruiterRescheduleHelper.rescheduleCalls(
      taskIds,
      '',
      '10:00',
      'Test notes'
    );
    Test.stopTest();

    System.assert(
      result.startsWith('ERROR'),
      'Should return error for blank date'
    );
    System.assert(
      result.contains('New date is required'),
      'Should contain appropriate error message'
    );
  }

  @isTest
  static void testRescheduleCalls_InvalidTaskIds() {
    List<String> invalidTaskIds = new List<String>{
      '001000000000000',
      '001000000000001'
    };
    String newDate = String.valueOf(Date.today().addDays(5));

    Test.startTest();
    String result = RecruiterRescheduleHelper.rescheduleCalls(
      invalidTaskIds,
      newDate,
      '10:00',
      'Test notes'
    );
    Test.stopTest();

    System.assert(
      result.startsWith('ERROR'),
      'Should return error for invalid task IDs'
    );
    System.assert(
      result.contains('No tasks found'),
      'Should contain appropriate error message'
    );
  }

  @isTest
  static void testRescheduleCalls_InvalidDateFormat() {
    List<Task> testTasks = [SELECT Id FROM Task LIMIT 1];
    List<String> taskIds = new List<String>{ testTasks[0].Id };

    Test.startTest();
    String result = RecruiterRescheduleHelper.rescheduleCalls(
      taskIds,
      'invalid-date',
      '10:00',
      'Test notes'
    );
    Test.stopTest();

    System.assert(
      result.startsWith('ERROR'),
      'Should return error for invalid date format'
    );
  }

  @isTest
  static void testRescheduleCalls_WithTimeAndNotes() {
    List<Task> testTasks = [SELECT Id FROM Task LIMIT 1];
    List<String> taskIds = new List<String>{ testTasks[0].Id };

    String newDate = String.valueOf(Date.today().addDays(7));
    String newTime = '15:30';
    String notes = 'Client requested reschedule';

    Test.startTest();
    String result = RecruiterRescheduleHelper.rescheduleCalls(
      taskIds,
      newDate,
      newTime,
      notes
    );
    Test.stopTest();

    System.assert(
      result.startsWith('SUCCESS'),
      'Should be successful with time and notes'
    );

    Task updatedTask = [
      SELECT Description
      FROM Task
      WHERE Id = :testTasks[0].Id
    ];
    System.assert(
      updatedTask.Description.contains(newTime),
      'Description should contain new time'
    );
    System.assert(
      updatedTask.Description.contains(notes),
      'Description should contain notes'
    );
  }

  @isTest
  static void testRescheduleCalls_WithoutTimeAndNotes() {
    List<Task> testTasks = [SELECT Id FROM Task LIMIT 1];
    List<String> taskIds = new List<String>{ testTasks[0].Id };

    String newDate = String.valueOf(Date.today().addDays(7));

    Test.startTest();
    String result = RecruiterRescheduleHelper.rescheduleCalls(
      taskIds,
      newDate,
      null,
      null
    );
    Test.stopTest();

    System.assert(
      result.startsWith('SUCCESS'),
      'Should be successful without time and notes'
    );

    Task updatedTask = [
      SELECT ActivityDate
      FROM Task
      WHERE Id = :testTasks[0].Id
    ];
    System.assertEquals(
      Date.today().addDays(7),
      updatedTask.ActivityDate,
      'Date should be updated'
    );
  }
}
