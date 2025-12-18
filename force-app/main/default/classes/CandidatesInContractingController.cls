public with sharing class CandidatesInContractingController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<CandidateWrapper>> getCandidatesInContracting() {
        Map<String, List<CandidateWrapper>> stageMap = new Map<String, List<CandidateWrapper>>();
        
        try {
            // Query ALL ALC records with Career record type
            // Exclude Candidate Complete, CANCELED, and TERMINATED stages
            List<ALC__c> alcRecords = [
                SELECT Id, Name, Stage__c, Candidate__c, Candidate__r.Name, LastModifiedDate
                FROM ALC__c
                WHERE RecordType.DeveloperName = 'Career'
                AND Stage__c NOT IN ('Candidate Complete', 'CANCELED', 'TERMINATED', 'CANCELLED')
                ORDER BY Stage__c, Name ASC
            ];
            
            for (ALC__c alc : alcRecords) {
                if (!stageMap.containsKey(alc.Stage__c)) {
                    stageMap.put(alc.Stage__c, new List<CandidateWrapper>());
                }
                
                CandidateWrapper wrapper = new CandidateWrapper();
                wrapper.alcId = alc.Id;
                wrapper.candidateId = alc.Candidate__c;
                // Use Candidate name if linked, otherwise use ALC Name
                wrapper.candidateName = alc.Candidate__c != null ? alc.Candidate__r.Name : alc.Name;
                wrapper.alcStage = alc.Stage__c;
                wrapper.lastStageChange = alc.LastModifiedDate;
                
                stageMap.get(alc.Stage__c).add(wrapper);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving candidates in contracting: ' + e.getMessage());
        }
        
        return stageMap;
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
    
    public class CandidateWrapper {
        @AuraEnabled public String alcId { get; set; }
        @AuraEnabled public String candidateId { get; set; }
        @AuraEnabled public String candidateName { get; set; }
        @AuraEnabled public String alcStage { get; set; }
        @AuraEnabled public DateTime lastStageChange { get; set; }
    }
}