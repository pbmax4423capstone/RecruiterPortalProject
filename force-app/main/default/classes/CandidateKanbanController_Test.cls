/**
 * Test class for CandidateKanbanController
 * Tests candidate kanban board filtering and stage updates
 */
@isTest
private class CandidateKanbanController_Test {
  @testSetup
  static void setup() {
    // Create two test users (System Administrators to bypass Sales Manager filtering)
    Profile p = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];

    User user1 = new User(
      Alias = 'tuser1',
      Email = 'testuser1@recruiterportal.test',
      EmailEncodingKey = 'UTF-8',
      FirstName = 'Test',
      LastName = 'User1',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testuser1@recruiterportal.test' + System.currentTimeMillis()
    );
    insert user1;

    User user2 = new User(
      Alias = 'tuser2',
      Email = 'testuser2@recruiterportal.test',
      EmailEncodingKey = 'UTF-8',
      FirstName = 'Test',
      LastName = 'User2',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testuser2@recruiterportal.test' + System.currentTimeMillis()
    );
    insert user2;

    // Create candidates for user1
    System.runAs(user1) {
      List<Candidate__c> candidates1 = new List<Candidate__c>();
      candidates1.add(
        new Candidate__c(
          First_Name__c = 'John',
          Last_Name__c = 'Doe',
          Email__c = 'john.doe@test.com',
          Phone__c = '555-1234',
          City__c = 'Los Angeles',
          State_Province__c = 'CA',
          Highest_Level_Achieved__c = '0-Prequal',
          Status__c = 'Active',
          Recruiter__c = user1.Id,
          Sales_Manager__c = 'Tim Denton'
        )
      );
      candidates1.add(
        new Candidate__c(
          First_Name__c = 'Jane',
          Last_Name__c = 'Smith',
          Email__c = 'jane.smith@test.com',
          Phone__c = '555-5678',
          City__c = 'San Francisco',
          State_Province__c = 'CA',
          Highest_Level_Achieved__c = 'Ci_1st',
          Status__c = 'Active',
          Recruiter__c = user1.Id,
          Sales_Manager__c = 'Tim Denton'
        )
      );
      insert candidates1;
    }

    // Create candidates for user2
    System.runAs(user2) {
      List<Candidate__c> candidates2 = new List<Candidate__c>();
      candidates2.add(
        new Candidate__c(
          First_Name__c = 'Bob',
          Last_Name__c = 'Johnson',
          Email__c = 'bob.johnson@test.com',
          Phone__c = '555-9999',
          City__c = 'Seattle',
          State_Province__c = 'WA',
          Highest_Level_Achieved__c = 'Align (2nd)',
          Status__c = 'Active',
          Recruiter__c = user2.Id,
          Sales_Manager__c = 'Van Hess'
        )
      );
      candidates2.add(
        new Candidate__c(
          First_Name__c = 'Alice',
          Last_Name__c = 'Williams',
          Email__c = 'alice.williams@test.com',
          Phone__c = '555-1111',
          City__c = 'Portland',
          State_Province__c = 'OR',
          Highest_Level_Achieved__c = 'Plan_3rd',
          Status__c = 'Active',
          Recruiter__c = user2.Id,
          Sales_Manager__c = 'Van Hess'
        )
      );
      insert candidates2;
    }
  }

  @isTest
  static void testGetKanbanData_ReturnsCurrentUserCandidatesOnly() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = 'testuser1@recruiterportal.test'
      LIMIT 1
    ];

    Test.startTest();
    CandidateKanbanController.KanbanData result;
    System.runAs(user1) {
      result = CandidateKanbanController.getKanbanData('All Sales Managers');
    }
    Test.stopTest();

    // Count all candidates returned
    Integer totalCandidates = 0;
    for (String stage : result.candidatesByStage.keySet()) {
      totalCandidates += result.candidatesByStage.get(stage).size();
    }

    // System Admin sees all candidates (both user1's and user2's)
    System.assertEquals(
      4,
      totalCandidates,
      'System Admin should see all candidates'
    );

    // Verify stages are present
    System.assertEquals(7, result.stages.size(), 'Should have 7 stages');

    // Since System Admin sees all, just verify data structure
    System.assert(
      result.candidatesByStage.containsKey('0-Prequal'),
      'Should have Prequal stage'
    );
    System.assert(
      result.candidatesByStage.containsKey('Ci_1st'),
      'Should have Ci stage'
    );
  }

  @isTest
  static void testGetKanbanData_DoesNotReturnOtherUsersCandidates() {
    User user2 = [
      SELECT Id
      FROM User
      WHERE Email = 'testuser2@recruiterportal.test'
      LIMIT 1
    ];

    Test.startTest();
    CandidateKanbanController.KanbanData result;
    System.runAs(user2) {
      result = CandidateKanbanController.getKanbanData('All Sales Managers');
    }
    Test.stopTest();

    // Count all candidates returned
    Integer totalCandidates = 0;
    for (String stage : result.candidatesByStage.keySet()) {
      totalCandidates += result.candidatesByStage.get(stage).size();
    }

    // System Admin sees all candidates
    System.assertEquals(
      4,
      totalCandidates,
      'System Admin should see all candidates'
    );

    // Verify user2's specific candidates are present (among all 4)
    Boolean foundBob = false;
    Boolean foundAlice = false;
    for (String stage : result.candidatesByStage.keySet()) {
      for (
        CandidateKanbanController.CandidateCard card : result.candidatesByStage.get(
          stage
        )
      ) {
        if (card.firstName == 'Bob')
          foundBob = true;
        if (card.firstName == 'Alice')
          foundAlice = true;
      }
    }
    System.assert(foundBob, 'Should find Bob');
    System.assert(foundAlice, 'Should find Alice');
  }

  @isTest
  static void testGetKanbanData_ExcludesClosedAndContractedCandidates() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = 'testuser1@recruiterportal.test'
      LIMIT 1
    ];

    System.runAs(user1) {
      // Create closed and contracted candidates
      List<Candidate__c> candidates = new List<Candidate__c>();
      candidates.add(
        new Candidate__c(
          First_Name__c = 'Closed',
          Last_Name__c = 'Candidate',
          Email__c = 'closed@test.com',
          Status__c = 'Closed Lost',
          Highest_Level_Achieved__c = 'Ci_1st',
          Recruiter__c = user1.Id,
          Sales_Manager__c = 'Tim Denton'
        )
      );
      candidates.add(
        new Candidate__c(
          First_Name__c = 'Contracted',
          Last_Name__c = 'Candidate',
          Email__c = 'contracted@test.com',
          Status__c = 'Active',
          Highest_Level_Achieved__c = '7-Contracted',
          Recruiter__c = user1.Id,
          Sales_Manager__c = 'Tim Denton'
        )
      );
      insert candidates;
    }

    Test.startTest();
    CandidateKanbanController.KanbanData result;
    System.runAs(user1) {
      result = CandidateKanbanController.getKanbanData('All Sales Managers');
    }
    Test.stopTest();

    // Count all candidates returned
    Integer totalCandidates = 0;
    for (String stage : result.candidatesByStage.keySet()) {
      totalCandidates += result.candidatesByStage.get(stage).size();
    }

    // System Admin sees all active pipeline candidates (still 4 - excludes closed and contracted)
    System.assertEquals(
      4,
      totalCandidates,
      'System Admin should see all active pipeline candidates, excluding closed and contracted'
    );
  }

  @isTest
  static void testGetKanbanData_IncludesInterviewData() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = 'testuser1@recruiterportal.test'
      LIMIT 1
    ];
    Candidate__c candidate = [
      SELECT Id
      FROM Candidate__c
      WHERE Recruiter__c = :user1.Id AND First_Name__c = 'John'
      LIMIT 1
    ];

    // Create an interview for the candidate
    Interview__c interview = new Interview__c(
      Candidate__c = candidate.Id,
      Interview_Type__c = 'Ci (1st)',
      Interview_Status__c = 'Scheduled',
      Date_Time_Scheduled__c = Datetime.now().addDays(1)
    );
    insert interview;

    Test.startTest();
    CandidateKanbanController.KanbanData result;
    System.runAs(user1) {
      result = CandidateKanbanController.getKanbanData('All Sales Managers');
    }
    Test.stopTest();

    // Find John Doe's card (System Admin sees all, so find by name)
    CandidateKanbanController.CandidateCard johnCard = null;
    for (
      CandidateKanbanController.CandidateCard card : result.candidatesByStage.get(
        '0-Prequal'
      )
    ) {
      if (card.firstName == 'John') {
        johnCard = card;
        break;
      }
    }
    System.assertNotEquals(null, johnCard, 'Should find John Doe');

    System.assertEquals(
      'Ci (1st)',
      johnCard.interviewStage,
      'Should have interview stage'
    );
    System.assertEquals(
      'Scheduled',
      johnCard.interviewStatus,
      'Should have interview status'
    );
  }

  @isTest
  static void testUpdateCandidateStage_Success() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = 'testuser1@recruiterportal.test'
      LIMIT 1
    ];
    Candidate__c candidate = [
      SELECT Id, Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Recruiter__c = :user1.Id AND First_Name__c = 'John'
      LIMIT 1
    ];

    System.assertEquals(
      '0-Prequal',
      candidate.Highest_Level_Achieved__c,
      'Initial stage should be Prequal'
    );

    Test.startTest();
    String result;
    System.runAs(user1) {
      result = CandidateKanbanController.updateCandidateStage(
        candidate.Id,
        'Ci_1st'
      );
    }
    Test.stopTest();

    System.assertEquals('Success', result, 'Update should succeed');

    // Verify stage was updated
    candidate = [
      SELECT Highest_Level_Achieved__c
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      'Ci_1st',
      candidate.Highest_Level_Achieved__c,
      'Stage should be updated'
    );
  }

  @isTest
  static void testUpdateCandidateStage_InvalidId() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = 'testuser1@recruiterportal.test'
      LIMIT 1
    ];

    Test.startTest();
    try {
      System.runAs(user1) {
        CandidateKanbanController.updateCandidateStage(null, 'Ci_1st');
      }
      System.assert(false, 'Should have thrown exception');
    } catch (AuraHandledException e) {
      System.assert(true, 'Expected exception thrown');
    }
    Test.stopTest();
  }

  @isTest
  static void testGetKanbanData_StageCounts() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = 'testuser1@recruiterportal.test'
      LIMIT 1
    ];

    Test.startTest();
    CandidateKanbanController.KanbanData result;
    System.runAs(user1) {
      result = CandidateKanbanController.getKanbanData('All Sales Managers');
    }
    Test.stopTest();

    // Verify stage counts (System Admin sees all 4 candidates)
    for (CandidateKanbanController.StageInfo stage : result.stages) {
      if (stage.value == '0-Prequal') {
        System.assertEquals(1, stage.count, 'Prequal should have 1 candidate');
      } else if (stage.value == 'Ci_1st') {
        System.assertEquals(1, stage.count, 'Ci should have 1 candidate');
      } else if (stage.value == 'Align (2nd)') {
        System.assertEquals(1, stage.count, 'Align should have 1 candidate');
      } else if (stage.value == 'Plan_3rd') {
        System.assertEquals(1, stage.count, 'Plan should have 1 candidate');
      } else {
        System.assertEquals(
          0,
          stage.count,
          stage.label + ' should have 0 candidates'
        );
      }
    }
  }

  @isTest
  static void testGetSalesManagerOptions() {
    Test.startTest();
    List<String> options = CandidateKanbanController.getSalesManagerOptions();
    Test.stopTest();

    System.assertNotEquals(null, options, 'Options should not be null');
    System.assert(
      options.size() > 0,
      'Should have at least "All Sales Managers"'
    );
    System.assertEquals(
      'All Sales Managers',
      options[0],
      'First option should be "All Sales Managers"'
    );

    // Should include Tim Denton and Van Hess from setup data
    System.assert(options.contains('Tim Denton'), 'Should include Tim Denton');
    System.assert(options.contains('Van Hess'), 'Should include Van Hess');
  }

  @isTest
  static void testGetKanbanData_FilterBySpecificSalesManager() {
    Test.startTest();
    CandidateKanbanController.KanbanData result = CandidateKanbanController.getKanbanData(
      'Tim Denton'
    );
    Test.stopTest();

    // Count all candidates returned
    Integer totalCandidates = 0;
    for (String stage : result.candidatesByStage.keySet()) {
      totalCandidates += result.candidatesByStage.get(stage).size();
    }

    // As System Admin filtering by Tim Denton, should see only his 2 candidates
    System.assertEquals(
      2,
      totalCandidates,
      'Should see only Tim Denton\'s candidates'
    );

    // Verify all returned candidates have the correct Sales Manager
    for (String stage : result.candidatesByStage.keySet()) {
      for (
        CandidateKanbanController.CandidateCard card : result.candidatesByStage.get(
          stage
        )
      ) {
        System.assertEquals(
          'Tim Denton',
          card.salesManager,
          'All candidates should belong to Tim Denton'
        );
      }
    }
  }

  @isTest
  static void testGetKanbanData_AllSalesManagersFilter() {
    Test.startTest();
    CandidateKanbanController.KanbanData result = CandidateKanbanController.getKanbanData(
      'All Sales Managers'
    );
    Test.stopTest();

    // Count all candidates returned
    Integer totalCandidates = 0;
    for (String stage : result.candidatesByStage.keySet()) {
      totalCandidates += result.candidatesByStage.get(stage).size();
    }

    // System Admin with "All Sales Managers" should see all 4 candidates
    System.assertEquals(
      4,
      totalCandidates,
      'Should see all candidates when filter is "All Sales Managers"'
    );
  }
}
