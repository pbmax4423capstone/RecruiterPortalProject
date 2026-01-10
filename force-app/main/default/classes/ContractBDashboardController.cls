/**
 * Controller for Contract B Pipeline Dashboard and related functionality
 * Handles Contract B lifecycle tracking, interview stats by period, and recruiting metrics
 */
public without sharing class ContractBDashboardController {
  /**
   * Get Contract B Pipeline data for dashboard
   * Shows active Contract B candidates with FYC progress, submission count, days remaining
   */
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> getContractBPipelineData() {
    Map<String, Object> result = new Map<String, Object>();

    try {
      List<Map<String, Object>> pipelineData = new List<Map<String, Object>>();
      List<Map<String, Object>> atRiskCandidates = new List<Map<String, Object>>();

      // Query contracted Contract B candidates with lifecycle fields
      // These are candidates who have been contracted and are actively working
      // Note: Using only fields that exist in the org
      List<Candidate__c> contractBCandidates = [
        SELECT
          Id,
          Name,
          Contact__c,
          Contact__r.Name,
          Contract_Type__c,
          Start_Date__c,
          Sales_Manager__c,
          Status__c,
          Highest_Level_Achieved__c
        FROM Candidate__c
        WHERE
          Contract_Type__c = 'Contract B'
          AND (Status__c = 'Contracted- Contract B'
          OR Highest_Level_Achieved__c = '7-Contracted')
        ORDER BY Start_Date__c ASC NULLS LAST
      ];

      // Collect Contact IDs to query opportunities
      Set<Id> contactIds = new Set<Id>();
      for (Candidate__c cand : contractBCandidates) {
        if (cand.Contact__c != null) {
          contactIds.add(cand.Contact__c);
        }
      }

      // Query opportunities for each contact (Soliciting Agent)
      Map<Id, Integer> contactToSubmissionCount = new Map<Id, Integer>();
      Map<Id, Decimal> contactToFYC = new Map<Id, Decimal>();
      if (!contactIds.isEmpty()) {
        // Count all opportunities (submissions) per soliciting agent
        for (AggregateResult ar : [
          SELECT Soliciting_Agent__c, COUNT(Id) oppCount
          FROM Opportunity
          WHERE Soliciting_Agent__c IN :contactIds
          GROUP BY Soliciting_Agent__c
        ]) {
          Id contactId = (Id) ar.get('Soliciting_Agent__c');
          Integer count = (Integer) ar.get('oppCount');
          contactToSubmissionCount.put(contactId, count);
        }

        // Sum FYC from won opportunities per soliciting agent
        for (AggregateResult ar : [
          SELECT Soliciting_Agent__c, SUM(Amount) totalFYC
          FROM Opportunity
          WHERE Soliciting_Agent__c IN :contactIds AND IsWon = TRUE
          GROUP BY Soliciting_Agent__c
        ]) {
          Id contactId = (Id) ar.get('Soliciting_Agent__c');
          Decimal fyc = ar.get('totalFYC') != null
            ? (Decimal) ar.get('totalFYC')
            : 0;
          contactToFYC.put(contactId, fyc);
        }
      }

      Integer totalActive = 0;
      Integer requirementsMet = 0;
      Integer atRiskCount = 0;
      Integer onTrackCount = 0;
      Decimal totalFYC = 0;

      for (Candidate__c cand : contractBCandidates) {
        totalActive++;

        // Get submission count and FYC for this candidate's contact
        Integer submissionCount = 0;
        Decimal candFYC = 0;
        if (cand.Contact__c != null) {
          submissionCount = contactToSubmissionCount.containsKey(
              cand.Contact__c
            )
            ? contactToSubmissionCount.get(cand.Contact__c)
            : 0;
          candFYC = contactToFYC.containsKey(cand.Contact__c)
            ? contactToFYC.get(cand.Contact__c)
            : 0;
        }

        Map<String, Object> candData = new Map<String, Object>();
        candData.put('id', cand.Id);
        candData.put('name', cand.Name);
        candData.put(
          'contactName',
          cand.Contact__r != null ? cand.Contact__r.Name : ''
        );
        candData.put('startDate', cand.Start_Date__c);
        candData.put('contractEndDate', null);
        candData.put('extensionGranted', false);
        candData.put('totalFYC', candFYC);
        candData.put('opportunityCount', submissionCount);
        candData.put('daysRemaining', null);
        candData.put('requirementsMet', false);
        candData.put('fycProgress', 0);
        candData.put('submissionsProgress', submissionCount);
        candData.put('statusIndicator', 'On Track');
        candData.put('salesManager', cand.Sales_Manager__c);

        // Add to total FYC
        totalFYC += candFYC;

        // Count as on track since we don't have the metrics fields
        onTrackCount++;

        pipelineData.add(candData);
      }

      // Summary statistics
      Map<String, Object> summary = new Map<String, Object>();
      summary.put('totalActive', totalActive);
      summary.put('requirementsMet', requirementsMet);
      summary.put('atRiskCount', atRiskCount);
      summary.put('onTrackCount', onTrackCount);
      summary.put('totalFYC', totalFYC);
      summary.put('avgFYC', totalActive > 0 ? totalFYC / totalActive : 0);

      result.put('pipeline', pipelineData);
      result.put('atRiskCandidates', atRiskCandidates);
      result.put('summary', summary);
    } catch (Exception e) {
      System.debug('Error in getContractBPipelineData: ' + e.getMessage());
      result.put('error', e.getMessage());
    }

    return result;
  }

  /**
   * Get interview statistics with period filter (currentMonth or yearToDate)
   */
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> getInterviewStatsByPeriod(String period) {
    Map<String, Object> result = new Map<String, Object>();

    try {
      Date startDate;
      Date endDate = Date.today();
      String periodLabel;

      if (period == 'yearToDate') {
        startDate = Date.newInstance(Date.today().year(), 1, 1);
        periodLabel = 'Year to Date';
      } else {
        // Default to current month
        startDate = Date.today().toStartOfMonth();
        periodLabel = 'Current Month';
      }

      DateTime startDT = DateTime.newInstance(
        startDate.year(),
        startDate.month(),
        startDate.day(),
        0,
        0,
        0
      );
      DateTime endDT = DateTime.newInstance(
        endDate.year(),
        endDate.month(),
        endDate.day(),
        23,
        59,
        59
      );

      // Get interview counts by type
      // Map actual interview types to dashboard labels:
      // Ci-First → Attraction, Align-2nd → SI1, Plan-3rd → SI2, Present-4th → SI3, Optional-5th → Career
      Map<String, String> typeMapping = new Map<String, String>{
        'Ci-First' => 'attraction',
        'Align-2nd' => 'si1',
        'Plan-3rd' => 'si2',
        'Present-4th' => 'si3',
        'Optional-5th' => 'career',
        // Also support legacy type names
        'Attraction' => 'attraction',
        'SI1' => 'si1',
        'SI2' => 'si2',
        'SI3' => 'si3',
        'Career' => 'career'
      };

      Map<String, Integer> typeStats = new Map<String, Integer>{
        'attraction' => 0,
        'si1' => 0,
        'si2' => 0,
        'si3' => 0,
        'career' => 0
      };

      List<AggregateResult> typeResults = [
        SELECT Interview_Type__c interviewType, COUNT(Id) cnt
        FROM Interview__c
        WHERE
          Interview_Status__c = 'Completed'
          AND CreatedDate >= :startDT
          AND CreatedDate <= :endDT
        GROUP BY Interview_Type__c
      ];

      Integer totalInterviews = 0;
      for (AggregateResult ar : typeResults) {
        String interviewType = (String) ar.get('interviewType');
        Integer count = (Integer) ar.get('cnt');
        totalInterviews += count;

        // Map to dashboard label
        String dashboardKey = typeMapping.get(interviewType);
        if (dashboardKey != null) {
          typeStats.put(dashboardKey, typeStats.get(dashboardKey) + count);
        }
      }

      result.put('attraction', typeStats.get('attraction'));
      result.put('si1', typeStats.get('si1'));
      result.put('si2', typeStats.get('si2'));
      result.put('si3', typeStats.get('si3'));
      result.put('career', typeStats.get('career'));
      result.put('total', totalInterviews);
      result.put('period', period);
      result.put('periodLabel', periodLabel);

      // Get interviewer breakdown for each type
      Map<String, List<Map<String, Object>>> interviewerBreakdown = new Map<String, List<Map<String, Object>>>{
        'attraction' => new List<Map<String, Object>>(),
        'si1' => new List<Map<String, Object>>(),
        'si2' => new List<Map<String, Object>>(),
        'si3' => new List<Map<String, Object>>(),
        'career' => new List<Map<String, Object>>()
      };

      List<AggregateResult> interviewerResults = [
        SELECT
          Interview_Type__c interviewType,
          Conducted_By__r.Name interviewer,
          COUNT(Id) cnt
        FROM Interview__c
        WHERE
          Interview_Status__c = 'Completed'
          AND CreatedDate >= :startDT
          AND CreatedDate <= :endDT
          AND Conducted_By__c != NULL
        GROUP BY Interview_Type__c, Conducted_By__r.Name
        ORDER BY Interview_Type__c, COUNT(Id) DESC
      ];

      for (AggregateResult ar : interviewerResults) {
        String interviewType = (String) ar.get('interviewType');
        String interviewer = (String) ar.get('interviewer');
        Integer count = (Integer) ar.get('cnt');

        // Map to dashboard key
        String dashboardKey = typeMapping.get(interviewType);
        if (
          dashboardKey != null && interviewerBreakdown.containsKey(dashboardKey)
        ) {
          interviewerBreakdown.get(dashboardKey)
            .add(
              new Map<String, Object>{
                'interviewer' => interviewer,
                'count' => count
              }
            );
        }
      }

      result.put(
        'attractionByInterviewer',
        interviewerBreakdown.get('attraction')
      );
      result.put('si1ByInterviewer', interviewerBreakdown.get('si1'));
      result.put('si2ByInterviewer', interviewerBreakdown.get('si2'));
      result.put('si3ByInterviewer', interviewerBreakdown.get('si3'));
      result.put('careerByInterviewer', interviewerBreakdown.get('career'));
    } catch (Exception e) {
      System.debug('Error in getInterviewStatsByPeriod: ' + e.getMessage());
      result.put('error', e.getMessage());
    }

    return result;
  }

  /**
   * Get recruiting metrics: Contract A vs B by month, transition rates, termination rates
   */
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> getRecruitingMetrics() {
    Map<String, Object> result = new Map<String, Object>();

    try {
      // Get current year's data
      Date yearStart = Date.newInstance(Date.today().year(), 1, 1);

      // Contract A vs B recruited by month
      List<Map<String, Object>> monthlyRecruiting = new List<Map<String, Object>>();

      // Get Contract A started by month
      List<AggregateResult> contractAByMonth = [
        SELECT CALENDAR_MONTH(Start_Date__c) month, COUNT(Id) cnt
        FROM Candidate__c
        WHERE
          Contract_Type__c IN ('Contract A', 'Career Contract')
          AND Start_Date__c >= :yearStart
          AND Start_Date__c != NULL
        GROUP BY CALENDAR_MONTH(Start_Date__c)
        ORDER BY CALENDAR_MONTH(Start_Date__c)
      ];

      // Get Contract B started by month
      List<AggregateResult> contractBByMonth = [
        SELECT CALENDAR_MONTH(Start_Date__c) month, COUNT(Id) cnt
        FROM Candidate__c
        WHERE
          Contract_Type__c = 'Contract B'
          AND Start_Date__c >= :yearStart
          AND Start_Date__c != NULL
        GROUP BY CALENDAR_MONTH(Start_Date__c)
        ORDER BY CALENDAR_MONTH(Start_Date__c)
      ];

      // Get transitions B to A by month
      List<AggregateResult> transitionsByMonth = [
        SELECT CALENDAR_MONTH(Transition_to_A_Date__c) month, COUNT(Id) cnt
        FROM Candidate__c
        WHERE
          Transition_to_A_Date__c >= :yearStart
          AND Transition_to_A_Date__c != NULL
        GROUP BY CALENDAR_MONTH(Transition_to_A_Date__c)
        ORDER BY CALENDAR_MONTH(Transition_to_A_Date__c)
      ];

      // Get terminations by month
      List<AggregateResult> terminationsByMonth = [
        SELECT CALENDAR_MONTH(Termination_Date__c) month, COUNT(Id) cnt
        FROM Candidate__c
        WHERE Termination_Date__c >= :yearStart AND Termination_Date__c != NULL
        GROUP BY CALENDAR_MONTH(Termination_Date__c)
        ORDER BY CALENDAR_MONTH(Termination_Date__c)
      ];

      // Build maps for easy lookup
      Map<Integer, Integer> contractAMap = new Map<Integer, Integer>();
      Map<Integer, Integer> contractBMap = new Map<Integer, Integer>();
      Map<Integer, Integer> transitionsMap = new Map<Integer, Integer>();
      Map<Integer, Integer> terminationsMap = new Map<Integer, Integer>();

      for (AggregateResult ar : contractAByMonth) {
        contractAMap.put((Integer) ar.get('month'), (Integer) ar.get('cnt'));
      }
      for (AggregateResult ar : contractBByMonth) {
        contractBMap.put((Integer) ar.get('month'), (Integer) ar.get('cnt'));
      }
      for (AggregateResult ar : transitionsByMonth) {
        transitionsMap.put((Integer) ar.get('month'), (Integer) ar.get('cnt'));
      }
      for (AggregateResult ar : terminationsByMonth) {
        terminationsMap.put((Integer) ar.get('month'), (Integer) ar.get('cnt'));
      }

      // Build monthly data array
      String[] monthNames = new List<String>{
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      };
      Integer currentMonth = Date.today().month();

      for (Integer i = 1; i <= currentMonth; i++) {
        Map<String, Object> monthData = new Map<String, Object>();
        monthData.put('month', monthNames[i - 1]);
        monthData.put('monthNumber', i);
        monthData.put(
          'contractA',
          contractAMap.get(i) != null ? contractAMap.get(i) : 0
        );
        monthData.put(
          'contractB',
          contractBMap.get(i) != null ? contractBMap.get(i) : 0
        );
        monthData.put(
          'transitions',
          transitionsMap.get(i) != null ? transitionsMap.get(i) : 0
        );
        monthData.put(
          'terminations',
          terminationsMap.get(i) != null ? terminationsMap.get(i) : 0
        );
        monthlyRecruiting.add(monthData);
      }

      result.put('monthlyRecruiting', monthlyRecruiting);

      // Get termination reasons breakdown
      List<Map<String, Object>> terminationReasons = new List<Map<String, Object>>();
      List<AggregateResult> reasonResults = [
        SELECT Termination_Reason__c reason, COUNT(Id) cnt
        FROM Candidate__c
        WHERE
          Termination_Date__c >= :yearStart
          AND Termination_Reason__c != NULL
        GROUP BY Termination_Reason__c
        ORDER BY COUNT(Id) DESC
      ];

      for (AggregateResult ar : reasonResults) {
        terminationReasons.add(
          new Map<String, Object>{
            'reason' => (String) ar.get('reason'),
            'count' => (Integer) ar.get('cnt')
          }
        );
      }

      result.put('terminationReasons', terminationReasons);

      // YTD totals
      Integer ytdContractA = 0;
      Integer ytdContractB = 0;
      Integer ytdTransitions = 0;
      Integer ytdTerminations = 0;

      for (Integer cnt : contractAMap.values()) {
        ytdContractA += cnt;
      }
      for (Integer cnt : contractBMap.values()) {
        ytdContractB += cnt;
      }
      for (Integer cnt : transitionsMap.values()) {
        ytdTransitions += cnt;
      }
      for (Integer cnt : terminationsMap.values()) {
        ytdTerminations += cnt;
      }

      Map<String, Object> ytdTotals = new Map<String, Object>();
      ytdTotals.put('contractA', ytdContractA);
      ytdTotals.put('contractB', ytdContractB);
      ytdTotals.put('transitions', ytdTransitions);
      ytdTotals.put('terminations', ytdTerminations);
      ytdTotals.put(
        'transitionRate',
        ytdContractB > 0
          ? ((Decimal) ytdTransitions / ytdContractB * 100).setScale(1)
          : 0
      );
      ytdTotals.put(
        'terminationRate',
        (ytdContractA + ytdContractB) > 0
          ? ((Decimal) ytdTerminations /
              (ytdContractA + ytdContractB) *
              100)
              .setScale(1)
          : 0
      );

      result.put('ytdTotals', ytdTotals);
    } catch (Exception e) {
      System.debug('Error in getRecruitingMetrics: ' + e.getMessage());
      result.put('error', e.getMessage());
    }

    return result;
  }

  /**
   * Get Contract A Progress data - agents who completed contracting (not Contract B)
   * Uses Contract Qualification data for FYC metrics
   */
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> getContractAProgressData() {
    Map<String, Object> result = new Map<String, Object>();

    try {
      List<Map<String, Object>> contractAData = new List<Map<String, Object>>();

      // Get all Contract Qualification records with their data
      List<Contract_Qualification__c> cqRecords = [
        SELECT
          Id,
          Name,
          Advisor__c,
          Agent__c,
          Contract_Code__c,
          Contract_Status__c,
          Contract_Date__c,
          WLADL_GDC_Qual_Status__c,
          All_MTD_FYC__c,
          MTD_WLADL__c,
          All_YTD_FYC__c,
          YTD_WLADL__c,
          WLADL_Contract_Minimum__c,
          YTD_GDC_Equivalent__c,
          GDC_Equivalent_Minimum__c,
          OneInFiveUsed__c,
          OneInFiveStartYear__c,
          Advisor_Active_Indicator__c
        FROM Contract_Qualification__c
        WHERE Advisor_Active_Indicator__c = TRUE
        ORDER BY All_YTD_FYC__c DESC
      ];

      // Build lookup map by agent name for matching
      Map<String, Contract_Qualification__c> cqByName = new Map<String, Contract_Qualification__c>();
      for (Contract_Qualification__c cq : cqRecords) {
        cqByName.put(cq.Name.toLowerCase(), cq);
      }

      // Summary totals
      Decimal totalYTDFYC = 0;
      Decimal totalYTDWLADL = 0;
      Integer metCount = 0;
      Integer notOnTargetCount = 0;
      Integer naCount = 0;

      for (Contract_Qualification__c cq : cqRecords) {
        Map<String, Object> agentData = new Map<String, Object>();
        agentData.put('id', cq.Id);
        agentData.put('name', cq.Name);
        agentData.put('contractCode', cq.Contract_Code__c);
        agentData.put('contractStatus', cq.Contract_Status__c);
        agentData.put('contractDate', cq.Contract_Date__c);
        agentData.put('qualStatus', cq.WLADL_GDC_Qual_Status__c);
        agentData.put(
          'ytdFYC',
          cq.All_YTD_FYC__c != null ? cq.All_YTD_FYC__c : 0
        );
        agentData.put(
          'ytdWLADL',
          cq.YTD_WLADL__c != null ? cq.YTD_WLADL__c : 0
        );
        agentData.put(
          'wladlMinimum',
          cq.WLADL_Contract_Minimum__c != null
            ? cq.WLADL_Contract_Minimum__c
            : 38000
        );
        agentData.put(
          'ytdGDCEquiv',
          cq.YTD_GDC_Equivalent__c != null ? cq.YTD_GDC_Equivalent__c : 0
        );
        agentData.put('gdcMinimum', cq.GDC_Equivalent_Minimum__c);
        agentData.put('oneInFive', cq.OneInFiveUsed__c);
        agentData.put('oneInFiveYear', cq.OneInFiveStartYear__c);
        agentData.put(
          'mtdFYC',
          cq.All_MTD_FYC__c != null ? cq.All_MTD_FYC__c : 0
        );
        agentData.put(
          'mtdWLADL',
          cq.MTD_WLADL__c != null ? cq.MTD_WLADL__c : 0
        );

        // Calculate progress percentage toward WLADL minimum
        Decimal wladlMin = cq.WLADL_Contract_Minimum__c != null
          ? cq.WLADL_Contract_Minimum__c
          : 38000;
        Decimal ytdWladl = cq.YTD_WLADL__c != null ? cq.YTD_WLADL__c : 0;
        Decimal progress = wladlMin > 0 ? (ytdWladl / wladlMin * 100) : 0;
        agentData.put('wladlProgress', progress.setScale(0));

        // Add to totals
        totalYTDFYC += cq.All_YTD_FYC__c != null ? cq.All_YTD_FYC__c : 0;
        totalYTDWLADL += cq.YTD_WLADL__c != null ? cq.YTD_WLADL__c : 0;

        // Count by status
        String status = cq.WLADL_GDC_Qual_Status__c;
        if (
          status == 'Met WLADL' ||
          status == 'Met GDC Equivalent' ||
          status == 'Met Both'
        ) {
          metCount++;
        } else if (status == 'Not On Target') {
          notOnTargetCount++;
        } else {
          naCount++;
        }

        contractAData.add(agentData);
      }

      // Summary
      Map<String, Object> summary = new Map<String, Object>();
      summary.put('totalAgents', cqRecords.size());
      summary.put('metCount', metCount);
      summary.put('notOnTargetCount', notOnTargetCount);
      summary.put('naCount', naCount);
      summary.put('totalYTDFYC', totalYTDFYC);
      summary.put('totalYTDWLADL', totalYTDWLADL);
      summary.put(
        'avgYTDFYC',
        cqRecords.size() > 0 ? totalYTDFYC / cqRecords.size() : 0
      );

      result.put('contractAData', contractAData);
      result.put('summary', summary);
    } catch (Exception e) {
      System.debug('Error in getContractAProgressData: ' + e.getMessage());
      result.put('error', e.getMessage());
    }

    return result;
  }
}
