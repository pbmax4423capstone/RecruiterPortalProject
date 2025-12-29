/**
 * Batch class to migrate completed interviews from Candidate__c to Event records.
 * Processes candidates in batches to avoid governor limits.
 * 
 * Usage:
 *   CandidateInterviewMigrationBatch batch = new CandidateInterviewMigrationBatch(false); // false = real run
 *   Database.executeBatch(batch, 200); // Process 200 candidates per batch
 */
public class CandidateInterviewMigrationBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private Boolean dryRun;
    private Integer totalProcessed = 0;
    private Integer totalEvents = 0;
    private List<String> allWarnings = new List<String>();
    private List<String> allErrors = new List<String>();
    
    /**
     * Constructor
     * @param dryRun If true, no DML operations will be performed
     */
    public CandidateInterviewMigrationBatch(Boolean dryRun) {
        this.dryRun = dryRun;
    }
    
    /**
     * Start method - queries all candidates with completed interviews
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query only candidates that have at least one completed interview
        String query = 'SELECT Id FROM Candidate__c ' +
                      'WHERE AI_Completed_Date_Time__c != null ' +
                      'OR Attraction_Interview_Date_Completed__c != null ' +
                      'OR SI_1_Date_Completed__c != null ' +
                      'OR SI_2_Date_Completed__c != null ' +
                      'OR SI_3_Completed__c != null ' +
                      'OR Career_Presentation_Date_Completed__c != null ' +
                      'ORDER BY Id';
        
        System.debug('Starting batch migration. DryRun: ' + dryRun);
        return Database.getQueryLocator(query);
    }
    
    /**
     * Execute method - processes each batch of candidates
     */
    public void execute(Database.BatchableContext bc, List<Candidate__c> scope) {
        List<Id> candidateIds = new List<Id>();
        for (Candidate__c c : scope) {
            candidateIds.add(c.Id);
        }
        
        System.debug('Processing batch of ' + candidateIds.size() + ' candidates...');
        
        // Call the migration logic
        CandidateToEventInterviewMigration.Result result = 
            CandidateToEventInterviewMigration.migrate(candidateIds, dryRun, null, null);
        
        // Accumulate results
        totalProcessed += candidateIds.size();
        totalEvents += result.eventsUpserted;
        allWarnings.addAll(result.warnings);
        allErrors.addAll(result.errors);
        
        System.debug('Batch complete. Events created: ' + result.eventsUpserted + 
                    ', Warnings: ' + result.warnings.size() + 
                    ', Errors: ' + result.errors.size());
    }
    
    /**
     * Finish method - prints final summary
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('\n========================================');
        System.debug('BATCH MIGRATION COMPLETE');
        System.debug('========================================');
        System.debug('Mode: ' + (dryRun ? 'DRY RUN' : 'REAL RUN'));
        System.debug('Total Candidates Processed: ' + totalProcessed);
        System.debug('Total Events Created: ' + totalEvents);
        System.debug('Total Warnings: ' + allWarnings.size());
        System.debug('Total Errors: ' + allErrors.size());
        System.debug('========================================\n');
        
        // Print first 100 warnings
        Integer warningCount = 0;
        for (String w : allWarnings) {
            if (warningCount++ >= 100) {
                System.debug('... ' + (allWarnings.size() - 100) + ' more warnings not shown');
                break;
            }
            System.debug('WARN: ' + w);
        }
        
        // Print first 100 errors
        Integer errorCount = 0;
        for (String e : allErrors) {
            if (errorCount++ >= 100) {
                System.debug('... ' + (allErrors.size() - 100) + ' more errors not shown');
                break;
            }
            System.debug('ERROR: ' + e);
        }
        
        System.debug('\nBatch Job Id: ' + bc.getJobId());
    }
}
