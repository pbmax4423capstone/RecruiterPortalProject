/**
 * @description Test class for CandidateFunnelController
 */
@isTest
private class CandidateFunnelControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test candidates at various stages
        List<Candidate__c> candidates = new List<Candidate__c>();
        
        // Prequal stage (5 candidates)
        for (Integer i = 0; i < 5; i++) {
            candidates.add(new Candidate__c(
                First_Name__c = 'Prequal',
                Last_Name__c = 'Candidate' + i,
                Email__c = 'prequal' + i + '@test.com',
                Status__c = 'Active/In Process',
                Highest_Level_Achieved__c = '0-Prequal'
            ));
        }
        
        // Ci_1st stage (3 candidates)
        for (Integer i = 0; i < 3; i++) {
            candidates.add(new Candidate__c(
                First_Name__c = 'Ci',
                Last_Name__c = 'Candidate' + i,
                Email__c = 'ci' + i + '@test.com',
                Status__c = 'Active/In Process',
                Highest_Level_Achieved__c = 'Ci_1st'
            ));
        }
        
        // Align stage (2 candidates)
        for (Integer i = 0; i < 2; i++) {
            candidates.add(new Candidate__c(
                First_Name__c = 'Align',
                Last_Name__c = 'Candidate' + i,
                Email__c = 'align' + i + '@test.com',
                Status__c = 'Active/In Process',
                Highest_Level_Achieved__c = 'Align (2nd)'
            ));
        }
        
        // Add a closed lost candidate (should not appear in funnel)
        candidates.add(new Candidate__c(
            First_Name__c = 'Closed',
            Last_Name__c = 'Candidate',
            Email__c = 'closed@test.com',
            Status__c = 'Closed Lost',
            Highest_Level_Achieved__c = 'Ci_1st'
        ));
        
        insert candidates;
        
        // Create some scheduled interviews
        Candidate__c ciCandidate = [SELECT Id FROM Candidate__c WHERE Email__c = 'ci0@test.com' LIMIT 1];
        
        List<Interview__c> interviews = new List<Interview__c>();
        interviews.add(new Interview__c(
            Candidate__c = ciCandidate.Id,
            Interview_Type__c = 'Ci-First',
            Interview_Status__c = 'Scheduled',
            Date_Time_Scheduled__c = System.now().addDays(1)
        ));
        interviews.add(new Interview__c(
            Candidate__c = ciCandidate.Id,
            Interview_Type__c = 'Align-2nd',
            Interview_Status__c = 'Scheduled',
            Date_Time_Scheduled__c = System.now().addDays(2)
        ));
        
        insert interviews;
    }
    
    @isTest
    static void testGetActiveFunnelData() {
        Test.startTest();
        CandidateFunnelController.FunnelData result = CandidateFunnelController.getActiveFunnelData();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.stages, 'Stages should not be null');
        System.assert(result.stages.size() > 0, 'Should have stages');
        System.assertEquals(10, result.totalCandidates, 'Should have 10 active candidates (excluding Closed Lost)');
    }
    
    @isTest
    static void testGetFunnelData_ActiveOnly() {
        Test.startTest();
        CandidateFunnelController.FunnelData result = CandidateFunnelController.getFunnelData(true);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(10, result.totalCandidates, 'Should have 10 active candidates');
        
        // Verify stages are populated
        Boolean foundPrequal = false;
        Boolean foundCi = false;
        Boolean foundAlign = false;
        
        for (CandidateFunnelController.FunnelStage stage : result.stages) {
            if (stage.value == '0-Prequal' && stage.count == 5) {
                foundPrequal = true;
            }
            if (stage.value == 'Ci_1st' && stage.count == 3) {
                foundCi = true;
            }
            if (stage.value == 'Align (2nd)' && stage.count == 2) {
                foundAlign = true;
            }
        }
        
        System.assert(foundPrequal, 'Should find Prequal stage with 5 candidates');
        System.assert(foundCi, 'Should find Ci stage with 3 candidates');
        System.assert(foundAlign, 'Should find Align stage with 2 candidates');
    }
    
    @isTest
    static void testGetFunnelData_AllCandidates() {
        Test.startTest();
        CandidateFunnelController.FunnelData result = CandidateFunnelController.getFunnelData(false);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        // Should still exclude Closed Lost, Not Interested, etc.
        System.assertEquals(10, result.totalCandidates, 'Should have 10 candidates (excluding Closed Lost)');
    }
    
    @isTest
    static void testGetFunnelData_WithScheduledInterviews() {
        Test.startTest();
        CandidateFunnelController.FunnelData result = CandidateFunnelController.getFunnelData(true);
        Test.stopTest();
        
        System.assertNotEquals(null, result.totalScheduledInterviews, 'Scheduled interviews should be counted');
        System.assertEquals(2, result.totalScheduledInterviews, 'Should have 2 scheduled interviews');
    }
    
    @isTest
    static void testGetFunnelData_ConversionRates() {
        Test.startTest();
        CandidateFunnelController.FunnelData result = CandidateFunnelController.getFunnelData(true);
        Test.stopTest();
        
        // First stage should always have 100% conversion
        System.assertEquals(100.0, result.stages[0].conversionRate, 'First stage should have 100% conversion');
        System.assertEquals(0, result.stages[0].dropOffCount, 'First stage should have 0 drop off');
        
        // Verify conversion calculations exist
        for (CandidateFunnelController.FunnelStage stage : result.stages) {
            System.assertNotEquals(null, stage.conversionRate, 'Conversion rate should not be null');
            System.assertNotEquals(null, stage.dropOffRate, 'Drop off rate should not be null');
            System.assertNotEquals(null, stage.percentOfTotal, 'Percent of total should not be null');
        }
    }
    
    @isTest
    static void testGetFunnelData_NullActiveOnly() {
        Test.startTest();
        CandidateFunnelController.FunnelData result = CandidateFunnelController.getFunnelData(null);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null even with null parameter');
    }
    
    @isTest
    static void testGetFunnelData_EmptyFunnel() {
        // Delete all test candidates
        delete [SELECT Id FROM Candidate__c WHERE Email__c LIKE '%@test.com'];
        
        Test.startTest();
        CandidateFunnelController.FunnelData result = CandidateFunnelController.getFunnelData(true);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.totalCandidates, 'Should have 0 candidates');
        System.assertNotEquals(null, result.stages, 'Stages should still be populated');
    }
}
