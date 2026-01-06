// Find Bradley Sofonia
List<Candidate__c> candidates = [SELECT Id, Name FROM Candidate__c WHERE First_Name__c = 'Bradley' AND Last_Name__c = 'Sofonia' LIMIT 1];
if (candidates.isEmpty()) {
    System.debug('ERROR: Could not find Bradley Sofonia');
} else {
    Id candidateId = candidates[0].Id;
    System.debug('=== Candidate ID: ' + candidateId + ' (Bradley Sofonia)');
    
    // Check ContentDocumentLinks
    List<ContentDocumentLink> links = [
        SELECT Id, ContentDocumentId, LinkedEntityId, Visibility
        FROM ContentDocumentLink 
        WHERE LinkedEntityId = :candidateId
    ];
    System.debug('=== ContentDocumentLinks found: ' + links.size());
    for (ContentDocumentLink link : links) {
        System.debug('Link: ' + link.Id + ', Visibility: ' + link.Visibility + ', DocId: ' + link.ContentDocumentId);
    }
    
    if (!links.isEmpty()) {
        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            docIds.add(link.ContentDocumentId);
        }
        
        // Check ContentDocuments
        List<ContentDocument> docs = [
            SELECT Id, LatestPublishedVersionId, OwnerId, Title
            FROM ContentDocument
            WHERE Id IN :docIds
        ];
        System.debug('=== ContentDocuments found: ' + docs.size());
        for (ContentDocument doc : docs) {
            System.debug('Doc: ' + doc.Id + ', Owner: ' + doc.OwnerId + ', Title: ' + doc.Title);
        }
        
        Set<Id> versionIds = new Set<Id>();
        for (ContentDocument doc : docs) {
            versionIds.add(doc.LatestPublishedVersionId);
        }
        
        // Check ContentVersions
        List<ContentVersion> versions = [
            SELECT Id, Title, TextPreview, FileType, OwnerId, LastModifiedById
            FROM ContentVersion
            WHERE Id IN :versionIds
        ];
        System.debug('=== ContentVersions found: ' + versions.size());
        for (ContentVersion cv : versions) {
            System.debug('Version: ' + cv.Id + ', Title: ' + cv.Title + ', FileType: ' + cv.FileType + ', Owner: ' + cv.OwnerId);
        }
        
        // Filter for notes only
        Integer noteCount = 0;
        for (ContentVersion cv : versions) {
            if (cv.FileType == 'SNOTE') {
                noteCount++;
                System.debug('FOUND NOTE: ' + cv.Title);
            }
        }
        System.debug('=== Total SNOTE files: ' + noteCount);
    }
}

// Check user permissions
System.debug('=== Current User: ' + UserInfo.getUserId() + ' (' + UserInfo.getName() + ')');
System.debug('=== Profile: ' + [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name);
