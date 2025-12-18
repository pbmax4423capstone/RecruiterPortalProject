// Link existing "Test Note" to a Candidate record
// Replace with actual Candidate ID you're viewing

// Get the candidate - replace this with the ID from your screenshot
String candidateId = 'a025f000006PYwiAAG'; // Michael Kruse - replace with your candidate ID

// Get the most recent note (Test Note)
List<ContentVersion> notes = [
    SELECT Id, ContentDocumentId, Title
    FROM ContentVersion 
    WHERE FileType = 'SNOTE'
    AND Title = 'Test Note'
    ORDER BY CreatedDate DESC
    LIMIT 1
];

if (!notes.isEmpty()) {
    ContentVersion note = notes[0];
    System.debug('Found note: ' + note.Title);
    
    // Check if already linked
    List<ContentDocumentLink> existingLinks = [
        SELECT Id
        FROM ContentDocumentLink
        WHERE ContentDocumentId = :note.ContentDocumentId
        AND LinkedEntityId = :candidateId
    ];
    
    if (existingLinks.isEmpty()) {
        // Create the link between the note and the candidate
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = note.ContentDocumentId;
        cdl.LinkedEntityId = candidateId;
        cdl.ShareType = 'V'; // Viewer permission
        cdl.Visibility = 'AllUsers';
        
        insert cdl;
        System.debug('Successfully linked note to candidate!');
    } else {
        System.debug('Note already linked to this candidate');
    }
} else {
    System.debug('Note not found');
}
