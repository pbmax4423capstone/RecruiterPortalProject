@isTest
public class ContractBDashboardControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Contract B',
            LastName = 'Test Contact',
            Email = 'contractbtest@example.com'
        );
        insert testContact;
        
        // Create Contract B candidates with various states
        List<Candidate__c> contractBCandidates = new List<Candidate__c>();
        
        // At-risk candidate (less than 30 days remaining, requirements not met)
        contractBCandidates.add(new Candidate__c(
            Email__c = 'contractb1@test.com',
            Contract_Type__c = 'Contract B',
            Status__c = 'Contracted- Contract B',
            Start_Date__c = Date.today().addMonths(-3).addDays(-15),
            Contact__c = testContact.Id,
            Sales_Manager__c = 'Tim Denton'
        ));
        
        // On track candidate
        contractBCandidates.add(new Candidate__c(
            Email__c = 'contractb2@test.com',
            Contract_Type__c = 'Contract B',
            Status__c = 'Contracted- Contract B',
            Start_Date__c = Date.today().addMonths(-2),
            Contact__c = testContact.Id,
            Sales_Manager__c = 'Elizabeth Kagele'
        ));
        
        // New candidate (plenty of time)
        contractBCandidates.add(new Candidate__c(
            Email__c = 'contractb3@test.com',
            Contract_Type__c = 'Contract B',
            Status__c = 'Contracted- Contract B',
            Start_Date__c = Date.today().addDays(-30),
            Contact__c = testContact.Id,
            Sales_Manager__c = 'Van Hess'
        ));
        
        // Career Contract candidate for metrics
        contractBCandidates.add(new Candidate__c(
            Email__c = 'contracta1@test.com',
            Contract_Type__c = 'Career Contract',
            Status__c = 'Active/In Process',
            Start_Date__c = Date.today().addMonths(-2),
            Sales_Manager__c = 'Tim Denton'
        ));
        
        // Terminated candidate for metrics
        contractBCandidates.add(new Candidate__c(
            Email__c = 'terminated1@test.com',
            Contract_Type__c = 'Contract B',
            Status__c = 'Terminated',
            Start_Date__c = Date.today().addMonths(-5),
            Termination_Date__c = Date.today().addDays(-10),
            Termination_Reason__c = 'Did not meet initial contract requirements',
            Sales_Manager__c = 'Elizabeth Kagele'
        ));
        
        // Transitioned candidate
        contractBCandidates.add(new Candidate__c(
            Email__c = 'transitioned1@test.com',
            Contract_Type__c = 'Career Contract', // Transitioned to Career Contract
            Status__c = 'Active/In Process',
            Start_Date__c = Date.today().addMonths(-6),
            Transition_to_A_Date__c = Date.today().addMonths(-1),
            Sales_Manager__c = 'Van Hess'
        ));
        
        insert contractBCandidates;
        
        // Create Interview records for interview stats testing
        List<Interview__c> interviews = new List<Interview__c>();
        
        // Completed interviews this month
        for (Integer i = 0; i < 5; i++) {
            interviews.add(new Interview__c(
                Interview_Type__c = 'Attraction',
                Interview_Status__c = 'Completed',
                Candidate__c = contractBCandidates[0].Id,
                Date_Time_Scheduled__c = System.now().addDays(-i)
            ));
        }
        
        for (Integer i = 0; i < 3; i++) {
            interviews.add(new Interview__c(
                Interview_Type__c = 'SI1',
                Interview_Status__c = 'Completed',
                Candidate__c = contractBCandidates[1].Id,
                Date_Time_Scheduled__c = System.now().addDays(-i)
            ));
        }
        
        for (Integer i = 0; i < 2; i++) {
            interviews.add(new Interview__c(
                Interview_Type__c = 'SI2',
                Interview_Status__c = 'Completed',
                Candidate__c = contractBCandidates[2].Id,
                Date_Time_Scheduled__c = System.now().addDays(-i)
            ));
        }
        
        interviews.add(new Interview__c(
            Interview_Type__c = 'Career',
            Interview_Status__c = 'Completed',
            Candidate__c = contractBCandidates[0].Id,
            Date_Time_Scheduled__c = System.now().addDays(-1)
        ));
        
        // Some scheduled (not completed) interviews
        interviews.add(new Interview__c(
            Interview_Type__c = 'SI3',
            Interview_Status__c = 'Scheduled',
            Candidate__c = contractBCandidates[1].Id,
            Date_Time_Scheduled__c = System.now().addDays(1)
        ));
        
        insert interviews;
    }
    
    @isTest
    static void testGetContractBPipelineData() {
        Test.startTest();
        Map<String, Object> result = ContractBDashboardController.getContractBPipelineData();
        Test.stopTest();
        
        // Verify result structure
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('pipeline'), 'Result should contain pipeline');
        System.assert(result.containsKey('summary'), 'Result should contain summary');
        System.assert(result.containsKey('atRiskCandidates'), 'Result should contain atRiskCandidates');
        
        // Verify pipeline data
        List<Object> pipeline = (List<Object>)result.get('pipeline');
        System.assertNotEquals(null, pipeline, 'Pipeline should not be null');
        System.assertEquals(3, pipeline.size(), 'Should have 3 active Contract B candidates');
        
        // Verify summary
        Map<String, Object> summary = (Map<String, Object>)result.get('summary');
        System.assertNotEquals(null, summary, 'Summary should not be null');
        System.assertEquals(3, summary.get('totalActive'), 'Should have 3 total active');
    }
    
    @isTest
    static void testGetInterviewStatsByPeriodCurrentMonth() {
        Test.startTest();
        Map<String, Object> result = ContractBDashboardController.getInterviewStatsByPeriod('currentMonth');
        Test.stopTest();
        
        // Verify result structure
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('currentMonth', result.get('period'), 'Period should be currentMonth');
        System.assertEquals('Current Month', result.get('periodLabel'), 'Period label should be Current Month');
        
        // Verify interview counts exist
        System.assert(result.containsKey('attraction'), 'Should have attraction count');
        System.assert(result.containsKey('si1'), 'Should have si1 count');
        System.assert(result.containsKey('si2'), 'Should have si2 count');
        System.assert(result.containsKey('si3'), 'Should have si3 count');
        System.assert(result.containsKey('career'), 'Should have career count');
        System.assert(result.containsKey('total'), 'Should have total count');
    }
    
    @isTest
    static void testGetInterviewStatsByPeriodYTD() {
        Test.startTest();
        Map<String, Object> result = ContractBDashboardController.getInterviewStatsByPeriod('yearToDate');
        Test.stopTest();
        
        // Verify result structure
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('yearToDate', result.get('period'), 'Period should be yearToDate');
        System.assertEquals('Year to Date', result.get('periodLabel'), 'Period label should be Year to Date');
        
        // Verify interviewer breakdown
        System.assert(result.containsKey('attractionByInterviewer'), 'Should have attractionByInterviewer');
        System.assert(result.containsKey('si1ByInterviewer'), 'Should have si1ByInterviewer');
    }
    
    @isTest
    static void testGetRecruitingMetrics() {
        Test.startTest();
        Map<String, Object> result = ContractBDashboardController.getRecruitingMetrics();
        Test.stopTest();
        
        // Verify result structure
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('monthlyRecruiting'), 'Should have monthlyRecruiting');
        System.assert(result.containsKey('terminationReasons'), 'Should have terminationReasons');
        System.assert(result.containsKey('ytdTotals'), 'Should have ytdTotals');
        
        // Verify monthly recruiting data
        List<Object> monthlyData = (List<Object>)result.get('monthlyRecruiting');
        System.assertNotEquals(null, monthlyData, 'Monthly recruiting should not be null');
        System.assert(monthlyData.size() > 0, 'Should have at least one month of data');
        
        // Verify YTD totals structure
        Map<String, Object> ytdTotals = (Map<String, Object>)result.get('ytdTotals');
        System.assertNotEquals(null, ytdTotals, 'YTD totals should not be null');
        System.assert(ytdTotals.containsKey('contractA'), 'Should have contractA count');
        System.assert(ytdTotals.containsKey('contractB'), 'Should have contractB count');
        System.assert(ytdTotals.containsKey('transitions'), 'Should have transitions count');
        System.assert(ytdTotals.containsKey('terminations'), 'Should have terminations count');
        System.assert(ytdTotals.containsKey('transitionRate'), 'Should have transitionRate');
        System.assert(ytdTotals.containsKey('terminationRate'), 'Should have terminationRate');
        
        // Verify termination reasons
        List<Object> terminationReasons = (List<Object>)result.get('terminationReasons');
        System.assertNotEquals(null, terminationReasons, 'Termination reasons should not be null');
    }
    
    @isTest
    static void testGetContractBPipelineDataNoData() {
        // Delete only test data created in @TestSetup to test empty state
        delete [SELECT Id FROM Candidate__c WHERE Email__c LIKE 'contractb%@test.com' OR Email__c LIKE '%@test.com'];
        
        Test.startTest();
        Map<String, Object> result = ContractBDashboardController.getContractBPipelineData();
        Test.stopTest();
        
        // Verify result handles empty data
        System.assertNotEquals(null, result, 'Result should not be null');
        
        Map<String, Object> summary = (Map<String, Object>)result.get('summary');
        System.assertEquals(0, summary.get('totalActive'), 'Should have 0 total active');
    }
    
    @isTest
    static void testGetContractAProgressData() {
        // Create Contract_Qualification__c test data
        List<Contract_Qualification__c> cqRecords = new List<Contract_Qualification__c>();
        
        cqRecords.add(new Contract_Qualification__c(
            Name = 'Test Agent 1',
            Advisor_Active_Indicator__c = true,
            Contract_Status__c = 'Active',
            All_YTD_FYC__c = 50000,
            YTD_WLADL__c = 40000,
            WLADL_Contract_Minimum__c = 38000,
            WLADL_GDC_Qual_Status__c = 'Met WLADL',
            All_MTD_FYC__c = 5000,
            MTD_WLADL__c = 4000
        ));
        
        cqRecords.add(new Contract_Qualification__c(
            Name = 'Test Agent 2',
            Advisor_Active_Indicator__c = true,
            Contract_Status__c = 'Active',
            All_YTD_FYC__c = 30000,
            YTD_WLADL__c = 25000,
            WLADL_Contract_Minimum__c = 38000,
            WLADL_GDC_Qual_Status__c = 'Not On Target',
            All_MTD_FYC__c = 3000,
            MTD_WLADL__c = 2500
        ));
        
        insert cqRecords;
        
        Test.startTest();
        Map<String, Object> result = ContractBDashboardController.getContractAProgressData();
        Test.stopTest();
        
        // Verify result structure
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('contractAData'), 'Should contain contractAData');
        System.assert(result.containsKey('summary'), 'Should contain summary');
        
        // Verify data
        List<Object> contractAData = (List<Object>)result.get('contractAData');
        System.assertNotEquals(null, contractAData, 'Contract A data should not be null');
        System.assertEquals(2, contractAData.size(), 'Should have 2 agents');
        
        // Verify summary
        Map<String, Object> summary = (Map<String, Object>)result.get('summary');
        System.assertEquals(2, summary.get('totalAgents'), 'Should have 2 total agents');
        System.assertEquals(1, summary.get('metCount'), 'Should have 1 agent who met requirements');
        System.assertEquals(1, summary.get('notOnTargetCount'), 'Should have 1 agent not on target');
        System.assertEquals(80000, summary.get('totalYTDFYC'), 'Total YTD FYC should be 80000');
    }
    
    @isTest
    static void testGetContractAProgressDataNoData() {
        // Test with no Contract_Qualification__c records
        Test.startTest();
        Map<String, Object> result = ContractBDashboardController.getContractAProgressData();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        
        List<Object> contractAData = (List<Object>)result.get('contractAData');
        System.assertEquals(0, contractAData.size(), 'Should have no agents');
        
        Map<String, Object> summary = (Map<String, Object>)result.get('summary');
        System.assertEquals(0, summary.get('totalAgents'), 'Should have 0 total agents');
    }
}