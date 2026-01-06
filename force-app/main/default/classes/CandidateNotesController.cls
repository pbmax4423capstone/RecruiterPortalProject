public without sharing class CandidateNotesController {
  public class NoteWrapper {
    @AuraEnabled
    public String Id;
    @AuraEnabled
    public String Title;
    @AuraEnabled
    public String TextPreview;
    @AuraEnabled
    public DateTime LastModifiedDate;
    @AuraEnabled
    public String LastModifiedByName;
  }

  @AuraEnabled
  public static List<NoteWrapper> getNotes(Id recordId) {
    List<NoteWrapper> notes = new List<NoteWrapper>();

    try {
      System.debug('Getting notes for record: ' + recordId);

      // Query ContentDocumentLinks to find notes attached to this record
      // Using without sharing class context to ensure visibility across all users
      List<ContentDocumentLink> links = [
        SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :recordId
        ORDER BY SystemModstamp DESC
      ];

      System.debug('Found ' + links.size() + ' ContentDocumentLinks');

      if (!links.isEmpty()) {
        Set<Id> versionIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
          if (
            link.ContentDocument != null &&
            link.ContentDocument.LatestPublishedVersionId != null
          ) {
            versionIds.add(link.ContentDocument.LatestPublishedVersionId);
          }
        }

        // Query ContentVersion for the note details
        // Include all notes regardless of who created them
        List<ContentVersion> versions = [
          SELECT
            Id,
            Title,
            TextPreview,
            LastModifiedDate,
            LastModifiedBy.Name,
            FileType
          FROM ContentVersion
          WHERE Id IN :versionIds AND FileType = 'SNOTE'
          ORDER BY LastModifiedDate DESC
        ];

        System.debug('Found ' + versions.size() + ' ContentVersion notes');

        // Convert to wrapper for display
        for (ContentVersion cv : versions) {
          NoteWrapper note = new NoteWrapper();
          note.Id = cv.Id;
          note.Title = cv.Title != null ? cv.Title : 'Untitled Note';
          note.TextPreview = cv.TextPreview != null ? cv.TextPreview : '';
          note.LastModifiedDate = cv.LastModifiedDate;
          note.LastModifiedByName = cv.LastModifiedBy != null
            ? cv.LastModifiedBy.Name
            : 'Unknown';
          notes.add(note);
        }
      }
    } catch (Exception e) {
      System.debug('Error retrieving notes: ' + e.getMessage());
      System.debug('Stack trace: ' + e.getStackTraceString());
      // Return empty list instead of throwing error to prevent UI from breaking
    }

    return notes;
  }
}
