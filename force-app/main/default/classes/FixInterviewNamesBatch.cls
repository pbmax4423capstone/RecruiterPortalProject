public class FixInterviewNamesBatch implements Database.Batchable<SObject> {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    // Query all interviews with ID-based names
    return Database.getQueryLocator(
      [
        SELECT
          Id,
          Name,
          Candidate__c,
          Candidate__r.First_Name__c,
          Candidate__r.Last_Name__c,
          Interview_Type__c
        FROM Interview__c
        WHERE Name LIKE 'a0%' AND Candidate__c != NULL
      ]
    );
  }

  public void execute(Database.BatchableContext bc, List<Interview__c> scope) {
    for (Interview__c interview : scope) {
      // Generate correct name format
      interview.Name =
        interview.Candidate__r.First_Name__c +
        ' ' +
        interview.Candidate__r.Last_Name__c +
        ' - ' +
        interview.Interview_Type__c;
    }

    update scope;
  }

  public void finish(Database.BatchableContext bc) {
    System.debug('Finished fixing interview names');
  }
}
