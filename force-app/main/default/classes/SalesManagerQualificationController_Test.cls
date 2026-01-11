/**
 * @description Test class for SalesManagerQualificationController
 * @author Patrick's Agent
 * @date 2026-01-09
 */
@IsTest
private class SalesManagerQualificationController_Test {
  /**
   * Create test data
   */
  @TestSetup
  static void setupTestData() {
    // Create test Account (required for Opportunities)
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Create test Contacts
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 1; i <= 5; i++) {
      contacts.add(
        new Contact(
          FirstName = 'Test',
          LastName = 'Agent' + i,
          Email = 'agent' + i + '@test.com',
          AccountId = testAccount.Id
        )
      );
    }
    insert contacts;

    // Create Contract B Candidates
    List<Candidate__c> contractBCandidates = new List<Candidate__c>();

    // Agent 1: Complete (5 submissions, $3000 FYC)
    contractBCandidates.add(
      new Candidate__c(
        First_Name__c = 'Test',
        Last_Name__c = 'Agent1',
        Contact__c = contacts[0].Id,
        Sales_Manager__c = 'Tim Denton',
        Contract_Type__c = 'Contract B',
        Start_Date__c = Date.today().addDays(-60),
        Extension_Granted__c = false
      )
    );

    // Agent 2: Critical (< 14 days, 2 submissions, $500 FYC)
    contractBCandidates.add(
      new Candidate__c(
        First_Name__c = 'Test',
        Last_Name__c = 'Agent2',
        Contact__c = contacts[1].Id,
        Sales_Manager__c = 'Tim Denton',
        Contract_Type__c = 'Contract B',
        Start_Date__c = Date.today().addDays(-110),
        Extension_Granted__c = false
      )
    );

    // Agent 3: At Risk (< 30 days, 3 submissions, $1500 FYC)
    contractBCandidates.add(
      new Candidate__c(
        First_Name__c = 'Test',
        Last_Name__c = 'Agent3',
        Contact__c = contacts[2].Id,
        Sales_Manager__c = 'Elizabeth Kagele',
        Contract_Type__c = 'Contract B',
        Start_Date__c = Date.today().addDays(-95),
        Extension_Granted__c = false
      )
    );

    // Agent 4: On Track (60 days left, 2 submissions, $1000 FYC)
    contractBCandidates.add(
      new Candidate__c(
        First_Name__c = 'Test',
        Last_Name__c = 'Agent4',
        Contact__c = contacts[3].Id,
        Sales_Manager__c = 'Van Hess',
        Contract_Type__c = 'Contract B',
        Start_Date__c = Date.today().addDays(-60),
        Extension_Granted__c = false
      )
    );

    // Agent 5: Extension granted (240 days total, 100 days in)
    contractBCandidates.add(
      new Candidate__c(
        First_Name__c = 'Test',
        Last_Name__c = 'Agent5',
        Contact__c = contacts[4].Id,
        Sales_Manager__c = 'Tim Denton',
        Contract_Type__c = 'Contract B',
        Start_Date__c = Date.today().addDays(-100),
        Extension_Granted__c = true
      )
    );

    insert contractBCandidates;

    // Get Account for Opportunities
    Account acct = [SELECT Id FROM Account LIMIT 1];

    // Create Opportunities for Contract B agents
    List<Opportunity> opportunities = new List<Opportunity>();

    // Agent 1: 5 submitted, 3 won ($3000 FYC)
    for (Integer i = 0; i < 5; i++) {
      opportunities.add(
        new Opportunity(
          Name = 'Opp Agent1-' + i,
          AccountId = acct.Id,
          Soliciting_Agent__c = contacts[0].Id,
          Amount = i < 3 ? 1000 : 0,
          StageName = i < 3 ? 'Closed Won' : 'Prospecting',
          CloseDate = Date.today()
        )
      );
    }

    // Agent 2: 2 submitted, 1 won ($500 FYC)
    for (Integer i = 0; i < 2; i++) {
      opportunities.add(
        new Opportunity(
          Name = 'Opp Agent2-' + i,
          AccountId = acct.Id,
          Soliciting_Agent__c = contacts[1].Id,
          Amount = i == 0 ? 500 : 0,
          StageName = i == 0 ? 'Closed Won' : 'Prospecting',
          CloseDate = Date.today()
        )
      );
    }

    // Agent 3: 3 submitted, 2 won ($1500 FYC)
    for (Integer i = 0; i < 3; i++) {
      opportunities.add(
        new Opportunity(
          Name = 'Opp Agent3-' + i,
          AccountId = acct.Id,
          Soliciting_Agent__c = contacts[2].Id,
          Amount = i < 2 ? 750 : 0,
          StageName = i < 2 ? 'Closed Won' : 'Prospecting',
          CloseDate = Date.today()
        )
      );
    }

    // Agent 4: 2 submitted, 1 won ($1000 FYC)
    for (Integer i = 0; i < 2; i++) {
      opportunities.add(
        new Opportunity(
          Name = 'Opp Agent4-' + i,
          AccountId = acct.Id,
          Soliciting_Agent__c = contacts[3].Id,
          Amount = i == 0 ? 1000 : 0,
          StageName = i == 0 ? 'Closed Won' : 'Prospecting',
          CloseDate = Date.today()
        )
      );
    }

    // Agent 5: 1 submitted, 0 won
    opportunities.add(
      new Opportunity(
        Name = 'Opp Agent5-0',
        AccountId = acct.Id,
        Soliciting_Agent__c = contacts[4].Id,
        Amount = 0,
        StageName = 'Prospecting',
        CloseDate = Date.today()
      )
    );

    insert opportunities;

    // Create Contract A data (Contract_Qualification__c records)
    List<Contract_Qualification__c> qualifications = new List<Contract_Qualification__c>();

    qualifications.add(
      new Contract_Qualification__c(
        Agent__c = contacts[0].Id,
        Contract_Date__c = Date.today().addDays(-180),
        All_YTD_FYC__c = 5000,
        YTD_WLADL__c = 15000,
        WLADL_Contract_Minimum__c = 10000,
        WLADL_GDC_Qual_Status__c = 'Met Qualified'
      )
    );

    qualifications.add(
      new Contract_Qualification__c(
        Agent__c = contacts[1].Id,
        Contract_Date__c = Date.today().addDays(-90),
        All_YTD_FYC__c = 2000,
        YTD_WLADL__c = 5000,
        WLADL_Contract_Minimum__c = 10000,
        WLADL_GDC_Qual_Status__c = 'Not Qualified'
      )
    );

    insert qualifications;
  }

  /**
   * Test getCurrentUserRole() with System Administrator profile
   */
  @IsTest
  static void testGetCurrentUserRole_GlobalView() {
    // This test runs as the current user (typically System Administrator)
    Test.startTest();
    Map<String, Object> result = SalesManagerQualificationController.getCurrentUserRole();
    Test.stopTest();

    // Should return global view for System Administrator
    Assert.areEqual(
      true,
      result.get('isGlobalView'),
      'System Administrator should have global view'
    );
    Assert.areEqual(
      null,
      result.get('salesManagerUnit'),
      'Global view should not have specific unit'
    );
  }

  /**
   * Test getCurrentUserRole() with non-Director profile
   */
  @IsTest
  static void testGetCurrentUserRole_SalesManagerView() {
    // Create test user with standard profile
    Profile standardProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Standard User'
      LIMIT 1
    ];
    User testUser = new User(
      FirstName = 'Test',
      LastName = 'SalesManager',
      Email = 'testsm@test.com',
      Username = 'testsm' + DateTime.now().getTime() + '@test.com',
      Alias = 'tsm',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      ProfileId = standardProfile.Id,
      LanguageLocaleKey = 'en_US'
    );
    insert testUser;

    System.runAs(testUser) {
      Test.startTest();
      Map<String, Object> result = SalesManagerQualificationController.getCurrentUserRole();
      Test.stopTest();

      // Should not have global view
      Assert.areEqual(
        false,
        result.get('isGlobalView'),
        'Standard User should not have global view'
      );
      // Should have error since user is not linked to a Candidate
      Assert.isTrue(
        result.containsKey('error'),
        'Should have error for user without Sales Manager unit'
      );
    }
  }

  /**
   * Test getSalesManagerUnits()
   */
  @IsTest
  static void testGetSalesManagerUnits() {
    Test.startTest();
    List<String> units = SalesManagerQualificationController.getSalesManagerUnits();
    Test.stopTest();

    // Should return 3 unique Sales Managers from test data
    Assert.isNotNull(units, 'Units list should not be null');
    Assert.areEqual(3, units.size(), 'Should have 3 unique Sales Managers');
    Assert.isTrue(units.contains('Tim Denton'), 'Should contain Tim Denton');
    Assert.isTrue(
      units.contains('Elizabeth Kagele'),
      'Should contain Elizabeth Kagele'
    );
    Assert.isTrue(units.contains('Van Hess'), 'Should contain Van Hess');
  }

  /**
   * Test getContractBAgentProgress() with specific unit
   */
  @IsTest
  static void testGetContractBAgentProgress_SpecificUnit() {
    Test.startTest();
    List<SalesManagerQualificationController.ContractBAgentData> results = SalesManagerQualificationController.getContractBAgentProgress(
      'Tim Denton'
    );
    Test.stopTest();

    // Should return 3 agents for Tim Denton
    Assert.isNotNull(results, 'Results should not be null');
    Assert.areEqual(3, results.size(), 'Should have 3 agents for Tim Denton');

    // Verify first agent (Complete status)
    SalesManagerQualificationController.ContractBAgentData agent1 = results[0];
    Assert.areEqual('Test Agent1', agent1.agentName, 'Agent name should match');
    Assert.areEqual(
      5,
      agent1.opportunitiesSubmitted,
      'Should have 5 submissions'
    );
    Assert.areEqual(3, agent1.opportunitiesWon, 'Should have 3 won');
    Assert.areEqual(3000, agent1.totalFYC, 'Should have $3000 FYC');
    Assert.areEqual(
      100,
      agent1.submissionsProgress,
      'Submissions progress should be 100%'
    );
    Assert.areEqual(100, agent1.fycProgress, 'FYC progress should be 100%');
    Assert.areEqual('Complete', agent1.status, 'Status should be Complete');
    Assert.isTrue(agent1.requirementsMet, 'Requirements should be met');
  }

  /**
   * Test getContractBAgentProgress() with "All Units"
   */ // Note: Requirements_Met__c is a formula field in production, can't test exact value
  @IsTest
  static void testGetContractBAgentProgress_AllUnits() {
    Test.startTest();
    List<SalesManagerQualificationController.ContractBAgentData> results = SalesManagerQualificationController.getContractBAgentProgress(
      'All Units'
    );
    Test.stopTest();

    // Should return all 5 agents
    Assert.isNotNull(results, 'Results should not be null');
    Assert.areEqual(5, results.size(), 'Should have 5 agents total');
  }

  /**
   * Test progress calculations
   */
  @IsTest
  static void testProgressCalculations() {
    Test.startTest();
    List<SalesManagerQualificationController.ContractBAgentData> results = SalesManagerQualificationController.getContractBAgentProgress(
      'Elizabeth Kagele'
    );
    Test.stopTest();

    // Agent3 belongs to Elizabeth Kagele; expect 1 agent in result
    Assert.areEqual(1, results.size(), 'Should have 1 agent for Elizabeth Kagele');

    // Agent 3: 3 submissions (60%), $1500 FYC (60%)
    SalesManagerQualificationController.ContractBAgentData agent3 = results[0];
    Assert.areEqual('Test Agent3', agent3.agentName, 'Agent3 should be present');
    Assert.areEqual(3, agent3.opportunitiesSubmitted, 'Should have 3 submissions');
    Assert.areEqual(60, agent3.submissionsProgress, 'Submissions progress should be 60%');
    Assert.areEqual(60, agent3.fycProgress, 'FYC progress should be 60%');
  }

  /**
   * Test status determination logic
   */
  @IsTest
  static void testStatusDetermination() {
    Test.startTest();
    List<SalesManagerQualificationController.ContractBAgentData> results = SalesManagerQualificationController.getContractBAgentProgress(
      'All Units'
    );
    Test.stopTest();

    // Find agents by name and verify status
    Map<String, String> agentStatusMap = new Map<String, String>();
    for (
      SalesManagerQualificationController.ContractBAgentData agent : results
    ) {
      agentStatusMap.put(agent.agentName, agent.status);
    }

    Assert.areEqual(
      'Complete',
      agentStatusMap.get('Test Agent1'),
      'Agent1 should be Complete'
    );
    Assert.areEqual(
      'Critical',
      agentStatusMap.get('Test Agent2'),
      'Agent2 should be Critical'
    );
    Assert.areEqual(
      'At Risk',
      agentStatusMap.get('Test Agent3'),
      'Agent3 should be At Risk'
    );
    Assert.areEqual(
      'On Track',
      agentStatusMap.get('Test Agent4'),
      'Agent4 should be On Track'
    );
  }

  /**
   * Test days remaining with extension
   */
  @IsTest
  static void testDaysRemainingWithExtension() {
    Test.startTest();
    List<SalesManagerQualificationController.ContractBAgentData> results = SalesManagerQualificationController.getContractBAgentProgress(
      'All Units'
    );
    Test.stopTest();

    // Find Agent5 (extension granted)
    SalesManagerQualificationController.ContractBAgentData agent5 = null;
    for (
      SalesManagerQualificationController.ContractBAgentData agent : results
    ) {
      if (agent.agentName == 'Test Agent5') {
        agent5 = agent;
        break;
      }
    }

    Assert.isNotNull(agent5, 'Agent5 should be found');
    // Agent5 started 100 days ago with 240-day deadline = 140 days remaining
    Assert.isTrue(
      agent5.daysRemaining > 120,
      'Extension should give more than 120 days total'
    );
  }

  /**
   * Test getContractAAgentProgress() with specific unit
   */
  @IsTest
  static void testGetContractAAgentProgress_SpecificUnit() {
    Test.startTest();
    List<SalesManagerQualificationController.ContractAAgentData> results = SalesManagerQualificationController.getContractAAgentProgress(
      'Tim Denton'
    );
    Test.stopTest();

    // Should return agents with Contract_Qualification__c records
    Assert.isNotNull(results, 'Results should not be null');
    Assert.isTrue(
      results.size() > 0,
      'Should have at least 1 Contract A agent'
    );

    // Verify first agent
    SalesManagerQualificationController.ContractAAgentData agent = results[0];
    Assert.isNotNull(agent.agentName, 'Agent name should be populated');
    Assert.isNotNull(agent.contractDate, 'Contract date should be populated');
    Assert.areEqual(5000, agent.ytdFYC, 'YTD FYC should match');
    Assert.areEqual(15000, agent.ytdWLADL, 'YTD WLADL should match');
    Assert.areEqual(10000, agent.wladlGoal, 'WLADL Goal should match');
    Assert.areEqual(100, agent.progress, 'Progress should be 100% (capped)');

    // Verify Opportunity counts are included
    Assert.areEqual(
      5,
      agent.opportunitiesSubmitted,
      'Should have 5 submissions'
    );
    Assert.areEqual(3, agent.opportunitiesWon, 'Should have 3 won');
  }

  /**
   * Test getContractAAgentProgress() with "All Units"
   */
  @IsTest
  static void testGetContractAAgentProgress_AllUnits() {
    Test.startTest();
    List<SalesManagerQualificationController.ContractAAgentData> results = SalesManagerQualificationController.getContractAAgentProgress(
      'All Units'
    );
    Test.stopTest();

    // Should return all Contract A agents
    Assert.isNotNull(results, 'Results should not be null');
    Assert.areEqual(2, results.size(), 'Should have 2 Contract A agents');
  }

  /**
   * Test edge case: No Opportunities
   */
  @IsTest
  static void testEdgeCase_NoOpportunities() {
    // Create a new Candidate with no Opportunities
    Contact newContact = new Contact(
      FirstName = 'No',
      LastName = 'Opportunities',
      Email = 'noopp@test.com'
    );
    insert newContact;

    Candidate__c newCandidate = new Candidate__c(
      First_Name__c = 'No',
      Last_Name__c = 'Opportunities',
      Contact__c = newContact.Id,
      Sales_Manager__c = 'Tim Denton',
      Contract_Type__c = 'Contract B',
      Start_Date__c = Date.today().addDays(-30)
    );
    insert newCandidate;

    Test.startTest();
    List<SalesManagerQualificationController.ContractBAgentData> results = SalesManagerQualificationController.getContractBAgentProgress(
      'Tim Denton'
    );
    Test.stopTest();

    // Find the agent with no opportunities
    SalesManagerQualificationController.ContractBAgentData noOppAgent = null;
    for (
      SalesManagerQualificationController.ContractBAgentData agent : results
    ) {
      if (agent.agentName == 'No Opportunities') {
        noOppAgent = agent;
        break;
      }
    }

    Assert.isNotNull(noOppAgent, 'Agent should be found');
    Assert.areEqual(
      0,
      noOppAgent.opportunitiesSubmitted,
      'Should have 0 submissions'
    );
    Assert.areEqual(0, noOppAgent.opportunitiesWon, 'Should have 0 won');
    Assert.areEqual(0, noOppAgent.totalFYC, 'Should have $0 FYC');
    Assert.areEqual(0, noOppAgent.submissionsProgress, 'Progress should be 0%');
  }

  /**
   * Test edge case: Null Start Date
   */
  @IsTest
  static void testEdgeCase_NullStartDate() {
    // Create a Candidate with null Start_Date__c
    Contact newContact = new Contact(
      FirstName = 'Null',
      LastName = 'StartDate',
      Email = 'nulldate@test.com'
    );
    insert newContact;

    Candidate__c newCandidate = new Candidate__c(
      First_Name__c = 'Null',
      Last_Name__c = 'StartDate',
      Contact__c = newContact.Id,
      Sales_Manager__c = 'Tim Denton',
      Contract_Type__c = 'Contract B',
      Start_Date__c = null // Null start date
    );
    insert newCandidate;

    Test.startTest();
    List<SalesManagerQualificationController.ContractBAgentData> results = SalesManagerQualificationController.getContractBAgentProgress(
      'Tim Denton'
    );
    Test.stopTest();

    // Find the agent with null start date
    SalesManagerQualificationController.ContractBAgentData nullDateAgent = null;
    for (
      SalesManagerQualificationController.ContractBAgentData agent : results
    ) {
      if (agent.agentName == 'Null StartDate') {
        nullDateAgent = agent;
        break;
      }
    }

    Assert.isNotNull(nullDateAgent, 'Agent should be found');
    Assert.areEqual(null, nullDateAgent.deadline, 'Deadline should be null');
    Assert.areEqual(
      0,
      nullDateAgent.daysRemaining,
      'Days remaining should default to 0'
    );
  }

  /**
   * Test calculateProgress helper method
   */
  @IsTest
  static void testCalculateProgressHelper() {
    // Test through getContractBAgentProgress to increase coverage
    Test.startTest();
    List<SalesManagerQualificationController.ContractBAgentData> results = SalesManagerQualificationController.getContractBAgentProgress(
      'All Units'
    );
    Test.stopTest();

    // Verify progress calculations are working
    Assert.isNotNull(results, 'Results should not be null');
    for (
      SalesManagerQualificationController.ContractBAgentData agent : results
    ) {
      // Progress should be between 0 and 100
      Assert.isTrue(
        agent.submissionsProgress >= 0 && agent.submissionsProgress <= 100,
        'Submissions progress should be 0-100'
      );
      Assert.isTrue(
        agent.fycProgress >= 0 && agent.fycProgress <= 100,
        'FYC progress should be 0-100'
      );
    }
  }

  /**
   * Test getCandidatePipelineByStage - specific Sales Manager
   */
  @IsTest
  static void testGetCandidatePipelineByStage_SpecificManager() {
    // Create additional candidates with various stages for Tim Denton
    List<Candidate__c> additionalCandidates = new List<Candidate__c>();

    additionalCandidates.add(
      new Candidate__c(
        First_Name__c = 'Stage',
        Last_Name__c = 'Test1',
        Sales_Manager__c = 'Tim Denton',
        Status__c = 'Active/In Process',
        Highest_Level_Achieved__c = '0-Prequal'
      )
    );

    additionalCandidates.add(
      new Candidate__c(
        First_Name__c = 'Stage',
        Last_Name__c = 'Test2',
        Sales_Manager__c = 'Tim Denton',
        Status__c = 'Active/In Process',
        Highest_Level_Achieved__c = '0-Prequal'
      )
    );

    additionalCandidates.add(
      new Candidate__c(
        First_Name__c = 'Stage',
        Last_Name__c = 'Test3',
        Sales_Manager__c = 'Tim Denton',
        Status__c = 'Active/In Process',
        Highest_Level_Achieved__c = 'Ci_1st'
      )
    );

    insert additionalCandidates;

    Test.startTest();
    Map<String, Object> pipeline = SalesManagerQualificationController.getCandidatePipelineByStage(
      'Tim Denton'
    );
    Test.stopTest();

    // Verify results
    Assert.isNotNull(pipeline, 'Pipeline should not be null');
    Assert.isTrue(
      pipeline.containsKey('stageData'),
      'Should have stageData key'
    );
    Assert.isTrue(pipeline.containsKey('total'), 'Should have total key');

    List<Object> stageData = (List<Object>) pipeline.get('stageData');
    Integer total = (Integer) pipeline.get('total');

    Assert.isNotNull(stageData, 'Stage data should not be null');
    Assert.isTrue(total >= 3, 'Should have at least 3 candidates');
  }

  /**
   * Test getCandidatePipelineByStage - All Units
   */
  @IsTest
  static void testGetCandidatePipelineByStage_AllUnits() {
    // Create candidates with different Sales Managers
    List<Candidate__c> additionalCandidates = new List<Candidate__c>();

    additionalCandidates.add(
      new Candidate__c(
        First_Name__c = 'AllUnits',
        Last_Name__c = 'Test1',
        Sales_Manager__c = 'Elizabeth Kagele',
        Status__c = 'Active/In Process',
        Highest_Level_Achieved__c = 'Present-4th'
      )
    );

    additionalCandidates.add(
      new Candidate__c(
        First_Name__c = 'AllUnits',
        Last_Name__c = 'Test2',
        Sales_Manager__c = 'Van Hess',
        Status__c = 'Active/In Process',
        Highest_Level_Achieved__c = 'Present-4th'
      )
    );

    insert additionalCandidates;

    Test.startTest();
    Map<String, Object> pipeline = SalesManagerQualificationController.getCandidatePipelineByStage(
      'All Units'
    );
    Test.stopTest();

    // Verify results include candidates from all managers
    Assert.isNotNull(pipeline, 'Pipeline should not be null');

    List<Object> stageData = (List<Object>) pipeline.get('stageData');
    Integer total = (Integer) pipeline.get('total');

    Assert.isNotNull(stageData, 'Stage data should not be null');
    Assert.isTrue(total >= 2, 'Should have at least 2 candidates');
  }

  /**
   * Test getCandidatePipelineByStage - No active candidates
   */
  @IsTest
  static void testGetCandidatePipelineByStage_NoActiveCandidates() {
    // Query for a manager with no Active/In Process candidates
    Test.startTest();
    Map<String, Object> pipeline = SalesManagerQualificationController.getCandidatePipelineByStage(
      'Nonexistent Manager'
    );
    Test.stopTest();

    // Verify empty results
    Assert.isNotNull(pipeline, 'Pipeline should not be null');

    List<Object> stageData = (List<Object>) pipeline.get('stageData');
    Integer total = (Integer) pipeline.get('total');

    Assert.areEqual(0, stageData.size(), 'Should have no stage data');
    Assert.areEqual(0, total, 'Total should be 0');
  }
}
