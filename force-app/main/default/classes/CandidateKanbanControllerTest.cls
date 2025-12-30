/**
 * @description Test class for CandidateKanbanController
 */
@isTest
private class CandidateKanbanControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test candidates at various stages
        List<Candidate__c> candidates = new List<Candidate__c>();
        
        // Prequal stage
        candidates.add(new Candidate__c(
            First_Name__c = 'Prequal',
            Last_Name__c = 'Candidate',
            Email__c = 'prequal@kanban.com',
            Status__c = 'Active/In Process',
            Highest_Level_Achieved__c = '0-Prequal'
        ));
        
        // Ci_1st stage
        candidates.add(new Candidate__c(
            First_Name__c = 'Ci',
            Last_Name__c = 'Candidate',
            Email__c = 'ci@kanban.com',
            Status__c = 'Active/In Process',
            Highest_Level_Achieved__c = 'Ci_1st'
        ));
        
        // Align stage
        candidates.add(new Candidate__c(
            First_Name__c = 'Align',
            Last_Name__c = 'Candidate',
            Email__c = 'align@kanban.com',
            Status__c = 'Active/In Process',
            Highest_Level_Achieved__c = 'Align (2nd)'
        ));
        
        // Closed Lost candidate (should not appear in kanban)
        candidates.add(new Candidate__c(
            First_Name__c = 'Closed',
            Last_Name__c = 'Candidate',
            Email__c = 'closed@kanban.com',
            Status__c = 'Closed Lost',
            Highest_Level_Achieved__c = 'Ci_1st'
        ));
        
        // Contracted candidate (should not appear in kanban)
        candidates.add(new Candidate__c(
            First_Name__c = 'Contracted',
            Last_Name__c = 'Candidate',
            Email__c = 'contracted@kanban.com',
            Status__c = 'Active/In Process',
            Highest_Level_Achieved__c = '7-Contracted'
        ));
        
        insert candidates;
        
        // Create interview for one candidate
        Candidate__c ciCandidate = [SELECT Id FROM Candidate__c WHERE Email__c = 'ci@kanban.com' LIMIT 1];
        Interview__c interview = new Interview__c(
            Candidate__c = ciCandidate.Id,
            Interview_Type__c = 'Ci-First',
            Interview_Status__c = 'Scheduled',
            Date_Time_Scheduled__c = System.now().addDays(1)
        );
        insert interview;
        
        // Create ALC for one candidate
        Candidate__c alignCandidate = [SELECT Id FROM Candidate__c WHERE Email__c = 'align@kanban.com' LIMIT 1];
        ALC__c alc = new ALC__c(
            Candidate__c = alignCandidate.Id,
            Stage__c = 'Initial Form Sent'
        );
        insert alc;
    }
    
    @isTest
    static void testGetKanbanData_Success() {
        Test.startTest();
        CandidateKanbanController.KanbanData result = CandidateKanbanController.getKanbanData();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.stages, 'Stages should not be null');
        System.assertNotEquals(null, result.candidatesByStage, 'Candidates by stage should not be null');
        System.assertEquals(7, result.stages.size(), 'Should have 7 stages');
    }
    
    @isTest
    static void testGetKanbanData_ExcludesClosedLost() {
        Test.startTest();
        CandidateKanbanController.KanbanData result = CandidateKanbanController.getKanbanData();
        Test.stopTest();
        
        // Count all candidates across all stages
        Integer totalCandidates = 0;
        for (String stage : result.candidatesByStage.keySet()) {
            totalCandidates += result.candidatesByStage.get(stage).size();
        }
        
        // Should have 3 active candidates (excluding Closed Lost and Contracted)
        System.assertEquals(3, totalCandidates, 'Should only include active candidates in pipeline');
    }
    
    @isTest
    static void testGetKanbanData_StageDistribution() {
        Test.startTest();
        CandidateKanbanController.KanbanData result = CandidateKanbanController.getKanbanData();
        Test.stopTest();
        
        // Verify candidates are in correct stages
        System.assertEquals(1, result.candidatesByStage.get('0-Prequal').size(), 'Should have 1 in Prequal');
        System.assertEquals(1, result.candidatesByStage.get('Ci_1st').size(), 'Should have 1 in Ci_1st');
        System.assertEquals(1, result.candidatesByStage.get('Align (2nd)').size(), 'Should have 1 in Align');
    }
    
    @isTest
    static void testGetKanbanData_StageCounts() {
        Test.startTest();
        CandidateKanbanController.KanbanData result = CandidateKanbanController.getKanbanData();
        Test.stopTest();
        
        // Verify stage counts are populated
        for (CandidateKanbanController.StageInfo stage : result.stages) {
            System.assertNotEquals(null, stage.count, 'Stage count should not be null for ' + stage.label);
            
            if (stage.value == '0-Prequal') {
                System.assertEquals(1, stage.count, 'Prequal count should be 1');
            } else if (stage.value == 'Ci_1st') {
                System.assertEquals(1, stage.count, 'Ci_1st count should be 1');
            } else if (stage.value == 'Align (2nd)') {
                System.assertEquals(1, stage.count, 'Align count should be 1');
            }
        }
    }
    
    @isTest
    static void testGetKanbanData_WithInterviewData() {
        Test.startTest();
        CandidateKanbanController.KanbanData result = CandidateKanbanController.getKanbanData();
        Test.stopTest();
        
        // Find the Ci_1st candidate (has interview)
        List<CandidateKanbanController.CandidateCard> ciCandidates = result.candidatesByStage.get('Ci_1st');
        System.assertEquals(1, ciCandidates.size(), 'Should have 1 Ci candidate');
        
        CandidateKanbanController.CandidateCard card = ciCandidates[0];
        System.assertEquals('Ci-First', card.interviewStage, 'Should have interview stage');
        System.assertEquals('Scheduled', card.interviewStatus, 'Should have interview status');
    }
    
    @isTest
    static void testGetKanbanData_WithALCData() {
        Test.startTest();
        CandidateKanbanController.KanbanData result = CandidateKanbanController.getKanbanData();
        Test.stopTest();
        
        // Find the Align candidate (has ALC)
        List<CandidateKanbanController.CandidateCard> alignCandidates = result.candidatesByStage.get('Align (2nd)');
        System.assertEquals(1, alignCandidates.size(), 'Should have 1 Align candidate');
        
        CandidateKanbanController.CandidateCard card = alignCandidates[0];
        System.assertEquals(true, card.inContracting, 'Should be in contracting');
        System.assertEquals('Initial Form Sent', card.contractingStage, 'Should have contracting stage');
    }
    
    @isTest
    static void testUpdateCandidateStage_Success() {
        Candidate__c candidate = [SELECT Id, Highest_Level_Achieved__c FROM Candidate__c WHERE Email__c = 'prequal@kanban.com' LIMIT 1];
        
        Test.startTest();
        String result = CandidateKanbanController.updateCandidateStage(candidate.Id, 'Ci_1st');
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Update should be successful');
        
        // Verify stage was updated
        Candidate__c updated = [SELECT Highest_Level_Achieved__c FROM Candidate__c WHERE Id = :candidate.Id];
        System.assertEquals('Ci_1st', updated.Highest_Level_Achieved__c, 'Stage should be updated');
    }
    
    @isTest
    static void testUpdateCandidateStage_InvalidId() {
        Id fakeId = '001000000000000AAA';
        
        Test.startTest();
        try {
            String result = CandidateKanbanController.updateCandidateStage(fakeId, 'Ci_1st');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error'), 'Exception message should indicate error');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetKanbanData_NoData() {
        // Delete all test candidates
        delete [SELECT Id FROM Candidate__c WHERE Email__c LIKE '%@kanban.com'];
        
        Test.startTest();
        CandidateKanbanController.KanbanData result = CandidateKanbanController.getKanbanData();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(7, result.stages.size(), 'Should have 7 stages even with no data');
        
        // All stages should have 0 count
        for (CandidateKanbanController.StageInfo stage : result.stages) {
            System.assertEquals(0, stage.count, 'Stage count should be 0 with no data');
        }
    }
}
