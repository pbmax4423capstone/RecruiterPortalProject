/**
 * @description Test class for CandidateNotesController
 */
@isTest
private class CandidateNotesControllerTest {
  @TestSetup
  static void setupTestData() {
    // Create test Candidate
    Candidate__c testCandidate = new Candidate__c(
      First_Name__c = 'Test',
      Last_Name__c = 'Candidate',
      Email__c = 'testnotes@example.com',
      Status__c = 'Active/In Process'
    );
    insert testCandidate;
  }

  @isTest
  static void testGetNotes_WithNotes() {
    Candidate__c candidate = [
      SELECT Id
      FROM Candidate__c
      WHERE Email__c = 'testnotes@example.com'
      LIMIT 1
    ];

    // Create a ContentVersion (note)
    ContentVersion cv = new ContentVersion(
      Title = 'Test Note',
      PathOnClient = 'TestNote.snote',
      VersionData = Blob.valueOf('Test note content')
    );
    insert cv;

    // Get the ContentDocumentId
    ContentVersion insertedCV = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
    ];

    // Link the note to the candidate
    ContentDocumentLink cdl = new ContentDocumentLink(
      ContentDocumentId = insertedCV.ContentDocumentId,
      LinkedEntityId = candidate.Id,
      ShareType = 'V',
      Visibility = 'AllUsers'
    );
    insert cdl;

    Test.startTest();
    List<CandidateNotesController.NoteWrapper> notes = CandidateNotesController.getNotes(
      candidate.Id
    );
    Test.stopTest();

    System.assertNotEquals(null, notes, 'Notes should not be null');
    System.assertEquals(1, notes.size(), 'Should have 1 note');
    System.assertEquals('Test Note', notes[0].Title, 'Note title should match');
  }

  @isTest
  static void testGetNotes_NoNotes() {
    Candidate__c candidate = [
      SELECT Id
      FROM Candidate__c
      WHERE Email__c = 'testnotes@example.com'
      LIMIT 1
    ];

    Test.startTest();
    List<CandidateNotesController.NoteWrapper> notes = CandidateNotesController.getNotes(
      candidate.Id
    );
    Test.stopTest();

    System.assertNotEquals(null, notes, 'Notes should not be null');
    System.assertEquals(0, notes.size(), 'Should have no notes');
  }

  @isTest
  static void testGetNotes_InvalidRecordId() {
    // Create a fake ID for a non-existent record
    Id fakeId = '001000000000000AAA';

    Test.startTest();
    List<CandidateNotesController.NoteWrapper> notes = CandidateNotesController.getNotes(
      fakeId
    );
    Test.stopTest();

    System.assertNotEquals(null, notes, 'Notes should not be null');
    System.assertEquals(
      0,
      notes.size(),
      'Should have no notes for invalid record'
    );
  }
}
