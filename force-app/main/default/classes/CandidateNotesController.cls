public without sharing class CandidateNotesController {
    
    public class NoteWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Title;
        @AuraEnabled public String TextPreview;
        @AuraEnabled public DateTime LastModifiedDate;
        @AuraEnabled public String LastModifiedByName;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<NoteWrapper> getNotes(Id recordId) {
        List<NoteWrapper> notes = new List<NoteWrapper>();
        
        try {
            System.debug('Getting notes for record: ' + recordId);
            
            if (recordId == null) {
                return notes;
            }
            
            // Query ContentDocumentLinks to find notes attached to this record
            List<ContentDocumentLink> links = [
                SELECT ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :recordId
                ORDER BY SystemModstamp DESC
            ];
            
            System.debug('Found ' + links.size() + ' ContentDocumentLinks');
        
        if (!links.isEmpty()) {
            Set<Id> documentIds = new Set<Id>();
            for (ContentDocumentLink link : links) {
                documentIds.add(link.ContentDocumentId);
            }
            
            // Query ContentDocument to get the LatestPublishedVersionId
            List<ContentDocument> documents = [
                SELECT LatestPublishedVersionId
                FROM ContentDocument
                WHERE Id IN :documentIds
            ];
            
            Set<Id> versionIds = new Set<Id>();
            for (ContentDocument doc : documents) {
                versionIds.add(doc.LatestPublishedVersionId);
            }
            
            // Query ContentVersion for the note details
            List<ContentVersion> versions = [
                SELECT Id, Title, TextPreview, LastModifiedDate, LastModifiedBy.Name, FileType
                FROM ContentVersion
                WHERE Id IN :versionIds
                AND FileType = 'SNOTE'
                ORDER BY LastModifiedDate DESC
            ];
            
            System.debug('Found ' + versions.size() + ' ContentVersion notes');
            
            // Convert to wrapper for display
            for (ContentVersion cv : versions) {
                NoteWrapper note = new NoteWrapper();
                note.Id = cv.Id;
                note.Title = cv.Title;
                note.TextPreview = cv.TextPreview;
                note.LastModifiedDate = cv.LastModifiedDate;
                note.LastModifiedByName = cv.LastModifiedBy.Name;
                notes.add(note);
            }
        }
        
        return notes;
        } catch (Exception e) {
            System.debug('Error in getNotes: ' + e.getMessage());
            throw new AuraHandledException('Error loading notes: ' + e.getMessage());
        }
    }
}