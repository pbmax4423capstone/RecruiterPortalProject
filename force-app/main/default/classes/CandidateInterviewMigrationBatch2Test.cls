/**
 * @description Test class for CandidateInterviewMigrationBatch2
 */
@isTest
private class CandidateInterviewMigrationBatch2Test {
  @TestSetup
  static void setupTestData() {
    // Create test candidates with completed interview data
    List<Candidate__c> candidates = new List<Candidate__c>();

    // Candidate with AI interview
    candidates.add(
      new Candidate__c(
        First_Name__c = 'AI',
        Last_Name__c = 'Interview',
        Email__c = 'ai@migration.com',
        Status__c = 'Active/In Process',
        AI_Completed_Date_Time__c = DateTime.now().addDays(-10)
      )
    );

    // Candidate with Attraction interview
    candidates.add(
      new Candidate__c(
        First_Name__c = 'Attraction',
        Last_Name__c = 'Interview',
        Email__c = 'attraction@migration.com',
        Status__c = 'Active/In Process',
        Attraction_Interview_Date_Completed__c = Date.today().addDays(-8)
      )
    );

    // Candidate with SI1 interview
    candidates.add(
      new Candidate__c(
        First_Name__c = 'SI1',
        Last_Name__c = 'Interview',
        Email__c = 'si1@migration.com',
        Status__c = 'Active/In Process',
        SI_1_Date_Completed__c = Date.today().addDays(-5)
      )
    );

    // Candidate with SI2 interview
    candidates.add(
      new Candidate__c(
        First_Name__c = 'SI2',
        Last_Name__c = 'Interview',
        Email__c = 'si2@migration.com',
        Status__c = 'Active/In Process',
        SI_2_Date_Completed__c = Date.today().addDays(-3)
      )
    );

    // Candidate with Career Presentation
    candidates.add(
      new Candidate__c(
        First_Name__c = 'Career',
        Last_Name__c = 'Interview',
        Email__c = 'career@migration.com',
        Status__c = 'Active/In Process',
        Career_Presentation_Date_Completed__c = Date.today().addDays(-1)
      )
    );

    // Candidate with no completed interviews (should be excluded)
    candidates.add(
      new Candidate__c(
        First_Name__c = 'No',
        Last_Name__c = 'Interview',
        Email__c = 'no@migration.com',
        Status__c = 'Active/In Process'
      )
    );

    insert candidates;
  }

  @isTest
  static void testBatchExecution() {
    // Count candidates with completed interviews
    Integer candidatesWithInterviews = [
      SELECT COUNT()
      FROM Candidate__c
      WHERE
        AI_Completed_Date_Time__c != NULL
        OR Attraction_Interview_Date_Completed__c != NULL
        OR SI_1_Date_Completed__c != NULL
        OR SI_2_Date_Completed__c != NULL
        OR SI_3_Completed__c != NULL
        OR Career_Presentation_Date_Completed__c != NULL
    ];

    System.assertEquals(
      5,
      candidatesWithInterviews,
      'Should have 5 candidates with completed interviews'
    );

    Test.startTest();
    CandidateInterviewMigrationBatch2 batch = new CandidateInterviewMigrationBatch2();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    // Verify batch completed
    AsyncApexJob job = [
      SELECT Status, NumberOfErrors
      FROM AsyncApexJob
      WHERE
        ApexClass.Name = 'CandidateInterviewMigrationBatch2'
        AND JobType = 'BatchApex'
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    System.assertEquals('Completed', job.Status, 'Batch should complete');
    System.assertEquals(0, job.NumberOfErrors, 'Batch should have no errors');
  }

  @isTest
  static void testBatchStart() {
    Test.startTest();
    CandidateInterviewMigrationBatch2 batch = new CandidateInterviewMigrationBatch2();
    Database.QueryLocator ql = batch.start(null);
    Test.stopTest();

    System.assertNotEquals(null, ql, 'QueryLocator should not be null');
  }

  @isTest
  static void testBatchFinish() {
    Test.startTest();
    CandidateInterviewMigrationBatch2 batch = new CandidateInterviewMigrationBatch2();
    Id batchId = Database.executeBatch(batch, 200);
    Test.stopTest();

    // Verify finish method executed
    AsyncApexJob job = [SELECT Status FROM AsyncApexJob WHERE Id = :batchId];
    System.assertEquals(
      'Completed',
      job.Status,
      'Finish method should execute'
    );
  }

  @isTest
  static void testBatchWithNoCandidates() {
    // Delete all test candidates
    delete [SELECT Id FROM Candidate__c WHERE Email__c LIKE '%@migration.com'];

    Test.startTest();
    CandidateInterviewMigrationBatch2 batch = new CandidateInterviewMigrationBatch2();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    // Should complete without errors even with no data
    AsyncApexJob job = [
      SELECT Status, NumberOfErrors
      FROM AsyncApexJob
      WHERE
        ApexClass.Name = 'CandidateInterviewMigrationBatch2'
        AND JobType = 'BatchApex'
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    System.assertEquals('Completed', job.Status, 'Batch should complete');
    System.assertEquals(0, job.NumberOfErrors, 'Should have no errors');
  }

  @isTest
  static void testBatchExecuteDirectly() {
    List<Candidate__c> candidates = [
      SELECT
        Id,
        First_Name__c,
        Last_Name__c,
        AI_Conducted_By__c,
        AI_Completed_Date_Time__c,
        Attraction_Interview_Conducted_By__c,
        Attraction_Interview_Date_Completed__c,
        SI_1_Conducted_By__c,
        SI_1_Date_Completed__c,
        SI_2_Conducted_By__c,
        SI_2_Date_Completed__c,
        SI_3_Conducted_By__c,
        SI_3_Completed__c,
        Career_Presentation_Conducted_By__c,
        Career_Presentation_Date_Completed__c
      FROM Candidate__c
      WHERE Email__c = 'ai@migration.com'
    ];

    Test.startTest();
    CandidateInterviewMigrationBatch2 batch = new CandidateInterviewMigrationBatch2();
    batch.execute(null, candidates);
    Test.stopTest();

    // Test should complete without errors
    System.assertEquals(1, candidates.size(), 'Should have one candidate');
  }

  @isTest
  static void testBatchWithAllInterviewTypes() {
    // Create a candidate with all interview types
    Candidate__c allTypes = new Candidate__c(
      First_Name__c = 'All',
      Last_Name__c = 'Types',
      Email__c = 'all@migration.com',
      Status__c = 'Active/In Process',
      AI_Completed_Date_Time__c = DateTime.now().addDays(-10),
      Attraction_Interview_Date_Completed__c = Date.today().addDays(-8),
      SI_1_Date_Completed__c = Date.today().addDays(-5),
      SI_2_Date_Completed__c = Date.today().addDays(-3),
      Career_Presentation_Date_Completed__c = Date.today().addDays(-1)
    );
    insert allTypes;

    Test.startTest();
    CandidateInterviewMigrationBatch2 batch = new CandidateInterviewMigrationBatch2();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    AsyncApexJob job = [
      SELECT Status
      FROM AsyncApexJob
      WHERE
        ApexClass.Name = 'CandidateInterviewMigrationBatch2'
        AND JobType = 'BatchApex'
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    System.assertEquals(
      'Completed',
      job.Status,
      'Batch should complete with all interview types'
    );
  }
}
