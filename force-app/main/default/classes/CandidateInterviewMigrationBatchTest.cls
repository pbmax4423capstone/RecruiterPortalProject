@isTest
private class CandidateInterviewMigrationBatchTest {
    
    @testSetup
    static void setup() {
        // Create test candidates with various completed interview dates
        List<Candidate__c> candidates = new List<Candidate__c>();
        
        // Candidate with SI_1 completed
        candidates.add(new Candidate__c(
            First_Name__c = 'Test1',
            Last_Name__c = 'Candidate1',
            Email__c = 'test1@example.com',
            SI_1_Date_Completed__c = Date.today()
        ));
        
        // Candidate with SI_2 completed
        candidates.add(new Candidate__c(
            First_Name__c = 'Test2',
            Last_Name__c = 'Candidate2',
            Email__c = 'test2@example.com',
            SI_2_Date_Completed__c = Date.today()
        ));
        
        // Candidate with AI completed
        candidates.add(new Candidate__c(
            First_Name__c = 'Test3',
            Last_Name__c = 'Candidate3',
            Email__c = 'test3@example.com',
            AI_Completed_Date_Time__c = Datetime.now()
        ));
        
        insert candidates;
    }
    
    @isTest
    static void testBatchExecutionDryRun() {
        // Test dry run mode - should query candidates but not create events
        Test.startTest();
        CandidateInterviewMigrationBatch batch = new CandidateInterviewMigrationBatch(true);
        Id jobId = Database.executeBatch(batch, 200);
        Test.stopTest();
        
        System.assertNotEquals(null, jobId, 'Job ID should be returned');
        
        // In dry run mode, no events should be created
        Integer eventCount = [SELECT COUNT() FROM Event];
        System.assertEquals(0, eventCount, 'Dry run should not create events');
    }
    
    @isTest
    static void testBatchExecutionRealRun() {
        // Test real run mode - should create events
        Test.startTest();
        CandidateInterviewMigrationBatch batch = new CandidateInterviewMigrationBatch(false);
        Id jobId = Database.executeBatch(batch, 200);
        Test.stopTest();
        
        System.assertNotEquals(null, jobId, 'Job ID should be returned');
        
        // In real run mode, events should be created for our test candidates
        Integer eventCount = [SELECT COUNT() FROM Event];
        System.assert(eventCount > 0, 'Real run should create events');
    }
}
