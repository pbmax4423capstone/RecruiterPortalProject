@isTest
private class CandidateNotesController_Test {
  @isTest
  static void testGetNotes() {
    // Create test candidate
    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Test',
      Last_Name__c = 'Candidate',
      Email__c = 'test@example.com'
    );
    insert candidate;

    // Create a ContentVersion (note) - this will auto-create ContentDocument
    ContentVersion cv = new ContentVersion(
      Title = 'Test Note',
      PathOnClient = 'TestNote.snote',
      VersionData = Blob.valueOf('Test note content'),
      FirstPublishLocationId = candidate.Id
    );
    insert cv;

    // Get the ContentDocument Id
    cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

    // Create ContentDocumentLink to relate the note to the candidate
    // (FirstPublishLocationId should have created this, but let's ensure)
    List<ContentDocumentLink> existingLinks = [
      SELECT Id
      FROM ContentDocumentLink
      WHERE
        ContentDocumentId = :cv.ContentDocumentId
        AND LinkedEntityId = :candidate.Id
    ];

    if (existingLinks.isEmpty()) {
      ContentDocumentLink cdl = new ContentDocumentLink(
        LinkedEntityId = candidate.Id,
        ContentDocumentId = cv.ContentDocumentId,
        ShareType = 'V'
      );
      insert cdl;
    }

    Test.startTest();

    // Call the method
    List<CandidateNotesController.NoteWrapper> notes = CandidateNotesController.getNotes(
      candidate.Id
    );

    Test.stopTest();

    // Verify results
    System.assertNotEquals(null, notes, 'Notes list should not be null');
    System.assertEquals(1, notes.size(), 'Should return 1 note');
    System.assertEquals('Test Note', notes[0].Title, 'Note title should match');
  }

  @isTest
  static void testGetNotesNoNotes() {
    // Create test candidate without notes
    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Test',
      Last_Name__c = 'Candidate',
      Email__c = 'test@example.com'
    );
    insert candidate;

    Test.startTest();

    // Call the method
    List<CandidateNotesController.NoteWrapper> notes = CandidateNotesController.getNotes(
      candidate.Id
    );

    Test.stopTest();

    // Verify results
    System.assertNotEquals(null, notes, 'Notes list should not be null');
    System.assertEquals(
      0,
      notes.size(),
      'Should return empty list when no notes'
    );
  }

  @isTest
  static void testGetNotesMultipleNotes() {
    // Create test candidate
    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'Test',
      Last_Name__c = 'Candidate',
      Email__c = 'test@example.com'
    );
    insert candidate;

    // Create multiple notes
    List<ContentVersion> contentVersions = new List<ContentVersion>();
    for (Integer i = 1; i <= 3; i++) {
      ContentVersion cv = new ContentVersion(
        Title = 'Test Note ' + i,
        PathOnClient = 'TestNote' + i + '.snote',
        VersionData = Blob.valueOf('Test note content ' + i),
        FirstPublishLocationId = candidate.Id
      );
      contentVersions.add(cv);
    }
    insert contentVersions;

    Test.startTest();

    // Call the method
    List<CandidateNotesController.NoteWrapper> notes = CandidateNotesController.getNotes(
      candidate.Id
    );

    Test.stopTest();

    // Verify results
    System.assertNotEquals(null, notes, 'Notes list should not be null');
    System.assertEquals(3, notes.size(), 'Should return 3 notes');
  }
}
