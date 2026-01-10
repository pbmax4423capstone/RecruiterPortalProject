/**
 * @description Test class for CandidateFYCRollupService
 * @author Contract Lifecycle Tracking System
 * @date December 2025
 */
@isTest
private class CandidateFYCRollupServiceTest {
  @TestSetup
  static void setupTestData() {
    // Create test Contact
    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'Agent',
      Email = 'test.agent@test.com'
    );
    insert testContact;

    // Create test Candidate linked to Contact
    Candidate__c testCandidate = new Candidate__c(
      First_Name__c = 'Test',
      Last_Name__c = 'Agent',
      Contact__c = testContact.Id,
      Contract_Type__c = 'Contract B',
      Contract_Outcome__c = 'Active',
      Start_Date__c = Date.today().addMonths(-2)
    );
    insert testCandidate;
  }

  @isTest
  static void testUpdateCandidateFYCRollup_WithOpportunities() {
    Contact testContact = [
      SELECT Id
      FROM Contact
      WHERE LastName = 'Agent'
      LIMIT 1
    ];
    Candidate__c testCandidate = [
      SELECT Id, Contact__c
      FROM Candidate__c
      WHERE Contact__c = :testContact.Id
      LIMIT 1
    ];

    // Create test Opportunities
    List<Opportunity> testOpps = new List<Opportunity>();
    for (Integer i = 0; i < 5; i++) {
      testOpps.add(
        new Opportunity(
          Name = 'Test Opp ' + i,
          ContactId = testContact.Id,
          StageName = 'Submitted',
          CloseDate = Date.today().addDays(30),
          FYC__c = 600 // Total will be 3000 (5 x 600)
        )
      );
    }
    insert testOpps;

    Test.startTest();
    CandidateFYCRollupService.updateCandidateFYCRollup(
      new List<Id>{ testContact.Id }
    );
    Test.stopTest();

    // Verify rollup
    Candidate__c updatedCandidate = [
      SELECT Id, Total_FYC__c, Opportunity_Count__c, Requirements_Met__c
      FROM Candidate__c
      WHERE Id = :testCandidate.Id
    ];

    System.assertEquals(
      3000,
      updatedCandidate.Total_FYC__c,
      'Total FYC should be 3000'
    );
    System.assertEquals(
      5,
      updatedCandidate.Opportunity_Count__c,
      'Opportunity count should be 5'
    );
    System.assertEquals(
      true,
      updatedCandidate.Requirements_Met__c,
      'Requirements should be met (FYC >= 2500 AND Count >= 5)'
    );
  }

  @isTest
  static void testUpdateCandidateFYCRollup_NoOpportunities() {
    Contact testContact = [
      SELECT Id
      FROM Contact
      WHERE LastName = 'Agent'
      LIMIT 1
    ];
    Candidate__c testCandidate = [
      SELECT Id
      FROM Candidate__c
      WHERE Contact__c = :testContact.Id
      LIMIT 1
    ];

    Test.startTest();
    CandidateFYCRollupService.updateCandidateFYCRollup(
      new List<Id>{ testContact.Id }
    );
    Test.stopTest();

    Candidate__c updatedCandidate = [
      SELECT Id, Total_FYC__c, Opportunity_Count__c
      FROM Candidate__c
      WHERE Id = :testCandidate.Id
    ];

    System.assertEquals(
      0,
      updatedCandidate.Total_FYC__c,
      'Total FYC should be 0'
    );
    System.assertEquals(
      0,
      updatedCandidate.Opportunity_Count__c,
      'Opportunity count should be 0'
    );
  }

  @isTest
  static void testUpdateCandidateFYCRollup_NullInput() {
    Test.startTest();
    // Should not throw exception
    CandidateFYCRollupService.updateCandidateFYCRollup(null);
    CandidateFYCRollupService.updateCandidateFYCRollup(new List<Id>());
    Test.stopTest();

    // No assertions needed - just verifying no exceptions
  }

  @isTest
  static void testUpdateAllContractBCandidates() {
    Contact testContact = [
      SELECT Id
      FROM Contact
      WHERE LastName = 'Agent'
      LIMIT 1
    ];

    // Create opportunities
    List<Opportunity> testOpps = new List<Opportunity>();
    for (Integer i = 0; i < 3; i++) {
      testOpps.add(
        new Opportunity(
          Name = 'Test Opp ' + i,
          ContactId = testContact.Id,
          StageName = 'Submitted',
          CloseDate = Date.today().addDays(30),
          FYC__c = 500
        )
      );
    }
    insert testOpps;

    Test.startTest();
    CandidateFYCRollupService.updateAllContractBCandidates();
    Test.stopTest();

    Candidate__c updatedCandidate = [
      SELECT Id, Total_FYC__c, Opportunity_Count__c
      FROM Candidate__c
      WHERE Contact__c = :testContact.Id
    ];

    System.assertEquals(
      1500,
      updatedCandidate.Total_FYC__c,
      'Total FYC should be 1500'
    );
    System.assertEquals(
      3,
      updatedCandidate.Opportunity_Count__c,
      'Opportunity count should be 3'
    );
  }
}
