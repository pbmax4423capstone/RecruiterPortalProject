public with sharing class CandidatesInContractingController {
    
    @AuraEnabled(cacheable=true scope='global')
    public static Map<String, List<CandidateWrapper>> getCandidatesInContracting() {
        Map<String, List<CandidateWrapper>> stageMap = new Map<String, List<CandidateWrapper>>();
        
        try {
            // Query ALC records in Career/Broker contracting stages with related Candidate
            // Filter for Contract Type A or B, or null (Career contracts)
            // Exclude completed and canceled stages
            // Only get the most recent ALC per candidate
            List<ALC__c> alcRecords = [
                SELECT Id, Name, Stage__c, Candidate__c, Candidate__r.Name, Contract_Type__c, LastModifiedDate,
                       RecordType.DeveloperName, RecordType.Name, Agency__c
                FROM ALC__c
                WHERE Stage__c IN ('Initial Form Sent', 'MM_ONX_Sent', 'In Background', 
                                   'Post Background - Pending Rachyll',
                                   'Sent To Compliance', 'Pending SM', 'Contract Codes (A/B) & DocuSign', 
                                   'Submit to HO', 'AA Received', 'Received Approval Letter')
                AND Candidate__c != null
                AND (Contract_Type__c IN ('A', 'B') OR Contract_Type__c = null)
                AND Stage__c NOT IN ('Candidate Complete', 'COMPLETE', 'TERMINATED', 'CANCELED', 'CANCELED-(Registrations)', 'CANCELLED')
                ORDER BY Candidate__c, LastModifiedDate DESC
            ];
            
            // Track which candidates we've already added (keep only most recent)
            Set<Id> processedCandidates = new Set<Id>();
            
            for (ALC__c alc : alcRecords) {
                // Skip if we've already processed this candidate
                if (processedCandidates.contains(alc.Candidate__c)) {
                    continue;
                }
                
                if (!stageMap.containsKey(alc.Stage__c)) {
                    stageMap.put(alc.Stage__c, new List<CandidateWrapper>());
                }
                
                CandidateWrapper wrapper = new CandidateWrapper();
                wrapper.alcId = alc.Id;
                wrapper.candidateId = alc.Candidate__c;
                wrapper.candidateName = alc.Candidate__r.Name;
                wrapper.alcStage = alc.Stage__c;
                wrapper.lastStageChange = alc.LastModifiedDate;
                wrapper.recordTypeName = alc.RecordType.DeveloperName;
                wrapper.agency = alc.Agency__c;
                
                stageMap.get(alc.Stage__c).add(wrapper);
                processedCandidates.add(alc.Candidate__c);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving candidates in contracting: ' + e.getMessage());
        }
        
        return stageMap;
    }
    
    /**
     * Returns list of Agency__c picklist values dynamically
     */
    @AuraEnabled(cacheable=true scope='global')
    public static List<String> getAgencyPicklistValues() {
        List<String> picklistValues = new List<String>();
        picklistValues.add('All'); // Add 'All' option first
        
        try {
            Schema.DescribeFieldResult fieldResult = ALC__c.Agency__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for (Schema.PicklistEntry entry : ple) {
                if (entry.isActive()) {
                    picklistValues.add(entry.getValue());
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving agency picklist values: ' + e.getMessage());
        }
        
        return picklistValues;
    }
    
    /**
     * Returns stage configurations from Custom Metadata grouped by record type
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<StageConfig>> getStageConfiguration() {
        Map<String, List<StageConfig>> stageConfigMap = new Map<String, List<StageConfig>>();
        
        try {
            List<ALC_Stage_Config__mdt> configs = [
                SELECT Record_Type_API_Name__c, Stage_API_Value__c, Stage_Display_Label__c, 
                       Sort_Order__c, Column_Color__c
                FROM ALC_Stage_Config__mdt
                WHERE Is_Active__c = true
                ORDER BY Sort_Order__c
            ];
            
            for (ALC_Stage_Config__mdt config : configs) {
                if (!stageConfigMap.containsKey(config.Record_Type_API_Name__c)) {
                    stageConfigMap.put(config.Record_Type_API_Name__c, new List<StageConfig>());
                }
                
                StageConfig stageConfig = new StageConfig();
                stageConfig.recordType = config.Record_Type_API_Name__c;
                stageConfig.stageApiValue = config.Stage_API_Value__c;
                stageConfig.stageDisplayLabel = config.Stage_Display_Label__c;
                stageConfig.sortOrder = Integer.valueOf(config.Sort_Order__c);
                stageConfig.columnColor = config.Column_Color__c;
                
                stageConfigMap.get(config.Record_Type_API_Name__c).add(stageConfig);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving stage configuration: ' + e.getMessage());
        }
        
        return stageConfigMap;
    }
    
    /**
     * Returns ALCs filtered by agency with stage configs and record type counts
     */
    @AuraEnabled(cacheable=true)
    public static ALCDataResponse getALCDataWithConfig(String agencyFilter) {
        ALCDataResponse response = new ALCDataResponse();
        response.alcsByStage = new Map<String, List<CandidateWrapper>>();
        response.stageConfigs = getStageConfiguration();
        response.recordTypeCounts = new Map<String, Integer>{
            'Broker' => 0,
            'Career' => 0,
            'Financing' => 0,
            'NRF' => 0,
            'Registration' => 0
        };
        
        try {
            // Validate agency filter
            if (String.isBlank(agencyFilter)) {
                agencyFilter = 'All';
            }
            
            // Get all valid stages from Custom Metadata
            Set<String> validStages = new Set<String>();
            for (String recordType : response.stageConfigs.keySet()) {
                for (StageConfig config : response.stageConfigs.get(recordType)) {
                    validStages.add(config.stageApiValue);
                }
            }
            
            // Build query based on agency filter
            String query = 'SELECT Id, Name, Stage__c, Candidate__c, Candidate__r.Name, Candidate__r.Sales_Manager__c, ' +
                          'Contract_Type__c, LastModifiedDate, ' +
                          'RecordType.DeveloperName, RecordType.Name, Agency__c ' +
                          'FROM ALC__c ' +
                          'WHERE Stage__c IN :validStages ';
            
            // Add agency filter if not 'All'
            if (agencyFilter != 'All') {
                query += 'AND Agency__c = :agencyFilter ';
            }
            
            query += 'ORDER BY LastModifiedDate DESC';
            
            List<ALC__c> alcRecords = Database.query(query);
            
            for (ALC__c alc : alcRecords) {
                // Initialize stage list if needed
                if (!response.alcsByStage.containsKey(alc.Stage__c)) {
                    response.alcsByStage.put(alc.Stage__c, new List<CandidateWrapper>());
                }
                
                // Create wrapper for each ALC record
                CandidateWrapper wrapper = new CandidateWrapper();
                wrapper.alcId = alc.Id;
                wrapper.alcName = alc.Name;
                wrapper.candidateId = alc.Candidate__c;
                wrapper.candidateName = alc.Candidate__r.Name;
                wrapper.salesManager = alc.Candidate__r.Sales_Manager__c;
                wrapper.alcStage = alc.Stage__c;
                wrapper.lastStageChange = alc.LastModifiedDate;
                wrapper.recordTypeName = alc.RecordType.DeveloperName;
                wrapper.agency = alc.Agency__c;
                
                response.alcsByStage.get(alc.Stage__c).add(wrapper);
                
                // Update record type counts
                if (response.recordTypeCounts.containsKey(alc.RecordType.DeveloperName)) {
                    Integer currentCount = response.recordTypeCounts.get(alc.RecordType.DeveloperName);
                    response.recordTypeCounts.put(alc.RecordType.DeveloperName, currentCount + 1);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving ALC data: ' + e.getMessage());
        }
        
        return response;
    }
    
    @AuraEnabled
    public static String updateCandidateStage(String alcId, String newStage) {
        try {
            ALC__c alcRecord = [SELECT Id, Stage__c FROM ALC__c WHERE Id = :alcId LIMIT 1];
            alcRecord.Stage__c = newStage;
            update alcRecord;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException('Error updating stage: ' + e.getMessage());
        }
    }
    
    // ========== Inner Classes ==========
    
    public class CandidateWrapper {
        @AuraEnabled public String alcId { get; set; }
        @AuraEnabled public String alcName { get; set; }
        @AuraEnabled public String candidateId { get; set; }
        @AuraEnabled public String candidateName { get; set; }
        @AuraEnabled public String salesManager { get; set; }
        @AuraEnabled public String alcStage { get; set; }
        @AuraEnabled public DateTime lastStageChange { get; set; }
        @AuraEnabled public String recordTypeName { get; set; }
        @AuraEnabled public String agency { get; set; }
    }
    
    public class StageConfig {
        @AuraEnabled public String recordType { get; set; }
        @AuraEnabled public String stageApiValue { get; set; }
        @AuraEnabled public String stageDisplayLabel { get; set; }
        @AuraEnabled public Integer sortOrder { get; set; }
        @AuraEnabled public String columnColor { get; set; }
    }
    
    public class ALCDataResponse {
        @AuraEnabled public Map<String, List<CandidateWrapper>> alcsByStage { get; set; }
        @AuraEnabled public Map<String, List<StageConfig>> stageConfigs { get; set; }
        @AuraEnabled public Map<String, Integer> recordTypeCounts { get; set; }
    }
}