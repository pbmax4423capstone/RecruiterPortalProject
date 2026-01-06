/**
 * @description Batch class to rollback Notes__c migration by deleting migrated ContentNotes
 * @author Copilot
 * @date 2026-01-05
 */
public class NotesFieldMigrationRollback implements Database.Batchable<SObject> {
    
    private String migrationDate;
    private Integer totalDeleted = 0;
    private List<String> errors = new List<String>();
    
    /**
     * Constructor
     * @param migrationDate Date string to filter notes (MM/dd/yyyy format). 
     *                      Only notes with title containing this date will be deleted.
     */
    public NotesFieldMigrationRollback(String migrationDate) {
        this.migrationDate = migrationDate;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('=== NOTES MIGRATION ROLLBACK START ===');
        System.debug('Target Migration Date: ' + migrationDate);
        
        String titlePattern = 'Legacy Note - Migrated ' + migrationDate;
        
        // First get ContentVersions matching our title pattern
        List<ContentVersion> matchingVersions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion 
            WHERE FileType = 'SNOTE' 
            AND Title = :titlePattern
        ];
        
        Set<Id> documentIds = new Set<Id>();
        for (ContentVersion cv : matchingVersions) {
            documentIds.add(cv.ContentDocumentId);
        }
        
        // Query ContentDocumentLinks for these documents
        // Will filter to Candidate__c records in execute method
        return Database.getQueryLocator([
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :documentIds
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<ContentDocumentLink> links) {
        if (links.isEmpty()) {
            return;
        }
        
        // Filter to only Candidate__c linked entities
        Set<Id> documentIdsToDelete = new Set<Id>();
        Set<Id> linkedEntityIds = new Set<Id>();
        
        for (ContentDocumentLink link : links) {
            linkedEntityIds.add(link.LinkedEntityId);
        }
        
        // Query to verify these are Candidate__c records
        List<Candidate__c> candidates = [SELECT Id FROM Candidate__c WHERE Id IN :linkedEntityIds];
        Set<Id> candidateIds = new Set<Id>();
        for (Candidate__c c : candidates) {
            candidateIds.add(c.Id);
        }
        
        // Only delete documents linked to actual Candidate records
        for (ContentDocumentLink link : links) {
            if (candidateIds.contains(link.LinkedEntityId)) {
                documentIdsToDelete.add(link.ContentDocumentId);
            }
        }
        
        System.debug('Found ' + documentIdsToDelete.size() + ' ContentDocuments to delete');
        
        // Delete ContentDocuments (this will cascade delete ContentNotes and ContentDocumentLinks)
        List<ContentDocument> docsToDelete = [
            SELECT Id 
            FROM ContentDocument 
            WHERE Id IN :documentIdsToDelete
        ];
        
        try {
            delete docsToDelete;
            totalDeleted += docsToDelete.size();
            System.debug('Deleted ' + docsToDelete.size() + ' ContentDocuments in this batch');
        } catch (Exception e) {
            errors.add('Error deleting ContentDocuments: ' + e.getMessage());
            System.debug('ERROR: ' + e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('=== NOTES MIGRATION ROLLBACK COMPLETE ===');
        System.debug('Total ContentNotes deleted: ' + totalDeleted);
        System.debug('Errors: ' + errors.size());
        
        if (!errors.isEmpty()) {
            System.debug('ERROR DETAILS:');
            for (String error : errors) {
                System.debug('  - ' + error);
            }
        }
        
        System.debug('');
        System.debug('IMPORTANT: Notes__c field data on Candidate records was NOT affected.');
        System.debug('Original legacy notes are still preserved in the Notes__c field.');
    }
}
