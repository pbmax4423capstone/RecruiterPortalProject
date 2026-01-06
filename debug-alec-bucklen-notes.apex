// Find Alec Bucklen 
List<Candidate__c> candidates = [SELECT Id, Name FROM Candidate__c WHERE Last_Name__c = 'Bucklen' LIMIT 1];
if (candidates.isEmpty()) {
    System.debug('ERROR: Could not find Alec Bucklen');
} else {
    Id candidateId = candidates[0].Id;
    System.debug('=== Candidate ID: ' + candidateId + ' (Alec Bucklen)');
    
    // Check ContentDocumentLinks
    List<ContentDocumentLink> links = [
        SELECT Id, ContentDocumentId, LinkedEntityId, Visibility
        FROM ContentDocumentLink 
        WHERE LinkedEntityId = :candidateId
    ];
    System.debug('=== ContentDocumentLinks found: ' + links.size());
    
    if (!links.isEmpty()) {
        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            docIds.add(link.ContentDocumentId);
            System.debug('Link Visibility: ' + link.Visibility);
        }
        
        // Check ContentDocuments
        List<ContentDocument> docs = [
            SELECT Id, LatestPublishedVersionId, OwnerId, Title
            FROM ContentDocument
            WHERE Id IN :docIds
        ];
        System.debug('=== ContentDocuments found: ' + docs.size());
        
        Set<Id> versionIds = new Set<Id>();
        for (ContentDocument doc : docs) {
            versionIds.add(doc.LatestPublishedVersionId);
        }
        
        // Check ContentVersions - ALL FileTypes
        List<ContentVersion> versions = [
            SELECT Id, Title, TextPreview, FileType, OwnerId, LastModifiedById, LastModifiedBy.Name, LastModifiedDate
            FROM ContentVersion
            WHERE Id IN :versionIds
            ORDER BY LastModifiedDate DESC
        ];
        System.debug('=== ContentVersions found (ALL types): ' + versions.size());
        for (ContentVersion cv : versions) {
            System.debug('Title: ' + cv.Title + ', FileType: ' + cv.FileType + ', Modified: ' + cv.LastModifiedDate + ', By: ' + cv.LastModifiedBy.Name);
        }
        
        // Check SNOTE specifically
        Integer noteCount = 0;
        for (ContentVersion cv : versions) {
            if (cv.FileType == 'SNOTE') {
                noteCount++;
                System.debug('>>> SNOTE FOUND: ' + cv.Title);
            }
        }
        System.debug('=== Total SNOTE files: ' + noteCount);
    }
}
