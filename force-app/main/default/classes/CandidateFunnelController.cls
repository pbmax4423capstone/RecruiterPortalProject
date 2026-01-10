/**
 * Controller for the Candidate Funnel Dashboard component
 * Provides funnel metrics, conversion rates, and drop-off analysis based on Interview data
 */
public with sharing class CandidateFunnelController {
  /**
   * Get active candidates funnel data (Status = 'Active/In Process')
   * This method is cacheable for use with @wire
   * @return FunnelData wrapper with all metrics for active candidates only
   */
  @AuraEnabled(cacheable=true)
  public static FunnelData getActiveFunnelData() {
    return getFunnelData(true);
  }

  /**
   * Get funnel data with counts and conversion rates for each interview stage
   * @param activeOnly If true, only includes candidates with Status 'Active/In Process'
   * @return FunnelData wrapper with all metrics
   */
  @AuraEnabled
  public static FunnelData getFunnelData(Boolean activeOnly) {
    FunnelData result = new FunnelData();

    // Set default if null
    if (activeOnly == null) {
      activeOnly = false;
    }

    // Define interview types in order (the funnel stages) - matching Kanban board
    List<String> stageOrder = new List<String>{
      '0-Prequal',
      'Ci_1st',
      'Align (2nd)',
      'Plan_3rd',
      'Present-4th',
      'Optional_5th',
      '6-Offer Acc'
    };

    Map<String, String> stageLabels = new Map<String, String>{
      '0-Prequal' => 'Prequal',
      'Ci_1st' => 'Ci (1st)',
      'Align (2nd)' => 'Align (2nd)',
      'Plan_3rd' => 'Plan (3rd)',
      'Present-4th' => 'Present (4th)',
      'Optional_5th' => 'Optional (5th)',
      '6-Offer Acc' => 'Offer Accepted'
    };

    // Query active candidates in pipeline - matching Kanban board filters
    // Add optional filter for Active/In Process status only
    String query =
      'SELECT Id, Name, Highest_Level_Achieved__c ' +
      'FROM Candidate__c ' +
      'WHERE Status__c NOT IN (\'Closed Lost\', \'Not Interested\', \'Hired\', \'Terminated\') ' +
      'AND Highest_Level_Achieved__c != \'7-Contracted\' ';

    if (activeOnly) {
      query += 'AND Status__c = \'Active/In Process\' ';
    }

    query += 'ORDER BY Name, Highest_Level_Achieved__c DESC';

    List<Candidate__c> candidates = Database.query(query);

    // Deduplicate by Name - keep only the highest level achieved for each person
    Map<String, Candidate__c> uniqueCandidatesByName = new Map<String, Candidate__c>();
    for (Candidate__c c : candidates) {
      String candidateName = c.Name;
      if (!uniqueCandidatesByName.containsKey(candidateName)) {
        uniqueCandidatesByName.put(candidateName, c);
      }
      // If duplicate exists, the ORDER BY ensures we already have the higher stage
    }

    // Count candidates by stage (using deduplicated list)
    Map<String, Integer> candidateCountByStage = new Map<String, Integer>();
    for (String stage : stageOrder) {
      candidateCountByStage.put(stage, 0);
    }

    for (Candidate__c c : uniqueCandidatesByName.values()) {
      String stage = c.Highest_Level_Achieved__c;
      if (stage == null) {
        stage = '0-Prequal';
      }
      if (candidateCountByStage.containsKey(stage)) {
        candidateCountByStage.put(stage, candidateCountByStage.get(stage) + 1);
      }
    }

    Integer totalCandidatesInFunnel = uniqueCandidatesByName.size();

    // Query SCHEDULED interviews for display
    Map<String, Integer> scheduledCountByStage = new Map<String, Integer>();
    for (String stage : stageOrder) {
      scheduledCountByStage.put(stage, 0);
    }

    List<Interview__c> scheduledInterviews = [
      SELECT Interview_Type__c
      FROM Interview__c
      WHERE Interview_Status__c = 'Scheduled' AND Candidate__c != NULL
    ];

    for (Interview__c interview : scheduledInterviews) {
      String interviewType = interview.Interview_Type__c;
      if (interviewType == 'Ci-First') {
        scheduledCountByStage.put(
          'Ci_1st',
          scheduledCountByStage.get('Ci_1st') + 1
        );
      } else if (interviewType == 'Align-2nd') {
        scheduledCountByStage.put(
          'Align (2nd)',
          scheduledCountByStage.get('Align (2nd)') + 1
        );
      } else if (interviewType == 'Plan-3rd') {
        scheduledCountByStage.put(
          'Plan_3rd',
          scheduledCountByStage.get('Plan_3rd') + 1
        );
      } else if (interviewType == 'Present-4th') {
        scheduledCountByStage.put(
          'Present-4th',
          scheduledCountByStage.get('Present-4th') + 1
        );
      } else if (interviewType == 'Optional-5th') {
        scheduledCountByStage.put(
          'Optional_5th',
          scheduledCountByStage.get('Optional_5th') + 1
        );
      }
    }

    // Build funnel stages with metrics
    result.stages = new List<FunnelStage>();
    Integer previousCount = totalCandidatesInFunnel;

    for (Integer i = 0; i < stageOrder.size(); i++) {
      String stageValue = stageOrder[i];
      String stageLabel = stageLabels.get(stageValue);

      Integer stageCount = candidateCountByStage.get(stageValue);
      Integer scheduledCount = scheduledCountByStage.get(stageValue);

      FunnelStage fs = new FunnelStage();
      fs.value = stageValue;
      fs.label = stageLabel;
      fs.count = stageCount;
      fs.scheduledCount = scheduledCount;
      fs.order = i;

      // Calculate percentage of total candidates in funnel
      fs.percentOfTotal = totalCandidatesInFunnel > 0
        ? ((Decimal) stageCount / totalCandidatesInFunnel * 100).setScale(1)
        : 0;

      // Cumulative is just the count for this stage
      fs.cumulativeCount = stageCount;

      // Calculate conversion rate from previous stage
      if (i == 0) {
        fs.conversionRate = 100.0;
        fs.dropOffRate = 0;
        fs.dropOffCount = 0;
      } else {
        fs.conversionRate = previousCount > 0
          ? ((Decimal) stageCount / previousCount * 100).setScale(1)
          : 0;
        fs.dropOffRate = 100 - fs.conversionRate;
        fs.dropOffCount = previousCount - stageCount;
      }

      // Visual width for funnel
      fs.widthPercent = totalCandidatesInFunnel > 0
        ? Math.max(
            15,
            ((Decimal) stageCount /
              totalCandidatesInFunnel *
              100)
              .setScale(0)
              .intValue()
          )
        : 15;

      result.stages.add(fs);
      previousCount = stageCount;
    }

    // Calculate summary metrics
    result.totalCandidates = totalCandidatesInFunnel;

    // Total scheduled interviews across all stages
    Integer totalScheduled = 0;
    for (String stage : stageOrder) {
      totalScheduled += scheduledCountByStage.get(stage);
    }
    result.totalScheduledInterviews = totalScheduled;

    // Calculate overall progression rate
    Integer firstStageCount = candidateCountByStage.get('0-Prequal');
    result.overallConversionRate = totalCandidatesInFunnel > 0
      ? ((Decimal) firstStageCount / totalCandidatesInFunnel * 100).setScale(1)
      : 0;

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
      SELECT COUNT()
      FROM Interview__c
      WHERE Date_Completed__c = THIS_MONTH AND Interview_Status__c = 'Completed'
    ];

    return result;
  }

  /**
   * Wrapper class for complete funnel data
   */
  public class FunnelData {
    @AuraEnabled
    public List<FunnelStage> stages { get; set; }
    @AuraEnabled
    public Integer totalCandidates { get; set; }
    @AuraEnabled
    public Integer totalScheduledInterviews { get; set; }
    @AuraEnabled
    public Decimal overallConversionRate { get; set; }
    @AuraEnabled
    public String biggestDropOffStage { get; set; }
    @AuraEnabled
    public Decimal biggestDropOffRate { get; set; }
    @AuraEnabled
    public Integer completedThisMonth { get; set; }
  }

  /**
   * Wrapper class for individual funnel stage
   */
  public class FunnelStage {
    @AuraEnabled
    public String value { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public Integer count { get; set; }
    @AuraEnabled
    public Integer scheduledCount { get; set; }
    @AuraEnabled
    public Integer cumulativeCount { get; set; }
    @AuraEnabled
    public Integer order { get; set; }
    @AuraEnabled
    public Decimal percentOfTotal { get; set; }
    @AuraEnabled
    public Decimal conversionRate { get; set; }
    @AuraEnabled
    public Decimal dropOffRate { get; set; }
    @AuraEnabled
    public Integer dropOffCount { get; set; }
    @AuraEnabled
    public Integer widthPercent { get; set; }
  }
}
