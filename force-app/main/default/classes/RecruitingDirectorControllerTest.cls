/**
 * Test class for RecruitingDirectorController
 * 
 * @author Recruiter Portal Development Team
 * @date 2026-01-07
 */
@isTest
private class RecruitingDirectorControllerTest {
    
    @TestSetup
    static void setup() {
        // Create test candidates with sales managers
        List<Candidate__c> testCandidates = new List<Candidate__c>();
        
        testCandidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Manager1',
            Status__c = 'Active/In Process',
            Sales_Manager__c = 'Tim Denton',
            Email__c = 'test1@example.com'
        ));
        
        testCandidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Manager2',
            Status__c = 'Active/In Process',
            Sales_Manager__c = 'Bradley Sofonia',
            Email__c = 'test2@example.com'
        ));
        
        testCandidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Manager3',
            Status__c = 'Archived',
            Sales_Manager__c = 'Tim Denton',
            Email__c = 'test3@example.com'
        ));
        
        insert testCandidates;
        
        // Create test interviews
        List<Interview__c> testInterviews = new List<Interview__c>();
        
        testInterviews.add(new Interview__c(
            Candidate__c = testCandidates[0].Id,
            Date_Time_Scheduled__c = Date.today().addDays(5),
            Interview_Status__c = 'Scheduled'
        ));
        
        testInterviews.add(new Interview__c(
            Candidate__c = testCandidates[1].Id,
            Date_Time_Scheduled__c = Date.today().addDays(-5),
            Interview_Status__c = 'Completed',
            Date_Completed__c = Date.today().addDays(-5)
        ));
        
        insert testInterviews;
        
        // Create test ALC records
        List<ALC__c> testALCs = new List<ALC__c>();
        
        testALCs.add(new ALC__c(
            Candidate__c = testCandidates[0].Id,
            Contract_Type__c = 'B',
            Stage__c = 'Contracting Complete',
            Contract_Effective__c = Date.today()
        ));
        
        testALCs.add(new ALC__c(
            Candidate__c = testCandidates[1].Id,
            Contract_Type__c = 'A',
            Stage__c = 'Contracting Complete',
            Contract_Effective__c = Date.today()
        ));
        
        insert testALCs;
    }
    
    @isTest
    static void testGetSalesManagerList() {
        Test.startTest();
        List<Map<String,String>> managers = RecruitingDirectorController.getSalesManagerList();
        Test.stopTest();
        
        System.assertEquals(3, managers.size(), 'Expected 3 options (All + 2 managers)');
        System.assertEquals('All Sales Managers', managers[0].get('label'), 'First option should be "All Sales Managers"');
    }
    
    @isTest
    static void testGetMetricsForManager_TimDenton() {
        Test.startTest();
        Map<String,Object> metrics = RecruitingDirectorController.getMetricsForManager('Tim Denton', 'This Month');
        Test.stopTest();
        
        System.assertEquals(2, (Integer)metrics.get('totalCandidates'), 'Tim should have 2 candidates');
        System.assertEquals(1, (Integer)metrics.get('activePipeline'), 'Tim should have 1 active candidate');
        System.assertEquals(1, (Integer)metrics.get('upcomingInterviews'), 'Tim should have 1 upcoming interview');
    }
    
    @isTest
    static void testGetMetricsForManager_BradleySofonia() {
        Test.startTest();
        Map<String,Object> metrics = RecruitingDirectorController.getMetricsForManager('Bradley Sofonia', 'This Month');
        Test.stopTest();
        
        System.assertEquals(1, (Integer)metrics.get('totalCandidates'), 'Bradley should have 1 candidate');
        System.assertEquals(1, (Integer)metrics.get('activePipeline'), 'Bradley should have 1 active candidate');
    }
    
    @isTest
    static void testGetGlobalMetrics() {
        Test.startTest();
        Map<String,Object> metrics = RecruitingDirectorController.getGlobalMetrics('This Month');
        Test.stopTest();
        
        System.assertEquals(3, (Integer)metrics.get('totalCandidates'), 'Global should have 3 candidates');
        System.assertEquals(2, (Integer)metrics.get('activePipeline'), 'Global should have 2 active candidates');
    }
    
    @isTest
    static void testGetManagerComparison_TotalCandidates() {
        Test.startTest();
        Map<String,Object> chartData = RecruitingDirectorController.getManagerComparison('totalCandidates', 'This Month');
        Test.stopTest();
        
        List<String> labels = (List<String>)chartData.get('labels');
        List<Integer> values = (List<Integer>)chartData.get('values');
        
        System.assertEquals(2, labels.size(), 'Should have 2 managers');
        System.assertEquals(2, values.size(), 'Should have 2 value points');
    }
    
    @isTest
    static void testGetManagerComparison_ActivePipeline() {
        Test.startTest();
        Map<String,Object> chartData = RecruitingDirectorController.getManagerComparison('activePipeline', 'This Month');
        Test.stopTest();
        
        List<String> labels = (List<String>)chartData.get('labels');
        List<Integer> values = (List<Integer>)chartData.get('values');
        
        System.assertEquals(2, labels.size(), 'Should have 2 managers');
        System.assertEquals(2, values.size(), 'Should have 2 value points');
    }
    
    @isTest
    static void testGetCandidatesList_AllManagers() {
        Test.startTest();
        List<Map<String,Object>> candidates = RecruitingDirectorController.getCandidatesList('All Sales Managers', 'This Month');
        Test.stopTest();
        
        System.assertEquals(3, candidates.size(), 'Should return all 3 candidates');
    }
    
    @isTest
    static void testGetCandidatesList_SpecificManager() {
        Test.startTest();
        List<Map<String,Object>> candidates = RecruitingDirectorController.getCandidatesList('Tim Denton', 'This Month');
        Test.stopTest();
        
        System.assertEquals(2, candidates.size(), 'Should return only Tim\'s 2 candidates');
    }
    
    @isTest
    static void testGetUpcomingInterviewsList_AllManagers() {
        Test.startTest();
        List<Map<String,Object>> interviews = RecruitingDirectorController.getUpcomingInterviewsList('All Sales Managers', 'This Month');
        Test.stopTest();
        
        System.assertEquals(1, interviews.size(), 'Should return all upcoming interviews');
    }
    
    @isTest
    static void testGetActivePipelineList_SpecificManager() {
        Test.startTest();
        List<Map<String,Object>> candidates = RecruitingDirectorController.getActivePipelineList('Tim Denton', 'This Month');
        Test.stopTest();
        
        System.assertEquals(1, candidates.size(), 'Should return Tim\'s active candidates');
    }
    
    @isTest
    static void testGetContractBList_AllManagers() {
        Test.startTest();
        List<Map<String,Object>> contracts = RecruitingDirectorController.getContractBList('All Sales Managers', 'This Month');
        Test.stopTest();
        
        System.assertNotEquals(null, contracts, 'Should return contract B list');
    }
    
    @isTest
    static void testGetContractAList_AllManagers() {
        Test.startTest();
        List<Map<String,Object>> contracts = RecruitingDirectorController.getContractAList('All Sales Managers', 'This Month');
        Test.stopTest();
        
        System.assertNotEquals(null, contracts, 'Should return contract A list');
    }
    
    @isTest
    static void testGetHiredList_AllManagers() {
        Test.startTest();
        List<Map<String,Object>> hired = RecruitingDirectorController.getHiredList('All Sales Managers', 'This Month');
        Test.stopTest();
        
        System.assertNotEquals(null, hired, 'Should return hired list');
    }
    
    @isTest
    static void testGetCompletedInterviewsList_AllManagers() {
        Test.startTest();
        List<Map<String,Object>> interviews = RecruitingDirectorController.getCompletedInterviewsList('All Sales Managers', 'This Month');
        Test.stopTest();
        
        System.assertNotEquals(null, interviews, 'Should return completed interviews list');
    }
    
    @isTest
    static void testDateRangeFilters() {
        Test.startTest();
        Map<String,Object> monthMetrics = RecruitingDirectorController.getGlobalMetrics('This Month');
        Map<String,Object> quarterMetrics = RecruitingDirectorController.getGlobalMetrics('This Quarter');
        Map<String,Object> yearMetrics = RecruitingDirectorController.getGlobalMetrics('This Year');
        Test.stopTest();
        
        System.assertNotEquals(null, monthMetrics.get('totalCandidates'), 'Month metrics should return data');
        System.assertNotEquals(null, quarterMetrics.get('totalCandidates'), 'Quarter metrics should return data');
        System.assertNotEquals(null, yearMetrics.get('totalCandidates'), 'Year metrics should return data');
    }
    
    @isTest
    static void testExportToCsv_AllManagers() {
        Test.startTest();
        String csv = RecruitingDirectorController.exportToCsv(
            RecruitingDirectorController.getCandidatesList('All Sales Managers', 'This Month'),
            'totalCandidates'
        );
        Test.stopTest();
        
        System.assert(csv.contains('Name,Sales Manager,Status'), 'CSV should contain headers');
    }
}
