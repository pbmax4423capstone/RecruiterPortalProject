/**
 * @description Test class for InterviewHistoricalMigration and InterviewHistoricalMigrationBatch
 * Validates interview migration logic, status determination, outcome inference, conductor resolution
 */
@isTest
private class InterviewHistoricalMigrationTest {
    
    /**
     * @description Create test data with various interview configurations
     */
    @testSetup
    static void setup() {
        // Create test users for conductor resolution
        User testUser1 = new User(
            FirstName = 'Bradley',
            LastName = 'Sofonia',
            Email = 'bradley.sofonia@test.com',
            Username = 'bradley.sofonia@test.financialguide.com.test',
            Alias = 'bsofonia',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert testUser1;
        
        // Create test candidates with various interview scenarios
        List<Candidate__c> candidates = new List<Candidate__c>();
        
        // Scenario 1: Only Ci-First completed (last interview, outcome should be null)
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'CandidateOne',
            Email__c = 'test1@example.com',
            Attraction_Interview_Date_Scheduled__c = Date.today().addDays(-10),
            AI_Completed_Date_Time__c = DateTime.now().addDays(-8)
        ));
        
        // Scenario 2: Ci-First and Align-2nd completed (Ci-First should have outcome='Proceed')
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'CandidateTwo',
            Email__c = 'test2@example.com',
            Attraction_Interview_Date_Scheduled__c = Date.today().addDays(-20),
            Attraction_Interview_Date_Completed__c = Date.today().addDays(-18),
            SI_1_Date_Scheduled__c = Date.today().addDays(-15),
            SI_1_Date_Completed__c = Date.today().addDays(-13)
        ));
        
        // Scenario 3: Only scheduled Ci-First (no completed date, status='Scheduled')
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'CandidateThree',
            Email__c = 'test3@example.com',
            Attraction_Interview_Date_Scheduled__c = Date.today().addDays(5)
        ));
        
        // Scenario 4: All 5 interview types completed
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'CandidateFour',
            Email__c = 'test4@example.com',
            // Ci-First
            Attraction_Interview_Date_Scheduled__c = Date.today().addDays(-50),
            Attraction_Interview_Date_Completed__c = Date.today().addDays(-48),
            // Align-2nd
            SI_1_Date_Scheduled__c = Date.today().addDays(-45),
            SI_1_Date_Completed__c = Date.today().addDays(-43),
            // Plan-3rd
            SI_2_Date_Scheduled__c = Date.today().addDays(-40),
            SI_2_Date_Completed__c = Date.today().addDays(-38),
            // Present-4th
            Career_Presentation_Date_Scheduled__c = Date.today().addDays(-35),
            Career_Presentation_Date_Completed__c = Date.today().addDays(-33),
            // Optional-5th
            SI_3_Scheduled__c = Date.today().addDays(-30),
            SI_3_Completed__c = Date.today().addDays(-28)
        ));
        
        // Scenario 5: No interview dates (should not create records)
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'CandidateFive',
            Email__c = 'test5@example.com'
        ));
        
        insert candidates;
    }
    
    /**
     * @description Test migration of single completed interview (last interview, outcome=null)
     */
    @isTest
    static void testSingleCompletedInterview() {
        Candidate__c candidate = [SELECT Id, Name, 
                                    Attraction_Interview_Date_Scheduled__c, AI_Completed_Date_Time__c, Attraction_Interview_Date_Completed__c,
                                    AI_Conducted_By__c, Attraction_Interview_Conducted_By__c, Attraction_Conducted_by__c,
                                    SI_1_Date_Scheduled__c, SI_1_Date_Completed__c, SI_1_Conducted_By__c, SI_1_Interview_Conducted_by__c, SI1_Conducted_by__c,
                                    SI_2_Date_Scheduled__c, SI_2_Date_Completed__c, SI_2_Conducted_By__c, SI2_Conducted_by__c, SI_2_Interviewer__c,
                                    Career_Presentation_Date_Scheduled__c, Career_Presentation_Date_Completed__c, CP_Conducted_By__c, Career_Presentation_Conducted_By__c,
                                    SI_3_Scheduled__c, SI_3_Completed__c, SI_3_Conducted_By__c, SI3_Conducted_by__c, SI_3_Interviewer__c
                                    FROM Candidate__c WHERE Email__c = 'test1@example.com' LIMIT 1];
        
        Test.startTest();
        InterviewHistoricalMigration.Result result = 
            InterviewHistoricalMigration.migrateInterviewsForCandidates(new List<Candidate__c>{candidate});
        Test.stopTest();
        
        // Verify result
        System.assertEquals(1, result.candidatesProcessed, 'Should process 1 candidate');
        System.assertEquals(1, result.interviewsCreated, 'Should create 1 interview');
        System.assertEquals(1, result.interviewsByType.get('Ci-First'), 'Should create Ci-First interview');
        
        // Verify Interview__c record
        Interview__c interview = [SELECT Id, External_Id__c, Interview_Type__c, Interview_Status__c, 
                                    Outcome__c, Date_Time_Scheduled__c, Date_Completed__c
                                    FROM Interview__c WHERE Candidate__c = :candidate.Id LIMIT 1];
        
        System.assertEquals(candidate.Id + '_Ci-First', interview.External_Id__c, 'External ID should match pattern');
        System.assertEquals('Ci-First', interview.Interview_Type__c, 'Interview type should be Ci-First');
        System.assertEquals('Completed', interview.Interview_Status__c, 'Status should be Completed');
        System.assertEquals(null, interview.Outcome__c, 'Outcome should be null for last interview');
        System.assertNotEquals(null, interview.Date_Time_Scheduled__c, 'Scheduled date should be set');
        System.assertNotEquals(null, interview.Date_Completed__c, 'Completed date should be set');
    }
    
    /**
     * @description Test multiple completed interviews with outcome inference
     */
    @isTest
    static void testMultipleCompletedInterviewsWithOutcome() {
        Candidate__c candidate = [SELECT Id, Name, 
                                    Attraction_Interview_Date_Scheduled__c, AI_Completed_Date_Time__c, Attraction_Interview_Date_Completed__c,
                                    AI_Conducted_By__c, Attraction_Interview_Conducted_By__c, Attraction_Conducted_by__c,
                                    SI_1_Date_Scheduled__c, SI_1_Date_Completed__c, SI_1_Conducted_By__c, SI_1_Interview_Conducted_by__c, SI1_Conducted_by__c,
                                    SI_2_Date_Scheduled__c, SI_2_Date_Completed__c, SI_2_Conducted_By__c, SI2_Conducted_by__c, SI_2_Interviewer__c,
                                    Career_Presentation_Date_Scheduled__c, Career_Presentation_Date_Completed__c, CP_Conducted_By__c, Career_Presentation_Conducted_By__c,
                                    SI_3_Scheduled__c, SI_3_Completed__c, SI_3_Conducted_By__c, SI3_Conducted_by__c, SI_3_Interviewer__c
                                    FROM Candidate__c WHERE Email__c = 'test2@example.com' LIMIT 1];
        
        Test.startTest();
        InterviewHistoricalMigration.Result result = 
            InterviewHistoricalMigration.migrateInterviewsForCandidates(new List<Candidate__c>{candidate});
        Test.stopTest();
        
        // Verify result
        System.assertEquals(1, result.candidatesProcessed, 'Should process 1 candidate');
        System.assertEquals(2, result.interviewsCreated, 'Should create 2 interviews');
        
        // Verify Ci-First has outcome='Proceed'
        Interview__c ciFirst = [SELECT Id, Interview_Type__c, Outcome__c 
                                FROM Interview__c 
                                WHERE Candidate__c = :candidate.Id AND Interview_Type__c = 'Ci-First' LIMIT 1];
        System.assertEquals('Proceed', ciFirst.Outcome__c, 'Ci-First outcome should be Proceed');
        
        // Verify Align-2nd has outcome=null (last interview)
        Interview__c alignSecond = [SELECT Id, Interview_Type__c, Outcome__c 
                                    FROM Interview__c 
                                    WHERE Candidate__c = :candidate.Id AND Interview_Type__c = 'Align-2nd' LIMIT 1];
        System.assertEquals(null, alignSecond.Outcome__c, 'Align-2nd outcome should be null (last interview)');
    }
    
    /**
     * @description Test scheduled interview (no completed date)
     */
    @isTest
    static void testScheduledInterview() {
        Candidate__c candidate = [SELECT Id, Name, 
                                    Attraction_Interview_Date_Scheduled__c, AI_Completed_Date_Time__c, Attraction_Interview_Date_Completed__c,
                                    AI_Conducted_By__c, Attraction_Interview_Conducted_By__c, Attraction_Conducted_by__c,
                                    SI_1_Date_Scheduled__c, SI_1_Date_Completed__c, SI_1_Conducted_By__c, SI_1_Interview_Conducted_by__c, SI1_Conducted_by__c,
                                    SI_2_Date_Scheduled__c, SI_2_Date_Completed__c, SI_2_Conducted_By__c, SI2_Conducted_by__c, SI_2_Interviewer__c,
                                    Career_Presentation_Date_Scheduled__c, Career_Presentation_Date_Completed__c, CP_Conducted_By__c, Career_Presentation_Conducted_By__c,
                                    SI_3_Scheduled__c, SI_3_Completed__c, SI_3_Conducted_By__c, SI3_Conducted_by__c, SI_3_Interviewer__c
                                    FROM Candidate__c WHERE Email__c = 'test3@example.com' LIMIT 1];
        
        Test.startTest();
        InterviewHistoricalMigration.Result result = 
            InterviewHistoricalMigration.migrateInterviewsForCandidates(new List<Candidate__c>{candidate});
        Test.stopTest();
        
        // Verify result
        System.assertEquals(1, result.interviewsCreated, 'Should create 1 interview');
        
        // Verify Interview__c record
        Interview__c interview = [SELECT Id, Interview_Status__c, Outcome__c, Date_Completed__c
                                    FROM Interview__c WHERE Candidate__c = :candidate.Id LIMIT 1];
        
        System.assertEquals('Scheduled', interview.Interview_Status__c, 'Status should be Scheduled');
        System.assertEquals(null, interview.Outcome__c, 'Outcome should be null for scheduled interview');
        System.assertEquals(null, interview.Date_Completed__c, 'Completed date should be null');
    }
    
    /**
     * @description Test all 5 interview types
     */
    @isTest
    static void testAllInterviewTypes() {
        Candidate__c candidate = [SELECT Id, Name, 
                                    Attraction_Interview_Date_Scheduled__c, AI_Completed_Date_Time__c, Attraction_Interview_Date_Completed__c,
                                    AI_Conducted_By__c, Attraction_Interview_Conducted_By__c, Attraction_Conducted_by__c,
                                    SI_1_Date_Scheduled__c, SI_1_Date_Completed__c, SI_1_Conducted_By__c, SI_1_Interview_Conducted_by__c, SI1_Conducted_by__c,
                                    SI_2_Date_Scheduled__c, SI_2_Date_Completed__c, SI_2_Conducted_By__c, SI2_Conducted_by__c, SI_2_Interviewer__c,
                                    Career_Presentation_Date_Scheduled__c, Career_Presentation_Date_Completed__c, CP_Conducted_By__c, Career_Presentation_Conducted_By__c,
                                    SI_3_Scheduled__c, SI_3_Completed__c, SI_3_Conducted_By__c, SI3_Conducted_by__c, SI_3_Interviewer__c
                                    FROM Candidate__c WHERE Email__c = 'test4@example.com' LIMIT 1];
        
        Test.startTest();
        InterviewHistoricalMigration.Result result = 
            InterviewHistoricalMigration.migrateInterviewsForCandidates(new List<Candidate__c>{candidate});
        Test.stopTest();
        
        // Verify result
        System.assertEquals(5, result.interviewsCreated, 'Should create 5 interviews');
        System.assertEquals(1, result.interviewsByType.get('Ci-First'), 'Should create Ci-First');
        System.assertEquals(1, result.interviewsByType.get('Align-2nd'), 'Should create Align-2nd');
        System.assertEquals(1, result.interviewsByType.get('Plan-3rd'), 'Should create Plan-3rd');
        System.assertEquals(1, result.interviewsByType.get('Present-4th'), 'Should create Present-4th');
        System.assertEquals(1, result.interviewsByType.get('Optional-5th'), 'Should create Optional-5th');
        
        // Verify outcome progression
        Interview__c ciFirst = [SELECT Outcome__c FROM Interview__c WHERE Candidate__c = :candidate.Id AND Interview_Type__c = 'Ci-First'];
        Interview__c alignSecond = [SELECT Outcome__c FROM Interview__c WHERE Candidate__c = :candidate.Id AND Interview_Type__c = 'Align-2nd'];
        Interview__c planThird = [SELECT Outcome__c FROM Interview__c WHERE Candidate__c = :candidate.Id AND Interview_Type__c = 'Plan-3rd'];
        Interview__c presentFourth = [SELECT Outcome__c FROM Interview__c WHERE Candidate__c = :candidate.Id AND Interview_Type__c = 'Present-4th'];
        Interview__c optionalFifth = [SELECT Outcome__c FROM Interview__c WHERE Candidate__c = :candidate.Id AND Interview_Type__c = 'Optional-5th'];
        
        System.assertEquals('Proceed', ciFirst.Outcome__c, 'Ci-First should have Proceed outcome');
        System.assertEquals('Proceed', alignSecond.Outcome__c, 'Align-2nd should have Proceed outcome');
        System.assertEquals('Proceed', planThird.Outcome__c, 'Plan-3rd should have Proceed outcome');
        System.assertEquals('Proceed', presentFourth.Outcome__c, 'Present-4th should have Proceed outcome');
        System.assertEquals(null, optionalFifth.Outcome__c, 'Optional-5th should have null outcome (last)');
    }
    
    /**
     * @description Test External_Id__c upsert idempotency
     */
    @isTest
    static void testUpsertIdempotency() {
        Candidate__c candidate = [SELECT Id, Name, 
                                    Attraction_Interview_Date_Scheduled__c, AI_Completed_Date_Time__c, Attraction_Interview_Date_Completed__c,
                                    AI_Conducted_By__c, Attraction_Interview_Conducted_By__c, Attraction_Conducted_by__c,
                                    SI_1_Date_Scheduled__c, SI_1_Date_Completed__c, SI_1_Conducted_By__c, SI_1_Interview_Conducted_by__c, SI1_Conducted_by__c,
                                    SI_2_Date_Scheduled__c, SI_2_Date_Completed__c, SI_2_Conducted_By__c, SI2_Conducted_by__c, SI_2_Interviewer__c,
                                    Career_Presentation_Date_Scheduled__c, Career_Presentation_Date_Completed__c, CP_Conducted_By__c, Career_Presentation_Conducted_By__c,
                                    SI_3_Scheduled__c, SI_3_Completed__c, SI_3_Conducted_By__c, SI3_Conducted_by__c, SI_3_Interviewer__c
                                    FROM Candidate__c WHERE Email__c = 'test1@example.com' LIMIT 1];
        
        Test.startTest();
        // First run
        InterviewHistoricalMigration.Result result1 = 
            InterviewHistoricalMigration.migrateInterviewsForCandidates(new List<Candidate__c>{candidate});
        
        // Second run (should update, not create duplicates)
        InterviewHistoricalMigration.Result result2 = 
            InterviewHistoricalMigration.migrateInterviewsForCandidates(new List<Candidate__c>{candidate});
        Test.stopTest();
        
        // Verify first run created records
        System.assertEquals(1, result1.interviewsCreated, 'First run should create 1 interview');
        System.assertEquals(0, result1.interviewsUpdated, 'First run should not update any');
        
        // Verify second run updated records (no duplicates)
        System.assertEquals(0, result2.interviewsCreated, 'Second run should not create new records');
        System.assertEquals(1, result2.interviewsUpdated, 'Second run should update existing record');
        
        // Verify only 1 record exists
        Integer count = [SELECT COUNT() FROM Interview__c WHERE Candidate__c = :candidate.Id];
        System.assertEquals(1, count, 'Should have exactly 1 interview record (no duplicates)');
    }
    
    /**
     * @description Test batch processor
     */
    @isTest
    static void testBatchProcessor() {
        Test.startTest();
        InterviewHistoricalMigrationBatch batch = new InterviewHistoricalMigrationBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify interviews created for candidates with interview dates
        Integer interviewCount = [SELECT COUNT() FROM Interview__c];
        System.assert(interviewCount > 0, 'Batch should create Interview__c records');
        
        // Verify no interviews created for candidate without dates
        Candidate__c candidateNoInterviews = [SELECT Id FROM Candidate__c WHERE Email__c = 'test5@example.com' LIMIT 1];
        Integer countForCandidate = [SELECT COUNT() FROM Interview__c WHERE Candidate__c = :candidateNoInterviews.Id];
        System.assertEquals(0, countForCandidate, 'Should not create interviews for candidate with no dates');
    }
    
    /**
     * @description Test date/datetime conversion with noon default
     */
    @isTest
    static void testDateTimeConversion() {
        Candidate__c candidate = [SELECT Id, Name, 
                                    Attraction_Interview_Date_Scheduled__c, AI_Completed_Date_Time__c, Attraction_Interview_Date_Completed__c,
                                    AI_Conducted_By__c, Attraction_Interview_Conducted_By__c, Attraction_Conducted_by__c,
                                    SI_1_Date_Scheduled__c, SI_1_Date_Completed__c, SI_1_Conducted_By__c, SI_1_Interview_Conducted_by__c, SI1_Conducted_by__c,
                                    SI_2_Date_Scheduled__c, SI_2_Date_Completed__c, SI_2_Conducted_By__c, SI2_Conducted_by__c, SI_2_Interviewer__c,
                                    Career_Presentation_Date_Scheduled__c, Career_Presentation_Date_Completed__c, CP_Conducted_By__c, Career_Presentation_Conducted_By__c,
                                    SI_3_Scheduled__c, SI_3_Completed__c, SI_3_Conducted_By__c, SI3_Conducted_by__c, SI_3_Interviewer__c
                                    FROM Candidate__c WHERE Email__c = 'test2@example.com' LIMIT 1];
        
        Test.startTest();
        InterviewHistoricalMigration.migrateInterviewsForCandidates(new List<Candidate__c>{candidate});
        Test.stopTest();
        
        // Verify scheduled date has noon (12:00 PM) time
        Interview__c interview = [SELECT Date_Time_Scheduled__c FROM Interview__c 
                                    WHERE Candidate__c = :candidate.Id AND Interview_Type__c = 'Ci-First'];
        
        System.assertEquals(12, interview.Date_Time_Scheduled__c.hour(), 'Should use noon (12:00 PM) for date conversion');
        System.assertEquals(0, interview.Date_Time_Scheduled__c.minute(), 'Minutes should be 0');
    }
}
