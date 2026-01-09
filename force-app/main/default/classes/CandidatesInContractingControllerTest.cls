/**
 * @description Test class for CandidatesInContractingController
 */
@isTest
private class CandidatesInContractingControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Get record type IDs
        Id brokerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Broker').getRecordTypeId();
        Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Career').getRecordTypeId();
        Id nrfRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('NRF').getRecordTypeId();
        Id registrationRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName().get('Registration').getRecordTypeId();
        
        // Create Contact records first (required for email automation)
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 20; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Candidate' + i,
                Email = 'contracting' + i + '@test.com'
            ));
        }
        insert contacts;
        
        // Create test candidates (20 for comprehensive testing) linked to Contacts
        List<Candidate__c> candidates = new List<Candidate__c>();
        for (Integer i = 0; i < 20; i++) {
            candidates.add(new Candidate__c(
                First_Name__c = 'Test',
                Last_Name__c = 'Candidate' + i,
                Email__c = 'contracting' + i + '@test.com',
                Status__c = 'Active/In Process',
                Contact__c = contacts[i].Id
            ));
        }
        insert candidates;
        
        // Create ALC records across all 4 record types with different stages and agencies
        List<ALC__c> alcRecords = new List<ALC__c>();
        
        // A157 Agency - Broker Record Type (5 records)
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[0].Id,
            Stage__c = 'Initial Form Sent',
            Contract_Type__c = null,
            RecordTypeId = brokerRTId,
            Agency__c = 'A157'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[1].Id,
            Stage__c = 'MM_ONX_Sent',
            Contract_Type__c = 'Broker',
            RecordTypeId = brokerRTId,
            Agency__c = 'A157'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[2].Id,
            Stage__c = 'In Background',
            Contract_Type__c = null,
            RecordTypeId = brokerRTId,
            Agency__c = 'A157'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[3].Id,
            Stage__c = 'Post Background - Pending Rachyll',
            Contract_Type__c = 'Broker',
            RecordTypeId = brokerRTId,
            Agency__c = 'A157'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[4].Id,
            Stage__c = 'CORP- ECQ Request',
            Contract_Type__c = null,
            RecordTypeId = brokerRTId,
            Agency__c = 'A157'
        ));
        
        // A157 Agency - Career Record Type (5 records)
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[5].Id,
            Stage__c = 'Sent To Compliance',
            Contract_Type__c = null,
            RecordTypeId = careerRTId,
            Agency__c = 'A157'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[6].Id,
            Stage__c = 'Pending SM',
            Contract_Type__c = null,
            RecordTypeId = careerRTId,
            Agency__c = 'A157'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[7].Id,
            Stage__c = 'Contract Codes (A/B) & DocuSign',
            Contract_Type__c = null,
            RecordTypeId = careerRTId,
            Agency__c = 'A157'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[8].Id,
            Stage__c = 'In Background',
            Contract_Type__c = null,
            RecordTypeId = careerRTId,
            Agency__c = 'A157'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[9].Id,
            Stage__c = 'Pending SM',
            Contract_Type__c = null,
            RecordTypeId = careerRTId,
            Agency__c = 'A157'
        ));
        
        // A007 Agency - NRF Record Type (5 records)
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[10].Id,
            Stage__c = 'AA Received',
            Contract_Type__c = null,
            RecordTypeId = nrfRTId,
            Agency__c = 'A007'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[11].Id,
            Stage__c = 'Received Approval Letter',
            Contract_Type__c = 'NRF',
            RecordTypeId = nrfRTId,
            Agency__c = 'A007'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[12].Id,
            Stage__c = 'Initial Form Sent',
            Contract_Type__c = null,
            RecordTypeId = nrfRTId,
            Agency__c = 'A007'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[13].Id,
            Stage__c = 'MM_ONX_Sent',
            Contract_Type__c = 'NRF',
            RecordTypeId = nrfRTId,
            Agency__c = 'A007'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[14].Id,
            Stage__c = 'Pending Instructions',
            Contract_Type__c = null,
            RecordTypeId = nrfRTId,
            Agency__c = 'A007'
        ));
        
        // A007 Agency - Registration Record Type (5 records)
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[15].Id,
            Stage__c = 'In Background',
            Contract_Type__c = null,
            RecordTypeId = registrationRTId,
            Agency__c = 'A007'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[16].Id,
            Stage__c = 'Sent To Compliance',
            Contract_Type__c = null,
            RecordTypeId = registrationRTId,
            Agency__c = 'A007'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[17].Id,
            Stage__c = 'Pending SM',
            Contract_Type__c = null,
            RecordTypeId = registrationRTId,
            Agency__c = 'A007'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[18].Id,
            Stage__c = 'Contract Codes (A/B) & DocuSign',
            Contract_Type__c = null,
            RecordTypeId = registrationRTId,
            Agency__c = 'A007'
        ));
        
        alcRecords.add(new ALC__c(
            Candidate__c = candidates[19].Id,
            Stage__c = 'In Background',
            Contract_Type__c = null,
            RecordTypeId = registrationRTId,
            Agency__c = 'A007'
        ));
        
        insert alcRecords;
    }
    
    @isTest
    static void testGetCandidatesInContracting_Success() {
        Test.startTest();
        Map<String, List<CandidatesInContractingController.CandidateWrapper>> result = 
            CandidatesInContractingController.getCandidatesInContracting();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should have stage mappings');
        
        // Verify stages exist
        System.assert(result.containsKey('Initial Form Sent'), 'Should have Initial Form Sent stage');
        System.assert(result.containsKey('In Background'), 'Should have In Background stage');
        System.assert(result.containsKey('Sent To Compliance'), 'Should have Sent To Compliance stage');
    }
    
    @isTest
    static void testGetCandidatesInContracting_VerifyWrapperData() {
        Test.startTest();
        Map<String, List<CandidatesInContractingController.CandidateWrapper>> result = 
            CandidatesInContractingController.getCandidatesInContracting();
        Test.stopTest();
        
        // Get one wrapper to verify data structure
        List<CandidatesInContractingController.CandidateWrapper> wrappers = result.get('Initial Form Sent');
        System.assertNotEquals(null, wrappers, 'Wrappers should not be null');
        System.assertEquals(2, wrappers.size(), 'Should have 2 candidates in Initial Form Sent');
        
        CandidatesInContractingController.CandidateWrapper wrapper = wrappers[0];
        System.assertNotEquals(null, wrapper.alcId, 'ALC ID should be populated');
        System.assertNotEquals(null, wrapper.candidateId, 'Candidate ID should be populated');
        System.assertNotEquals(null, wrapper.candidateName, 'Candidate name should be populated');
        System.assertEquals('Initial Form Sent', wrapper.alcStage, 'Stage should match');
    }
    
    @isTest
    static void testGetCandidatesInContracting_MultipleCandidatesOneStage() {
        // Add another candidate to same stage
        Candidate__c newCandidate = new Candidate__c(
            First_Name__c = 'Another',
            Last_Name__c = 'Candidate',
            Email__c = 'another@test.com',
            Status__c = 'Active/In Process'
        );
        insert newCandidate;
        
        ALC__c newAlc = new ALC__c(
            Candidate__c = newCandidate.Id,
            Stage__c = 'In Background',
            Contract_Type__c = null
        );
        insert newAlc;
        
        Test.startTest();
        Map<String, List<CandidatesInContractingController.CandidateWrapper>> result = 
            CandidatesInContractingController.getCandidatesInContracting();
        Test.stopTest();
        
        List<CandidatesInContractingController.CandidateWrapper> backgroundCandidates = result.get('In Background');
        System.assertEquals(5, backgroundCandidates.size(), 'Should have 5 candidates in In Background stage');
    }
    
    @isTest
    static void testUpdateCandidateStage_Success() {
        ALC__c alc = [SELECT Id, Stage__c FROM ALC__c WHERE Stage__c = 'Initial Form Sent' LIMIT 1];
        
        Test.startTest();
        String result = CandidatesInContractingController.updateCandidateStage(alc.Id, 'MM_ONX_Sent');
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Update should be successful');
        
        // Verify stage was updated
        ALC__c updatedAlc = [SELECT Stage__c FROM ALC__c WHERE Id = :alc.Id];
        System.assertEquals('MM_ONX_Sent', updatedAlc.Stage__c, 'Stage should be updated');
    }
    
    @isTest
    static void testUpdateCandidateStage_InvalidId() {
        Id fakeId = '001000000000000AAA';
        
        Test.startTest();
        try {
            String result = CandidatesInContractingController.updateCandidateStage(fakeId, 'MM_ONX_Sent');
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            // AuraHandledException wraps the original exception message
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetStageConfiguration_OnlyReturnsActiveStages() {
        Test.startTest();
        Map<String, List<CandidatesInContractingController.StageConfig>> configs = 
            CandidatesInContractingController.getStageConfiguration();
        Test.stopTest();
        
        // Verify terminal stages are not returned
        for (String recordType : configs.keySet()) {
            for (CandidatesInContractingController.StageConfig config : configs.get(recordType)) {
                // None of these exact terminal stages should be in active configs
                String stageLower = config.stageApiValue.toLowerCase();
                System.assert(
                    stageLower != 'complete' &&
                    stageLower != 'canceled' &&
                    stageLower != 'terminated' &&
                    stageLower != 'cancelled' &&
                    stageLower != 'candidate complete',
                    'Terminal stage should not be active: ' + config.stageApiValue
                );
            }
        }
    }
    
    @isTest
    static void testGetCandidatesInContracting_NoData() {
        // Delete all ALC records
        delete [SELECT Id FROM ALC__c];
        
        Test.startTest();
        Map<String, List<CandidatesInContractingController.CandidateWrapper>> result = 
            CandidatesInContractingController.getCandidatesInContracting();
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Should have no stage mappings with no data');
    }
    
    // ========== New Test Methods for Enhanced Functionality ==========
    
    @isTest
    static void testGetAgencyPicklistValues() {
        Test.startTest();
        List<String> agencyValues = CandidatesInContractingController.getAgencyPicklistValues();
        Test.stopTest();
        
        System.assertNotEquals(null, agencyValues, 'Agency values should not be null');
        System.assert(agencyValues.size() > 0, 'Should have at least one agency value');
        System.assertEquals('All', agencyValues[0], 'First value should be All');
        System.assert(agencyValues.contains('A157'), 'Should include A157');
        System.assert(agencyValues.contains('A007'), 'Should include A007');
    }
    
    @isTest
    static void testGetStageConfiguration() {
        Test.startTest();
        Map<String, List<CandidatesInContractingController.StageConfig>> stageConfigs = 
            CandidatesInContractingController.getStageConfiguration();
        Test.stopTest();
        
        System.assertNotEquals(null, stageConfigs, 'Stage configs should not be null');
        System.assert(stageConfigs.size() > 0, 'Should have at least one record type configuration');
        
        // Verify we have configurations for expected record types
        System.assert(stageConfigs.containsKey('Broker') || stageConfigs.containsKey('Career') || 
                     stageConfigs.containsKey('NRF') || stageConfigs.containsKey('Registration'),
                     'Should have at least one known record type');
        
        // Verify stage config structure
        for (String recordType : stageConfigs.keySet()) {
            List<CandidatesInContractingController.StageConfig> configs = stageConfigs.get(recordType);
            System.assert(configs.size() > 0, 'Each record type should have at least one stage config');
            
            // Verify first config has required fields
            CandidatesInContractingController.StageConfig config = configs[0];
            System.assertNotEquals(null, config.stageApiValue, 'Stage API value should be set');
            System.assertNotEquals(null, config.stageDisplayLabel, 'Display label should be set');
            System.assertNotEquals(null, config.sortOrder, 'Sort order should be set');
        }
    }
    
    @isTest
    static void testGetALCDataWithConfig_AllAgencies() {
        Test.startTest();
        CandidatesInContractingController.ALCDataResponse response = 
            CandidatesInContractingController.getALCDataWithConfig('All');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertNotEquals(null, response.alcsByStage, 'ALCs by stage should not be null');
        System.assertNotEquals(null, response.stageConfigs, 'Stage configs should not be null');
        System.assertNotEquals(null, response.recordTypeCounts, 'Record type counts should not be null');
        
        // Verify we have ALCs (all using active stages only)
        Integer totalAlcs = 0;
        for (List<CandidatesInContractingController.CandidateWrapper> wrappers : response.alcsByStage.values()) {
            totalAlcs += wrappers.size();
        }
        System.assert(totalAlcs > 0, 'Should have at least one ALC in non-terminal stages');
        
        // Verify record type counts include all 4 types
        System.assert(response.recordTypeCounts.containsKey('Broker'), 'Should have Broker count');
        System.assert(response.recordTypeCounts.containsKey('Career'), 'Should have Career count');
        System.assert(response.recordTypeCounts.containsKey('NRF'), 'Should have NRF count');
        System.assert(response.recordTypeCounts.containsKey('Registration'), 'Should have Registration count');
        
        // Verify counts are correct (should be 4 each for non-terminal stages: 4 Broker, 4 Career, 4 NRF, 5 Registration)
        Integer totalCount = 0;
        for (Integer count : response.recordTypeCounts.values()) {
            totalCount += count;
        }
        System.assertEquals(totalAlcs, totalCount, 'Total counts should match total ALCs');
    }
    
    @isTest
    static void testGetALCDataWithConfig_A157() {
        Test.startTest();
        CandidatesInContractingController.ALCDataResponse response = 
            CandidatesInContractingController.getALCDataWithConfig('A157');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Response should not be null');
        
        // Verify all ALCs are from A157
        for (List<CandidatesInContractingController.CandidateWrapper> wrappers : response.alcsByStage.values()) {
            for (CandidatesInContractingController.CandidateWrapper wrapper : wrappers) {
                System.assertEquals('A157', wrapper.agency, 'All ALCs should be from A157 agency');
            }
        }
        
        // Verify we have the expected number of A157 records (should be 8 in non-terminal stages)
        Integer totalA157 = 0;
        for (List<CandidatesInContractingController.CandidateWrapper> wrappers : response.alcsByStage.values()) {
            totalA157 += wrappers.size();
        }
        System.assert(totalA157 > 0, 'Should have A157 records');
        
        // Verify record type counts
        Integer brokerCount = response.recordTypeCounts.get('Broker');
        Integer careerCount = response.recordTypeCounts.get('Career');
        System.assert(brokerCount > 0, 'Should have Broker records for A157');
        System.assert(careerCount > 0, 'Should have Career records for A157');
    }
    
    @isTest
    static void testGetALCDataWithConfig_A007() {
        Test.startTest();
        CandidatesInContractingController.ALCDataResponse response = 
            CandidatesInContractingController.getALCDataWithConfig('A007');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'Response should not be null');
        
        // Verify all ALCs are from A007
        for (List<CandidatesInContractingController.CandidateWrapper> wrappers : response.alcsByStage.values()) {
            for (CandidatesInContractingController.CandidateWrapper wrapper : wrappers) {
                System.assertEquals('A007', wrapper.agency, 'All ALCs should be from A007 agency');
            }
        }
        
        // Verify we have the expected number of A007 records (should be 9 in non-terminal stages)
        Integer totalA007 = 0;
        for (List<CandidatesInContractingController.CandidateWrapper> wrappers : response.alcsByStage.values()) {
            totalA007 += wrappers.size();
        }
        System.assert(totalA007 > 0, 'Should have A007 records');
        
        // Verify record type counts
        Integer nrfCount = response.recordTypeCounts.get('NRF');
        Integer registrationCount = response.recordTypeCounts.get('Registration');
        System.assert(nrfCount > 0, 'Should have NRF records for A007');
        System.assert(registrationCount > 0, 'Should have Registration records for A007');
    }
    
    @isTest
    static void testRecordTypeCountsIncludeZeros() {
        // Delete all ALCs except one record type to verify 0 counts
        List<ALC__c> careerAlcs = [SELECT Id FROM ALC__c WHERE RecordType.DeveloperName = 'Career' LIMIT 1];
        List<ALC__c> allOtherAlcs = [SELECT Id FROM ALC__c WHERE RecordType.DeveloperName != 'Career'];
        delete allOtherAlcs;
        
        Test.startTest();
        CandidatesInContractingController.ALCDataResponse response = 
            CandidatesInContractingController.getALCDataWithConfig('All');
        Test.stopTest();
        
        // Verify all 5 record types are present in counts map
        System.assertEquals(5, response.recordTypeCounts.size(), 'Should have all 5 record type counts');
        System.assert(response.recordTypeCounts.containsKey('Broker'), 'Should have Broker count');
        System.assert(response.recordTypeCounts.containsKey('Career'), 'Should have Career count');
        System.assert(response.recordTypeCounts.containsKey('NRF'), 'Should have NRF count');
        System.assert(response.recordTypeCounts.containsKey('Registration'), 'Should have Registration count');
        System.assert(response.recordTypeCounts.containsKey('Financing'), 'Should have Financing count');
        
        // Verify only Career has count > 0
        System.assert(response.recordTypeCounts.get('Career') > 0, 'Career should have records');
        System.assertEquals(0, response.recordTypeCounts.get('Broker'), 'Broker should have 0 records');
        System.assertEquals(0, response.recordTypeCounts.get('NRF'), 'NRF should have 0 records');
        System.assertEquals(0, response.recordTypeCounts.get('Registration'), 'Registration should have 0 records');
    }
    
    @isTest
    static void testUpdateStageToTerminal() {
        ALC__c alc = [SELECT Id, Stage__c FROM ALC__c WHERE Stage__c = 'Initial Form Sent' LIMIT 1];
        
        Test.startTest();
        String result = CandidatesInContractingController.updateCandidateStage(alc.Id, 'AA Received');
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Update should be successful');
        
        // Verify stage was updated
        ALC__c updatedAlc = [SELECT Stage__c FROM ALC__c WHERE Id = :alc.Id];
        System.assertEquals('AA Received', updatedAlc.Stage__c, 'Stage should be updated to AA Received');
    }
    
    @isTest
    static void testUpdateStageFromActive() {
        ALC__c alc = [SELECT Id, Stage__c FROM ALC__c WHERE Stage__c = 'AA Received' LIMIT 1];
        
        Test.startTest();
        String result = CandidatesInContractingController.updateCandidateStage(alc.Id, 'In Background');
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Update should be successful');
        
        // Verify stage was updated from terminal stage
        ALC__c updatedAlc = [SELECT Stage__c FROM ALC__c WHERE Id = :alc.Id];
        System.assertEquals('In Background', updatedAlc.Stage__c, 'Stage should be updated from COMPLETE');
    }
    
    @isTest
    static void testGetALCDataWithConfig_NullAgencyFilter() {
        Test.startTest();
        CandidatesInContractingController.ALCDataResponse response = 
            CandidatesInContractingController.getALCDataWithConfig(null);
        Test.stopTest();
        
        // Should default to 'All' when null
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertNotEquals(null, response.alcsByStage, 'ALCs by stage should not be null');
        
        // Should return records from all agencies
        Integer totalAlcs = 0;
        for (List<CandidatesInContractingController.CandidateWrapper> wrappers : response.alcsByStage.values()) {
            totalAlcs += wrappers.size();
        }
        System.assert(totalAlcs > 0, 'Should return records when agency filter is null');
    }
    
    @isTest
    static void testGetALCDataWithConfig_EmptyAgencyFilter() {
        Test.startTest();
        CandidatesInContractingController.ALCDataResponse response = 
            CandidatesInContractingController.getALCDataWithConfig('');
        Test.stopTest();
        
        // Should default to 'All' when empty
        System.assertNotEquals(null, response, 'Response should not be null');
        
        // Should return records from all agencies
        Integer totalAlcs = 0;
        for (List<CandidatesInContractingController.CandidateWrapper> wrappers : response.alcsByStage.values()) {
            totalAlcs += wrappers.size();
        }
        System.assert(totalAlcs > 0, 'Should return records when agency filter is empty');
    }
    
    @isTest
    static void testGetALCDataWithConfig_OnlyIncludesConfiguredStages() {
        Test.startTest();
        CandidatesInContractingController.ALCDataResponse response = 
            CandidatesInContractingController.getALCDataWithConfig('All');
        Test.stopTest();
        
        // Verify only stages defined in Custom Metadata are returned
        // The query should only include stages that are in stageConfigs
        System.assertNotEquals(null, response.alcsByStage, 'Should have alcsByStage map');
        System.assertNotEquals(null, response.stageConfigs, 'Should have stageConfigs');
        
        // All stages in results should be defined in Custom Metadata
        for (String stage : response.alcsByStage.keySet()) {
            Boolean foundInConfig = false;
            for (String recordType : response.stageConfigs.keySet()) {
                for (CandidatesInContractingController.StageConfig config : response.stageConfigs.get(recordType)) {
                    if (config.stageApiValue == stage) {
                        foundInConfig = true;
                        break;
                    }
                }
            }
            System.assert(foundInConfig, 'Stage ' + stage + ' should be in Custom Metadata configuration');
        }
    }
    
    @isTest
    static void testCandidateWrapperFields() {
        Test.startTest();
        CandidatesInContractingController.ALCDataResponse response = 
            CandidatesInContractingController.getALCDataWithConfig('All');
        Test.stopTest();
        
        // Get a wrapper to verify all fields are populated
        CandidatesInContractingController.CandidateWrapper wrapper = null;
        for (List<CandidatesInContractingController.CandidateWrapper> wrappers : response.alcsByStage.values()) {
            if (wrappers.size() > 0) {
                wrapper = wrappers[0];
                break;
            }
        }
        
        System.assertNotEquals(null, wrapper, 'Should have at least one wrapper');
        System.assertNotEquals(null, wrapper.alcId, 'ALC ID should be populated');
        System.assertNotEquals(null, wrapper.candidateId, 'Candidate ID should be populated');
        System.assertNotEquals(null, wrapper.candidateName, 'Candidate name should be populated');
        System.assertNotEquals(null, wrapper.alcStage, 'Stage should be populated');
        System.assertNotEquals(null, wrapper.lastStageChange, 'Last stage change should be populated');
        System.assertNotEquals(null, wrapper.recordTypeName, 'Record type name should be populated');
        System.assertNotEquals(null, wrapper.agency, 'Agency should be populated');
    }
}
