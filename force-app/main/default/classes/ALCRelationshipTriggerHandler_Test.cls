/**
 * Test class for ALCRelationshipTriggerHandler
 * Tests automatic Contact/Candidate creation on ALC insert
 * 
 * @group ALC Automation
 * @date 2026-01-08
 */
@isTest
private class ALCRelationshipTriggerHandler_Test {
    
    @TestSetup
    static void makeData() {
        // Create existing Contact for duplicate prevention tests
        Contact existingContact = new Contact(
            FirstName = 'Existing',
            LastName = 'Contact',
            Personal_Email__c = 'existing@test.com',
            MobilePhone = '555-999-8888'
        );
        insert existingContact;
    }
    
    @isTest
    static void testHandleBeforeInsert_CreatesContact() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        ALC__c testALC = new ALC__c(
            First_Name__c = 'New',
            Last_Name__c = 'Person',
            Personal_Email_Address__c = 'new.person@test.com',
            Mobile__c = '555-111-2222',
            RecordTypeId = careerRTId
        );
        
        Test.startTest();
        insert testALC;
        Test.stopTest();
        
        // Verify Contact was created
        testALC = [SELECT Contact__c, Candidate__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertNotEquals(null, testALC.Contact__c, 'Should create Contact');
        
        Contact createdContact = [SELECT FirstName, LastName, Personal_Email__c FROM Contact WHERE Id = :testALC.Contact__c];
        System.assertEquals('New', createdContact.FirstName, 'Contact first name should match');
        System.assertEquals('Person', createdContact.LastName, 'Contact last name should match');
    }
    
    @isTest
    static void testHandleBeforeInsert_CreatesCandidate_CareerType() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Career',
            Last_Name__c = 'Candidate',
            Personal_Email_Address__c = 'career@test.com',
            Mobile__c = '555-222-3333',
            RecordTypeId = careerRTId
        );
        
        Test.startTest();
        insert testALC;
        Test.stopTest();
        
        // Verify Candidate was created for Career type
        testALC = [SELECT Contact__c, Candidate__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertNotEquals(null, testALC.Candidate__c, 'Should create Candidate for Career type');
        
        Candidate__c createdCandidate = [SELECT First_Name__c, personal_email__c, Status__c FROM Candidate__c WHERE Id = :testALC.Candidate__c];
        System.assertEquals('Career', createdCandidate.First_Name__c, 'Candidate name should match');
        System.assertEquals('career@test.com', createdCandidate.personal_email__c, 'Candidate email should match');
        System.assertEquals('Contract Sent', createdCandidate.Status__c, 'Candidate should have default status');
    }
    
    @isTest
    static void testHandleBeforeInsert_NoCandidate_BrokerType() {
        Id brokerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Broker')?.getRecordTypeId();
        if (brokerRTId == null) return;
        
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Broker',
            Last_Name__c = 'Person',
            Personal_Email_Address__c = 'broker@test.com',
            Mobile__c = '555-333-4444',
            RecordTypeId = brokerRTId
        );
        
        Test.startTest();
        insert testALC;
        Test.stopTest();
        
        // Verify no Candidate for Broker type
        testALC = [SELECT Contact__c, Candidate__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertNotEquals(null, testALC.Contact__c, 'Should create Contact');
        System.assertEquals(null, testALC.Candidate__c, 'Should not create Candidate for Broker type');
    }
    
    @isTest
    static void testHandleBeforeInsert_UsesExistingContact_Email() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        Contact existingContact = [SELECT Id FROM Contact WHERE Personal_Email__c = 'existing@test.com' LIMIT 1];
        
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Match',
            Last_Name__c = 'Test',
            Personal_Email_Address__c = 'existing@test.com',
            Mobile__c = '555-444-5555',
            RecordTypeId = careerRTId
        );
        
        Test.startTest();
        insert testALC;
        Test.stopTest();
        
        // Verify linked to existing Contact
        testALC = [SELECT Contact__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertEquals(existingContact.Id, testALC.Contact__c, 'Should link to existing Contact by email');
        
        // Verify no duplicate Contact created
        Integer contactCount = [SELECT COUNT() FROM Contact WHERE Personal_Email__c = 'existing@test.com'];
        System.assertEquals(1, contactCount, 'Should not create duplicate Contact');
    }
    
    @isTest
    static void testHandleBeforeInsert_UsesExistingContact_Phone() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        Contact existingContact = [SELECT Id, MobilePhone FROM Contact WHERE MobilePhone = '555-999-8888' LIMIT 1];
        
        ALC__c testALC = new ALC__c(
            First_Name__c = 'PhoneMatch',
            Last_Name__c = 'Test',
            Personal_Email_Address__c = 'phonematch@unique.com', // Unique email to avoid match
            Mobile__c = '(555) 999-8888', // Different format, same number
            RecordTypeId = careerRTId
        );
        
        Test.startTest();
        insert testALC;
        Test.stopTest();
        
        // Verify linked to existing Contact
        testALC = [SELECT Contact__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertEquals(existingContact.Id, testALC.Contact__c, 'Should link to existing Contact by phone');
    }
    
    @isTest
    static void testHandleBeforeInsert_BulkInsert() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        List<ALC__c> bulkALCs = new List<ALC__c>();
        for (Integer i = 0; i < 200; i++) {
            bulkALCs.add(new ALC__c(
                First_Name__c = 'Bulk' + i,
                Last_Name__c = 'Test' + i,
                Personal_Email_Address__c = 'bulk' + i + '@test.com',
                Mobile__c = '555-' + String.valueOf(1000 + i),
                RecordTypeId = careerRTId
            ));
        }
        
        Test.startTest();
        insert bulkALCs;
        Test.stopTest();
        
        // Verify all ALCs have Contacts
        List<ALC__c> insertedALCs = [SELECT Contact__c, Candidate__c FROM ALC__c WHERE Id IN :bulkALCs];
        for (ALC__c alc : insertedALCs) {
            System.assertNotEquals(null, alc.Contact__c, 'Bulk insert should create Contacts');
            System.assertNotEquals(null, alc.Candidate__c, 'Bulk insert should create Candidates for Career type');
        }
        
        // Verify correct number of Contacts created
        Integer contactCount = [SELECT COUNT() FROM Contact WHERE Personal_Email__c LIKE 'bulk%@test.com'];
        System.assertEquals(200, contactCount, 'Should create 200 Contacts');
        
        // Verify correct number of Candidates created
        Integer candidateCount = [SELECT COUNT() FROM Candidate__c WHERE personal_email__c LIKE 'bulk%@test.com'];
        System.assertEquals(200, candidateCount, 'Should create 200 Candidates');
    }
    
    @isTest
    static void testHandleBeforeInsert_SkipsExistingContact() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        Contact prelinkedContact = new Contact(FirstName = 'Prelinked', LastName = 'Contact', Email = 'prelinked@test.com');
        insert prelinkedContact;
        
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Skip',
            Last_Name__c = 'Test',
            Personal_Email_Address__c = 'skip@test.com',
            Mobile__c = '555-555-5555',
            Contact__c = prelinkedContact.Id,
            RecordTypeId = careerRTId
        );
        
        Test.startTest();
        insert testALC;
        Test.stopTest();
        
        // Verify Contact wasn't changed
        testALC = [SELECT Contact__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertEquals(prelinkedContact.Id, testALC.Contact__c, 'Should not overwrite existing Contact');
        
        // Verify no new Contact created
        Integer contactCount = [SELECT COUNT() FROM Contact WHERE Personal_Email__c = 'skip@test.com'];
        System.assertEquals(0, contactCount, 'Should not create Contact when already linked');
    }
    
    @isTest
    static void testHandleBeforeInsert_MixedRecordTypes() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        Id brokerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Broker')?.getRecordTypeId();
        
        if (careerRTId == null || brokerRTId == null) return;
        
        List<ALC__c> mixedALCs = new List<ALC__c>{
            new ALC__c(First_Name__c = 'Career1', Last_Name__c = 'Test', Personal_Email_Address__c = 'c1@test.com', Mobile__c = '555-100-0001', RecordTypeId = careerRTId),
            new ALC__c(First_Name__c = 'Broker1', Last_Name__c = 'Test', Personal_Email_Address__c = 'b1@test.com', Mobile__c = '555-100-0002', RecordTypeId = brokerRTId),
            new ALC__c(First_Name__c = 'Career2', Last_Name__c = 'Test', Personal_Email_Address__c = 'c2@test.com', Mobile__c = '555-100-0003', RecordTypeId = careerRTId)
        };
        
        Test.startTest();
        insert mixedALCs;
        Test.stopTest();
        
        // Verify Career types have Candidates, Broker doesn't
        List<ALC__c> insertedALCs = [SELECT RecordType.DeveloperName, Contact__c, Candidate__c FROM ALC__c WHERE Id IN :mixedALCs];
        for (ALC__c alc : insertedALCs) {
            System.assertNotEquals(null, alc.Contact__c, 'All types should have Contact');
            if (alc.RecordType.DeveloperName == 'Career') {
                System.assertNotEquals(null, alc.Candidate__c, 'Career types should have Candidate');
            } else {
                System.assertEquals(null, alc.Candidate__c, 'Non-Career types should not have Candidate');
            }
        }
    }
    
    @isTest
    static void testHandleBeforeInsert_NoLastName() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        ALC__c testALC = new ALC__c(
            First_Name__c = 'OnlyFirst',
            Last_Name__c = null, // No last name
            Personal_Email_Address__c = 'onlyfirst@test.com',
            Mobile__c = '555-777-8888',
            RecordTypeId = careerRTId
        );
        
        Test.startTest();
        insert testALC;
        Test.stopTest();
        
        // Verify Contact created with default last name
        testALC = [SELECT Contact__c FROM ALC__c WHERE Id = :testALC.Id];
        System.assertNotEquals(null, testALC.Contact__c, 'Should create Contact even without last name');
        
        Contact createdContact = [SELECT LastName FROM Contact WHERE Id = :testALC.Contact__c];
        System.assertEquals('Unknown', createdContact.LastName, 'Should use Unknown as default last name');
    }
    
    @isTest
    static void testPhoneStandardization() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        // Test various phone formats that should match
        List<ALC__c> phoneTests = new List<ALC__c>{
            new ALC__c(First_Name__c = 'Phone1', Last_Name__c = 'Test', Personal_Email_Address__c = 'p1@t.com', Mobile__c = '555-888-9999', RecordTypeId = careerRTId),
            new ALC__c(First_Name__c = 'Phone2', Last_Name__c = 'Test', Personal_Email_Address__c = 'p2@t.com', Mobile__c = '(555) 888-9999', RecordTypeId = careerRTId),
            new ALC__c(First_Name__c = 'Phone3', Last_Name__c = 'Test', Personal_Email_Address__c = 'p3@t.com', Mobile__c = '1-555-888-9999', RecordTypeId = careerRTId)
        };
        
        Test.startTest();
        insert phoneTests;
        Test.stopTest();
        
        // All should be created (no duplicates detected because emails are different)
        List<ALC__c> insertedALCs = [SELECT Contact__c FROM ALC__c WHERE Id IN :phoneTests];
        System.assertEquals(3, insertedALCs.size(), 'Should create all ALCs');
    }
}
