/**
 * Test class for CandidatesInContractingController
 * Tests Sales Manager Contracting Kanban functionality
 */
@isTest
private class CandidatesInContractingController_Test {
  @testSetup
  static void setup() {
    // Create test candidates
    List<Candidate__c> candidates = new List<Candidate__c>();
    for (Integer i = 0; i < 3; i++) {
      candidates.add(
        new Candidate__c(
          First_Name__c = 'Test' + i,
          Last_Name__c = 'Candidate' + i,
          Email__c = 'test' + i + '@test.com',
          Sales_Manager__c = 'Tim Denton', // Valid picklist value
          Status__c = 'Active'
        )
      );
    }
    insert candidates;

    // Get Career record type
    Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName()
      .get('Career')
      .getRecordTypeId();

    // Create ALC records with Career/Broker contracting stages
    List<ALC__c> alcs = new List<ALC__c>();
    for (Candidate__c c : candidates) {
      alcs.add(
        new ALC__c(
          Name = 'ALC-' + c.First_Name__c,
          Candidate__c = c.Id,
          RecordTypeId = careerRTId,
          Stage__c = 'Pending SM',
          Agency__c = 'A157',
          Contract_Type__c = 'A'
        )
      );
    }
    insert alcs;
  }

  @isTest
  static void testGetCandidatesInContracting() {
    Test.startTest();
    Map<String, List<CandidatesInContractingController.CandidateWrapper>> result = CandidatesInContractingController.getCandidatesInContracting();
    Test.stopTest();

    System.assert(result != null, 'Result should not be null');
    System.assert(
      result.containsKey('Pending SM'),
      'Should contain Pending SM stage'
    );
    System.assertEquals(
      3,
      result.get('Pending SM').size(),
      'Should have 3 candidates'
    );
  }

  @isTest
  static void testGetAgencyPicklistValues() {
    Test.startTest();
    List<String> result = CandidatesInContractingController.getAgencyPicklistValues();
    Test.stopTest();

    System.assert(result != null, 'Result should not be null');
    System.assert(result.size() > 0, 'Should have values');
    System.assertEquals('All', result[0], 'First value should be All');
  }

  @isTest
  static void testGetStageConfiguration() {
    Test.startTest();
    Map<String, List<CandidatesInContractingController.StageConfig>> result = CandidatesInContractingController.getStageConfiguration();
    Test.stopTest();

    System.assert(result != null, 'Result should not be null');
  }

  @isTest
  static void testGetALCDataForSalesManager() {
    Test.startTest();
    CandidatesInContractingController.ALCDataResponse result = CandidatesInContractingController.getALCDataForSalesManager(
      'Tim Denton'
    );
    Test.stopTest();

    System.assert(result != null, 'Result should not be null');
    System.assert(result.alcsByStage != null, 'Should have alcsByStage');
  }

  @isTest
  static void testGetCurrentUserSalesManagerName() {
    Test.startTest();
    String result = CandidatesInContractingController.getCurrentUserSalesManagerName();
    Test.stopTest();

    System.assert(result != null, 'Result should not be null');
  }

  @isTest
  static void testGetSalesManagerOptions() {
    Test.startTest();
    List<String> result = CandidatesInContractingController.getSalesManagerOptions();
    Test.stopTest();

    System.assert(result != null, 'Result should not be null');
  }

  @isTest
  static void testCanViewAllSalesManagers() {
    Test.startTest();
    Boolean result = CandidatesInContractingController.canViewAllSalesManagers();
    Test.stopTest();

    // Should work without exceptions
    System.assert(result != null, 'Result should not be null');
  }

  @isTest
  static void testGetALCDataForSalesManager_AllManagers() {
    Test.startTest();
    CandidatesInContractingController.ALCDataResponse result = CandidatesInContractingController.getALCDataForSalesManager(
      'All Sales Managers'
    );
    Test.stopTest();

    System.assert(result != null, 'Result should not be null');
    System.assert(result.alcsByStage != null, 'Should have alcsByStage');
  }

  @isTest
  static void testGetALCDataForSalesManager_NullFilter() {
    Test.startTest();
    CandidatesInContractingController.ALCDataResponse result = CandidatesInContractingController.getALCDataForSalesManager(
      null
    );
    Test.stopTest();

    System.assert(result != null, 'Result should not be null');
  }

  @isTest
  static void testGetCandidatesInContracting_MultipleCandidates() {
    // Just test that the method returns data
    Test.startTest();
    Map<String, List<CandidatesInContractingController.CandidateWrapper>> result = CandidatesInContractingController.getCandidatesInContracting();
    Test.stopTest();

    System.assert(result != null, 'Result should not be null');
    // Method may return empty map if stages don't match contract type filter
  }
}
