/**
 * Test class for ALCRelationshipMonitorController
 * Tests dashboard queries, statistics, and fix operations
 * 
 * @group ALC Automation
 * @date 2026-01-08
 */
@isTest
private class ALCRelationshipMonitorController_Test {
    
    @TestSetup
    static void makeData() {
        // Create test Contacts
        List<Contact> testContacts = new List<Contact>{
            new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@example.com'),
            new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test2@example.com')
        };
        insert testContacts;
        
        // Create test Candidates with and without Contacts
        List<Candidate__c> testCandidates = new List<Candidate__c>{
            new Candidate__c(First_Name__c = 'Linked', Last_Name__c = 'Candidate', Email__c = 'linked@test.com', Contact__c = testContacts[0].Id),
            new Candidate__c(First_Name__c = 'Unlinked', Last_Name__c = 'Candidate', personal_email__c = 'unlinked@test.com', Contact__c = null)
        };
        insert testCandidates;
        
        // Create test audit logs
        List<ALC_Automation_Log__c> testLogs = new List<ALC_Automation_Log__c>{
            new ALC_Automation_Log__c(Operation_Type__c = 'Manual Fix', Success__c = true, Error_Message__c = 'Test message'),
            new ALC_Automation_Log__c(Operation_Type__c = 'Auto-create via trigger', Success__c = false, Error_Type__c = 'Test Error', Error_Message__c = 'Error message')
        };
        insert testLogs;
    }
    
    @isTest
    static void testGetRelationshipGaps() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        // Create ALC without Contact
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Gap',
            Last_Name__c = 'Test',
            Personal_Email_Address__c = 'gap@test.com',
            Mobile__c = '555-111-2222',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        Test.startTest();
        List<ALCRelationshipMonitorController.RelationshipGap> gaps = 
            ALCRelationshipMonitorController.getRelationshipGaps();
        Test.stopTest();
        
        System.assert(gaps.size() > 0, 'Should find at least one gap');
        System.assertEquals(false, gaps[0].hasContact, 'Gap should show no Contact');
    }
    
    @isTest
    static void testGetRelationshipGaps_CareerWithoutCandidate() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        // Create Career ALC with Contact but no Candidate
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Career',
            Last_Name__c = 'NoCandidate',
            Personal_Email_Address__c = 'career@test.com',
            Mobile__c = '555-222-3333',
            Contact__c = testContact.Id,
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        Test.startTest();
        List<ALCRelationshipMonitorController.RelationshipGap> gaps = 
            ALCRelationshipMonitorController.getRelationshipGaps();
        Test.stopTest();
        
        Boolean foundCareerGap = false;
        for (ALCRelationshipMonitorController.RelationshipGap gap : gaps) {
            if (gap.alcId == testALC.Id) {
                foundCareerGap = true;
                System.assertEquals(true, gap.hasContact, 'Should have Contact');
                System.assertEquals(false, gap.hasCandidate, 'Should not have Candidate');
            }
        }
        System.assert(foundCareerGap, 'Should find Career ALC without Candidate');
    }
    
    @isTest
    static void testGetCandidatesWithoutContacts() {
        Test.startTest();
        List<ALCRelationshipMonitorController.CandidateGap> gaps = 
            ALCRelationshipMonitorController.getCandidatesWithoutContacts();
        Test.stopTest();
        
        System.assert(gaps.size() > 0, 'Should find at least one Candidate without Contact');
        System.assertEquals('unlinked@test.com', gaps[0].email, 'Should match unlinked candidate email');
    }
    
    @isTest
    static void testGetRecentAuditLogs_DefaultLimit() {
        Test.startTest();
        List<ALC_Automation_Log__c> logs = 
            ALCRelationshipMonitorController.getRecentAuditLogs(null);
        Test.stopTest();
        
        System.assert(logs.size() >= 2, 'Should return test logs');
    }
    
    @isTest
    static void testGetRecentAuditLogs_CustomLimit() {
        Test.startTest();
        List<ALC_Automation_Log__c> logs = 
            ALCRelationshipMonitorController.getRecentAuditLogs(10);
        Test.stopTest();
        
        System.assert(logs.size() <= 10, 'Should respect custom limit');
    }
    
    @isTest
    static void testMarkLogResolved() {
        ALC_Automation_Log__c log = [SELECT Id, Resolved__c FROM ALC_Automation_Log__c WHERE Success__c = false LIMIT 1];
        System.assertEquals(false, log.Resolved__c, 'Log should start unresolved');
        
        Test.startTest();
        ALCRelationshipMonitorController.markLogResolved(log.Id, 'Fixed manually');
        Test.stopTest();
        
        log = [SELECT Resolved__c, Resolved_By__c, Resolution_Notes__c FROM ALC_Automation_Log__c WHERE Id = :log.Id];
        System.assertEquals(true, log.Resolved__c, 'Log should be marked resolved');
        System.assertEquals(UserInfo.getUserId(), log.Resolved_By__c, 'Should record resolver');
        System.assertEquals('Fixed manually', log.Resolution_Notes__c, 'Should save notes');
    }
    
    @isTest
    static void testFixCandidateContact_Success() {
        Candidate__c candidate = [SELECT Id, Contact__c FROM Candidate__c WHERE Contact__c = null LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        ALCRelationshipMonitorController.fixCandidateContact(candidate.Id, contact.Id);
        Test.stopTest();
        
        candidate = [SELECT Contact__c FROM Candidate__c WHERE Id = :candidate.Id];
        System.assertEquals(contact.Id, candidate.Contact__c, 'Should link Candidate to Contact');
        
        // Verify audit log created
        List<ALC_Automation_Log__c> logs = [
            SELECT Success__c, Operation_Type__c 
            FROM ALC_Automation_Log__c 
            WHERE Candidate__c = :candidate.Id 
            AND Operation_Type__c = 'Manual Fix'
        ];
        System.assertEquals(1, logs.size(), 'Should create audit log');
        System.assertEquals(true, logs[0].Success__c, 'Audit log should show success');
    }
    
    @isTest
    static void testFixCandidateContact_InvalidId() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        try {
            ALCRelationshipMonitorController.fixCandidateContact(null, contact.Id);
            System.assert(false, 'Should throw exception for null ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error'), 'Should throw AuraHandledException');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetSummaryStatistics() {
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career')?.getRecordTypeId();
        if (careerRTId == null) return;
        
        // Create test data
        ALC__c testALC = new ALC__c(
            First_Name__c = 'Stat',
            Last_Name__c = 'Test',
            Personal_Email_Address__c = 'stat@test.com',
            Mobile__c = '555-999-8888',
            RecordTypeId = careerRTId
        );
        insert testALC;
        
        Test.startTest();
        Map<String, Integer> stats = ALCRelationshipMonitorController.getSummaryStatistics();
        Test.stopTest();
        
        System.assertNotEquals(null, stats.get('alcsWithoutContacts'), 'Should return ALCs without Contacts stat');
        System.assertNotEquals(null, stats.get('careerWithoutCandidates'), 'Should return Career without Candidates stat');
        System.assertNotEquals(null, stats.get('candidatesWithoutContacts'), 'Should return Candidates without Contacts stat');
        System.assertNotEquals(null, stats.get('recentErrors'), 'Should return recent errors stat');
        System.assertNotEquals(null, stats.get('unresolvedErrors'), 'Should return unresolved errors stat');
        
        System.assert(stats.get('alcsWithoutContacts') > 0, 'Should have at least one ALC without Contact');
        System.assert(stats.get('candidatesWithoutContacts') > 0, 'Should have at least one Candidate without Contact');
    }
    
    @isTest
    static void testGetSummaryStatistics_RecentErrors() {
        // Create recent error log
        ALC_Automation_Log__c recentError = new ALC_Automation_Log__c(
            Operation_Type__c = 'Auto-create via trigger',
            Success__c = false,
            Error_Type__c = 'Test',
            Error_Message__c = 'Recent error message'
        );
        insert recentError;
        
        Test.startTest();
        Map<String, Integer> stats = ALCRelationshipMonitorController.getSummaryStatistics();
        Test.stopTest();
        
        System.assert(stats.get('recentErrors') > 0, 'Should count recent errors');
        System.assert(stats.get('unresolvedErrors') > 0, 'Should count unresolved errors');
    }
    
    @isTest
    static void testGetRelationshipGaps_NoGaps() {
        // Delete all ALCs to ensure no gaps
        delete [SELECT Id FROM ALC__c];
        
        Test.startTest();
        List<ALCRelationshipMonitorController.RelationshipGap> gaps = 
            ALCRelationshipMonitorController.getRelationshipGaps();
        Test.stopTest();
        
        System.assertEquals(0, gaps.size(), 'Should return empty list when no gaps');
    }
    
    @isTest
    static void testGetCandidatesWithoutContacts_NoGaps() {
        // Link all candidates
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        List<Candidate__c> candidates = [SELECT Id FROM Candidate__c WHERE Contact__c = null];
        for (Candidate__c c : candidates) {
            c.Contact__c = contact.Id;
        }
        update candidates;
        
        Test.startTest();
        List<ALCRelationshipMonitorController.CandidateGap> gaps = 
            ALCRelationshipMonitorController.getCandidatesWithoutContacts();
        Test.stopTest();
        
        System.assertEquals(0, gaps.size(), 'Should return empty list when all linked');
    }
    
    @isTest
    static void testGetRecentAuditLogs_EmptyResults() {
        // Delete all logs
        delete [SELECT Id FROM ALC_Automation_Log__c];
        
        Test.startTest();
        List<ALC_Automation_Log__c> logs = 
            ALCRelationshipMonitorController.getRecentAuditLogs(50);
        Test.stopTest();
        
        System.assertEquals(0, logs.size(), 'Should return empty list when no logs');
    }
}
