/**
 * @description Test class for TestDataFactory
 * Tests the test data generation and cleanup methods
 * @author RecruiterPortal Team
 * @date 2026-01-07
 */
@isTest
private class TestDataFactoryTest {
    
    /**
     * @description Test the complete data generation flow
     * Verifies that all objects are created with proper relationships
     */
    @isTest
    static void testGenerateCompleteTestData() {
        Test.startTest();
        
        // Execute the main data generation method
        TestDataFactory.generateCompleteTestData();
        
        Test.stopTest();
        
        // Verify capstone account was created
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'capstone'];
        System.assertEquals(1, accounts.size(), 'Should have created capstone account');
        
        // Verify Contacts were created
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Email LIKE '%testfactory%'];
        System.assertEquals(500, contacts.size(), 'Should have created 500 Contacts');
        
        // Verify Candidates were created and linked to Contacts
        List<Candidate__c> candidates = [SELECT Id, Contact__c FROM Candidate__c];
        System.assertEquals(500, candidates.size(), 'Should have created 500 Candidates');
        System.assertNotEquals(null, candidates[0].Contact__c, 'Candidate should be linked to Contact');
    }
    
    /**
     * @description Test the sandbox-safe data generation with automation bypass
     * Verifies that data is created even with potential flow failures
     */
    @isTest
    static void testGenerateSandboxSafeTestData() {
        Test.startTest();
        
        // Execute the sandbox-safe data generation method
        TestDataFactory.generateSandboxSafeTestData();
        
        Test.stopTest();
        
        // Verify capstone account was created
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'capstone'];
        System.assertEquals(1, accounts.size(), 'Should have created capstone account');
        
        // Verify Contacts were created
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Email LIKE '%testfactory%'];
        System.assertEquals(500, contacts.size(), 'Should have created 500 Contacts');
        
        // Verify Candidates were created (allowing for partial success)
        List<Candidate__c> candidates = [SELECT Id, Contact__c FROM Candidate__c];
        System.assert(candidates.size() > 0, 'Should have created at least some Candidates');
        System.assert(candidates.size() <= 500, 'Should not exceed 500 Candidates');
        if (!candidates.isEmpty()) {
            System.assertNotEquals(null, candidates[0].Contact__c, 'Candidate should be linked to Contact');
        }
        
        // Verify Interviews were created with proper distribution
        List<Interview__c> interviews = [SELECT Id, Interview_Type__c FROM Interview__c];
        System.assertEquals(800, interviews.size(), 'Should have created 800 Interviews');
        
        // Count by type
        Integer ciFirstCount = 0;
        Integer planThirdCount = 0;
        Integer presentFourthCount = 0;
        Integer optionalFifthCount = 0;
        
        for (Interview__c interview : interviews) {
            if (interview.Interview_Type__c == 'Ci-First') ciFirstCount++;
            else if (interview.Interview_Type__c == 'Plan-3rd') planThirdCount++;
            else if (interview.Interview_Type__c == 'Present-4th') presentFourthCount++;
            else if (interview.Interview_Type__c == 'Optional-5th') optionalFifthCount++;
        }
        
        System.assertEquals(500, ciFirstCount, 'Should have 500 Ci-First interviews');
        System.assertEquals(150, planThirdCount, 'Should have 150 Plan-3rd interviews');
        System.assertEquals(100, presentFourthCount, 'Should have 100 Present-4th interviews');
        System.assertEquals(50, optionalFifthCount, 'Should have 50 Optional-5th interviews');
        
        // Verify ALC records were created
        List<ALC__c> alcs = [SELECT Id, Candidate__c, Contact__c FROM ALC__c];
        System.assertEquals(300, alcs.size(), 'Should have created 300 ALC records');
        System.assertNotEquals(null, alcs[0].Candidate__c, 'ALC should be linked to Candidate');
        System.assertNotEquals(null, alcs[0].Contact__c, 'ALC should be linked to Contact');
        
        // Verify Opportunities were created
        List<Opportunity> opportunities = [SELECT Id, ContactId FROM Opportunity];
        System.assertEquals(1000, opportunities.size(), 'Should have created 1000 Opportunities');
        System.assertNotEquals(null, opportunities[0].ContactId, 'Opportunity should be linked to Contact');
    }
    
    /**
     * @description Test the data cleanup method
     * Verifies that all test data is properly deleted
     */
    @isTest
    static void testDeleteAllTestData() {
        // First generate test data
        TestDataFactory.generateCompleteTestData();
        
        // Verify data exists
        System.assertEquals(500, [SELECT COUNT() FROM Candidate__c], 'Should have 500 Candidates before cleanup');
        System.assertEquals(800, [SELECT COUNT() FROM Interview__c], 'Should have 800 Interviews before cleanup');
        System.assertEquals(300, [SELECT COUNT() FROM ALC__c], 'Should have 300 ALCs before cleanup');
        System.assertEquals(1000, [SELECT COUNT() FROM Opportunity], 'Should have 1000 Opportunities before cleanup');
        
        Test.startTest();
        
        // Execute cleanup
        TestDataFactory.deleteAllTestData();
        
        Test.stopTest();
        
        // Verify data was deleted
        System.assertEquals(0, [SELECT COUNT() FROM Candidate__c], 'Should have 0 Candidates after cleanup');
        System.assertEquals(0, [SELECT COUNT() FROM Interview__c], 'Should have 0 Interviews after cleanup');
        System.assertEquals(0, [SELECT COUNT() FROM ALC__c], 'Should have 0 ALCs after cleanup');
        System.assertEquals(0, [SELECT COUNT() FROM Opportunity], 'Should have 0 Opportunities after cleanup');
        
        // Verify capstone account still exists (not deleted)
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'capstone'];
        System.assertEquals(1, accounts.size(), 'capstone account should still exist');
    }
    
    /**
     * @description Test incremental data generation
     * Verifies that running the factory multiple times adds more data
     */
    @isTest
    static void testIncrementalDataGeneration() {
        // First run
        TestDataFactory.generateCompleteTestData();
        
        Integer firstRunCandidateCount = [SELECT COUNT() FROM Candidate__c];
        System.assertEquals(500, firstRunCandidateCount, 'First run should create 500 Candidates');
        
        Test.startTest();
        
        // Second run (should add more data with unique timestamps)
        TestDataFactory.generateCompleteTestData();
        
        Test.stopTest();
        
        // Verify incremental data was added
        Integer secondRunCandidateCount = [SELECT COUNT() FROM Candidate__c];
        System.assertEquals(1000, secondRunCandidateCount, 'Second run should add 500 more Candidates (total 1000)');
        
        // Verify all emails are unique (no duplicates)
        Set<String> emails = new Set<String>();
        for (Contact c : [SELECT Email FROM Contact WHERE Email LIKE '%testfactory%']) {
            System.assert(!emails.contains(c.Email), 'Email should be unique: ' + c.Email);
            emails.add(c.Email);
        }
    }
    
    /**
     * @description Test that realistic field values are populated
     * Verifies data quality and variety
     */
    @isTest
    static void testRealisticFieldValues() {
        Test.startTest();
        
        TestDataFactory.generateCompleteTestData();
        
        Test.stopTest();
        
        // Check Candidate field values
        List<Candidate__c> candidates = [SELECT Status__c, Sales_Manager__c, Contract_Type__c 
                                         FROM Candidate__c 
                                         LIMIT 10];
        System.assertNotEquals(null, candidates[0].Status__c, 'Status should be populated');
        System.assertNotEquals(null, candidates[0].Sales_Manager__c, 'Sales Manager should be populated');
        
        // Check Interview field values
        List<Interview__c> interviews = [SELECT Interview_Status__c, Date_Time_Scheduled__c 
                                         FROM Interview__c 
                                         LIMIT 10];
        System.assertNotEquals(null, interviews[0].Interview_Status__c, 'Interview Status should be populated');
        System.assertNotEquals(null, interviews[0].Date_Time_Scheduled__c, 'Date Time Scheduled should be populated');
        
        // Check ALC field values
        List<ALC__c> alcs = [SELECT Stage__c, Contract_Type__c, Life_Insurance_Licensed__c 
                             FROM ALC__c 
                             LIMIT 10];
        System.assertNotEquals(null, alcs[0].Stage__c, 'ALC Stage should be populated');
        System.assertNotEquals(null, alcs[0].Contract_Type__c, 'Contract Type should be populated');
        System.assertNotEquals(null, alcs[0].Life_Insurance_Licensed__c, 'Life Insurance Licensed should be populated');
        
        // Check Opportunity field values
        List<Opportunity> opportunities = [SELECT FYC__c, StageName, Reported_Date__c 
                                           FROM Opportunity 
                                           LIMIT 10];
        System.assertNotEquals(null, opportunities[0].FYC__c, 'FYC should be populated');
        System.assertNotEquals(null, opportunities[0].StageName, 'Stage Name should be populated');
        System.assert(opportunities[0].FYC__c >= 500, 'FYC should be at least $500');
    }
    
    /**
     * @description Test relationship integrity
     * Verifies that all relationships are properly established
     */
    @isTest
    static void testRelationshipIntegrity() {
        Test.startTest();
        
        TestDataFactory.generateCompleteTestData();
        
        Test.stopTest();
        
        // Test Candidate → Contact relationship
        List<Candidate__c> candidatesWithContact = [SELECT Id, Contact__c, Contact__r.Email 
                                                     FROM Candidate__c 
                                                     LIMIT 1];
        System.assertNotEquals(null, candidatesWithContact[0].Contact__c, 'Candidate should have Contact');
        System.assert(candidatesWithContact[0].Contact__r.Email.contains('testfactory'), 
                     'Contact email should be test factory email');
        
        // Test Interview → Candidate relationship
        List<Interview__c> interviewsWithCandidate = [SELECT Id, Candidate__c, Candidate__r.Last_Name__c 
                                                       FROM Interview__c 
                                                       LIMIT 1];
        System.assertNotEquals(null, interviewsWithCandidate[0].Candidate__c, 'Interview should have Candidate');
        System.assertNotEquals(null, interviewsWithCandidate[0].Candidate__r.Last_Name__c, 
                              'Candidate should have Last Name');
        
        // Test ALC → Candidate and Contact relationships
        List<ALC__c> alcsWithRelationships = [SELECT Id, Candidate__c, Contact__c, 
                                              Candidate__r.Email__c, Contact__r.Email 
                                              FROM ALC__c 
                                              LIMIT 1];
        System.assertNotEquals(null, alcsWithRelationships[0].Candidate__c, 'ALC should have Candidate');
        System.assertNotEquals(null, alcsWithRelationships[0].Contact__c, 'ALC should have Contact');
        
        // Test Opportunity → Contact relationship (for FYC rollup)
        List<Opportunity> oppsWithContact = [SELECT Id, ContactId 
                                             FROM Opportunity 
                                             LIMIT 1];
        System.assertNotEquals(null, oppsWithContact[0].ContactId, 'Opportunity should have Contact');
        
        // Verify the Contact exists
        Id contactId = oppsWithContact[0].ContactId;
        Contact oppContact = [SELECT Email FROM Contact WHERE Id = :contactId LIMIT 1];
        System.assert(oppContact.Email.contains('testfactory'), 
                     'Opportunity Contact should be test factory contact');
    }
}
