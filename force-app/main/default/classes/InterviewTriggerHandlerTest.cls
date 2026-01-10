/**
 * Test class for InterviewTriggerHandler
 * Tests automatic update of Candidate.Highest_Level_Achieved__c when interviews complete
 */
@isTest
private class InterviewTriggerHandlerTest {
  @testSetup
  static void setupTestData() {
    // Create test candidate
    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Test',
      Last_Name__c = 'Candidate',
      Email__c = 'test.trigger@example.com',
      Phone__c = '555-0200',
      Highest_Level_Achieved__c = '0-Prequal'
    );
    insert candidate;
  }

  @isTest
  static void testInsertCompletedInterview_UpdatesHighestLevel() {
    Candidate__c candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      LIMIT 1
    ];
    System.assertEquals(
      '0-Prequal',
      candidate.Highest_Level_Achieved__c,
      'Should start at Prequal'
    );

    Test.startTest();
    // Insert a completed Ci-First interview
    Interview__c interview = new Interview__c(
      Candidate__c = candidate.Id,
      Interview_Type__c = 'Ci-First',
      Interview_Status__c = 'Completed',
      Date_Time_Scheduled__c = DateTime.now()
    );
    insert interview;
    Test.stopTest();

    // Verify Candidate updated
    candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      'Ci-First',
      candidate.Highest_Level_Achieved__c,
      'Should update to Ci-First after completed interview'
    );
  }

  @isTest
  static void testUpdateInterviewToCompleted_UpdatesHighestLevel() {
    Candidate__c candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      LIMIT 1
    ];

    // Insert a scheduled interview
    Interview__c interview = new Interview__c(
      Candidate__c = candidate.Id,
      Interview_Type__c = 'Align-2nd',
      Interview_Status__c = 'Scheduled',
      Date_Time_Scheduled__c = DateTime.now()
    );
    insert interview;

    // Verify not updated yet
    candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      '0-Prequal',
      candidate.Highest_Level_Achieved__c,
      'Should still be Prequal before completion'
    );

    Test.startTest();
    // Update to completed
    interview.Interview_Status__c = 'Completed';
    update interview;
    Test.stopTest();

    // Verify updated
    candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      'Align-2nd',
      candidate.Highest_Level_Achieved__c,
      'Should update to Align-2nd after completion'
    );
  }

  @isTest
  static void testMultipleCompletedInterviews_UsesHighest() {
    Candidate__c candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      LIMIT 1
    ];

    Test.startTest();
    // Insert multiple completed interviews
    List<Interview__c> interviews = new List<Interview__c>();
    interviews.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Ci-First',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-5)
      )
    );
    interviews.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Plan-3rd',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-2)
      )
    );
    interviews.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Align-2nd',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-3)
      )
    );
    insert interviews;
    Test.stopTest();

    // Verify uses highest level (Plan-3rd)
    candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      'Plan-3rd',
      candidate.Highest_Level_Achieved__c,
      'Should use highest completed level'
    );
  }

  @isTest
  static void testCompletedInterviewLowerThanCurrent_NoDowngrade() {
    Candidate__c candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      LIMIT 1
    ];

    // Update candidate to Present-4th
    candidate.Highest_Level_Achieved__c = 'Present-4th';
    update candidate;

    Test.startTest();
    // Complete a lower-level interview
    Interview__c interview = new Interview__c(
      Candidate__c = candidate.Id,
      Interview_Type__c = 'Ci-First',
      Interview_Status__c = 'Completed',
      Date_Time_Scheduled__c = DateTime.now()
    );
    insert interview;
    Test.stopTest();

    // Verify NOT downgraded
    candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      'Present-4th',
      candidate.Highest_Level_Achieved__c,
      'Should not downgrade from higher level'
    );
  }

  @isTest
  static void testStatusChangedFromCompleted_NoChange() {
    Candidate__c candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      LIMIT 1
    ];

    // Insert completed interview
    Interview__c interview = new Interview__c(
      Candidate__c = candidate.Id,
      Interview_Type__c = 'Align-2nd',
      Interview_Status__c = 'Completed',
      Date_Time_Scheduled__c = DateTime.now()
    );
    insert interview;

    candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      'Align-2nd',
      candidate.Highest_Level_Achieved__c,
      'Should be Align-2nd'
    );

    Test.startTest();
    // Change status away from Completed
    interview.Interview_Status__c = 'Canceled';
    update interview;
    Test.stopTest();

    // Verify level unchanged (don't downgrade)
    candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      'Align-2nd',
      candidate.Highest_Level_Achieved__c,
      'Should remain at achieved level'
    );
  }

  @isTest
  static void testNullCandidate_NoError() {
    Test.startTest();
    // Insert interview with no candidate
    Interview__c interview = new Interview__c(
      Interview_Type__c = 'Ci-First',
      Interview_Status__c = 'Completed',
      Date_Time_Scheduled__c = DateTime.now()
    );
    insert interview;
    Test.stopTest();

    // Should not throw error
    System.assert(true, 'Should handle null candidate gracefully');
  }

  @isTest
  static void testNullInterviewType_NoError() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    Test.startTest();
    // Insert completed interview with no type
    Interview__c interview = new Interview__c(
      Candidate__c = candidate.Id,
      Interview_Status__c = 'Completed',
      Date_Time_Scheduled__c = DateTime.now()
    );
    insert interview;
    Test.stopTest();

    // Should not throw error or update candidate
    candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      '0-Prequal',
      candidate.Highest_Level_Achieved__c,
      'Should remain unchanged'
    );
  }

  @isTest
  static void testAllInterviewTypes_CorrectMapping() {
    Candidate__c candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      LIMIT 1
    ];

    // Test each interview type individually
    Map<String, String> expectedMappings = new Map<String, String>{
      'Ci-First' => 'Ci-First',
      'Align-2nd' => 'Align-2nd',
      'Plan-3rd' => 'Plan-3rd',
      'Present-4th' => 'Present-4th',
      'Optional-5th' => 'Optional-5th'
    };

    Test.startTest();
    for (String interviewType : expectedMappings.keySet()) {
      Interview__c interview = new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = interviewType,
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now()
      );
      insert interview;

      candidate = [
        SELECT Id, Highest_Level_Achieved__c
        FROM Candidate__c
        WHERE Id = :candidate.Id
      ];
      System.assertEquals(
        expectedMappings.get(interviewType),
        candidate.Highest_Level_Achieved__c,
        'Mapping should work for ' + interviewType
      );

      // Delete for next iteration
      delete interview;
    }
    Test.stopTest();
  }

  @isTest
  static void testBulkInsert_MultipleCompletedInterviews() {
    // Create multiple candidates
    List<Candidate__c> candidates = new List<Candidate__c>();
    for (Integer i = 0; i < 200; i++) {
      candidates.add(
        new Candidate__c(
          First_Name__c = 'Bulk',
          Last_Name__c = 'Test' + i,
          Email__c = 'bulk' + i + '@test.com',
          Highest_Level_Achieved__c = '0-Prequal'
        )
      );
    }
    insert candidates;

    // Create completed interviews for all
    List<Interview__c> interviews = new List<Interview__c>();
    for (Candidate__c cand : candidates) {
      interviews.add(
        new Interview__c(
          Candidate__c = cand.Id,
          Interview_Type__c = 'Ci-First',
          Interview_Status__c = 'Completed',
          Date_Time_Scheduled__c = DateTime.now()
        )
      );
    }

    Test.startTest();
    insert interviews;
    Test.stopTest();

    // Verify all updated
    List<Candidate__c> updated = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Id IN :candidates
    ];

    System.assertEquals(200, updated.size(), 'Should update all candidates');
    for (Candidate__c cand : updated) {
      System.assertEquals(
        'Ci-First',
        cand.Highest_Level_Achieved__c,
        'All should be updated to Ci-First'
      );
    }
  }

  @isTest
  static void testBulkUpdate_ToCompleted() {
    // Create candidates
    List<Candidate__c> candidates = new List<Candidate__c>();
    for (Integer i = 0; i < 200; i++) {
      candidates.add(
        new Candidate__c(
          First_Name__c = 'BulkUpdate',
          Last_Name__c = 'Test' + i,
          Email__c = 'bulkupdate' + i + '@test.com',
          Highest_Level_Achieved__c = '0-Prequal'
        )
      );
    }
    insert candidates;

    // Create scheduled interviews
    List<Interview__c> interviews = new List<Interview__c>();
    for (Candidate__c cand : candidates) {
      interviews.add(
        new Interview__c(
          Candidate__c = cand.Id,
          Interview_Type__c = 'Align-2nd',
          Interview_Status__c = 'Scheduled',
          Date_Time_Scheduled__c = DateTime.now()
        )
      );
    }
    insert interviews;

    // Update all to completed
    for (Interview__c interview : interviews) {
      interview.Interview_Status__c = 'Completed';
    }

    Test.startTest();
    update interviews;
    Test.stopTest();

    // Verify all updated
    List<Candidate__c> updated = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Id IN :candidates
    ];

    System.assertEquals(200, updated.size(), 'Should update all candidates');
    for (Candidate__c cand : updated) {
      System.assertEquals(
        'Align-2nd',
        cand.Highest_Level_Achieved__c,
        'All should be updated to Align-2nd'
      );
    }
  }
}
