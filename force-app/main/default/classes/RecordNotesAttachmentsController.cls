public with sharing class RecordNotesAttachmentsController {
    /**
     * DTO for Files linked to a record
     */
    public class FileItemDTO {
        @AuraEnabled public Id linkId;
        @AuraEnabled public Id contentDocumentId;
        @AuraEnabled public Id contentVersionId;
        @AuraEnabled public String title;
        @AuraEnabled public String fileType;
        @AuraEnabled public Integer contentSize;
        @AuraEnabled public String createdByName;
        @AuraEnabled public Datetime createdDate;
    }

    /**
     * DTO for Notes linked to a record
     */
    public class NoteItemDTO {
        @AuraEnabled public Id noteId;
        @AuraEnabled public String title;
        @AuraEnabled public String createdByName;
        @AuraEnabled public Datetime createdDate;
    }

    /**
     * Get latest ContentVersion details for all files linked to the given record via ContentDocumentLink
     */
    @AuraEnabled(cacheable=true)
    public static List<FileItemDTO> getFiles(Id recordId) {
        List<FileItemDTO> results = new List<FileItemDTO>();
        if (recordId == null) {
            return results;
        }

        // Object access checks
        if (!Schema.sObjectType.ContentVersion.isAccessible() || !Schema.sObjectType.ContentDocumentLink.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to view files.');
        }

        // First gather ContentDocumentLink records
        List<ContentDocumentLink> links = [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            WITH SECURITY_ENFORCED
        ];

        Set<Id> docIds = new Set<Id>();
        Map<Id, ContentDocumentLink> linkByDoc = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink l : links) {
            docIds.add(l.ContentDocumentId);
            linkByDoc.put(l.ContentDocumentId, l);
        }

        if (docIds.isEmpty()) {
            return results;
        }

        // Get latest versions for documents linked to the record
        List<ContentVersion> versions = [
            SELECT Id, ContentDocumentId, Title, FileType, ContentSize, CreatedDate, CreatedBy.Name
            FROM ContentVersion
            WHERE IsLatest = true AND ContentDocumentId IN :docIds
            WITH SECURITY_ENFORCED
        ];

        for (ContentVersion v : versions) {
            FileItemDTO dto = new FileItemDTO();
            dto.linkId = linkByDoc.containsKey(v.ContentDocumentId) ? linkByDoc.get(v.ContentDocumentId).Id : null;
            dto.contentDocumentId = v.ContentDocumentId;
            dto.contentVersionId = v.Id;
            dto.title = v.Title;
            dto.fileType = v.FileType;
            dto.contentSize = (Integer) v.ContentSize;
            dto.createdDate = v.CreatedDate;
            dto.createdByName = (v.CreatedBy != null ? v.CreatedBy.Name : null);
            results.add(dto);
        }

        return results;
    }

    /**
     * Get notes (ContentNote) linked to the given record
     */
    @AuraEnabled(cacheable=true)
    public static List<NoteItemDTO> getNotes(Id recordId) {
        List<NoteItemDTO> results = new List<NoteItemDTO>();
        if (recordId == null) {
            return results;
        }

        if (!Schema.sObjectType.ContentNote.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to view notes.');
        }

        // Gather ContentDocumentIds linked to the record
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            WITH SECURITY_ENFORCED
        ];

        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink l : links) {
            docIds.add(l.ContentDocumentId);
        }

        if (docIds.isEmpty()) {
            return results;
        }

        for (ContentNote note : [
            SELECT Id, Title, CreatedDate, CreatedBy.Name
            FROM ContentNote
            WHERE Id IN :docIds
            WITH SECURITY_ENFORCED
        ]) {
            NoteItemDTO dto = new NoteItemDTO();
            dto.noteId = note.Id;
            dto.title = note.Title;
            dto.createdDate = note.CreatedDate;
            dto.createdByName = (note.CreatedBy != null ? note.CreatedBy.Name : null);
            results.add(dto);
        }

        return results;
    }
}
