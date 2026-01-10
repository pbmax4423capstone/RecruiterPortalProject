/**
 * Batch Apex class to fix candidate names
 * Updates all Candidate__c records where Name field is null or contains record ID pattern
 * Sets Name = First_Name__c + ' ' + Last_Name__c
 *
 * Usage: Database.executeBatch(new BatchFixCandidateNames(), 200);
 *
 * @author Recruiter Portal Development Team
 * @date 2025-12-23
 */
public class BatchFixCandidateNames implements Database.Batchable<SObject> {
  /**
   * Start method - queries all candidates that need name fixes
   * Looks for records where Name is null or starts with 'a0' (Salesforce ID pattern)
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    // Query candidates where Name field needs updating
    // Name is null, or Name starts with a0 (record ID pattern)
    String query =
      'SELECT Id, Name, First_Name__c, Last_Name__c ' +
      'FROM Candidate__c ' +
      'WHERE (Name = null OR Name LIKE \'a0%\') ' +
      'AND (First_Name__c != null OR Last_Name__c != null)';

    System.debug('Starting BatchFixCandidateNames');
    return Database.getQueryLocator(query);
  }

  /**
   * Execute method - processes each batch of candidates
   * Updates Name field based on First_Name__c and Last_Name__c
   */
  public void execute(
    Database.BatchableContext bc,
    List<Candidate__c> candidates
  ) {
    List<Candidate__c> candidatesToUpdate = new List<Candidate__c>();

    for (Candidate__c candidate : candidates) {
      String firstName = candidate.First_Name__c != null
        ? candidate.First_Name__c.trim()
        : '';
      String lastName = candidate.Last_Name__c != null
        ? candidate.Last_Name__c.trim()
        : '';

      String newName = '';
      if (String.isNotBlank(firstName) && String.isNotBlank(lastName)) {
        newName = firstName + ' ' + lastName;
      } else if (String.isNotBlank(firstName)) {
        newName = firstName;
      } else if (String.isNotBlank(lastName)) {
        newName = lastName;
      }

      // Only update if we have a new name
      if (String.isNotBlank(newName) && newName != candidate.Name) {
        candidate.Name = newName;
        candidatesToUpdate.add(candidate);
      }
    }

    if (!candidatesToUpdate.isEmpty()) {
      try {
        update candidatesToUpdate;
        System.debug(
          'Updated ' + candidatesToUpdate.size() + ' candidates in this batch'
        );
      } catch (Exception e) {
        System.debug('Error updating candidates: ' + e.getMessage());
        // Continue processing - don't fail entire batch
      }
    }
  }

  /**
   * Finish method - logs completion
   */
  public void finish(Database.BatchableContext bc) {
    AsyncApexJob job = [
      SELECT
        Id,
        Status,
        NumberOfErrors,
        JobItemsProcessed,
        TotalJobItems,
        CreatedDate,
        CompletedDate
      FROM AsyncApexJob
      WHERE Id = :bc.getJobId()
    ];

    System.debug('BatchFixCandidateNames completed');
    System.debug('Status: ' + job.Status);
    System.debug('Job Items Processed: ' + job.JobItemsProcessed);
    System.debug('Total Job Items: ' + job.TotalJobItems);
    System.debug('Number of Errors: ' + job.NumberOfErrors);
  }
}
