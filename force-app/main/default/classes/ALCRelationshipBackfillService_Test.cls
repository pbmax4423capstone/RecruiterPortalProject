/**
 * Test class for ALCRelationshipBackfillService
 * Tests Levenshtein algorithm, phone standardization, fuzzy matching, and backfill logic
 * 
 * @group ALC Automation
 * @date 2026-01-08
 */
@isTest
private class ALCRelationshipBackfillService_Test {
    
    @TestSetup
    static void makeData() {
        // Create Record Types for ALC
        // Note: In production these already exist, so we query them
        
        // Create test Contacts
        List<Contact> testContacts = new List<Contact>{
            new Contact(FirstName = 'John', LastName = 'Smith', Email = 'john.smith@example.com', MobilePhone = '555-123-4567'),
            new Contact(FirstName = 'Jane', LastName = 'Doe', Personal_Email__c = 'jane.doe@personal.com', MobilePhone = '(555) 234-5678'),
            new Contact(FirstName = 'Bob', LastName = 'Johnson', Email = 'bob.j@work.com', MobilePhone = '15552345678')
        };
        insert testContacts;
        
        // Create test Candidates
        List<Candidate__c> testCandidates = new List<Candidate__c>{
            new Candidate__c(First_Name__c = 'Sarah', Last_Name__c = 'Williams', personal_email__c = 'sarah.w@example.com', Phone__c = '555-345-6789', Contact__c = testContacts[0].Id)
        };
        insert testCandidates;
    }
    
    @isTest
    static void testCalculateLevenshteinDistance_SameStrings() {
        // Test identical strings
        Integer distance = ALCRelationshipBackfillService.calculateLevenshteinDistance('hello', 'hello');
        System.assertEquals(0, distance, 'Distance should be 0 for identical strings');
    }
    
    @isTest
    static void testCalculateLevenshteinDistance_DifferentStrings() {
        // Test different strings
        Integer distance = ALCRelationshipBackfillService.calculateLevenshteinDistance('kitten', 'sitting');
        System.assertEquals(3, distance, 'Distance should be 3 for kitten/sitting');
    }
    
    @isTest
    static void testCalculateLevenshteinDistance_EmptyStrings() {
        // Test empty/null strings
        Integer distance1 = ALCRelationshipBackfillService.calculateLevenshteinDistance('', 'test');
        System.assertEquals(4, distance1, 'Distance should be 4 for empty to test');
        
        Integer distance2 = ALCRelationshipBackfillService.calculateLevenshteinDistance('test', '');
        System.assertEquals(4, distance2, 'Distance should be 4 for test to empty');
        
        Integer distance3 = ALCRelationshipBackfillService.calculateLevenshteinDistance('', '');
        System.assertEquals(0, distance3, 'Distance should be 0 for two empty strings');
    }
    
    @isTest
    static void testCalculateNameSimilarity_HighMatch() {
        // Test high similarity
        Decimal similarity = ALCRelationshipBackfillService.calculateNameSimilarity('John Smith', 'John Smyth');
        System.assert(similarity >= 80, 'Similarity should be >= 80% for John Smith/Smyth');
    }
    
    @isTest
    static void testCalculateNameSimilarity_LowMatch() {
        // Test low similarity
        Decimal similarity = ALCRelationshipBackfillService.calculateNameSimilarity('John Smith', 'Jane Doe');
        System.assert(similarity < 60, 'Similarity should be < 60% for John Smith/Jane Doe');
    }
    
    @isTest
    static void testStandardizePhone_USFormat() {
        // Test various US phone formats
        String std1 = ALCRelationshipBackfillService.standardizePhone('555-123-4567');
        System.assertEquals('5551234567', std1, 'Should standardize dashed format');
        
        String std2 = ALCRelationshipBackfillService.standardizePhone('(555) 123-4567');
        System.assertEquals('5551234567', std2, 'Should standardize parentheses format');
        
        String std3 = ALCRelationshipBackfillService.standardizePhone('1-555-123-4567');
        System.assertEquals('5551234567', std3, 'Should remove country code 1');
        
        String std4 = ALCRelationshipBackfillService.standardizePhone('15551234567');
        System.assertEquals('5551234567', std4, 'Should remove leading 1');
    }
    
    @isTest
    static void testStandardizePhone_InvalidFormats() {
        // Test invalid formats
        String std1 = ALCRelationshipBackfillService.standardizePhone('123');
        System.assertEquals(null, std1, 'Should return null for too short');
        
        String std2 = ALCRelationshipBackfillService.standardizePhone('');
        System.assertEquals(null, std2, 'Should return null for empty');
        
        String std3 = ALCRelationshipBackfillService.standardizePhone(null);
        System.assertEquals(null, std3, 'Should return null for null input');
    }
    
    @isTest
    static void testFindUnlinkedALCs() {
        // Get Career record type
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        
        if (careerRTId == null) {
            // Skip test if record type doesn't exist
            return;
        }
        
        // Create ALC without Contact
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Personal_Email_Address__c = 'test.user@example.com',
            Mobile__c = '555-999-8888',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        Test.startTest();
        List<ALC__c> unlinked = ALCRelationshipBackfillService.findUnlinkedALCs();
        Test.stopTest();
        
        System.assert(unlinked.size() > 0, 'Should find at least one unlinked ALC');
        System.assertEquals(null, unlinked[0].Contact__c, 'ALC should have no Contact');
    }
    
    @isTest
    static void testFindMatchingContacts_EmailMatch() {
        // Get Career record type
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        
        if (careerRTId == null) {
            return;
        }
        
        // Create ALC with email matching existing Contact
        ALC__c testALC = new ALC__c(
            First_Name__c = 'John',
            Last_Name__c = 'Smith',
            Personal_Email_Address__c = 'john.smith@example.com',
            Mobile__c = '555-123-4567',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        // Query to get populated RecordType
        testALC = [SELECT Id, First_Name__c, Last_Name__c, Personal_Email_Address__c, Mobile__c, RecordType.DeveloperName 
                   FROM ALC__c WHERE Id = :testALC.Id];
        
        Test.startTest();
        List<ALCRelationshipBackfillService.ContactMatchResult> matches = 
            ALCRelationshipBackfillService.findMatchingContacts(testALC);
        Test.stopTest();
        
        System.assert(matches.size() > 0, 'Should find at least one match');
        System.assertEquals('Email Match', matches[0].matchType, 'Should be email match');
        System.assertEquals(100, matches[0].similarityScore, 'Email match should be 100%');
    }
    
    @isTest
    static void testFindMatchingContacts_PhoneMatch() {
        // Get Broker record type
        Id brokerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Broker')?.getRecordTypeId();
        
        if (brokerRTId == null) {
            return;
        }
        
        // Create ALC with phone matching existing Contact (different format)
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Jane',
            Last_Name__c = 'Doe',
            Personal_Email_Address__c = 'nomatch1@test.com', // Ensure no email match
            Mobile__c = '5552345678', // Same as Jane's but different format
            RecordTypeId = brokerRTId
        );
        insert testALC;
        
        testALC = [SELECT Id, First_Name__c, Last_Name__c, Personal_Email_Address__c, Mobile__c, RecordType.DeveloperName 
                   FROM ALC__c WHERE Id = :testALC.Id];
        
        Test.startTest();
        List<ALCRelationshipBackfillService.ContactMatchResult> matches = 
            ALCRelationshipBackfillService.findMatchingContacts(testALC);
        Test.stopTest();
        
        System.assert(matches.size() > 0, 'Should find at least one match');
        System.assertEquals('Phone Match', matches[0].matchType, 'Should be phone match');
        System.assertEquals(95, matches[0].similarityScore, 'Phone match should be 95%');
    }
    
    @isTest
    static void testFindMatchingContacts_NameMatch() {
        // Get NRF record type
        Id nrfRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('NRF')?.getRecordTypeId();
        
        if (nrfRTId == null) {
            return;
        }
        
        // Create ALC with similar name but different email/phone
        ALC__c testALC = new ALC__c(
            First_Name__c = 'John',
            Last_Name__c = 'Smyth', // Misspelling
            Personal_Email_Address__c = 'nomatch2@test.com', // Ensure no email match
            Mobile__c = '555-999-7777',
            RecordTypeId = nrfRTId
        );
        insert testALC;
        
        testALC = [SELECT Id, First_Name__c, Last_Name__c, Personal_Email_Address__c, Mobile__c, RecordType.DeveloperName 
                   FROM ALC__c WHERE Id = :testALC.Id];
        
        Test.startTest();
        List<ALCRelationshipBackfillService.ContactMatchResult> matches = 
            ALCRelationshipBackfillService.findMatchingContacts(testALC);
        Test.stopTest();
        
        System.assert(matches.size() > 0, 'Should find at least one match');
        System.assertEquals('Name Match', matches[0].matchType, 'Should be name match');
        System.assert(matches[0].similarityScore >= 80, 'Name match should be >= 80%');
    }
    
    @isTest
    static void testProcessBackfillDecisions_CreateNewContact() {
        // Get Career record type
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        
        if (careerRTId == null) {
            return;
        }
        
        // Create ALC without Contact
        ALC__c testALC = new ALC__c(
            First_Name__c = 'New',
            Last_Name__c = 'Person',
            Personal_Email_Address__c = 'new.person@example.com',
            Mobile__c = '555-777-9999',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        // Manually unlink Contact (trigger auto-creates it)
        testALC.Contact__c = null;
        testALC.Candidate__c = null;
        update testALC;
        
        // Create decision to create new Contact
        ALCRelationshipBackfillService.BackfillDecision decision = new ALCRelationshipBackfillService.BackfillDecision();
        decision.alcId = testALC.Id;
        decision.createNewContact = true;
        
        Test.startTest();
        ALCRelationshipBackfillService.BackfillResult result = 
            ALCRelationshipBackfillService.processBackfillDecisions(new List<ALCRelationshipBackfillService.BackfillDecision>{decision});
        Test.stopTest();
        
        System.assertEquals(1, result.contactsCreated, 'Should create 1 Contact');
        System.assertEquals(1, result.candidatesCreated, 'Should create 1 Candidate for Career type');
        System.assertEquals(1, result.alcsUpdated, 'Should update 1 ALC');
        System.assert(result.errors.isEmpty(), 'Should have no errors');
        
        // Verify ALC has Contact and Candidate
        ALC__c updatedALC = [SELECT Contact__c, Candidate__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertNotEquals(null, updatedALC.Contact__c, 'ALC should have Contact');
        System.assertNotEquals(null, updatedALC.Candidate__c, 'Career ALC should have Candidate');
    }
    
    @isTest
    static void testProcessBackfillDecisions_UseExistingContact() {
        // Get Broker record type (non-Career)
        Id brokerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Broker')?.getRecordTypeId();
        
        if (brokerRTId == null) {
            return;
        }
        
        // Get existing Contact
        Contact existingContact = [SELECT Id FROM Contact LIMIT 1];
        
        // Create ALC without Contact
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Match',
            Personal_Email_Address__c = 'existing@example.com',
            Mobile__c = '555-888-9999',
            RecordTypeId = brokerRTId
        );
        insert testALC;
        
        // Create decision to use existing Contact
        ALCRelationshipBackfillService.BackfillDecision decision = new ALCRelationshipBackfillService.BackfillDecision();
        decision.alcId = testALC.Id;
        decision.selectedContactId = existingContact.Id;
        decision.createNewContact = false;
        
        Test.startTest();
        ALCRelationshipBackfillService.BackfillResult result = 
            ALCRelationshipBackfillService.processBackfillDecisions(new List<ALCRelationshipBackfillService.BackfillDecision>{decision});
        Test.stopTest();
        
        System.assertEquals(0, result.contactsCreated, 'Should not create new Contact');
        System.assertEquals(0, result.candidatesCreated, 'Should not create Candidate for Broker type');
        System.assertEquals(1, result.alcsUpdated, 'Should update 1 ALC');
        
        // Verify ALC has Contact
        ALC__c updatedALC = [SELECT Contact__c, Candidate__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertEquals(existingContact.Id, updatedALC.Contact__c, 'ALC should have selected Contact');
        System.assertEquals(null, updatedALC.Candidate__c, 'Broker ALC should not have Candidate');
    }
}
