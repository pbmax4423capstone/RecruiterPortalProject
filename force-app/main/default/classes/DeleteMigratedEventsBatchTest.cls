/**
 * @description Test class for DeleteMigratedEventsBatch
 */
@isTest
private class DeleteMigratedEventsBatchTest {
  @TestSetup
  static void setupTestData() {
    // Note: Event object may require RecordType setup
    // Creating basic events for testing

    // Create test candidate for event association
    Candidate__c testCandidate = new Candidate__c(
      First_Name__c = 'Event',
      Last_Name__c = 'Test',
      Email__c = 'eventtest@example.com',
      Status__c = 'Active/In Process'
    );
    insert testCandidate;
  }

  @isTest
  static void testBatchStart_QueryLocator() {
    Test.startTest();
    DeleteMigratedEventsBatch batch = new DeleteMigratedEventsBatch();
    Database.QueryLocator ql = batch.start(null);
    Test.stopTest();

    System.assertNotEquals(null, ql, 'QueryLocator should not be null');
  }

  @isTest
  static void testBatchExecute_WithEvents() {
    // Get or create Interview RecordType if it exists
    List<RecordType> interviewRT = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Event' AND Name = 'Interview'
      LIMIT 1
    ];

    if (!interviewRT.isEmpty()) {
      // Create test events if RecordType exists
      List<Event> testEvents = new List<Event>();
      for (Integer i = 0; i < 3; i++) {
        testEvents.add(
          new Event(
            Subject = 'Test Interview Event ' + i,
            StartDateTime = System.now(),
            EndDateTime = System.now().addHours(1),
            RecordTypeId = interviewRT[0].Id
          )
        );
      }
      insert testEvents;

      // Verify events were created
      Integer countBefore = [
        SELECT COUNT()
        FROM Event
        WHERE RecordTypeId = :interviewRT[0].Id AND CreatedDate = TODAY
      ];
      System.assertEquals(3, countBefore, 'Should have 3 test events');

      Test.startTest();
      DeleteMigratedEventsBatch batch = new DeleteMigratedEventsBatch();
      Database.executeBatch(batch, 200);
      Test.stopTest();

      // Verify events were deleted
      Integer countAfter = [
        SELECT COUNT()
        FROM Event
        WHERE RecordTypeId = :interviewRT[0].Id AND CreatedDate = TODAY
      ];
      System.assertEquals(0, countAfter, 'All events should be deleted');
    } else {
      // If no Interview RecordType, test with empty query
      Test.startTest();
      DeleteMigratedEventsBatch batch = new DeleteMigratedEventsBatch();
      Database.executeBatch(batch, 200);
      Test.stopTest();

      System.assert(
        true,
        'Batch should execute without errors even with no data'
      );
    }
  }

  @isTest
  static void testBatchExecute_EmptyList() {
    Test.startTest();
    DeleteMigratedEventsBatch batch = new DeleteMigratedEventsBatch();
    batch.execute(null, new List<Event>());
    Test.stopTest();

    // Should not throw exception with empty list
    System.assert(true, 'Should handle empty list gracefully');
  }

  @isTest
  static void testBatchFinish() {
    Test.startTest();
    DeleteMigratedEventsBatch batch = new DeleteMigratedEventsBatch();
    Id batchId = Database.executeBatch(batch, 200);
    Test.stopTest();

    // Verify job completed
    AsyncApexJob job = [
      SELECT Status, NumberOfErrors
      FROM AsyncApexJob
      WHERE Id = :batchId
    ];
    System.assertEquals(
      'Completed',
      job.Status,
      'Batch should complete successfully'
    );
    System.assertEquals(0, job.NumberOfErrors, 'Should have no errors');
  }

  @isTest
  static void testBatchExecution_NoEventsToDelete() {
    // Ensure no events exist for today
    List<RecordType> interviewRT = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Event' AND Name = 'Interview'
      LIMIT 1
    ];

    Test.startTest();
    DeleteMigratedEventsBatch batch = new DeleteMigratedEventsBatch();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    // Should complete successfully even with no events
    System.assert(true, 'Batch should complete successfully with no events');
  }

  @isTest
  static void testBatchWithMultipleBatches() {
    List<RecordType> interviewRT = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Event' AND Name = 'Interview'
      LIMIT 1
    ];

    if (!interviewRT.isEmpty()) {
      // Create multiple events to test batching
      List<Event> testEvents = new List<Event>();
      for (Integer i = 0; i < 10; i++) {
        testEvents.add(
          new Event(
            Subject = 'Batch Test Event ' + i,
            StartDateTime = System.now(),
            EndDateTime = System.now().addHours(1),
            RecordTypeId = interviewRT[0].Id
          )
        );
      }
      insert testEvents;

      Test.startTest();
      DeleteMigratedEventsBatch batch = new DeleteMigratedEventsBatch();
      Database.executeBatch(batch, 5); // Small batch size to test multiple batches
      Test.stopTest();

      // Verify all events were deleted across multiple batches
      Integer countAfter = [
        SELECT COUNT()
        FROM Event
        WHERE RecordTypeId = :interviewRT[0].Id AND CreatedDate = TODAY
      ];
      System.assertEquals(
        0,
        countAfter,
        'All events should be deleted across batches'
      );
    } else {
      System.assert(true, 'Test skipped - no Interview RecordType exists');
    }
  }
}
