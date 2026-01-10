@isTest
private class CandidateActivityController_Test {
  @testSetup
  static void setup() {
    // Create test Candidate
    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Test',
      Last_Name__c = 'Candidate',
      Email__c = 'test@example.com',
      Type__c = 'Candidate'
    );
    insert candidate;

    // Create test Task
    Task task = new Task(
      Subject = 'Test Task',
      WhatId = candidate.Id,
      Status = 'Not Started',
      Priority = 'Normal',
      ActivityDate = Date.today().addDays(7)
    );
    insert task;

    // Create test Event
    Event event = new Event(
      Subject = 'Test Event',
      WhatId = candidate.Id,
      StartDateTime = DateTime.now().addHours(2),
      EndDateTime = DateTime.now().addHours(3)
    );
    insert event;
  }

  @isTest
  static void testGetActivities() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    Test.startTest();
    List<CandidateActivityController.ActivityWrapper> activities = CandidateActivityController.getActivities(
      candidate.Id
    );
    Test.stopTest();

    System.assertNotEquals(null, activities, 'Activities should not be null');
    System.assert(
      activities.size() >= 2,
      'Should have at least 2 activities (1 task + 1 event)'
    );
  }

  @isTest
  static void testGetActivitiesNullId() {
    Test.startTest();
    List<CandidateActivityController.ActivityWrapper> activities = CandidateActivityController.getActivities(
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, activities, 'Activities should not be null');
    System.assertEquals(
      0,
      activities.size(),
      'Should have no activities for null ID'
    );
  }

  @isTest
  static void testCompleteTask() {
    Task task = [SELECT Id, Status FROM Task LIMIT 1];
    System.assertEquals(
      'Not Started',
      task.Status,
      'Initial status should be Not Started'
    );

    Test.startTest();
    CandidateActivityController.completeTask(task.Id);
    Test.stopTest();

    Task updatedTask = [SELECT Id, Status FROM Task WHERE Id = :task.Id];
    System.assertEquals(
      'Completed',
      updatedTask.Status,
      'Task status should be Completed'
    );
  }

  @isTest
  static void testCompleteTaskError() {
    // Test with invalid ID - create a fake ID that doesn't exist
    Id fakeTaskId = '00T000000000000AAA';
    Boolean exceptionThrown = false;

    Test.startTest();
    try {
      CandidateActivityController.completeTask(fakeTaskId);
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(
      exceptionThrown,
      'Exception should have been thrown for non-existent task'
    );
  }
}
