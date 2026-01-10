@isTest
private class UnifiedDashboardController_Test {
    
    @testSetup
    static void setupTestData() {
        // Query valid Sales_Manager__c picklist values dynamically
        Schema.DescribeFieldResult fieldResult = Candidate__c.Sales_Manager__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        
        String validSalesManager = null;
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.isActive()) {
                validSalesManager = entry.getValue();
                break;
            }
        }
        
        // Create Candidate records with valid Sales Manager and eligible Status
        List<Candidate__c> candidates = new List<Candidate__c>();
        for (Integer i = 0; i < 5; i++) {
            candidates.add(new Candidate__c(
                First_Name__c = 'Test',
                Last_Name__c = 'Candidate' + i,
                Sales_Manager__c = validSalesManager,
                Status__c = 'New' // Not in excluded status list
            ));
        }
        insert candidates;
        
        // Query Career RecordType for ALC__c
        Id careerRecordTypeId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName()
            .get('Career').getRecordTypeId();
        
        // Create ALC records with Career RecordType and Agency A157
        List<ALC__c> alcRecords = new List<ALC__c>();
        for (Integer i = 0; i < 3; i++) {
            alcRecords.add(new ALC__c(
                Sales_Manager__c = validSalesManager,
                RecordTypeId = careerRecordTypeId,
                Agency__c = 'A157'
            ));
        }
        insert alcRecords;
    }
    
    @isTest
    static void testCanViewAllCandidates_Director() {
        User testUser = createTestUser('Recruiting Director');
        
        System.runAs(testUser) {
            Test.startTest();
            Boolean result = UnifiedDashboardController.canViewAllCandidates();
            Test.stopTest();
            
            System.assertEquals(true, result, 'Director should be able to view all candidates');
        }
    }
    
    @isTest
    static void testCanViewAllCandidates_Admin() {
        User testUser = createTestUser('System Administrator');
        
        System.runAs(testUser) {
            Test.startTest();
            Boolean result = UnifiedDashboardController.canViewAllCandidates();
            Test.stopTest();
            
            System.assertEquals(true, result, 'Admin should be able to view all candidates');
        }
    }
    
    @isTest
    static void testCanViewAllCandidates_StandardUser() {
        User testUser = createTestUser('Standard User');
        
        System.runAs(testUser) {
            Test.startTest();
            Boolean result = UnifiedDashboardController.canViewAllCandidates();
            Test.stopTest();
            
            System.assertEquals(false, result, 'Standard user should not be able to view all candidates');
        }
    }
    
    @isTest
    static void testGetCurrentUserName() {
        User testUser = createTestUser('Standard User');
        
        System.runAs(testUser) {
            Test.startTest();
            String userName = UnifiedDashboardController.getCurrentUserName();
            Test.stopTest();
            
            System.assertNotEquals(null, userName, 'User name should not be null');
            System.assertEquals(testUser.FirstName + ' ' + testUser.LastName, userName);
        }
    }
    
    @isTest
    static void testGetSalesManagerOptions_WithData() {
        Test.startTest();
        List<String> options = UnifiedDashboardController.getSalesManagerOptions();
        Test.stopTest();
        
        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() > 1, 'Should have at least one sales manager plus "All Sales Managers"');
        System.assertEquals('All Sales Managers', options[0], 'First option should be "All Sales Managers"');
    }
    
    @isTest
    static void testGetSalesManagerOptions_NoData() {
        // Delete all test data to test empty result scenario
        delete [SELECT Id FROM Candidate__c];
        delete [SELECT Id FROM ALC__c];
        
        Test.startTest();
        List<String> options = UnifiedDashboardController.getSalesManagerOptions();
        Test.stopTest();
        
        System.assertEquals(1, options.size(), 'Should only have "All Sales Managers" option');
        System.assertEquals('All Sales Managers', options[0]);
    }
    
    @isTest
    static void testGetSalesManagerOptions_CandidatesOnly() {
        // Delete ALC records to test Candidate query only
        delete [SELECT Id FROM ALC__c];
        
        Test.startTest();
        List<String> options = UnifiedDashboardController.getSalesManagerOptions();
        Test.stopTest();
        
        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() >= 1, 'Should have at least "All Sales Managers"');
    }
    
    @isTest
    static void testGetSalesManagerOptions_ALCOnly() {
        // Delete Candidate records to test ALC query only
        delete [SELECT Id FROM Candidate__c];
        
        Test.startTest();
        List<String> options = UnifiedDashboardController.getSalesManagerOptions();
        Test.stopTest();
        
        System.assertNotEquals(null, options, 'Options should not be null');
        System.assert(options.size() >= 1, 'Should have at least "All Sales Managers"');
    }
    
    @isTest
    static void testGetDashboardConfig_Director() {
        User testUser = createTestUser('Recruiting Director');
        
        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> config = UnifiedDashboardController.getDashboardConfig();
            Test.stopTest();
            
            System.assertNotEquals(null, config, 'Config should not be null');
            System.assertEquals(testUser.FirstName + ' ' + testUser.LastName, config.get('userName'));
            System.assertEquals(true, config.get('isDirector'));
            System.assertEquals(true, config.get('showRecruitingMetrics'));
        }
    }
    
    @isTest
    static void testGetDashboardConfig_RachyllTenny() {
        User testUser = createTestUser('Standard User');
        testUser.FirstName = 'Rachyll';
        testUser.LastName = 'Tenny';
        update testUser;
        
        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> config = UnifiedDashboardController.getDashboardConfig();
            Test.stopTest();
            
            System.assertNotEquals(null, config, 'Config should not be null');
            System.assertEquals('Rachyll Tenny', config.get('userName'));
            System.assertEquals(true, config.get('isRachyllTenny'));
            System.assertEquals(true, config.get('showRecruitingMetrics'));
        }
    }
    
    @isTest
    static void testGetDashboardConfig_StandardUser() {
        User testUser = createTestUser('Standard User');
        
        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> config = UnifiedDashboardController.getDashboardConfig();
            Test.stopTest();
            
            System.assertNotEquals(null, config, 'Config should not be null');
            System.assertEquals(false, config.get('isDirector'));
            System.assertEquals(false, config.get('isRachyllTenny'));
            System.assertEquals(false, config.get('showRecruitingMetrics'));
        }
    }
    
    @isTest
    static void testCanViewAllCandidates_ExceptionHandling() {
        // Test runs as running user to ensure method handles current context
        Test.startTest();
        Boolean result = UnifiedDashboardController.canViewAllCandidates();
        Test.stopTest();
        
        // Should return a boolean value (true or false) without throwing exception
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    // Helper method to create test users with different profiles
    private static User createTestUser(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        
        String uniqueUsername = 'testuser' + DateTime.now().getTime() + '@test.com';
        User u = new User(
            Alias = 'tstu',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Test',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUsername
        );
        insert u;
        
        return u;
    }
}
