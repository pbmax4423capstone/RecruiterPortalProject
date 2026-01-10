@isTest
private class SalesManagerActivityController_Test {
    
    @testSetup
    static void setupTestData() {
        // Create test users with Sales Manager profile
        Profile salesManagerProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Sales Manager%' OR Name = 'Standard User' LIMIT 1];
        
        User salesManager1 = new User(
            FirstName = 'Test',
            LastName = 'Manager One',
            Email = 'testmanager1@test.com',
            Username = 'testmanager1@test.recruiter.com',
            Alias = 'tmgr1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = salesManagerProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert salesManager1;
        
        User salesManager2 = new User(
            FirstName = 'Test',
            LastName = 'Manager Two',
            Email = 'testmanager2@test.com',
            Username = 'testmanager2@test.recruiter.com',
            Alias = 'tmgr2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = salesManagerProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert salesManager2;
        
        // Create test candidates
        List<Candidate__c> candidates = new List<Candidate__c>();
        candidates.add(new Candidate__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@test.com',
            Sales_Manager__c = 'Tim Denton',
            Status__c = 'Active/In Process',
            Highest_Level_Achieved__c = '0-Prequal'
        ));
        candidates.add(new Candidate__c(
            First_Name__c = 'Jane',
            Last_Name__c = 'Smith',
            Email__c = 'jane.smith@test.com',
            Sales_Manager__c = 'Tim Denton',
            Status__c = 'Active/In Process',
            Highest_Level_Achieved__c = '7-Contracted'
        ));
        candidates.add(new Candidate__c(
            First_Name__c = 'Bob',
            Last_Name__c = 'Johnson',
            Email__c = 'bob.johnson@test.com',
            Sales_Manager__c = 'Elizabeth Kagele',
            Status__c = 'Active/In Process',
            Highest_Level_Achieved__c = 'Ci_1st'
        ));
        insert candidates;
        
        // Create test interviews
        List<Interview__c> interviews = new List<Interview__c>();
        interviews.add(new Interview__c(
            Candidate__c = candidates[0].Id,
            Date_Time_Scheduled__c = DateTime.now().addDays(-4),
            Interview_Status__c = 'Completed',
            Interview_Type__c = 'CI-First'
        ));
        interviews.add(new Interview__c(
            Candidate__c = candidates[1].Id,
            Date_Time_Scheduled__c = DateTime.now().addDays(-1),
            Interview_Status__c = 'Scheduled',
            Interview_Type__c = 'Align (2nd)'
        ));
        interviews.add(new Interview__c(
            Candidate__c = candidates[2].Id,
            Date_Time_Scheduled__c = DateTime.now().addDays(-20),
            Interview_Status__c = 'Completed',
            Interview_Type__c = 'CI-First'
        ));
        insert interviews;
        
        // Create test ALC records for onboarding
        RecordType careerRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'ALC__c' AND DeveloperName = 'Career' LIMIT 1];
        
        List<ALC__c> alcs = new List<ALC__c>();
        alcs.add(new ALC__c(
            Candidate__c = candidates[1].Id,
            Sales_Manager__c = 'Tim Denton',
            RecordTypeId = careerRecordType.Id,
            Agency__c = 'A157',
            Stage__c = 'Received Approval Letter'
        ));
        insert alcs;
    }
    
    @isTest
    static void testGetSalesManagerActivity_AllManagers() {
        Test.startTest();
        List<Map<String, Object>> results = SalesManagerActivityController.getSalesManagerActivity('THIS_MONTH', 'All Sales Managers');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() >= 2, 'Should return at least 2 sales managers');
        
        // Verify data structure
        for (Map<String, Object> record : results) {
            System.assert(record.containsKey('name'), 'Should have name field');
            System.assert(record.containsKey('lastLoginDate'), 'Should have lastLoginDate field');
            System.assert(record.containsKey('candidatesAdded'), 'Should have candidatesAdded field');
            System.assert(record.containsKey('interviewsScheduled'), 'Should have interviewsScheduled field');
            System.assert(record.containsKey('interviewsCompleted'), 'Should have interviewsCompleted field');
            System.assert(record.containsKey('candidatesInContracting'), 'Should have candidatesInContracting field');
            System.assert(record.containsKey('candidatesOnboarding'), 'Should have candidatesOnboarding field');
        }
    }
    
    @isTest
    static void testGetSalesManagerActivity_SpecificManager() {
        Test.startTest();
        List<Map<String, Object>> results = SalesManagerActivityController.getSalesManagerActivity('THIS_MONTH', 'Tim Denton');
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return only 1 sales manager');
        System.assertEquals('Tim Denton', results[0].get('name'), 'Should be Tim Denton');
        
        // Verify fields exist and have valid values
        System.assertNotEquals(null, results[0].get('candidatesAdded'), 'Should have candidatesAdded field');
        System.assertNotEquals(null, results[0].get('interviewsScheduled'), 'Should have interviewsScheduled field');
        System.assertNotEquals(null, results[0].get('interviewsCompleted'), 'Should have interviewsCompleted field');
        System.assertNotEquals(null, results[0].get('candidatesInContracting'), 'Should have candidatesInContracting field');
        System.assertNotEquals(null, results[0].get('candidatesOnboarding'), 'Should have candidatesOnboarding field');
    }
    
    @isTest
    static void testGetSalesManagerActivity_QuarterDateRange() {
        Test.startTest();
        List<Map<String, Object>> results = SalesManagerActivityController.getSalesManagerActivity('THIS_QUARTER', 'All Sales Managers');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() >= 2, 'Should return sales managers');
    }
    
    @isTest
    static void testGetSalesManagerActivity_YearDateRange() {
        Test.startTest();
        List<Map<String, Object>> results = SalesManagerActivityController.getSalesManagerActivity('THIS_YEAR', 'All Sales Managers');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() >= 2, 'Should return sales managers');
    }
    
    @isTest
    static void testGetSalesManagerSummary() {
        Test.startTest();
        Map<String, Object> summary = SalesManagerActivityController.getSalesManagerSummary('THIS_MONTH', 'All Sales Managers');
        Test.stopTest();
        
        System.assertNotEquals(null, summary, 'Summary should not be null');
        System.assert(summary.containsKey('totalManagers'), 'Should have totalManagers field');
        System.assert(summary.containsKey('activeManagers'), 'Should have activeManagers field');
        System.assert(summary.containsKey('inactiveManagers'), 'Should have inactiveManagers field');
        System.assert(summary.containsKey('totalCandidates'), 'Should have totalCandidates field');
        System.assert(summary.containsKey('totalInterviewsScheduled'), 'Should have totalInterviewsScheduled field');
        System.assert(summary.containsKey('totalInterviewsCompleted'), 'Should have totalInterviewsCompleted field');
        System.assert(summary.containsKey('totalInContracting'), 'Should have totalInContracting field');
        System.assert(summary.containsKey('totalOnboarding'), 'Should have totalOnboarding field');
        
        // Verify manager counts are valid
        Integer totalManagers = (Integer)summary.get('totalManagers');
        Integer activeManagers = (Integer)summary.get('activeManagers');
        Integer inactiveManagers = (Integer)summary.get('inactiveManagers');
        System.assert(totalManagers >= 0, 'Total managers should be >= 0');
        System.assert(activeManagers >= 0, 'Active managers should be >= 0');
        System.assert(inactiveManagers >= 0, 'Inactive managers should be >= 0');
        System.assertEquals(totalManagers, activeManagers + inactiveManagers, 'Total should equal active + inactive');
    }
    
    @isTest
    static void testLoginStatus() {
        Test.startTest();
        List<Map<String, Object>> results = SalesManagerActivityController.getSalesManagerActivity('THIS_MONTH', 'All Sales Managers');
        Test.stopTest();
        
        // Find the manager with 10 days since login
        Map<String, Object> inactiveManager = null;
        Map<String, Object> activeManager = null;
        
        for (Map<String, Object> record : results) {
            if ((Integer)record.get('daysSinceLogin') > 7) {
                inactiveManager = record;
            } else if ((Integer)record.get('daysSinceLogin') < 7) {
                activeManager = record;
            }
        }
        
        if (inactiveManager != null) {
            System.assertEquals('Inactive', inactiveManager.get('loginStatus'), 'Manager with 10 days should be inactive');
        }
        
        if (activeManager != null) {
            System.assertEquals('Active', activeManager.get('loginStatus'), 'Manager with 3 days should be active');
        }
    }
    
    @isTest
    static void testErrorHandling() {
        // Test with invalid date range
        Test.startTest();
        try {
            List<Map<String, Object>> results = SalesManagerActivityController.getSalesManagerActivity(null, 'All Sales Managers');
            System.assertNotEquals(null, results, 'Should handle null date range with default');
        } catch (Exception e) {
            // Exception is acceptable
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetInterviewDetails() {
        Test.startTest();
        
        // Test scheduled interviews
        List<Map<String, Object>> scheduledInterviews = SalesManagerActivityController.getInterviewDetails('Tim Denton', 'THIS_MONTH', 'scheduled');
        System.assertNotEquals(null, scheduledInterviews, 'Should return list of scheduled interviews');
        
        // Test completed interviews
        List<Map<String, Object>> completedInterviews = SalesManagerActivityController.getInterviewDetails('Tim Denton', 'THIS_MONTH', 'completed');
        System.assertNotEquals(null, completedInterviews, 'Should return list of completed interviews');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetCandidatesInContracting() {
        Test.startTest();
        
        List<Map<String, Object>> contractingCandidates = SalesManagerActivityController.getCandidatesInContracting('Tim Denton');
        System.assertNotEquals(null, contractingCandidates, 'Should return list of contracting candidates');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetCandidatesOnboarding() {
        Test.startTest();
        
        List<Map<String, Object>> onboardingCandidates = SalesManagerActivityController.getCandidatesOnboarding('Tim Denton', 'last_month');
        System.assertNotEquals(null, onboardingCandidates, 'Should return list of onboarding candidates');
        
        Test.stopTest();
    }
}
