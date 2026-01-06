// Query for Alex Bucklen candidate
List<Candidate__c> candidates = [
    SELECT Id, Name 
    FROM Candidate__c 
    WHERE Name LIKE '%Bucklen%' OR Name LIKE '%Alex%'
    LIMIT 5
];

System.debug('Found ' + candidates.size() + ' candidates matching Alex Bucklen');
for (Candidate__c c : candidates) {
    System.debug('  Candidate: ' + c.Name + ' (' + c.Id + ')');
}

if (!candidates.isEmpty()) {
    Id candidateId = candidates[0].Id;
    System.debug('\nChecking notes for: ' + candidates[0].Name + ' (' + candidateId + ')');
    
    // Query ContentDocumentLinks
    List<ContentDocumentLink> links = [
        SELECT Id, ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink 
        WHERE LinkedEntityId = :candidateId
    ];
    System.debug('Found ' + links.size() + ' ContentDocumentLinks');
    
    if (!links.isEmpty()) {
        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            System.debug('  Link: Doc ' + link.ContentDocumentId);
            docIds.add(link.ContentDocumentId);
        }
        
        // Query ContentDocuments
        List<ContentDocument> docs = [
            SELECT Id, Title, LatestPublishedVersionId, FileType
            FROM ContentDocument
            WHERE Id IN :docIds
        ];
        System.debug('\nFound ' + docs.size() + ' ContentDocuments:');
        
        Set<Id> versionIds = new Set<Id>();
        for (ContentDocument doc : docs) {
            System.debug('  Doc "' + doc.Title + '" FileType=' + doc.FileType);
            versionIds.add(doc.LatestPublishedVersionId);
        }
        
        // Query ContentVersions WITHOUT FileType filter
        List<ContentVersion> versions = [
            SELECT Id, Title, TextPreview, FileType
            FROM ContentVersion
            WHERE Id IN :versionIds
        ];
        System.debug('\nContentVersions (all):');
        for (ContentVersion v : versions) {
            System.debug('  "' + v.Title + '" FileType=' + v.FileType);
        }
        
        // Query WITH SNOTE filter
        List<ContentVersion> notes = [
            SELECT Id, Title, FileType
            FROM ContentVersion
            WHERE Id IN :versionIds
            AND FileType = 'SNOTE'
        ];
        System.debug('\nContentVersions (SNOTE only): ' + notes.size());
    } else {
        System.debug('NO ContentDocumentLinks found for this candidate!');
    }
}
