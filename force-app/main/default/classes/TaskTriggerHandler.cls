public class TaskTriggerHandler {
  public static void createNoteFromCall(
    List<Task> newTasks,
    Map<Id, Task> oldTaskMap
  ) {
    List<ContentNote> notesToInsert = new List<ContentNote>();
    Map<Id, Id> taskIdToWhatId = new Map<Id, Id>();

    System.debug('TaskTriggerHandler: Entered createNoteFromCall');
    for (Task t : newTasks) {
      // Only act on completed calls
      Boolean isNewlyCompleted =
        (Trigger.isInsert && t.Status == 'Completed') ||
        (Trigger.isUpdate &&
        oldTaskMap != null &&
        oldTaskMap.containsKey(t.Id) &&
        oldTaskMap.get(t.Id).Status != 'Completed' &&
        t.Status == 'Completed');

      System.debug(
        'TaskTriggerHandler: Task ' +
          t.Id +
          ' isNewlyCompleted=' +
          isNewlyCompleted +
          ', Type=' +
          t.Type +
          ', DescBlank=' +
          String.isNotBlank(t.Description) +
          ', WhatId=' +
          t.WhatId
      );
      if (
        isNewlyCompleted &&
        t.Type == 'Call' &&
        String.isNotBlank(t.Description) &&
        t.WhatId != null
      ) {
        ContentNote note = new ContentNote();
        note.Title = 'Call Notes - ' + t.Subject;
        note.Content = Blob.valueOf(t.Description);
        notesToInsert.add(note);
        taskIdToWhatId.put(t.Id, t.WhatId);
      }
    }

    System.debug(
      'TaskTriggerHandler: notesToInsert size = ' + notesToInsert.size()
    );
    if (!notesToInsert.isEmpty()) {
      try {
        insert notesToInsert;
        System.debug(
          'TaskTriggerHandler: Successfully inserted ContentNotes: ' +
          notesToInsert
        );
      } catch (Exception e) {
        System.debug(
          'TaskTriggerHandler: Failed to insert ContentNotes: ' + e.getMessage()
        );
        throw e;
      }

      // Collect ContentNote Ids
      List<Id> noteIds = new List<Id>();
      for (ContentNote note : notesToInsert) {
        noteIds.add(note.Id);
      }

      // Query ContentDocument for each inserted ContentNote using LatestPublishedVersionId
      Map<Id, Id> noteIdToDocId = new Map<Id, Id>();
      for (ContentDocument doc : [
        SELECT Id, LatestPublishedVersionId
        FROM ContentDocument
        WHERE LatestPublishedVersionId IN :noteIds
      ]) {
        noteIdToDocId.put(doc.LatestPublishedVersionId, doc.Id);
      }

      System.debug('TaskTriggerHandler: noteIdToDocId map = ' + noteIdToDocId);
      List<ContentDocumentLink> links = new List<ContentDocumentLink>();
      List<Id> taskIds = new List<Id>(taskIdToWhatId.keySet());
      for (Integer i = 0; i < notesToInsert.size(); i++) {
        Id noteId = notesToInsert[i].Id;
        Id docId = noteIdToDocId.get(noteId);
        Id whatId = taskIdToWhatId.get(taskIds[i]);
        if (docId != null && whatId != null) {
          ContentDocumentLink cdl = new ContentDocumentLink();
          cdl.LinkedEntityId = whatId; // Link to WhatId (Candidate/Opportunity/etc.)
          cdl.ContentDocumentId = docId;
          cdl.ShareType = 'V'; // Viewer
          cdl.Visibility = 'AllUsers';
          links.add(cdl);
        }
      }

      System.debug('TaskTriggerHandler: links size = ' + links.size());
      if (!links.isEmpty()) {
        try {
          insert links;
          System.debug(
            'TaskTriggerHandler: Successfully inserted ContentDocumentLinks: ' +
            links
          );
        } catch (Exception e) {
          System.debug(
            'TaskTriggerHandler: Failed to insert ContentDocumentLinks: ' +
            e.getMessage()
          );
          throw e;
        }
      }
    }
  }

  /**
   * Overloaded method for test context
   * Creates notes from completed call tasks
   * @param tasks List of tasks to process (should be completed calls with descriptions)
   */
  public static void createNoteFromCall(List<Task> tasks) {
    List<ContentNote> notesToInsert = new List<ContentNote>();
    Map<Integer, Id> indexToWhatId = new Map<Integer, Id>();

    for (Integer i = 0; i < tasks.size(); i++) {
      Task t = tasks[i];
      if (
        t.Status == 'Completed' &&
        t.Type == 'Call' &&
        String.isNotBlank(t.Description) &&
        t.WhatId != null
      ) {
        ContentNote note = new ContentNote();
        note.Title = 'Call Notes - ' + t.Subject;
        note.Content = Blob.valueOf(t.Description);
        notesToInsert.add(note);
        indexToWhatId.put(notesToInsert.size() - 1, t.WhatId);
      }
    }

    if (!notesToInsert.isEmpty()) {
      insert notesToInsert;

      // Get ContentDocument IDs
      List<Id> noteIds = new List<Id>();
      for (ContentNote note : notesToInsert) {
        noteIds.add(note.Id);
      }

      Map<Id, Id> noteIdToDocId = new Map<Id, Id>();
      for (ContentDocument doc : [
        SELECT Id, LatestPublishedVersionId
        FROM ContentDocument
        WHERE LatestPublishedVersionId IN :noteIds
      ]) {
        noteIdToDocId.put(doc.LatestPublishedVersionId, doc.Id);
      }

      // Create links
      List<ContentDocumentLink> links = new List<ContentDocumentLink>();
      for (Integer i = 0; i < notesToInsert.size(); i++) {
        Id noteId = notesToInsert[i].Id;
        Id docId = noteIdToDocId.get(noteId);
        Id whatId = indexToWhatId.get(i);

        if (docId != null && whatId != null) {
          ContentDocumentLink cdl = new ContentDocumentLink();
          cdl.LinkedEntityId = whatId;
          cdl.ContentDocumentId = docId;
          cdl.ShareType = 'V';
          cdl.Visibility = 'AllUsers';
          links.add(cdl);
        }
      }

      if (!links.isEmpty()) {
        insert links;
      }
    }
  }
}
