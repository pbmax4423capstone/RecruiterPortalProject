/**
 * @description Test class for ContractBDailyRollupScheduler
 * @author Contract Lifecycle Tracking System
 * @date December 2025
 */
@isTest
private class ContractBDailyRollupSchedulerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Scheduler',
            LastName = 'Test',
            Email = 'scheduler.test@test.com'
        );
        insert testContact;
        
        // Create test Candidate
        Candidate__c testCandidate = new Candidate__c(
            First_Name__c = 'Scheduler',
            Last_Name__c = 'Test',
            Contact__c = testContact.Id,
            Contract_Type__c = 'Contract B',
            Contract_Outcome__c = 'Active',
            Start_Date__c = Date.today().addMonths(-2)
        );
        insert testCandidate;
        
        // Create test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Scheduler Test Opp',
            ContactId = testContact.Id,
            StageName = 'Submitted',
            CloseDate = Date.today().addDays(30),
            FYC__c = 1000
        );
        insert testOpp;
    }
    
    @isTest
    static void testSchedulerExecution() {
        Test.startTest();
        
        // Execute the scheduler
        ContractBDailyRollupScheduler scheduler = new ContractBDailyRollupScheduler();
        scheduler.execute(null);
        
        Test.stopTest();
        
        // Verify the rollup was updated
        Candidate__c candidate = [
            SELECT Total_FYC__c, Opportunity_Count__c
            FROM Candidate__c
            WHERE First_Name__c = 'Scheduler'
            LIMIT 1
        ];
        
        System.assertEquals(1000, candidate.Total_FYC__c, 'FYC should be updated');
        System.assertEquals(1, candidate.Opportunity_Count__c, 'Count should be updated');
    }
    
    @isTest
    static void testScheduleDailyJob() {
        Test.startTest();
        
        String jobId = ContractBDailyRollupScheduler.scheduleDailyJob();
        
        Test.stopTest();
        
        System.assertNotEquals(null, jobId, 'Job should be scheduled');
        
        // Clean up
        ContractBDailyRollupScheduler.unscheduleJob();
    }
    
    @isTest
    static void testUnscheduleJob() {
        // Schedule a job first
        String jobId = ContractBDailyRollupScheduler.scheduleDailyJob();
        
        Test.startTest();
        ContractBDailyRollupScheduler.unscheduleJob();
        Test.stopTest();
        
        // Verify job was removed
        List<CronTrigger> jobs = [
            SELECT Id 
            FROM CronTrigger 
            WHERE CronJobDetail.Name LIKE 'Contract B Daily FYC Rollup%'
        ];
        
        System.assertEquals(0, jobs.size(), 'All jobs should be unscheduled');
    }
}
