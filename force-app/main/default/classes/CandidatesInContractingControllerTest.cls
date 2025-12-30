/**
 * @description Test class for CandidatesInContractingController
 */
@isTest
private class CandidatesInContractingControllerTest {
  @TestSetup
  static void setupTestData() {
    // Create test candidates
    List<Candidate__c> candidates = new List<Candidate__c>();
    for (Integer i = 0; i < 3; i++) {
      candidates.add(
        new Candidate__c(
          First_Name__c = 'Test',
          Last_Name__c = 'Candidate' + i,
          Email__c = 'contracting' + i + '@test.com',
          Status__c = 'Active/In Process',
          Contract_Type__c = 'Career Contract'
        )
      );
    }
    insert candidates;

    // Create ALC records at different stages
    List<ALC__c> alcRecords = new List<ALC__c>();

    alcRecords.add(
      new ALC__c(
        Candidate__c = candidates[0].Id,
        Stage__c = 'Initial Form Sent',
        Contract_Type__c = 'A'
      )
    );

    alcRecords.add(
      new ALC__c(
        Candidate__c = candidates[1].Id,
        Stage__c = 'In Background',
        Contract_Type__c = 'B'
      )
    );

    alcRecords.add(
      new ALC__c(
        Candidate__c = candidates[2].Id,
        Stage__c = 'Sent To Compliance',
        Contract_Type__c = null
      )
    );

    insert alcRecords;
  }

  @isTest
  static void testGetCandidatesInContracting_Success() {
    Test.startTest();
    Map<String, List<CandidatesInContractingController.CandidateWrapper>> result = CandidatesInContractingController.getCandidatesInContracting();
    Test.stopTest();

    System.assertNotEquals(null, result, 'Result should not be null');
    System.assert(result.size() > 0, 'Should have stage mappings');

    // Verify stages exist
    System.assert(
      result.containsKey('Initial Form Sent'),
      'Should have Initial Form Sent stage'
    );
    System.assert(
      result.containsKey('In Background'),
      'Should have In Background stage'
    );
    System.assert(
      result.containsKey('Sent To Compliance'),
      'Should have Sent To Compliance stage'
    );
  }

  @isTest
  static void testGetCandidatesInContracting_VerifyWrapperData() {
    Test.startTest();
    Map<String, List<CandidatesInContractingController.CandidateWrapper>> result = CandidatesInContractingController.getCandidatesInContracting();
    Test.stopTest();

    // Get one wrapper to verify data structure
    List<CandidatesInContractingController.CandidateWrapper> wrappers = result.get(
      'Initial Form Sent'
    );
    System.assertNotEquals(null, wrappers, 'Wrappers should not be null');
    System.assertEquals(
      1,
      wrappers.size(),
      'Should have 1 candidate in Initial Form Sent'
    );

    CandidatesInContractingController.CandidateWrapper wrapper = wrappers[0];
    System.assertNotEquals(null, wrapper.alcId, 'ALC ID should be populated');
    System.assertNotEquals(
      null,
      wrapper.candidateId,
      'Candidate ID should be populated'
    );
    System.assertNotEquals(
      null,
      wrapper.candidateName,
      'Candidate name should be populated'
    );
    System.assertEquals(
      'Initial Form Sent',
      wrapper.alcStage,
      'Stage should match'
    );
  }

  @isTest
  static void testGetCandidatesInContracting_MultipleCandidatesOneStage() {
    // Add another candidate to same stage
    Candidate__c newCandidate = new Candidate__c(
      First_Name__c = 'Another',
      Last_Name__c = 'Candidate',
      Email__c = 'another@test.com',
      Status__c = 'Active/In Process'
    );
    insert newCandidate;

    ALC__c newAlc = new ALC__c(
      Candidate__c = newCandidate.Id,
      Stage__c = 'In Background',
      Contract_Type__c = 'A'
    );
    insert newAlc;

    Test.startTest();
    Map<String, List<CandidatesInContractingController.CandidateWrapper>> result = CandidatesInContractingController.getCandidatesInContracting();
    Test.stopTest();

    List<CandidatesInContractingController.CandidateWrapper> backgroundCandidates = result.get(
      'In Background'
    );
    System.assertEquals(
      2,
      backgroundCandidates.size(),
      'Should have 2 candidates in In Background stage'
    );
  }

  @isTest
  static void testUpdateCandidateStage_Success() {
    ALC__c alc = [
      SELECT Id, Stage__c
      FROM ALC__c
      WHERE Stage__c = 'Initial Form Sent'
      LIMIT 1
    ];

    Test.startTest();
    String result = CandidatesInContractingController.updateCandidateStage(
      alc.Id,
      'MM_ONX_Sent'
    );
    Test.stopTest();

    System.assertEquals('Success', result, 'Update should be successful');

    // Verify stage was updated
    ALC__c updatedAlc = [SELECT Stage__c FROM ALC__c WHERE Id = :alc.Id];
    System.assertEquals(
      'MM_ONX_Sent',
      updatedAlc.Stage__c,
      'Stage should be updated'
    );
  }

  @isTest
  static void testUpdateCandidateStage_InvalidId() {
    Id fakeId = '001000000000000AAA';

    Test.startTest();
    try {
      String result = CandidatesInContractingController.updateCandidateStage(
        fakeId,
        'MM_ONX_Sent'
      );
      System.assert(false, 'Should have thrown an exception');
    } catch (AuraHandledException e) {
      // The controller throws: 'Error updating stage: ' + e.getMessage()
      // Just verify an exception was thrown with a message
      System.assert(
        e.getMessage() != null && e.getMessage().length() > 0,
        'Exception message should indicate error: ' + e.getMessage()
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testGetCandidatesInContracting_ExcludesCompletedStages() {
    // Add a candidate with completed stage
    Candidate__c completedCandidate = new Candidate__c(
      First_Name__c = 'Completed',
      Last_Name__c = 'Candidate',
      Email__c = 'completed@test.com',
      Status__c = 'Active/In Process'
    );
    insert completedCandidate;

    ALC__c completedAlc = new ALC__c(
      Candidate__c = completedCandidate.Id,
      Stage__c = 'COMPLETE',
      Contract_Type__c = 'A'
    );
    insert completedAlc;

    Test.startTest();
    Map<String, List<CandidatesInContractingController.CandidateWrapper>> result = CandidatesInContractingController.getCandidatesInContracting();
    Test.stopTest();

    // Verify COMPLETE stage is not in results
    System.assert(
      !result.containsKey('COMPLETE'),
      'Should exclude COMPLETE stage'
    );
  }

  @isTest
  static void testGetCandidatesInContracting_NoData() {
    // Delete all ALC records
    delete [SELECT Id FROM ALC__c];

    Test.startTest();
    Map<String, List<CandidatesInContractingController.CandidateWrapper>> result = CandidatesInContractingController.getCandidatesInContracting();
    Test.stopTest();

    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals(
      0,
      result.size(),
      'Should have no stage mappings with no data'
    );
  }
}
