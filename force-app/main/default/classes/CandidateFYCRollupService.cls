/**
 * @description Calculates FYC rollup and Opportunity count for Candidates
 *              linked to Contacts. Called from Flow when Opportunities change.
 * @author Contract Lifecycle Tracking System
 * @date December 2025
 */
public with sharing class CandidateFYCRollupService {
  /**
   * @description Invocable method to update FYC rollup for Candidates based on Contact IDs
   * @param contactIds List of Contact IDs whose related Candidates need updating
   */
  @InvocableMethod(
    label='Update Candidate FYC Rollup'
    description='Calculates Total FYC and Opportunity Count for Candidates linked to the specified Contacts'
  )
  public static void updateCandidateFYCRollup(List<Id> contactIds) {
    if (contactIds == null || contactIds.isEmpty()) {
      return;
    }

    // Remove nulls and get unique IDs
    Set<Id> uniqueContactIds = new Set<Id>();
    for (Id contactId : contactIds) {
      if (contactId != null) {
        uniqueContactIds.add(contactId);
      }
    }

    if (uniqueContactIds.isEmpty()) {
      return;
    }

    // Get aggregate data from Opportunities
    Map<Id, AggregateResult> oppAggregates = getOpportunityAggregates(
      uniqueContactIds
    );

    // Get Candidates linked to these Contacts
    List<Candidate__c> candidatesToUpdate = [
      SELECT Id, Contact__c, Total_FYC__c, Opportunity_Count__c
      FROM Candidate__c
      WHERE Contact__c IN :uniqueContactIds
    ];

    if (candidatesToUpdate.isEmpty()) {
      return;
    }

    // Update Candidates with aggregate values
    for (Candidate__c candidate : candidatesToUpdate) {
      AggregateResult aggResult = oppAggregates.get(candidate.Contact__c);

      if (aggResult != null) {
        candidate.Total_FYC__c = (Decimal) aggResult.get('totalFYC');
        candidate.Opportunity_Count__c = (Decimal) aggResult.get('oppCount');
      } else {
        // No opportunities found - set to 0
        candidate.Total_FYC__c = 0;
        candidate.Opportunity_Count__c = 0;
      }
    }

    // Perform update
    if (!candidatesToUpdate.isEmpty()) {
      update candidatesToUpdate;
    }
  }

  /**
   * @description Gets aggregate Opportunity data grouped by ContactId
   * @param contactIds Set of Contact IDs to aggregate
   * @return Map of ContactId to AggregateResult containing totalFYC and oppCount
   */
  private static Map<Id, AggregateResult> getOpportunityAggregates(
    Set<Id> contactIds
  ) {
    Map<Id, AggregateResult> resultMap = new Map<Id, AggregateResult>();

    List<AggregateResult> aggregates = [
      SELECT ContactId, SUM(FYC__c) totalFYC, COUNT(Id) oppCount
      FROM Opportunity
      WHERE ContactId IN :contactIds
      GROUP BY ContactId
    ];

    for (AggregateResult agg : aggregates) {
      Id contactId = (Id) agg.get('ContactId');
      resultMap.put(contactId, agg);
    }

    return resultMap;
  }

  /**
   * @description Bulk update method for scheduled jobs or batch processing
   *              Updates all Contract B Candidates with current FYC data
   */
  public static void updateAllContractBCandidates() {
    // Get all Contract B Candidates with Contact lookup
    List<Candidate__c> contractBCandidates = [
      SELECT Id, Contact__c, Total_FYC__c, Opportunity_Count__c
      FROM Candidate__c
      WHERE
        Contract_Type__c = 'Contract B'
        AND Contact__c != NULL
        AND Contract_Outcome__c = 'Active'
    ];

    if (contractBCandidates.isEmpty()) {
      return;
    }

    // Collect Contact IDs
    Set<Id> contactIds = new Set<Id>();
    for (Candidate__c candidate : contractBCandidates) {
      contactIds.add(candidate.Contact__c);
    }

    // Get aggregates
    Map<Id, AggregateResult> oppAggregates = getOpportunityAggregates(
      contactIds
    );

    // Update Candidates
    for (Candidate__c candidate : contractBCandidates) {
      AggregateResult aggResult = oppAggregates.get(candidate.Contact__c);

      if (aggResult != null) {
        candidate.Total_FYC__c = (Decimal) aggResult.get('totalFYC');
        candidate.Opportunity_Count__c = (Decimal) aggResult.get('oppCount');
      } else {
        candidate.Total_FYC__c = 0;
        candidate.Opportunity_Count__c = 0;
      }
    }

    if (!contractBCandidates.isEmpty()) {
      update contractBCandidates;
    }
  }
}
