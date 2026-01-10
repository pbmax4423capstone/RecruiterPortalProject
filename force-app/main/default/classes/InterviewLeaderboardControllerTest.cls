@isTest
private class InterviewLeaderboardControllerTest {
  @testSetup
  static void setupTestData() {
    // Create test user
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User testUser = new User(
      Alias = 'tuser',
      Email = 'testuser@test.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testuser' + DateTime.now().getTime() + '@test.com'
    );
    insert testUser;

    // Create test candidates
    List<Candidate__c> testCandidates = new List<Candidate__c>();
    for (Integer i = 0; i < 5; i++) {
      testCandidates.add(
        new Candidate__c(
          Name = 'Test Candidate ' + i,
          Status__c = 'Active/In Process',
          OwnerId = testUser.Id,
          AI_Completed_Date_Time__c = DateTime.now(),
          Attraction_Interview_Date_Completed__c = Date.today(),
          SI_1_Date_Completed__c = Date.today(),
          SI_2_Date_Completed__c = Date.today(),
          SI_3_Completed__c = Date.today(),
          Career_Presentation_Date_Completed__c = Date.today()
        )
      );
    }
    insert testCandidates;

    // Create test tasks (calls)
    List<Task> testTasks = new List<Task>();
    for (Integer i = 0; i < 3; i++) {
      testTasks.add(
        new Task(
          Subject = 'Call',
          OwnerId = testUser.Id,
          Status = 'Completed',
          ActivityDate = Date.today(),
          TaskSubtype = 'Call'
        )
      );
    }
    insert testTasks;
  }

  @isTest
  static void testGetLeaderboardData() {
    Test.startTest();
    List<InterviewLeaderboardController.LeaderboardEntry> results = InterviewLeaderboardController.getLeaderboardData();
    Test.stopTest();

    System.assertNotEquals(null, results, 'Results should not be null');
    System.assert(results.size() > 0, 'Should return at least one entry');

    // Verify structure of first entry
    InterviewLeaderboardController.LeaderboardEntry entry = results[0];
    System.assertNotEquals(
      null,
      entry.managerId,
      'Manager ID should not be null'
    );
    System.assertNotEquals(
      null,
      entry.managerName,
      'Manager name should not be null'
    );
    System.assertNotEquals(
      null,
      entry.weekBreakdown,
      'Week breakdown should not be null'
    );
    System.assertNotEquals(
      null,
      entry.monthBreakdown,
      'Month breakdown should not be null'
    );
    System.assertNotEquals(
      null,
      entry.yearBreakdown,
      'Year breakdown should not be null'
    );
  }

  @isTest
  static void testGetTopPerformersInterviewsWeek() {
    Test.startTest();
    List<InterviewLeaderboardController.LeaderboardEntry> results = InterviewLeaderboardController.getTopPerformers(
      'interviews',
      'week',
      5
    );
    Test.stopTest();

    System.assertNotEquals(null, results, 'Results should not be null');
    System.assert(results.size() <= 5, 'Should return at most 5 entries');
  }

  @isTest
  static void testGetTopPerformersInterviewsMonth() {
    Test.startTest();
    List<InterviewLeaderboardController.LeaderboardEntry> results = InterviewLeaderboardController.getTopPerformers(
      'interviews',
      'month',
      3
    );
    Test.stopTest();

    System.assertNotEquals(null, results, 'Results should not be null');
    System.assert(results.size() <= 3, 'Should return at most 3 entries');
  }

  @isTest
  static void testGetTopPerformersInterviewsYear() {
    Test.startTest();
    List<InterviewLeaderboardController.LeaderboardEntry> results = InterviewLeaderboardController.getTopPerformers(
      'interviews',
      'year',
      10
    );
    Test.stopTest();

    System.assertNotEquals(null, results, 'Results should not be null');
    System.assert(results.size() <= 10, 'Should return at most 10 entries');
  }

  @isTest
  static void testGetTopPerformersCallsWeek() {
    Test.startTest();
    List<InterviewLeaderboardController.LeaderboardEntry> results = InterviewLeaderboardController.getTopPerformers(
      'calls',
      'week',
      5
    );
    Test.stopTest();

    System.assertNotEquals(null, results, 'Results should not be null');
  }

  @isTest
  static void testGetTopPerformersCallsMonth() {
    Test.startTest();
    List<InterviewLeaderboardController.LeaderboardEntry> results = InterviewLeaderboardController.getTopPerformers(
      'calls',
      'month',
      5
    );
    Test.stopTest();

    System.assertNotEquals(null, results, 'Results should not be null');
  }

  @isTest
  static void testGetTopPerformersCallsYear() {
    Test.startTest();
    List<InterviewLeaderboardController.LeaderboardEntry> results = InterviewLeaderboardController.getTopPerformers(
      'calls',
      'year',
      5
    );
    Test.stopTest();

    System.assertNotEquals(null, results, 'Results should not be null');
  }

  @isTest
  static void testInterviewBreakdownStructure() {
    Test.startTest();
    List<InterviewLeaderboardController.LeaderboardEntry> results = InterviewLeaderboardController.getLeaderboardData();
    Test.stopTest();

    if (results.size() > 0) {
      InterviewLeaderboardController.InterviewBreakdown breakdown = results[0]
        .weekBreakdown;
      System.assertNotEquals(null, breakdown, 'Breakdown should not be null');
      System.assert(
        breakdown.totalInterviews >= 0,
        'Total interviews should be non-negative'
      );
      System.assertEquals(
        breakdown.totalInterviews,
        breakdown.citInterviews +
          breakdown.alignInterviews +
          breakdown.planInterviews +
          breakdown.presentInterviews +
          breakdown.optionalInterviews,
        'Total should equal sum of all interview types'
      );
    }
  }
}
