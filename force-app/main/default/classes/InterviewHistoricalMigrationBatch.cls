/**
 * @description Batch processor for migrating historical interview data from Candidate__c to Interview__c
 * Processes all active candidates in batches of 200
 * Safe to re-run - uses External_Id__c for idempotent upserts
 *
 * Usage:
 *   InterviewHistoricalMigrationBatch batch = new InterviewHistoricalMigrationBatch();
 *   Database.executeBatch(batch, 200);
 */
public with sharing class InterviewHistoricalMigrationBatch implements Database.Batchable<sObject> {
  // Track overall statistics
  private Integer totalCandidatesProcessed = 0;
  private Integer totalInterviewsCreated = 0;
  private Integer totalInterviewsUpdated = 0;
  private Map<String, Integer> totalInterviewsByType = new Map<String, Integer>{
    'Ci-First' => 0,
    'Align-2nd' => 0,
    'Plan-3rd' => 0,
    'Present-4th' => 0,
    'Optional-5th' => 0
  };
  private List<String> allWarnings = new List<String>();
  private List<String> allErrors = new List<String>();

  /**
   * @description Query all active candidates with interview fields
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    String query =
      'SELECT Id, Name, ' +
      // Attraction/AI fields
      'Attraction_Interview_Date_Scheduled__c, ' +
      'AI_Completed_Date_Time__c, ' +
      'Attraction_Interview_Date_Completed__c, ' +
      'AI_Conducted_By__c, ' +
      'Attraction_Interview_Conducted_By__c, ' +
      'Attraction_Conducted_by__c, ' +
      // SI1/Align-2nd fields
      'SI_1_Date_Scheduled__c, ' +
      'SI_1_Date_Completed__c, ' +
      'SI_1_Conducted_By__c, ' +
      'SI_1_Interview_Conducted_by__c, ' +
      'SI1_Conducted_by__c, ' +
      // SI2/Plan-3rd fields
      'SI_2_Date_Scheduled__c, ' +
      'SI_2_Date_Completed__c, ' +
      'SI_2_Conducted_By__c, ' +
      'SI2_Conducted_by__c, ' +
      'SI_2_Interviewer__c, ' +
      // Career/Present-4th fields
      'Career_Presentation_Date_Scheduled__c, ' +
      'Career_Presentation_Date_Completed__c, ' +
      'CP_Conducted_By__c, ' +
      'Career_Presentation_Conducted_By__c, ' +
      // SI3/Optional-5th fields
      'SI_3_Scheduled__c, ' +
      'SI_3_Completed__c, ' +
      'SI_3_Conducted_By__c, ' +
      'SI3_Conducted_by__c, ' +
      'SI_3_Interviewer__c ' +
      'FROM Candidate__c ' +
      'ORDER BY CreatedDate ASC';

    System.debug('Starting InterviewHistoricalMigrationBatch');
    System.debug('Query: ' + query);

    return Database.getQueryLocator(query);
  }

  /**
   * @description Process each batch of candidates
   */
  public void execute(Database.BatchableContext bc, List<Candidate__c> scope) {
    System.debug('Processing batch of ' + scope.size() + ' candidates');

    try {
      // Call migration utility
      InterviewHistoricalMigration.Result result = InterviewHistoricalMigration.migrateInterviewsForCandidates(
        scope
      );

      // Accumulate statistics
      totalCandidatesProcessed += result.candidatesProcessed;
      totalInterviewsCreated += result.interviewsCreated;
      totalInterviewsUpdated += result.interviewsUpdated;

      // Merge interview type counts
      for (String type : result.interviewsByType.keySet()) {
        Integer batchCount = result.interviewsByType.get(type);
        Integer totalCount = totalInterviewsByType.get(type);
        totalInterviewsByType.put(type, totalCount + batchCount);
      }

      // Collect warnings and errors
      if (!result.warnings.isEmpty()) {
        allWarnings.addAll(result.warnings);
      }
      if (!result.errors.isEmpty()) {
        allErrors.addAll(result.errors);
      }

      // Log batch results
      System.debug(
        'Batch complete: ' +
          result.candidatesProcessed +
          ' candidates, ' +
          result.interviewsCreated +
          ' created, ' +
          result.interviewsUpdated +
          ' updated'
      );
      System.debug('Batch errors: ' + result.errors.size());
      System.debug('Batch warnings: ' + result.warnings.size());
    } catch (Exception e) {
      // Log error but don't fail entire batch
      String errorMsg =
        'Batch execution error: ' +
        e.getMessage() +
        ' at ' +
        e.getStackTraceString();
      System.debug(LoggingLevel.ERROR, errorMsg);
      allErrors.add(errorMsg);
    }
  }

  /**
   * @description Finish batch and log final statistics
   */
  public void finish(Database.BatchableContext bc) {
    System.debug('=== InterviewHistoricalMigrationBatch COMPLETE ===');
    System.debug('Total Candidates Processed: ' + totalCandidatesProcessed);
    System.debug('Total Interviews Created: ' + totalInterviewsCreated);
    System.debug('Total Interviews Updated: ' + totalInterviewsUpdated);
    System.debug('');
    System.debug('Interviews by Type:');
    for (String type : totalInterviewsByType.keySet()) {
      System.debug('  ' + type + ': ' + totalInterviewsByType.get(type));
    }
    System.debug('');
    System.debug('Total Warnings: ' + allWarnings.size());
    if (!allWarnings.isEmpty() && allWarnings.size() <= 20) {
      for (String warning : allWarnings) {
        System.debug('  WARNING: ' + warning);
      }
    } else if (allWarnings.size() > 20) {
      System.debug(
        '  (Too many warnings to display. Check individual batch logs.)'
      );
    }
    System.debug('');
    System.debug('Total Errors: ' + allErrors.size());
    if (!allErrors.isEmpty() && allErrors.size() <= 20) {
      for (String error : allErrors) {
        System.debug('  ERROR: ' + error);
      }
    } else if (allErrors.size() > 20) {
      System.debug(
        '  (Too many errors to display. Check individual batch logs.)'
      );
    }
    System.debug('=== END MIGRATION SUMMARY ===');

    // Query final Interview__c counts for verification
    AggregateResult[] results = [
      SELECT Interview_Type__c, COUNT(Id) cnt
      FROM Interview__c
      WHERE
        Interview_Type__c IN (
          'Ci-First',
          'Align-2nd',
          'Plan-3rd',
          'Present-4th',
          'Optional-5th'
        )
      GROUP BY Interview_Type__c
    ];

    System.debug('');
    System.debug('Total Interview__c records in org (by type):');
    for (AggregateResult ar : results) {
      System.debug('  ' + ar.get('Interview_Type__c') + ': ' + ar.get('cnt'));
    }
  }
}
