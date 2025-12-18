public with sharing class CandidatesInContractingController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<CandidateWrapper>> getCandidatesInContracting() {
        Map<String, List<CandidateWrapper>> stageMap = new Map<String, List<CandidateWrapper>>();
        
        try {
            // Query ALC records in Career/Broker contracting stages with related Candidate
            // Filter for Contract Type A or B, or null (Career contracts)
            // Exclude completed and canceled stages
            // Only get the most recent ALC per candidate
            List<ALC__c> alcRecords = [
                SELECT Id, Name, Stage__c, Candidate__c, Candidate__r.Name, Contract_Type__c, LastModifiedDate
                FROM ALC__c
                WHERE Stage__c IN ('Initial Form Sent', 'MM_ONX_Sent', 'MM ONX sent', 'In Background', 
                                   'Post Background - Pending Rachyll', 'Post Background - Pending SM/Rachyll',
                                   'Sent To Compliance', 'Pending SM', 'Contract Codes (A/B) & DocuSign', 
                                   'Submit to HO', 'AA Received', 'Received Approval Letter',
                                   'Create Card in Capstone ALC Trackers')
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
                
                stageMap.get(alc.Stage__c).add(wrapper);
                processedCandidates.add(alc.Candidate__c);
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