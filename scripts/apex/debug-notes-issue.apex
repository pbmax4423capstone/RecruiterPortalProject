// Test the actual CandidateNotesController.getNotes method
List<Candidate__c> candidates = [
    SELECT Id, Name 
    FROM Candidate__c 
    WHERE Name LIKE '%Alec Bucklen%'
    LIMIT 1
];

if (!candidates.isEmpty()) {
    Id candidateId = candidates[0].Id;
    System.debug('Testing getNotes for: ' + candidates[0].Name + ' (' + candidateId + ')');
    
    // Call the actual method that the LWC uses
    List<CandidateNotesController.NoteWrapper> notes = CandidateNotesController.getNotes(candidateId);
    
    System.debug('getNotes returned ' + notes.size() + ' notes');
    for (CandidateNotesController.NoteWrapper note : notes) {
        System.debug('Note: "' + note.Title + '" by ' + note.LastModifiedByName);
        System.debug('  Preview: ' + note.TextPreview);
    }
}
