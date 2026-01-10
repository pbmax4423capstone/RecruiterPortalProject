/**
 * @description Test class for CandidateRecordViewController
 */
@isTest
private class CandidateRecordViewControllerTest {
  @TestSetup
  static void setupTestData() {
    // Create test Contact
    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'Contact',
      Email = 'testcontact@example.com',
      Phone = '555-0100',
      MobilePhone = '555-0101'
    );
    insert testContact;

    // Create test Candidate with Contact relationship
    Candidate__c testCandidate = new Candidate__c(
      First_Name__c = 'Test',
      Last_Name__c = 'Candidate',
      Email__c = 'testcandidateview@example.com',
      Phone__c = '555-0102',
      Status__c = 'Active/In Process',
      Contact__c = testContact.Id,
      Sales_Manager__c = 'Tim Denton',
      Contract_Type__c = 'Career Contract'
    );
    insert testCandidate;
  }

  @isTest
  static void testGetCandidateData_Success() {
    Candidate__c candidate = [
      SELECT Id
      FROM Candidate__c
      WHERE Email__c = 'testcandidateview@example.com'
      LIMIT 1
    ];

    Test.startTest();
    Map<String, Object> result = CandidateRecordViewController.getCandidateData(
      candidate.Id
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals(
      candidate.Id,
      result.get('Id'),
      'Candidate ID should match'
    );
    System.assert(
      result.containsKey('First_Name__c'),
      'Should contain First_Name__c'
    );
    System.assert(
      result.containsKey('Last_Name__c'),
      'Should contain Last_Name__c'
    );
    System.assert(
      result.containsKey('Contact__r'),
      'Should contain Contact relationship'
    );
  }

  @isTest
  static void testGetCandidateData_WithContactRelationship() {
    Candidate__c candidate = [
      SELECT Id
      FROM Candidate__c
      WHERE Email__c = 'testcandidateview@example.com'
      LIMIT 1
    ];

    Test.startTest();
    Map<String, Object> result = CandidateRecordViewController.getCandidateData(
      candidate.Id
    );
    Test.stopTest();

    System.assert(
      result.containsKey('Contact__r'),
      'Should have Contact relationship data'
    );

    Map<String, Object> contactData = (Map<String, Object>) result.get(
      'Contact__r'
    );
    System.assertNotEquals(
      null,
      contactData,
      'Contact data should not be null'
    );
    System.assertEquals(
      'testcontact@example.com',
      contactData.get('Email'),
      'Contact email should match'
    );
  }

  @isTest
  static void testGetCandidateData_InvalidId() {
    // Create a fake ID for a non-existent record
    Id fakeId = '001000000000000AAA';

    Test.startTest();
    try {
      Map<String, Object> result = CandidateRecordViewController.getCandidateData(
        fakeId
      );
      System.assert(false, 'Should have thrown an exception');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage().contains('not found') ||
        e.getMessage().contains('Error'),
        'Exception message should indicate error'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testGetCandidateData_NullId() {
    Test.startTest();
    try {
      Map<String, Object> result = CandidateRecordViewController.getCandidateData(
        null
      );
      System.assert(false, 'Should have thrown an exception');
    } catch (Exception e) {
      // Expected - null ID should cause an exception
      System.assertNotEquals(null, e, 'Exception should be thrown for null ID');
    }
    Test.stopTest();
  }
}
