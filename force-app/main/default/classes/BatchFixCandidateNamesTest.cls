/**
 * @description Test class for BatchFixCandidateNames
 */
@isTest
private class BatchFixCandidateNamesTest {
  @TestSetup
  static void setupTestData() {
    // Create candidates with various name issues
    List<Candidate__c> candidates = new List<Candidate__c>();

    // Candidate with both first and last name
    candidates.add(
      new Candidate__c(
        First_Name__c = 'John',
        Last_Name__c = 'Doe',
        Email__c = 'john.doe@batchtest.com',
        Status__c = 'Active/In Process'
      )
    );

    // Candidate with only first name
    candidates.add(
      new Candidate__c(
        First_Name__c = 'Jane',
        Email__c = 'jane@batchtest.com',
        Status__c = 'Active/In Process'
      )
    );

    // Candidate with only last name
    candidates.add(
      new Candidate__c(
        Last_Name__c = 'Smith',
        Email__c = 'smith@batchtest.com',
        Status__c = 'Active/In Process'
      )
    );

    // Candidate with both names but Name will be set to ID pattern
    candidates.add(
      new Candidate__c(
        First_Name__c = 'Bob',
        Last_Name__c = 'Johnson',
        Email__c = 'bob.johnson@batchtest.com',
        Status__c = 'Active/In Process'
      )
    );

    insert candidates;

    // Manually update last candidate to have ID-like Name
    Candidate__c toUpdate = [
      SELECT Id
      FROM Candidate__c
      WHERE Email__c = 'bob.johnson@batchtest.com'
    ];
    toUpdate.Name = 'a0X' + String.valueOf(Math.random()).substring(2, 15);
    update toUpdate;
  }

  @isTest
  static void testBatchExecution_FixesNames() {
    // Verify test data setup
    List<Candidate__c> beforeBatch = [
      SELECT Id, Name, First_Name__c, Last_Name__c
      FROM Candidate__c
      ORDER BY Email__c
    ];
    System.assertEquals(4, beforeBatch.size(), 'Should have 4 test candidates');

    Test.startTest();
    BatchFixCandidateNames batch = new BatchFixCandidateNames();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    // Verify names were fixed
    List<Candidate__c> afterBatch = [
      SELECT Name, First_Name__c, Last_Name__c, Email__c
      FROM Candidate__c
      ORDER BY Email__c
    ];

    for (Candidate__c c : afterBatch) {
      if (c.Email__c == 'john.doe@batchtest.com') {
        System.assertEquals('John Doe', c.Name, 'Name should be First + Last');
      } else if (c.Email__c == 'jane@batchtest.com') {
        System.assertEquals('Jane', c.Name, 'Name should be First name only');
      } else if (c.Email__c == 'smith@batchtest.com') {
        System.assertEquals('Smith', c.Name, 'Name should be Last name only');
      } else if (c.Email__c == 'bob.johnson@batchtest.com') {
        System.assertEquals(
          'Bob Johnson',
          c.Name,
          'Name should be fixed from ID pattern'
        );
      }
    }
  }

  @isTest
  static void testBatchStart_QueryLocator() {
    Test.startTest();
    BatchFixCandidateNames batch = new BatchFixCandidateNames();
    Database.QueryLocator ql = batch.start(null);
    Test.stopTest();

    System.assertNotEquals(null, ql, 'QueryLocator should not be null');
  }

  @isTest
  static void testBatchExecute_WithValidData() {
    List<Candidate__c> candidates = [
      SELECT Id, Name, First_Name__c, Last_Name__c
      FROM Candidate__c
      WHERE Email__c = 'john.doe@batchtest.com'
    ];

    Test.startTest();
    BatchFixCandidateNames batch = new BatchFixCandidateNames();
    batch.execute(null, candidates);
    Test.stopTest();

    Candidate__c updated = [
      SELECT Name
      FROM Candidate__c
      WHERE Email__c = 'john.doe@batchtest.com'
    ];
    System.assertEquals('John Doe', updated.Name, 'Name should be updated');
  }

  @isTest
  static void testBatchExecute_EmptyList() {
    Test.startTest();
    BatchFixCandidateNames batch = new BatchFixCandidateNames();
    batch.execute(null, new List<Candidate__c>());
    Test.stopTest();

    // Should not throw exception with empty list
    System.assert(true, 'Should handle empty list gracefully');
  }

  @isTest
  static void testBatchFinish() {
    Test.startTest();
    BatchFixCandidateNames batch = new BatchFixCandidateNames();
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
  static void testBatchWithSpaces() {
    // Create candidate with names containing extra spaces
    Candidate__c candidate = new Candidate__c(
      First_Name__c = '  John  ',
      Last_Name__c = '  Doe  ',
      Email__c = 'spaces@batchtest.com',
      Status__c = 'Active/In Process'
    );
    insert candidate;

    Test.startTest();
    BatchFixCandidateNames batch = new BatchFixCandidateNames();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    Candidate__c updated = [
      SELECT Name
      FROM Candidate__c
      WHERE Email__c = 'spaces@batchtest.com'
    ];
    System.assertEquals(
      'John Doe',
      updated.Name,
      'Name should be trimmed and combined'
    );
  }

  @isTest
  static void testBatchWithNullNames() {
    // Create candidate with null names (should be excluded from batch processing)
    Candidate__c candidate = new Candidate__c(
      Email__c = 'nullnames@batchtest.com',
      Status__c = 'Active/In Process'
    );
    insert candidate;

    // Manually set Name to null
    candidate.Name = null;
    update candidate;

    Test.startTest();
    BatchFixCandidateNames batch = new BatchFixCandidateNames();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    // Candidate with no First or Last name should not be updated by batch
    Candidate__c result = [
      SELECT Name
      FROM Candidate__c
      WHERE Email__c = 'nullnames@batchtest.com'
    ];
    // Name will still be null since batch requires First_Name__c != null OR Last_Name__c != null in query
    System.assert(
      result.Name == null || result.Name == '',
      'Candidate without names should not be processed'
    );
  }
}
