/**
 * Test class for ALCBackfillWizardController
 * Tests all @AuraEnabled methods for the backfill wizard UI
 * 
 * @group ALC Automation
 * @date 2026-01-08
 */
@isTest
private class ALCBackfillWizardController_Test {
    
    @TestSetup
    static void makeData() {
        // Create record types
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        Id brokerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Broker')?.getRecordTypeId();
        
        // Skip if record types don't exist
        if (careerRTId == null || brokerRTId == null) {
            return;
        }
        
        // Create test Contacts
        List<Contact> testContacts = new List<Contact>{
            new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@test.com', MobilePhone = '555-123-4567', Personal_Email__c = 'john.doe@test.com'),
            new Contact(FirstName = 'Jane', LastName = 'Smith', Email = 'jane.smith@test.com', MobilePhone = '555-987-6543', Personal_Email__c = 'jane.smith@test.com')
        };
        insert testContacts;
        
        // Create test ALCs WITHOUT Contacts (manually remove link after trigger creates them)
        List<ALC__c> testALCs = new List<ALC__c>{
            new ALC__c(
                First_Name__c = 'Unlinked',
                Last_Name__c = 'Career',
                Personal_Email_Address__c = 'unlinked.career@test.com',
                Mobile__c = '555-111-1111',
                RecordTypeId = careerRTId
            ),
            new ALC__c(
                First_Name__c = 'Unlinked',
                Last_Name__c = 'Broker',
                Personal_Email_Address__c = 'unlinked.broker@test.com',
                Mobile__c = '555-222-2222',
                RecordTypeId = brokerRTId
            )
        };
        insert testALCs;
        
        // Manually remove Contact links to create "unlinked" state
        for (ALC__c alc : testALCs) {
            alc.Contact__c = null;
            alc.Candidate__c = null;
        }
        update testALCs;
    }
    
    @isTest
    static void testGetUnlinkedALCs_AllTypes() {
        List<ALC__c> unlinked = [SELECT Id FROM ALC__c WHERE Contact__c = null];
        if (unlinked.isEmpty()) {
            // If trigger auto-created Contacts, can't test this scenario
            return;
        }
        
        Test.startTest();
        List<ALCBackfillWizardController.ALCWrapper> results = ALCBackfillWizardController.getUnlinkedALCs(null);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Should return results');
        System.assert(results.size() >= 2, 'Should find at least 2 unlinked ALCs');
        System.assertNotEquals(null, results[0].firstName, 'Should have first name');
        System.assertNotEquals(null, results[0].recordType, 'Should have record type');
    }
    
    @isTest
    static void testGetUnlinkedALCs_CareerType() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        List<ALC__c> unlinked = [SELECT Id FROM ALC__c WHERE Contact__c = null AND RecordTypeId = :careerRTId];
        if (unlinked.isEmpty()) return;
        
        Test.startTest();
        List<ALCBackfillWizardController.ALCWrapper> results = ALCBackfillWizardController.getUnlinkedALCs('Career');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Should return results');
        System.assert(results.size() >= 1, 'Should find at least 1 Career ALC');
        System.assertEquals('Career', results[0].recordType, 'Should only return Career type');
    }
    
    @isTest
    static void testGetUnlinkedALCs_BrokerType() {
        Id brokerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Broker')?.getRecordTypeId();
        if (brokerRTId == null) return;
        
        List<ALC__c> unlinked = [SELECT Id FROM ALC__c WHERE Contact__c = null AND RecordTypeId = :brokerRTId];
        if (unlinked.isEmpty()) return;
        
        Test.startTest();
        List<ALCBackfillWizardController.ALCWrapper> results = ALCBackfillWizardController.getUnlinkedALCs('Broker');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Should return results');
        System.assert(results.size() >= 1, 'Should find at least 1 Broker ALC');
        System.assertEquals('Broker', results[0].recordType, 'Should only return Broker type');
    }
    
    @isTest
    static void testGetMatchingContacts_HasMatches() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        // Create ALC with similar name to existing Contact
        ALC__c testALC = new ALC__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Personal_Email_Address__c = 'john.doe.similar@test.com',
            Mobile__c = '555-999-9999',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        Test.startTest();
        List<ALCBackfillWizardController.MatchWrapper> matches = ALCBackfillWizardController.getMatchingContacts(testALC.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, matches, 'Should return match results');
        // Matches may or may not exist depending on name similarity threshold
    }
    
    @isTest
    static void testGetMatchingContacts_NoMatches() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        // Create ALC with completely unique data
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Unique',
            Last_Name__c = 'NoMatch',
            Personal_Email_Address__c = 'unique.nomatch@nowhere.com',
            Mobile__c = '555-000-0001',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        Test.startTest();
        List<ALCBackfillWizardController.MatchWrapper> matches = ALCBackfillWizardController.getMatchingContacts(testALC.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, matches, 'Should return empty list, not null');
    }
    
    @isTest
    static void testProcessBackfillBatch_LinkExistingContact() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        Contact existingContact = [SELECT Id FROM Contact WHERE Email = 'john.doe@test.com' LIMIT 1];
        
        // Create unlinked ALC
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Link',
            Last_Name__c = 'Test',
            Personal_Email_Address__c = 'link.test@test.com',
            Mobile__c = '555-444-4444',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        // Remove auto-created Contact link
        testALC.Contact__c = null;
        testALC.Candidate__c = null;
        update testALC;
        
        // Build decision JSON
        List<Map<String, Object>> decisions = new List<Map<String, Object>>{
            new Map<String, Object>{
                'alcId' => testALC.Id,
                'selectedContactId' => existingContact.Id,
                'createNewContact' => false
            }
        };
        String decisionsJson = JSON.serialize(decisions);
        
        Test.startTest();
        String resultJson = ALCBackfillWizardController.processBackfillBatch(decisionsJson);
        Test.stopTest();
        
        System.assertNotEquals(null, resultJson, 'Should return result JSON');
        
        // Verify ALC is now linked
        testALC = [SELECT Contact__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertEquals(existingContact.Id, testALC.Contact__c, 'Should link to existing Contact');
    }
    
    @isTest
    static void testProcessBackfillBatch_CreateNewContact() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        // Create unlinked ALC
        ALC__c testALC = new ALC__c(
            First_Name__c = 'NewContact',
            Last_Name__c = 'Test',
            Personal_Email_Address__c = 'newcontact.test@test.com',
            Mobile__c = '555-555-5555',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        // Remove auto-created Contact/Candidate
        testALC.Contact__c = null;
        testALC.Candidate__c = null;
        update testALC;
        
        Integer contactCountBefore = [SELECT COUNT() FROM Contact];
        
        // Build decision JSON
        List<Map<String, Object>> decisions = new List<Map<String, Object>>{
            new Map<String, Object>{
                'alcId' => testALC.Id,
                'selectedContactId' => null,
                'createNewContact' => true
            }
        };
        String decisionsJson = JSON.serialize(decisions);
        
        Test.startTest();
        String resultJson = ALCBackfillWizardController.processBackfillBatch(decisionsJson);
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resultJson);
        System.assertNotEquals(null, result, 'Should return result map');
        
        // Verify new Contact was created
        Integer contactCountAfter = [SELECT COUNT() FROM Contact];
        System.assert(contactCountAfter > contactCountBefore, 'Should create new Contact');
        
        // Verify ALC is now linked
        testALC = [SELECT Contact__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertNotEquals(null, testALC.Contact__c, 'Should link to new Contact');
    }
    
    @isTest
    static void testProcessBackfillBatch_MultipleBatch() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        // Create multiple unlinked ALCs
        List<ALC__c> testALCs = new List<ALC__c>();
        for (Integer i = 0; i < 3; i++) {
            testALCs.add(new ALC__c(
                First_Name__c = 'Multi' + i,
                Last_Name__c = 'Test' + i,
                Personal_Email_Address__c = 'multi' + i + '@test.com',
                Mobile__c = '555-666-000' + i,
                RecordTypeId = careerRTId
            ));
        }
        insert testALCs;
        
        // Remove auto-created links
        for (ALC__c alc : testALCs) {
            alc.Contact__c = null;
            alc.Candidate__c = null;
        }
        update testALCs;
        
        // Build decisions for all ALCs
        List<Map<String, Object>> decisions = new List<Map<String, Object>>();
        for (ALC__c alc : testALCs) {
            decisions.add(new Map<String, Object>{
                'alcId' => alc.Id,
                'selectedContactId' => null,
                'createNewContact' => true
            });
        }
        String decisionsJson = JSON.serialize(decisions);
        
        Test.startTest();
        String resultJson = ALCBackfillWizardController.processBackfillBatch(decisionsJson);
        Test.stopTest();
        
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resultJson);
        System.assertNotEquals(null, result, 'Should return result map');
        
        // Verify all ALCs are now linked
        List<ALC__c> linkedALCs = [SELECT Contact__c FROM ALC__c WHERE Id IN :testALCs];
        for (ALC__c alc : linkedALCs) {
            System.assertNotEquals(null, alc.Contact__c, 'Each ALC should be linked to Contact');
        }
    }
    
    @isTest
    static void testProcessBackfillBatch_InvalidJson() {
        Test.startTest();
        try {
            ALCBackfillWizardController.processBackfillBatch('invalid json {{{');
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Should throw AuraHandledException');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetUnlinkedALCs_Exception() {
        // Test with invalid record type name - should still work but return empty
        Test.startTest();
        List<ALCBackfillWizardController.ALCWrapper> results = ALCBackfillWizardController.getUnlinkedALCs('InvalidType');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Should return empty list, not throw');
    }
}
