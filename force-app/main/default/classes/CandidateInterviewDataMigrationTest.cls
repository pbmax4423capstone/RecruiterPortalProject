@isTest
private class CandidateInterviewDataMigrationTest {
    
    @testSetup
    static void setupTestData() {
        // Create test candidate with Attraction interview
        Candidate__c cand = new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Candidate'
        );
        // Use AI_Conducted_By__c for Attraction interview conductor
        cand.put('AI_Conducted_By__c', 'Tim Denton');
        cand.put('Attraction_Interview_Date_Completed__c', Date.today().addDays(-5));
        insert cand;
    }
    
    @isTest
    static void testMigrateInterviews() {
        // Get test candidate
        Candidate__c cand = [SELECT Id FROM Candidate__c LIMIT 1];
        
        Test.startTest();
        CandidateInterviewDataMigration.Result res = 
            CandidateInterviewDataMigration.migrateInterviews(new List<Id>{cand.Id});
        Test.stopTest();
        
        // Verify results - only testing Attraction interviews now
        System.assertEquals(1, res.candidatesProcessed, 'Should process 1 candidate');
        System.assertEquals(1, res.interviewRecordsCreated, 'Should create 1 Attraction Interview__c record');
        System.assertEquals(1, res.eventRecordsCreated, 'Should create 1 Event for Tim Denton (SF Sales Manager)');
    }
    
    @isTest
    static void testBatchMigration() {
        Test.startTest();
        CandidateInterviewMigrationBatch2 batch = new CandidateInterviewMigrationBatch2();
        Id jobId = Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify batch ran
        System.assertNotEquals(null, jobId, 'Batch job should start');
        
        // Verify Interview__c records created
        List<Interview__c> interviews = [SELECT Id FROM Interview__c];
        System.assert(interviews.size() > 0, 'Should create Interview__c records');
    }
    
    @isTest
    static void testMultipleCandidatesProcessing() {
        // Test processing multiple candidates
        List<Candidate__c> cands = new List<Candidate__c>();
        for (Integer i = 0; i < 3; i++) {
            Candidate__c c = new Candidate__c(
                First_Name__c = 'Multi' + i,
                Last_Name__c = 'Test' + i
            );
            c.put('AI_Conducted_By__c', 'Tim Denton');
            c.put('Attraction_Interview_Date_Completed__c', Date.today().addDays(-i));
            cands.add(c);
        }
        insert cands;
        
        List<Id> candIds = new List<Id>();
        for (Candidate__c c : cands) {
            candIds.add(c.Id);
        }
        
        Test.startTest();
        CandidateInterviewDataMigration.Result res = 
            CandidateInterviewDataMigration.migrateInterviews(candIds);
        Test.stopTest();
        
        System.assertEquals(3, res.candidatesProcessed, 'Should process 3 candidates');
        System.assertEquals(3, res.interviewRecordsCreated, 'Should create 3 interviews');
        System.assertEquals(3, res.eventRecordsCreated, 'Should create 3 events');
    }
    
    @isTest
    static void testMissingDataSkipped() {
        // Test that interviews with missing data are skipped
        Candidate__c cand = new Candidate__c(
            First_Name__c = 'Skip',
            Last_Name__c = 'Test'
        );
        // Don't set AI_Conducted_By__c or date
        insert cand;
        
        Test.startTest();
        CandidateInterviewDataMigration.Result res = 
            CandidateInterviewDataMigration.migrateInterviews(new List<Id>{cand.Id});
        Test.stopTest();
        
        System.assertEquals(1, res.candidatesProcessed, 'Should process candidate');
        System.assertEquals(0, res.interviewRecordsCreated, 'Should create no interviews');
        System.assertEquals(0, res.eventRecordsCreated, 'Should create no events');
    }
    
    @isTest
    static void testBulkMigration() {
        // Test bulk processing with multiple candidates
        List<Candidate__c> cands = new List<Candidate__c>();
        for (Integer i = 0; i < 50; i++) {
            Candidate__c c = new Candidate__c(
                First_Name__c = 'Bulk' + i,
                Last_Name__c = 'Test' + i
            );
            c.put('AI_Conducted_By__c', 'Brooke Ianni'); // SF Manager
            c.put('Attraction_Interview_Date_Completed__c', Date.today().addDays(-i));
            cands.add(c);
        }
        insert cands;
        
        List<Id> candIds = new List<Id>();
        for (Candidate__c c : cands) {
            candIds.add(c.Id);
        }
        
        Test.startTest();
        CandidateInterviewDataMigration.Result res = 
            CandidateInterviewDataMigration.migrateInterviews(candIds);
        Test.stopTest();
        
        System.assertEquals(50, res.candidatesProcessed, 'Should process 50 candidates');
        System.assertEquals(50, res.interviewRecordsCreated, 'Should create 50 interviews');
        System.assertEquals(50, res.eventRecordsCreated, 'Should create 50 events for SF manager');
    }
    
    @isTest
    static void testResultObjectProperties() {
        // Test that Result object properties are accessible
        Candidate__c cand = [SELECT Id FROM Candidate__c LIMIT 1];
        
        Test.startTest();
        CandidateInterviewDataMigration.Result res = 
            CandidateInterviewDataMigration.migrateInterviews(new List<Id>{cand.Id});
        Test.stopTest();
        
        // Verify Result object properties exist and are initialized
        System.assertNotEquals(null, res.candidatesProcessed, 'candidatesProcessed should exist');
        System.assertNotEquals(null, res.interviewRecordsCreated, 'interviewRecordsCreated should exist');
        System.assertNotEquals(null, res.eventRecordsCreated, 'eventRecordsCreated should exist');
        System.assertNotEquals(null, res.eventsSkipped, 'eventsSkipped should exist');
        System.assertNotEquals(null, res.errors, 'errors list should exist');
        System.assertNotEquals(null, res.warnings, 'warnings list should exist');
    }
}