public class CandidateInterviewMigrationBatch2 implements Database.Batchable<SObject> {
    
    private Integer totalProcessed = 0;
    private Integer totalInterviews = 0;
    private Integer totalEvents = 0;
    private Integer totalSkipped = 0;
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query all candidates with at least one completed interview
        return Database.getQueryLocator([
            SELECT Id, First_Name__c, Last_Name__c,
                AI_Conducted_By__c, AI_Completed_Date_Time__c,
                Attraction_Interview_Conducted_By__c, Attraction_Interview_Date_Completed__c,
                SI_1_Conducted_By__c, SI_1_Date_Completed__c,
                SI_2_Conducted_By__c, SI_2_Date_Completed__c,
                SI_3_Conducted_By__c, SI_3_Completed__c,
                Career_Presentation_Conducted_By__c, Career_Presentation_Date_Completed__c
            FROM Candidate__c
            WHERE (AI_Completed_Date_Time__c != null
                OR Attraction_Interview_Date_Completed__c != null
                OR SI_1_Date_Completed__c != null
                OR SI_2_Date_Completed__c != null
                OR SI_3_Completed__c != null
                OR Career_Presentation_Date_Completed__c != null)
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Candidate__c> candidates) {
        List<Id> candidateIds = new List<Id>();
        for (Candidate__c c : candidates) {
            candidateIds.add(c.Id);
        }
        
        CandidateInterviewDataMigration.Result res = CandidateInterviewDataMigration.migrateInterviews(candidateIds);
        
        totalProcessed += res.candidatesProcessed;
        totalInterviews += res.interviewRecordsCreated;
        totalEvents += res.eventRecordsCreated;
        totalSkipped += res.eventsSkipped;
        
        if (!res.errors.isEmpty()) {
            System.debug('ERRORS in batch: ' + res.errors);
        }
        if (!res.warnings.isEmpty()) {
            System.debug('WARNINGS in batch: ' + res.warnings);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('=== MIGRATION COMPLETE ===');
        System.debug('Candidates processed: ' + totalProcessed);
        System.debug('Interview__c records created: ' + totalInterviews);
        System.debug('Event records created (SF Sales Managers only): ' + totalEvents);
        System.debug('Events skipped (non-SF Sales Managers): ' + totalSkipped);
    }
}
