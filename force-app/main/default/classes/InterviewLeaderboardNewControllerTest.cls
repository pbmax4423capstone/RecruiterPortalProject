@isTest
private class InterviewLeaderboardNewControllerTest {
    
    @testSetup
    static void setup() {
        // Use sales manager names from Interviewer_s__c picklist
        String testInterviewer1 = 'Tim Denton';
        String testInterviewer2 = 'Bradley Sofonia';
        
        // Create test candidate
        Candidate__c candidate = new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Candidate',
            Email__c = 'testcandidate@test.com',
            Status__c = 'Active/In Process'
        );
        insert candidate;
        
        // Create interviews for this month with different types
        List<Interview__c> interviews = new List<Interview__c>();
        
        // Interviewer 1: 25 CI-First (SI1)
        for (Integer i = 0; i < 25; i++) {
            interviews.add(new Interview__c(
                Candidate__c = candidate.Id,
                Interviewer_s__c = testInterviewer1,
                Interview_Type__c = 'SI1',
                Interview_Status__c = 'Scheduled',
                Date_Time_Scheduled__c = DateTime.now().addDays(i)
            ));
        }
        
        // Interviewer 1: 15 additional SI1 for total of 40
        for (Integer i = 0; i < 15; i++) {
            interviews.add(new Interview__c(
                Candidate__c = candidate.Id,
                Interviewer_s__c = testInterviewer1,
                Interview_Type__c = 'SI1',
                Interview_Status__c = 'Scheduled',
                Date_Time_Scheduled__c = DateTime.now().addDays(i + 25)
            ));
        }
        
        // Interviewer 2: 9 Align-2nd (SI2)
        for (Integer i = 0; i < 9; i++) {
            interviews.add(new Interview__c(
                Candidate__c = candidate.Id,
                Interviewer_s__c = testInterviewer2,
                Interview_Type__c = 'SI2',
                Interview_Status__c = 'Scheduled',
                Date_Time_Scheduled__c = DateTime.now().addDays(i)
            ));
        }
        
        // Interviewer 2: 4 more SI2 for total of 13
        for (Integer i = 0; i < 4; i++) {
            interviews.add(new Interview__c(
                Candidate__c = candidate.Id,
                Interviewer_s__c = testInterviewer2,
                Interview_Type__c = 'SI2',
                Interview_Status__c = 'Scheduled',
                Date_Time_Scheduled__c = DateTime.now().addDays(i + 9)
            ));
        }
        
        // Interviewer 1: 5 Plan-3rd (SI3)
        for (Integer i = 0; i < 5; i++) {
            interviews.add(new Interview__c(
                Candidate__c = candidate.Id,
                Interviewer_s__c = testInterviewer1,
                Interview_Type__c = 'SI3',
                Interview_Status__c = 'Scheduled',
                Date_Time_Scheduled__c = DateTime.now().addDays(i)
            ));
        }
        
        // Interviewer 2: 1 Present-4th (Career)
        interviews.add(new Interview__c(
            Candidate__c = candidate.Id,
            Interviewer_s__c = testInterviewer2,
            Interview_Type__c = 'Career',
            Interview_Status__c = 'Scheduled',
            Date_Time_Scheduled__c = DateTime.now().addDays(1)
        ));
        
        // Unassigned interviews (no Interviewer_s__c)
        for (Integer i = 0; i < 2; i++) {
            interviews.add(new Interview__c(
                Candidate__c = candidate.Id,
                Interviewer_s__c = null,
                Interview_Type__c = 'SI1',
                Interview_Status__c = 'Scheduled',
                Date_Time_Scheduled__c = DateTime.now().addDays(i)
            ));
        }
        
        insert interviews;
    }
    
    @isTest
    static void testGetCurrentMonthLeaderboard() {
        Test.startTest();
        List<InterviewLeaderboardNewController.LeaderboardEntry> results = 
            InterviewLeaderboardNewController.getCurrentMonthLeaderboard();
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() >= 2, 'Should have at least 2 entries (2 users + possibly unassigned)');
        
        // Find top entry (should have most interviews)
        InterviewLeaderboardNewController.LeaderboardEntry topUser = results[0];
        System.assert(topUser.totalInterviews > 0, 'Top user should have interviews');
        
        // Verify counts are accurate
        Integer expectedTotal = topUser.ciFirstCount + topUser.alignSecondCount + 
                               topUser.planThirdCount + topUser.presentFourthCount + 
                               topUser.optionalFifthCount;
        System.assertEquals(expectedTotal, topUser.totalInterviews, 'Total should match sum of interview types');
        System.assertEquals(expectedTotal, topUser.interviewsThisMonth, 'Month total should match total');
    }
    
    @isTest
    static void testLeaderboardBreakdown() {
        Test.startTest();
        List<InterviewLeaderboardNewController.LeaderboardEntry> results = 
            InterviewLeaderboardNewController.getCurrentMonthLeaderboard();
        Test.stopTest();
        
        // Verify results exist and basic structure
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should have at least one entry');
        
        // Verify top entry has interviews
        InterviewLeaderboardNewController.LeaderboardEntry topEntry = results[0];
        System.assert(topEntry.totalInterviews > 0, 'Top user should have interviews');
        System.assert(topEntry.ciFirstCount >= 0, 'CI-First count should be non-negative');
        
        // Verify total equals sum of categories
        Integer calculatedTotal = topEntry.ciFirstCount + topEntry.alignSecondCount + 
                                 topEntry.planThirdCount + topEntry.presentFourthCount + 
                                 topEntry.optionalFifthCount;
        System.assertEquals(calculatedTotal, topEntry.totalInterviews, 'Total should equal sum of categories');
    }
    
    @isTest
    static void testLeaderboardSorting() {
        Test.startTest();
        List<InterviewLeaderboardNewController.LeaderboardEntry> results = 
            InterviewLeaderboardNewController.getCurrentMonthLeaderboard();
        Test.stopTest();
        
        // Verify sorted by total descending
        for (Integer i = 0; i < results.size() - 1; i++) {
            System.assert(
                results[i].totalInterviews >= results[i+1].totalInterviews,
                'Results should be sorted by total interviews descending'
            );
        }
    }
    
    @isTest
    static void testEmptyLeaderboard() {
        // Delete only test interviews (related to test candidate)
        Candidate__c candidate = [SELECT Id FROM Candidate__c WHERE Email__c = 'testcandidate@test.com' LIMIT 1];
        delete [SELECT Id FROM Interview__c WHERE Candidate__c = :candidate.Id];
        
        Test.startTest();
        List<InterviewLeaderboardNewController.LeaderboardEntry> results = 
            InterviewLeaderboardNewController.getCurrentMonthLeaderboard();
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(0, results.size(), 'Should have no entries when no interviews exist');
    }
    
    @isTest
    static void testOnlyUnassignedInterviews() {
        // Get test candidate
        Candidate__c candidate = [SELECT Id FROM Candidate__c WHERE Email__c = 'testcandidate@test.com' LIMIT 1];
        
        // Delete only test interviews (related to test candidate) and create only unassigned ones
        delete [SELECT Id FROM Interview__c WHERE Candidate__c = :candidate.Id];
        
        List<Interview__c> unassignedInterviews = new List<Interview__c>();
        for (Integer i = 0; i < 5; i++) {
            unassignedInterviews.add(new Interview__c(
                Candidate__c = candidate.Id,
                Interviewer_s__c = null,
                Interview_Type__c = 'SI1',
                Interview_Status__c = 'Scheduled',
                Date_Time_Scheduled__c = DateTime.now().addDays(i)
            ));
        }
        insert unassignedInterviews;
        
        Test.startTest();
        List<InterviewLeaderboardNewController.LeaderboardEntry> results = 
            InterviewLeaderboardNewController.getCurrentMonthLeaderboard();
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should have 1 entry for unassigned');
        System.assertEquals('Unassigned', results[0].userName, 'Entry should be for unassigned');
        System.assertEquals(5, results[0].unassignedCount, 'Should have 5 unassigned interviews');
    }
    
    @isTest
    static void testGetThisWeekInterviews() {
        // Create interviews for this week
        Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];
        List<Interview__c> weeklyInterviews = new List<Interview__c>();
        for (Integer i = 0; i < 10; i++) {
            weeklyInterviews.add(new Interview__c(
                Candidate__c = candidate.Id,
                Interviewer_s__c = 'Tim Denton',
                Interview_Type__c = 'SI1',
                Interview_Status__c = 'Scheduled',
                Date_Time_Scheduled__c = DateTime.now()
            ));
        }
        insert weeklyInterviews;
        
        Test.startTest();
        List<InterviewLeaderboardNewController.InterviewDetail> results = 
            InterviewLeaderboardNewController.getThisWeekInterviews();
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() >= 10, 'Should have at least 10 interviews');
        
        // Verify structure
        if (results.size() > 0) {
            System.assertNotEquals(null, results[0].id, 'Interview ID should be populated');
            System.assertNotEquals(null, results[0].candidateName, 'Candidate name should be populated');
            System.assertNotEquals(null, results[0].interviewType, 'Interview type should be populated');
            System.assertNotEquals(null, results[0].formattedDate, 'Formatted date should be populated');
        }
    }
    
    @isTest
    static void testGetThisMonthInterviews() {
        Test.startTest();
        List<InterviewLeaderboardNewController.InterviewDetail> results = 
            InterviewLeaderboardNewController.getThisMonthInterviews();
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        // Should have interviews from setup
        System.assert(results.size() > 0, 'Should have interviews this month');
        
        // Verify sorting (DESC by date, then ASC by name)
        if (results.size() > 1) {
            DateTime previousDate = results[0].scheduledDate;
            for (Integer i = 1; i < results.size(); i++) {
                DateTime currentDate = results[i].scheduledDate;
                System.assert(
                    previousDate >= currentDate,
                    'Interviews should be sorted by date descending'
                );
                previousDate = currentDate;
            }
        }
    }
    
    @isTest
    static void testGetInterviewsByTypeSI1() {
        Test.startTest();
        List<InterviewLeaderboardNewController.InterviewDetail> results = 
            InterviewLeaderboardNewController.getInterviewsByType('SI1');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should have SI1 interviews');
        
        // Verify all are SI1
        for (InterviewLeaderboardNewController.InterviewDetail detail : results) {
            System.assertEquals('SI1', detail.interviewType, 'All should be SI1 type');
        }
    }
    
    @isTest
    static void testGetInterviewsByTypeSI2() {
        Test.startTest();
        List<InterviewLeaderboardNewController.InterviewDetail> results = 
            InterviewLeaderboardNewController.getInterviewsByType('SI2');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        // Should have SI2 interviews from setup
        System.assert(results.size() > 0, 'Should have SI2 interviews');
        
        // Verify all are SI2
        for (InterviewLeaderboardNewController.InterviewDetail detail : results) {
            System.assertEquals('SI2', detail.interviewType, 'All should be SI2 type');
        }
    }
    
    @isTest
    static void testGetInterviewsByTypeSI3() {
        Test.startTest();
        List<InterviewLeaderboardNewController.InterviewDetail> results = 
            InterviewLeaderboardNewController.getInterviewsByType('SI3');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        // Should have SI3 interviews from setup
        System.assert(results.size() > 0, 'Should have SI3 interviews');
    }
    
    @isTest
    static void testGetInterviewsByTypeCareer() {
        Test.startTest();
        List<InterviewLeaderboardNewController.InterviewDetail> results = 
            InterviewLeaderboardNewController.getInterviewsByType('Career');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        // Should have Career interview from setup
        System.assert(results.size() > 0, 'Should have Career interviews');
    }
    
    @isTest
    static void testGetInterviewsByTypeNoResults() {
        Test.startTest();
        List<InterviewLeaderboardNewController.InterviewDetail> results = 
            InterviewLeaderboardNewController.getInterviewsByType('NonExistentType');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(0, results.size(), 'Should have no interviews for invalid type');
    }
    
    @isTest
    static void testInterviewDetailWithUnassigned() {
        // Create interview with no interviewer
        Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];
        Interview__c unassigned = new Interview__c(
            Candidate__c = candidate.Id,
            Interviewer_s__c = null,
            Interview_Type__c = 'SI1',
            Interview_Status__c = 'Scheduled',
            Date_Time_Scheduled__c = DateTime.now()
        );
        insert unassigned;
        
        Test.startTest();
        List<InterviewLeaderboardNewController.InterviewDetail> results = 
            InterviewLeaderboardNewController.getThisMonthInterviews();
        Test.stopTest();
        
        // Find the unassigned interview
        Boolean foundUnassigned = false;
        for (InterviewLeaderboardNewController.InterviewDetail detail : results) {
            if (detail.id == unassigned.Id) {
                System.assertEquals('Unassigned', detail.interviewers, 'Should show Unassigned for null interviewer');
                foundUnassigned = true;
                break;
            }
        }
        System.assert(foundUnassigned, 'Should find the unassigned interview');
    }
}
