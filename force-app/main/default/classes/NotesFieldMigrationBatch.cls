/**
 * @description Batch class to migrate Candidate__c.Notes__c field to enhanced ContentNotes
 * @author Copilot
 * @date 2026-01-05
 */
public class NotesFieldMigrationBatch implements Database.Batchable<SObject> {
    
    private Boolean dryRun;
    private String migrationDate;
    private Integer totalProcessed = 0;
    private Integer totalNotesCreated = 0;
    private Integer totalSkipped = 0;
    private List<String> errors = new List<String>();
    
    public class Result {
        public Integer candidatesProcessed = 0;
        public Integer notesCreated = 0;
        public Integer skipped = 0;
        public List<String> errors = new List<String>();
    }
    
    /**
     * Constructor
     * @param dryRun If true, will not perform any DML operations (validation mode)
     */
    public NotesFieldMigrationBatch(Boolean dryRun) {
        this.dryRun = dryRun;
        this.migrationDate = Datetime.now().format('MM/dd/yyyy');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('=== NOTES MIGRATION BATCH START ===');
        System.debug('Dry Run Mode: ' + dryRun);
        System.debug('Migration Date: ' + migrationDate);
        
        // Query all candidates (will filter Notes__c in execute method)
        return Database.getQueryLocator([
            SELECT Id, Name, Notes__c 
            FROM Candidate__c 
            ORDER BY Name
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Candidate__c> candidates) {
        // Filter to only candidates with populated Notes__c
        List<Candidate__c> candidatesWithNotes = new List<Candidate__c>();
        for (Candidate__c c : candidates) {
            if (c.Notes__c != null && String.isNotBlank(c.Notes__c)) {
                candidatesWithNotes.add(c);
            }
        }
        
        Result res = migrateNotes(candidatesWithNotes, dryRun, migrationDate);
        
        totalProcessed += res.candidatesProcessed;
        totalNotesCreated += res.notesCreated;
        totalSkipped += res.skipped;
        
        if (!res.errors.isEmpty()) {
            errors.addAll(res.errors);
            System.debug('ERRORS in batch: ' + res.errors);
        }
        
        System.debug('Batch processed: ' + res.candidatesProcessed + ' candidates, ' + res.notesCreated + ' notes created, ' + res.skipped + ' skipped');
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('=== NOTES MIGRATION BATCH COMPLETE ===');
        System.debug('Mode: ' + (dryRun ? 'DRY RUN (no changes made)' : 'REAL RUN (changes committed)'));
        System.debug('Candidates processed: ' + totalProcessed);
        System.debug('ContentNotes created: ' + totalNotesCreated);
        System.debug('Skipped (empty/null): ' + totalSkipped);
        System.debug('Errors: ' + errors.size());
        
        if (!errors.isEmpty()) {
            System.debug('ERROR DETAILS:');
            for (String error : errors) {
                System.debug('  - ' + error);
            }
        }
    }
    
    /**
     * Migrate notes for a list of candidates
     * @param candidates List of Candidate__c records with Notes__c field populated
     * @param dryRun If true, skip DML operations
     * @param migrationDate Date string to include in note title (MM/dd/yyyy format)
     * @return Result object with metrics
     */
    public static Result migrateNotes(List<Candidate__c> candidates, Boolean dryRun, String migrationDate) {
        Result result = new Result();
        
        if (candidates == null || candidates.isEmpty()) {
            return result;
        }
        
        List<ContentNote> notesToInsert = new List<ContentNote>();
        List<Candidate__c> candidatesWithNotes = new List<Candidate__c>();
        
        // Step 1: Create ContentNote objects
        for (Candidate__c candidate : candidates) {
            result.candidatesProcessed++;
            
            // Skip if Notes__c is empty or null
            if (String.isBlank(candidate.Notes__c)) {
                result.skipped++;
                continue;
            }
            
            try {
                ContentNote note = new ContentNote();
                note.Title = 'Legacy Note - Migrated ' + migrationDate;
                note.Content = Blob.valueOf(candidate.Notes__c);
                notesToInsert.add(note);
                
                // Keep track of candidates in same order as notes
                candidatesWithNotes.add(candidate);
                
            } catch (Exception e) {
                result.errors.add('Error creating ContentNote for Candidate ' + candidate.Name + ' (Id: ' + candidate.Id + '): ' + e.getMessage());
            }
        }
        
        if (dryRun) {
            result.notesCreated = notesToInsert.size();
            System.debug('DRY RUN: Would create ' + notesToInsert.size() + ' ContentNotes');
            return result;
        }
        
        // Step 2: Insert ContentNotes
        if (!notesToInsert.isEmpty()) {
            try {
                insert notesToInsert;
                result.notesCreated = notesToInsert.size();
                System.debug('Inserted ' + notesToInsert.size() + ' ContentNotes');
            } catch (Exception e) {
                result.errors.add('Error inserting ContentNotes: ' + e.getMessage());
                return result;
            }
        } else {
            return result;
        }
        
        // Step 3: Query ContentDocuments by LatestPublishedVersionId
        Set<Id> noteIds = new Set<Id>();
        for (ContentNote note : notesToInsert) {
            noteIds.add(note.Id);
        }
        
        Map<Id, Id> noteIdToDocIdMap = new Map<Id, Id>();
        try {
            List<ContentDocument> documents = [
                SELECT Id, LatestPublishedVersionId
                FROM ContentDocument
                WHERE LatestPublishedVersionId IN :noteIds
            ];
            
            for (ContentDocument doc : documents) {
                noteIdToDocIdMap.put(doc.LatestPublishedVersionId, doc.Id);
            }
            
            System.debug('Queried ' + documents.size() + ' ContentDocuments');
        } catch (Exception e) {
            result.errors.add('Error querying ContentDocuments: ' + e.getMessage());
            return result;
        }
        
        // Step 4: Create ContentDocumentLinks to attach notes to candidates
        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
        
        // Now we can safely iterate by index because both lists have same size
        for (Integer i = 0; i < notesToInsert.size(); i++) {
            ContentNote note = notesToInsert[i];
            Candidate__c candidate = candidatesWithNotes[i];
            
            Id documentId = noteIdToDocIdMap.get(note.Id);
            
            if (documentId == null) {
                result.errors.add('Could not find ContentDocument for ContentNote Id: ' + note.Id);
                continue;
            }
            
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = documentId;
            link.LinkedEntityId = candidate.Id;
            link.ShareType = 'V'; // Viewer permission
            link.Visibility = 'AllUsers';
            linksToInsert.add(link);
        }
        
        // Step 5: Insert ContentDocumentLinks
        if (!linksToInsert.isEmpty()) {
            try {
                insert linksToInsert;
                System.debug('Inserted ' + linksToInsert.size() + ' ContentDocumentLinks');
            } catch (Exception e) {
                result.errors.add('Error inserting ContentDocumentLinks: ' + e.getMessage());
            }
        }
        
        return result;
    }
}
