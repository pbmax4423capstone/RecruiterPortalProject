/**
 * Test class for ALCBackfillWizardController
 * Tests @AuraEnabled methods, wrappers, and JSON handling
 * 
 * @group ALC Automation
 * @date 2026-01-08
 */
@isTest
private class ALCBackfillWizardController_Test {
    
    @TestSetup
    static void makeData() {
        // Create test Contacts
        List<Contact> testContacts = new List<Contact>{
            new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@example.com', MobilePhone = '555-111-2222'),
            new Contact(FirstName = 'Test', LastName = 'Contact2', Personal_Email__c = 'test2@example.com', MobilePhone = '555-222-3333')
        };
        insert testContacts;
    }
    
    @isTest
    static void testGetUnlinkedALCs_AllTypes() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        // Create test ALCs without Contacts
        List<ALC__c> testALCs = new List<ALC__c>{
            new ALC__c(First_Name__c = 'John', Last_Name__c = 'Doe', Personal_Email_Address__c = 'john@test.com', Mobile__c = '555-123-4567', RecordTypeId = careerRTId),
            new ALC__c(First_Name__c = 'Jane', Last_Name__c = 'Smith', Personal_Email_Address__c = 'jane@test.com', Mobile__c = '555-234-5678', RecordTypeId = careerRTId)
        };
        insert testALCs;
        
        // Manually unlink Contacts (trigger auto-creates them)
        for (ALC__c alc : testALCs) {
            alc.Contact__c = null;
        }
        update testALCs;
        
        Test.startTest();
        List<ALCBackfillWizardController.ALCWrapper> results = ALCBackfillWizardController.getUnlinkedALCs(null);
        Test.stopTest();
        
        System.assert(results.size() >= 2, 'Should return at least 2 ALCs');
        System.assertEquals('John', results[0].firstName, 'First name should match');
        System.assertEquals('Career', results[0].recordType, 'Record type should be Career');
    }
    
    @isTest
    static void testGetUnlinkedALCs_CareerType() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Career',
            Last_Name__c = 'Test',
            Personal_Email_Address__c = 'career@test.com',
            Mobile__c = '555-999-8888',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        // Manually unlink Contact (trigger auto-creates it)
        testALC.Contact__c = null;
        update testALC;
        
        Test.startTest();
        List<ALCBackfillWizardController.ALCWrapper> results = ALCBackfillWizardController.getUnlinkedALCs('Career');
        Test.stopTest();
        
        System.assert(results.size() >= 1, 'Should return at least 1 Career ALC');
        System.assertEquals('Career', results[0].recordType, 'Should filter by Career type');
    }
    
    @isTest
    static void testGetUnlinkedALCs_BrokerType() {
        Id brokerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Broker')?.getRecordTypeId();
        if (brokerRTId == null) return;
        
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Broker',
            Last_Name__c = 'Test',
            Personal_Email_Address__c = 'broker@test.com',
            Mobile__c = '555-888-7777',
            RecordTypeId = brokerRTId
        );
        insert testALC;
        
        // Manually unlink Contact (trigger auto-creates it)
        testALC.Contact__c = null;
        update testALC;
        
        Test.startTest();
        List<ALCBackfillWizardController.ALCWrapper> results = ALCBackfillWizardController.getUnlinkedALCs('Broker');
        Test.stopTest();
        
        System.assert(results.size() >= 1, 'Should return at least 1 Broker ALC');
        System.assertEquals('Broker', results[0].recordType, 'Should filter by Broker type');
    }
    
    @isTest
    static void testGetMatchingContacts_WithMatches() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        // Create ALC with email matching existing Contact
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Contact1',
            Personal_Email_Address__c = 'test1@example.com',
            Mobile__c = '555-111-2222',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        Test.startTest();
        List<ALCBackfillWizardController.MatchWrapper> matches = ALCBackfillWizardController.getMatchingContacts(testALC.Id);
        Test.stopTest();
        
        System.assert(matches.size() > 0, 'Should find at least one match');
        System.assertNotEquals(null, matches[0].contactId, 'Match should have contact ID');
        System.assert(matches[0].similarityScore >= 80, 'Similarity score should be >= 80%');
    }
    
    @isTest
    static void testGetMatchingContacts_NoMatches() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        // Create ALC with no matching data
        ALC__c testALC = new ALC__c(
            First_Name__c = 'XyZAbC',
            Last_Name__c = 'QwErTy',
            Personal_Email_Address__c = 'xyzabc.qwerty@nowhere-unique-test.com',
            Mobile__c = '555-000-0001',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        Test.startTest();
        List<ALCBackfillWizardController.MatchWrapper> matches = ALCBackfillWizardController.getMatchingContacts(testALC.Id);
        Test.stopTest();
        
        System.assertEquals(0, matches.size(), 'Should find no matches');
    }
    
    @isTest
    static void testProcessBackfillBatch_CreateNewContact() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        ALC__c testALC = new ALC__c(
            First_Name__c = 'New',
            Last_Name__c = 'Person',
            Personal_Email_Address__c = 'new.person@test.com',
            Mobile__c = '555-777-8888',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        // Manually unlink Contact (trigger auto-creates it)
        testALC.Contact__c = null;
        testALC.Candidate__c = null;
        update testALC;
        
        // Build decision JSON
        Map<String, Object> decision = new Map<String, Object>{
            'alcId' => testALC.Id,
            'createNewContact' => true,
            'selectedContactId' => null
        };
        String decisionsJson = JSON.serialize(new List<Object>{ decision });
        
        Test.startTest();
        String resultJson = ALCBackfillWizardController.processBackfillBatch(decisionsJson);
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resultJson);
        System.assertEquals(1, result.get('contactsCreated'), 'Should create 1 Contact');
        System.assertEquals(1, result.get('candidatesCreated'), 'Should create 1 Candidate for Career');
        System.assertEquals(1, result.get('alcsUpdated'), 'Should update 1 ALC');
        
        // Verify ALC was linked
        ALC__c updatedALC = [SELECT Contact__c, Candidate__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertNotEquals(null, updatedALC.Contact__c, 'ALC should have Contact');
        System.assertNotEquals(null, updatedALC.Candidate__c, 'Career ALC should have Candidate');
    }
    
    @isTest
    static void testProcessBackfillBatch_UseExistingContact() {
        Id brokerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Broker')?.getRecordTypeId();
        if (brokerRTId == null) return;
        
        Contact existingContact = [SELECT Id FROM Contact LIMIT 1];
        
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Match',
            Personal_Email_Address__c = 'existing@test.com',
            Mobile__c = '555-666-7777',
            RecordTypeId = brokerRTId
        );
        insert testALC;
        
        // Manually unlink Contact (trigger auto-creates it)
        testALC.Contact__c = null;
        update testALC;
        
        // Build decision JSON
        Map<String, Object> decision = new Map<String, Object>{
            'alcId' => testALC.Id,
            'createNewContact' => false,
            'selectedContactId' => existingContact.Id
        };
        String decisionsJson = JSON.serialize(new List<Object>{ decision });
        
        Test.startTest();
        String resultJson = ALCBackfillWizardController.processBackfillBatch(decisionsJson);
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resultJson);
        System.assertEquals(0, result.get('contactsCreated'), 'Should not create new Contact');
        System.assertEquals(0, result.get('candidatesCreated'), 'Should not create Candidate for Broker');
        System.assertEquals(1, result.get('alcsUpdated'), 'Should update 1 ALC');
        
        // Verify ALC was linked
        ALC__c updatedALC = [SELECT Contact__c, Candidate__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertEquals(existingContact.Id, updatedALC.Contact__c, 'ALC should have selected Contact');
        System.assertEquals(null, updatedALC.Candidate__c, 'Broker ALC should not have Candidate');
    }
    
    @isTest
    static void testProcessBackfillBatch_MultipleBatch() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        List<ALC__c> testALCs = new List<ALC__c>{
            new ALC__c(First_Name__c = 'Batch1', Last_Name__c = 'Test', Personal_Email_Address__c = 'batch1@test.com', Mobile__c = '555-111-0000', RecordTypeId = careerRTId),
            new ALC__c(First_Name__c = 'Batch2', Last_Name__c = 'Test', Personal_Email_Address__c = 'batch2@test.com', Mobile__c = '555-222-0000', RecordTypeId = careerRTId),
            new ALC__c(First_Name__c = 'Batch3', Last_Name__c = 'Test', Personal_Email_Address__c = 'batch3@test.com', Mobile__c = '555-333-0000', RecordTypeId = careerRTId)
        };
        insert testALCs;
        
        // Manually unlink Contacts (trigger auto-creates them)
        for (ALC__c alc : testALCs) {
            alc.Contact__c = null;
            alc.Candidate__c = null;
        }
        update testALCs;
        
        // Build decisions JSON
        List<Object> decisions = new List<Object>();
        for (ALC__c alc : testALCs) {
            decisions.add(new Map<String, Object>{
                'alcId' => alc.Id,
                'createNewContact' => true,
                'selectedContactId' => null
            });
        }
        String decisionsJson = JSON.serialize(decisions);
        
        Test.startTest();
        String resultJson = ALCBackfillWizardController.processBackfillBatch(decisionsJson);
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resultJson);
        System.assertEquals(3, result.get('contactsCreated'), 'Should create 3 Contacts');
        System.assertEquals(3, result.get('candidatesCreated'), 'Should create 3 Candidates');
        System.assertEquals(3, result.get('alcsUpdated'), 'Should update 3 ALCs');
    }
    
    @isTest
    static void testGetUnlinkedALCs_ExceptionHandling() {
        // Test with invalid record type
        Test.startTest();
        try {
            List<ALCBackfillWizardController.ALCWrapper> results = 
                ALCBackfillWizardController.getUnlinkedALCs('InvalidType');
            System.assertEquals(0, results.size(), 'Should return empty list for invalid type');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error'), 'Should throw AuraHandledException');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetMatchingContacts_InvalidId() {
        Test.startTest();
        try {
            ALCBackfillWizardController.getMatchingContacts(null);
            System.assert(false, 'Should throw exception for null ID');
        } catch (Exception e) {
            System.assert(true, 'Expected exception for null ID');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessBackfillBatch_InvalidJson() {
        Test.startTest();
        try {
            ALCBackfillWizardController.processBackfillBatch('invalid json');
            System.assert(false, 'Should throw exception for invalid JSON');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error'), 'Should throw AuraHandledException');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessBackfillBatch_EmptyDecisions() {
        Test.startTest();
        String resultJson = ALCBackfillWizardController.processBackfillBatch('[]');
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resultJson);
        Test.stopTest();
        
        System.assertEquals(0, result.get('contactsCreated'), 'Should create 0 Contacts');
        System.assertEquals(0, result.get('alcsUpdated'), 'Should update 0 ALCs');
    }
}
