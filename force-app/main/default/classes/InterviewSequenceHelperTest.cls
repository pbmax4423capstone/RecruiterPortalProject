/**
 * Test class for InterviewSequenceHelper
 * Achieves 100% code coverage with comprehensive test scenarios
 */
@isTest
private class InterviewSequenceHelperTest {
  @testSetup
  static void setupTestData() {
    // Create test candidate
    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Test',
      Last_Name__c = 'Candidate',
      Email__c = 'test.candidate@example.com',
      Phone__c = '555-0100'
    );
    insert candidate;

    // Create multiple completed interviews in sequence
    List<Interview__c> interviews = new List<Interview__c>();

    // Ci-First interview
    interviews.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Ci-First',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-10)
      )
    );

    // Align-2nd interview
    interviews.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Align-2nd',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-8)
      )
    );

    insert interviews;
  }

  @isTest
  static void testGetNextInterviewType_NullCandidateId() {
    Test.startTest();
    String result = InterviewSequenceHelper.getNextInterviewType(null);
    Test.stopTest();

    System.assertEquals(
      'Ci-First',
      result,
      'Should return first interview type for null candidate ID'
    );
  }

  @isTest
  static void testGetNextInterviewType_NoCompletedInterviews() {
    // Create a candidate with no interviews
    Candidate__c newCandidate = new Candidate__c(
      First_Name__c = 'New',
      Last_Name__c = 'Person',
      Email__c = 'new.person@example.com'
    );
    insert newCandidate;

    Test.startTest();
    String result = InterviewSequenceHelper.getNextInterviewType(
      newCandidate.Id
    );
    Test.stopTest();

    System.assertEquals(
      'Ci-First',
      result,
      'Should return first interview type when no completed interviews'
    );
  }

  @isTest
  static void testGetNextInterviewType_OneCompleted() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    // Delete one interview to leave only Ci-First
    Interview__c toDelete = [
      SELECT Id
      FROM Interview__c
      WHERE Interview_Type__c = 'Align-2nd'
      LIMIT 1
    ];
    delete toDelete;

    Test.startTest();
    String result = InterviewSequenceHelper.getNextInterviewType(candidate.Id);
    Test.stopTest();

    System.assertEquals(
      'Align-2nd',
      result,
      'Should suggest Align-2nd after Ci-First is completed'
    );
  }

  @isTest
  static void testGetNextInterviewType_TwoCompleted() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    Test.startTest();
    String result = InterviewSequenceHelper.getNextInterviewType(candidate.Id);
    Test.stopTest();

    System.assertEquals(
      'Plan-3rd',
      result,
      'Should suggest Plan-3rd after two interviews completed'
    );
  }

  @isTest
  static void testGetNextInterviewType_ThreeCompleted() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    // Add Plan-3rd interview
    Interview__c planInterview = new Interview__c(
      Candidate__c = candidate.Id,
      Interview_Type__c = 'Plan-3rd',
      Interview_Status__c = 'Completed',
      Date_Time_Scheduled__c = DateTime.now().addDays(-6)
    );
    insert planInterview;

    Test.startTest();
    String result = InterviewSequenceHelper.getNextInterviewType(candidate.Id);
    Test.stopTest();

    System.assertEquals(
      'Present-4th',
      result,
      'Should suggest Present-4th after three interviews completed'
    );
  }

  @isTest
  static void testGetNextInterviewType_FourCompleted() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    // Add Plan-3rd and Present-4th interviews
    List<Interview__c> additionalInterviews = new List<Interview__c>();
    additionalInterviews.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Plan-3rd',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-6)
      )
    );
    additionalInterviews.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Present-4th',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-4)
      )
    );
    insert additionalInterviews;

    Test.startTest();
    String result = InterviewSequenceHelper.getNextInterviewType(candidate.Id);
    Test.stopTest();

    System.assertEquals(
      'Optional-5th',
      result,
      'Should suggest Optional-5th after four interviews completed'
    );
  }

  @isTest
  static void testGetNextInterviewType_AllCompleted() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    // Add remaining interviews to complete all 5
    List<Interview__c> remainingInterviews = new List<Interview__c>();
    remainingInterviews.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Plan-3rd',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-6)
      )
    );
    remainingInterviews.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Present-4th',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-4)
      )
    );
    remainingInterviews.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Optional-5th',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-2)
      )
    );
    insert remainingInterviews;

    Test.startTest();
    String result = InterviewSequenceHelper.getNextInterviewType(candidate.Id);
    Test.stopTest();

    System.assertEquals(
      'Optional-5th',
      result,
      'Should suggest last type when all interviews completed'
    );
  }

  @isTest
  static void testGetNextInterviewType_NonSequentialCompletion() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    // Delete existing interviews
    delete [SELECT Id FROM Interview__c WHERE Candidate__c = :candidate.Id];

    // Create interviews out of sequence
    List<Interview__c> outOfSequence = new List<Interview__c>();
    outOfSequence.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Ci-First',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-10)
      )
    );
    outOfSequence.add(
      new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = 'Present-4th',
        Interview_Status__c = 'Completed',
        Date_Time_Scheduled__c = DateTime.now().addDays(-8)
      )
    );
    insert outOfSequence;

    Test.startTest();
    String result = InterviewSequenceHelper.getNextInterviewType(candidate.Id);
    Test.stopTest();

    System.assertEquals(
      'Optional-5th',
      result,
      'Should suggest next after highest completed type'
    );
  }

  @isTest
  static void testGetNextInterviewType_ScheduledButNotCompleted() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    // Add a scheduled but not completed interview
    Interview__c scheduledInterview = new Interview__c(
      Candidate__c = candidate.Id,
      Interview_Type__c = 'Plan-3rd',
      Interview_Status__c = 'Scheduled',
      Date_Time_Scheduled__c = DateTime.now().addDays(2)
    );
    insert scheduledInterview;

    Test.startTest();
    String result = InterviewSequenceHelper.getNextInterviewType(candidate.Id);
    Test.stopTest();

    System.assertEquals(
      'Plan-3rd',
      result,
      'Should only count completed interviews, not scheduled ones'
    );
  }

  @isTest
  static void testGetCurrentUserName() {
    Test.startTest();
    String userName = InterviewSequenceHelper.getCurrentUserName();
    Test.stopTest();

    User currentUser = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()];
    System.assertEquals(
      currentUser.Name,
      userName,
      'Should return current user name'
    );
    System.assertNotEquals(null, userName, 'User name should not be null');
  }

  @isTest
  static void testGetCandidateInterviewSummary_NullCandidateId() {
    Test.startTest();
    InterviewSequenceHelper.InterviewSummary summary = InterviewSequenceHelper.getCandidateInterviewSummary(
      null
    );
    Test.stopTest();

    System.assertEquals(
      false,
      summary.hasCompletedInterviews,
      'Should have no completed interviews'
    );
    System.assertEquals(
      0,
      summary.totalCompleted,
      'Should have 0 total completed'
    );
    System.assertEquals(
      'No interviews completed yet.',
      summary.summaryText,
      'Should show default message'
    );
  }

  @isTest
  static void testGetCandidateInterviewSummary_NoInterviews() {
    Candidate__c newCandidate = new Candidate__c(
      First_Name__c = 'Empty',
      Last_Name__c = 'Candidate',
      Email__c = 'empty@example.com'
    );
    insert newCandidate;

    Test.startTest();
    InterviewSequenceHelper.InterviewSummary summary = InterviewSequenceHelper.getCandidateInterviewSummary(
      newCandidate.Id
    );
    Test.stopTest();

    System.assertEquals(
      false,
      summary.hasCompletedInterviews,
      'Should have no completed interviews'
    );
    System.assertEquals(
      0,
      summary.totalCompleted,
      'Should have 0 total completed'
    );
    System.assertEquals(
      'No interviews completed yet.',
      summary.summaryText,
      'Should show default message'
    );
  }

  @isTest
  static void testGetCandidateInterviewSummary_OneInterview() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    // Delete one interview to leave only one
    delete [SELECT Id FROM Interview__c WHERE Interview_Type__c = 'Align-2nd'];

    Test.startTest();
    InterviewSequenceHelper.InterviewSummary summary = InterviewSequenceHelper.getCandidateInterviewSummary(
      candidate.Id
    );
    Test.stopTest();

    System.assertEquals(
      true,
      summary.hasCompletedInterviews,
      'Should have completed interviews'
    );
    System.assertEquals(
      1,
      summary.totalCompleted,
      'Should have 1 total completed'
    );
    System.assert(
      summary.summaryText.contains('1 interview completed'),
      'Summary should mention 1 interview'
    );
    System.assertEquals(
      1,
      summary.completedTypes.size(),
      'Should have 1 unique type'
    );
  }

  @isTest
  static void testGetCandidateInterviewSummary_MultipleInterviews() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    Test.startTest();
    InterviewSequenceHelper.InterviewSummary summary = InterviewSequenceHelper.getCandidateInterviewSummary(
      candidate.Id
    );
    Test.stopTest();

    System.assertEquals(
      true,
      summary.hasCompletedInterviews,
      'Should have completed interviews'
    );
    System.assertEquals(
      2,
      summary.totalCompleted,
      'Should have 2 total completed'
    );
    System.assert(
      summary.summaryText.contains('2 interviews completed'),
      'Summary should mention 2 interviews'
    );
    System.assertEquals(
      2,
      summary.completedTypes.size(),
      'Should have 2 unique types'
    );
    System.assert(
      summary.completedTypes.contains('Ci-First'),
      'Should include Ci-First'
    );
    System.assert(
      summary.completedTypes.contains('Align-2nd'),
      'Should include Align-2nd'
    );
  }

  @isTest
  static void testGetCandidateInterviewSummary_DuplicateTypes() {
    Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];

    // Add another Ci-First interview
    Interview__c duplicateInterview = new Interview__c(
      Candidate__c = candidate.Id,
      Interview_Type__c = 'Ci-First',
      Interview_Status__c = 'Completed',
      Date_Time_Scheduled__c = DateTime.now().addDays(-5)
    );
    insert duplicateInterview;

    Test.startTest();
    InterviewSequenceHelper.InterviewSummary summary = InterviewSequenceHelper.getCandidateInterviewSummary(
      candidate.Id
    );
    Test.stopTest();

    System.assertEquals(
      true,
      summary.hasCompletedInterviews,
      'Should have completed interviews'
    );
    System.assertEquals(
      3,
      summary.totalCompleted,
      'Should have 3 total completed'
    );
    System.assertEquals(
      2,
      summary.completedTypes.size(),
      'Should have 2 unique types despite 3 interviews'
    );
  }
}
