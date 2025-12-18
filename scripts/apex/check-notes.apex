// Check if notes exist and are linked to candidates

// Get the most recent note
List<ContentVersion> recentNotes = [
    SELECT Id, Title, TextPreview, ContentDocumentId, CreatedDate
    FROM ContentVersion 
    WHERE FileType = 'SNOTE'
    ORDER BY CreatedDate DESC
    LIMIT 5
];

System.debug('=== Recent Notes ===');
for (ContentVersion cv : recentNotes) {
    System.debug('Note: ' + cv.Title);
    System.debug('  ID: ' + cv.Id);
    System.debug('  ContentDocumentId: ' + cv.ContentDocumentId);
    System.debug('  Created: ' + cv.CreatedDate);
    
    // Check if this note is linked to any records
    List<ContentDocumentLink> links = [
        SELECT Id, LinkedEntityId, LinkedEntity.Name, LinkedEntity.Type
        FROM ContentDocumentLink
        WHERE ContentDocumentId = :cv.ContentDocumentId
    ];
    
    System.debug('  Linked to ' + links.size() + ' records:');
    for (ContentDocumentLink link : links) {
        System.debug('    - ' + link.LinkedEntity.Type + ': ' + link.LinkedEntity.Name + ' (ID: ' + link.LinkedEntityId + ')');
    }
}

// Get a sample candidate to test with
List<Candidate__c> candidates = [SELECT Id, Name FROM Candidate__c LIMIT 1];
if (!candidates.isEmpty()) {
    System.debug('\n=== Sample Candidate ===');
    System.debug('Candidate: ' + candidates[0].Name + ' (ID: ' + candidates[0].Id + ')');
    
    // Check if this candidate has any notes
    List<ContentDocumentLink> candidateLinks = [
        SELECT ContentDocumentId 
        FROM ContentDocumentLink 
        WHERE LinkedEntityId = :candidates[0].Id
    ];
    System.debug('This candidate has ' + candidateLinks.size() + ' linked documents/notes');
}
