/**
 * Controller for the Candidate Funnel Dashboard component
 * Provides funnel metrics, conversion rates, and drop-off analysis based on Interview data
 */
public with sharing class CandidateFunnelController {
    
    /**
     * Get funnel data with counts and conversion rates for each interview stage
     * @return FunnelData wrapper with all metrics
     */
    @AuraEnabled(cacheable=true)
    public static FunnelData getFunnelData() {
        FunnelData result = new FunnelData();
        
        // Define interview types in order (the funnel stages)
        List<String> stageOrder = new List<String>{
            'Ci-First',
            'Align-2nd',
            'Plan-3rd',
            'Present-4th',
            'Optional-5th'
        };
        
        Map<String, String> stageLabels = new Map<String, String>{
            'Ci-First' => 'Ci (1st Interview)',
            'Align-2nd' => 'Align (2nd)',
            'Plan-3rd' => 'Plan (3rd)',
            'Present-4th' => 'Present (4th)',
            'Optional-5th' => 'Optional (5th)'
        };
        
        // Get total unique candidates who have had ANY interview scheduled
        Set<Id> allCandidatesWithInterviews = new Set<Id>();
        for (Interview__c i : [SELECT Candidate__c FROM Interview__c WHERE Candidate__c != null]) {
            allCandidatesWithInterviews.add(i.Candidate__c);
        }
        Integer totalCandidatesInFunnel = allCandidatesWithInterviews.size();
        
        // Query COMPLETED interviews by type - count unique candidates
        Map<String, Set<Id>> candidatesByCompletedStage = new Map<String, Set<Id>>();
        for (String stage : stageOrder) {
            candidatesByCompletedStage.put(stage, new Set<Id>());
        }
        
        List<Interview__c> completedInterviews = [
            SELECT Interview_Type__c, Candidate__c
            FROM Interview__c
            WHERE Interview_Status__c = 'Completed'
            AND Candidate__c != null
        ];
        
        for (Interview__c interview : completedInterviews) {
            String interviewType = interview.Interview_Type__c;
            if (candidatesByCompletedStage.containsKey(interviewType)) {
                candidatesByCompletedStage.get(interviewType).add(interview.Candidate__c);
            }
        }
        
        // Query SCHEDULED interviews by type - count unique candidates
        Map<String, Set<Id>> candidatesByScheduledStage = new Map<String, Set<Id>>();
        for (String stage : stageOrder) {
            candidatesByScheduledStage.put(stage, new Set<Id>());
        }
        
        List<Interview__c> scheduledInterviews = [
            SELECT Interview_Type__c, Candidate__c
            FROM Interview__c
            WHERE Interview_Status__c = 'Scheduled'
            AND Candidate__c != null
        ];
        
        for (Interview__c interview : scheduledInterviews) {
            String interviewType = interview.Interview_Type__c;
            if (candidatesByScheduledStage.containsKey(interviewType)) {
                candidatesByScheduledStage.get(interviewType).add(interview.Candidate__c);
            }
        }
        
        // Build funnel stages with metrics
        result.stages = new List<FunnelStage>();
        Integer previousCompletedCount = totalCandidatesInFunnel; // Start with all candidates
        
        for (Integer i = 0; i < stageOrder.size(); i++) {
            String stageValue = stageOrder[i];
            String stageLabel = stageLabels.get(stageValue);
            
            Integer completedCount = candidatesByCompletedStage.get(stageValue).size();
            Integer scheduledCount = candidatesByScheduledStage.get(stageValue).size();
            
            FunnelStage fs = new FunnelStage();
            fs.value = stageValue;
            fs.label = stageLabel;
            fs.count = completedCount; // Completed interviews
            fs.scheduledCount = scheduledCount; // Scheduled interviews
            fs.order = i;
            
            // Calculate percentage of total candidates in funnel
            fs.percentOfTotal = totalCandidatesInFunnel > 0 ? 
                ((Decimal)completedCount / totalCandidatesInFunnel * 100).setScale(1) : 0;
            
            // Cumulative is just the completed count for this stage
            fs.cumulativeCount = completedCount;
            
            // Calculate conversion rate from previous stage
            if (i == 0) {
                // First stage - conversion from total candidates in funnel
                fs.conversionRate = totalCandidatesInFunnel > 0 ? 
                    ((Decimal)completedCount / totalCandidatesInFunnel * 100).setScale(1) : 0;
                fs.dropOffRate = 100 - fs.conversionRate;
                fs.dropOffCount = totalCandidatesInFunnel - completedCount;
            } else {
                // Conversion from previous stage's completed count
                fs.conversionRate = previousCompletedCount > 0 ? 
                    ((Decimal)completedCount / previousCompletedCount * 100).setScale(1) : 0;
                fs.dropOffRate = 100 - fs.conversionRate;
                fs.dropOffCount = previousCompletedCount - completedCount;
            }
            
            // Visual width for funnel
            fs.widthPercent = totalCandidatesInFunnel > 0 ? 
                Math.max(15, ((Decimal)completedCount / totalCandidatesInFunnel * 100).setScale(0).intValue()) : 15;
            
            result.stages.add(fs);
            previousCompletedCount = completedCount;
        }
        
        // Calculate summary metrics
        result.totalCandidates = totalCandidatesInFunnel;
        
        // Total scheduled interviews across all stages
        Integer totalScheduled = 0;
        for (String stage : stageOrder) {
            totalScheduled += candidatesByScheduledStage.get(stage).size();
        }
        result.totalScheduledInterviews = totalScheduled;
        
        // Calculate overall progression rate (Ci-First completed / total candidates)
        Integer ciCompleted = candidatesByCompletedStage.get('Ci-First').size();
        result.overallConversionRate = totalCandidatesInFunnel > 0 ? 
            ((Decimal)ciCompleted / totalCandidatesInFunnel * 100).setScale(1) : 0;
        
        // Find biggest drop-off stage
        Decimal maxDropOff = 0;
        String maxDropOffStage = '';
        for (FunnelStage fs : result.stages) {
            if (fs.dropOffRate > maxDropOff && fs.dropOffCount > 0) {
                maxDropOff = fs.dropOffRate;
                maxDropOffStage = fs.label;
            }
        }
        result.biggestDropOffStage = maxDropOffStage;
        result.biggestDropOffRate = maxDropOff;
        
        // Get completed interviews this month (same query as leaderboard)
        result.completedThisMonth = [
            SELECT COUNT() FROM Interview__c 
            WHERE Date_Completed__c = THIS_MONTH
            AND Interview_Status__c = 'Completed'
        ];
        
        return result;
    }
    
    /**
     * Wrapper class for complete funnel data
     */
    public class FunnelData {
        @AuraEnabled public List<FunnelStage> stages { get; set; }
        @AuraEnabled public Integer totalCandidates { get; set; }
        @AuraEnabled public Integer totalScheduledInterviews { get; set; }
        @AuraEnabled public Decimal overallConversionRate { get; set; }
        @AuraEnabled public String biggestDropOffStage { get; set; }
        @AuraEnabled public Decimal biggestDropOffRate { get; set; }
        @AuraEnabled public Integer completedThisMonth { get; set; }
    }
    
    /**
     * Wrapper class for individual funnel stage
     */
    public class FunnelStage {
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Integer count { get; set; }
        @AuraEnabled public Integer scheduledCount { get; set; }
        @AuraEnabled public Integer cumulativeCount { get; set; }
        @AuraEnabled public Integer order { get; set; }
        @AuraEnabled public Decimal percentOfTotal { get; set; }
        @AuraEnabled public Decimal conversionRate { get; set; }
        @AuraEnabled public Decimal dropOffRate { get; set; }
        @AuraEnabled public Integer dropOffCount { get; set; }
        @AuraEnabled public Integer widthPercent { get; set; }
    }
}
