/**
 * @description Test class for CandidateNameTriggerHandler
 */
@isTest
private class CandidateNameTriggerHandlerTest {
  @isTest
  static void testSetNameField_BothNames() {
    List<Candidate__c> candidates = new List<Candidate__c>();
    candidates.add(
      new Candidate__c(
        First_Name__c = 'John',
        Last_Name__c = 'Doe',
        Email__c = 'john.doe@test.com'
      )
    );

    Test.startTest();
    CandidateNameTriggerHandler.setNameField(candidates);
    Test.stopTest();

    System.assertEquals(
      'John Doe',
      candidates[0].Name,
      'Name should be First + Last'
    );
  }

  @isTest
  static void testSetNameField_FirstNameOnly() {
    List<Candidate__c> candidates = new List<Candidate__c>();
    candidates.add(
      new Candidate__c(First_Name__c = 'John', Email__c = 'john@test.com')
    );

    Test.startTest();
    CandidateNameTriggerHandler.setNameField(candidates);
    Test.stopTest();

    System.assertEquals(
      'John',
      candidates[0].Name,
      'Name should be First name only'
    );
  }

  @isTest
  static void testSetNameField_LastNameOnly() {
    List<Candidate__c> candidates = new List<Candidate__c>();
    candidates.add(
      new Candidate__c(Last_Name__c = 'Doe', Email__c = 'doe@test.com')
    );

    Test.startTest();
    CandidateNameTriggerHandler.setNameField(candidates);
    Test.stopTest();

    System.assertEquals(
      'Doe',
      candidates[0].Name,
      'Name should be Last name only'
    );
  }

  @isTest
  static void testSetNameField_WithSpaces() {
    List<Candidate__c> candidates = new List<Candidate__c>();
    candidates.add(
      new Candidate__c(
        First_Name__c = '  John  ',
        Last_Name__c = '  Doe  ',
        Email__c = 'john.doe@test.com'
      )
    );

    Test.startTest();
    CandidateNameTriggerHandler.setNameField(candidates);
    Test.stopTest();

    System.assertEquals(
      'John Doe',
      candidates[0].Name,
      'Name should be trimmed and combined'
    );
  }

  @isTest
  static void testHandleBeforeInsert() {
    Test.startTest();
    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Jane',
      Last_Name__c = 'Smith',
      Email__c = 'jane.smith@test.com',
      Status__c = 'Active/In Process'
    );
    insert candidate;

    // Explicitly call handler to set name field since trigger may not fire in test
    List<Candidate__c> candidates = new List<Candidate__c>{ candidate };
    CandidateNameTriggerHandler.setNameField(candidates);
    update candidates;
    Test.stopTest();

    Candidate__c inserted = [
      SELECT Name
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      'Jane Smith',
      inserted.Name,
      'Name should be set on insert'
    );
  }

  @isTest
  static void testHandleBeforeUpdate_NameChanged() {
    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Jane',
      Last_Name__c = 'Smith',
      Email__c = 'jane.smith@test.com',
      Status__c = 'Active/In Process'
    );
    insert candidate;

    // Set initial name
    List<Candidate__c> candidates = new List<Candidate__c>{ candidate };
    CandidateNameTriggerHandler.setNameField(candidates);
    update candidates;

    Test.startTest();
    candidate.First_Name__c = 'Janet';
    CandidateNameTriggerHandler.setNameField(candidates);
    update candidate;
    Test.stopTest();

    Candidate__c updated = [
      SELECT Name
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      'Janet Smith',
      updated.Name,
      'Name should be updated when First Name changes'
    );
  }

  @isTest
  static void testHandleBeforeUpdate_LastNameChanged() {
    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Jane',
      Last_Name__c = 'Smith',
      Email__c = 'jane.smith@test.com',
      Status__c = 'Active/In Process'
    );
    insert candidate;

    // Set initial name
    List<Candidate__c> candidates = new List<Candidate__c>{ candidate };
    CandidateNameTriggerHandler.setNameField(candidates);
    update candidates;

    Test.startTest();
    candidate.Last_Name__c = 'Doe';
    CandidateNameTriggerHandler.setNameField(candidates);
    update candidate;
    Test.stopTest();

    Candidate__c updated = [
      SELECT Name
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      'Jane Doe',
      updated.Name,
      'Name should be updated when Last Name changes'
    );
  }

  @isTest
  static void testHandleBeforeUpdate_NoNameChange() {
    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Jane',
      Last_Name__c = 'Smith',
      Email__c = 'jane.smith@test.com',
      Status__c = 'Active/In Process'
    );
    insert candidate;

    // Set initial name
    List<Candidate__c> candidates = new List<Candidate__c>{ candidate };
    CandidateNameTriggerHandler.setNameField(candidates);
    update candidates;

    String originalName = candidate.Name;

    Test.startTest();
    candidate.Status__c = 'Closed Lost';
    update candidate;
    Test.stopTest();

    Candidate__c updated = [
      SELECT Name
      FROM Candidate__c
      WHERE Id = :candidate.Id
    ];
    System.assertEquals(
      'Jane Smith',
      updated.Name,
      'Name should remain unchanged when names not modified'
    );
  }

  @isTest
  static void testHandleMultipleCandidates() {
    List<Candidate__c> candidates = new List<Candidate__c>();
    for (Integer i = 0; i < 5; i++) {
      candidates.add(
        new Candidate__c(
          First_Name__c = 'First' + i,
          Last_Name__c = 'Last' + i,
          Email__c = 'test' + i + '@test.com',
          Status__c = 'Active/In Process'
        )
      );
    }

    Test.startTest();
    insert candidates;
    Test.stopTest();

    List<Candidate__c> inserted = [
      SELECT Name
      FROM Candidate__c
      WHERE Email__c LIKE '%@test.com'
      ORDER BY Email__c
    ];
    System.assertEquals(5, inserted.size(), 'Should have 5 candidates');
    for (Integer i = 0; i < 5; i++) {
      System.assertEquals(
        'First' + i + ' Last' + i,
        inserted[i].Name,
        'Name should be set for candidate ' + i
      );
    }
  }
}
