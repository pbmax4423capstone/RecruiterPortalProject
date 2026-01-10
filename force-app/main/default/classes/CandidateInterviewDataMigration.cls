public with sharing class CandidateInterviewDataMigration {
  public class Result {
    public Integer candidatesProcessed = 0;
    public Integer interviewRecordsCreated = 0;
    public Integer eventRecordsCreated = 0;
    public Integer eventsSkipped = 0;
    public List<String> warnings = new List<String>();
    public List<String> errors = new List<String>();
  }

  // Salesforce user Sales Managers who should have Events created
  private static final Set<String> SF_SALES_MANAGERS = new Set<String>{
    'Andrew Moore',
    'Brooke Ianni',
    'Rachyll Tenny',
    'Tim Denton',
    'Van Hess',
    'Elizabeth Kagele',
    'Bradley Sofonia',
    'Brad Sofonia'
  };

  public static Result migrateInterviews(List<Id> candidateIds) {
    Result res = new Result();

    // Get Interview RecordType for Events
    Id interviewRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName()
      .get('Interview')
      .getRecordTypeId();

    // Build user cache for lookups
    Map<String, Id> userCache = buildUserCache();

    // Query candidates
    List<Candidate__c> candidates = queryCandidates(candidateIds);
    res.candidatesProcessed = candidates.size();

    // Collections for bulk insert
    List<Interview__c> interviewsToInsert = new List<Interview__c>();
    List<Event> eventsToInsert = new List<Event>();

    for (Candidate__c cand : candidates) {
      // Process Attraction interviews ONLY
      // Use AI_Conducted_By__c for conductor (not Attraction_Interview_Conducted_By__c)
      processInterview(
        cand,
        'Attraction',
        cand.AI_Conducted_By__c,
        cand.Attraction_Interview_Date_Completed__c,
        interviewsToInsert,
        eventsToInsert,
        userCache,
        interviewRecordTypeId,
        res
      );
    }

    // Bulk insert Interview__c records
    if (!interviewsToInsert.isEmpty()) {
      try {
        insert interviewsToInsert;
        res.interviewRecordsCreated = interviewsToInsert.size();
      } catch (Exception e) {
        res.errors.add('Interview insert error: ' + e.getMessage());
      }
    }

    // Bulk insert Event records
    if (!eventsToInsert.isEmpty()) {
      try {
        insert eventsToInsert;
        res.eventRecordsCreated = eventsToInsert.size();
      } catch (Exception e) {
        res.errors.add('Event insert error: ' + e.getMessage());
      }
    }

    return res;
  }

  private static void processInterview(
    Candidate__c cand,
    String interviewType,
    String conductedBy,
    Object completedDateObj,
    List<Interview__c> interviewsToInsert,
    List<Event> eventsToInsert,
    Map<String, Id> userCache,
    Id interviewRecordTypeId,
    Result res
  ) {
    if (completedDateObj == null || conductedBy == null) {
      return; // Skip if no completed date or conductor
    }

    // Handle both Date and Datetime fields
    Date completedDate;
    if (completedDateObj instanceof Datetime) {
      completedDate = ((Datetime) completedDateObj).date();
    } else if (completedDateObj instanceof Date) {
      completedDate = (Date) completedDateObj;
    } else {
      return; // Unknown type
    }

    String conductedByClean = conductedBy.trim();
    Id conductorUserId = resolveUser(conductedByClean, userCache);

    // ALWAYS create Interview__c record (for reporting)
    // Set Date_Time_Scheduled__c to the completed date so queries work correctly
    Datetime scheduledDateTime = Datetime.newInstance(
      completedDate.year(),
      completedDate.month(),
      completedDate.day(),
      12,
      0,
      0
    );

    Interview__c interview = new Interview__c(
      Candidate__c = cand.Id,
      Interview_Type__c = interviewType,
      Conducted_By__c = conductorUserId, // Will be null for non-SF users
      Interview_Status__c = 'Completed',
      Date_Time_Scheduled__c = scheduledDateTime, // Set to completed date for historical records
      Notes__c = 'Conducted by: ' +
        conductedByClean +
        ' on ' +
        completedDate.format()
    );
    interviewsToInsert.add(interview);

    // Only create Event if conductor is a SF Sales Manager
    if (isSalesforceSalesManager(conductedByClean)) {
      if (conductorUserId != null) {
        Event evt = new Event(
          Subject = interviewType +
            ' Interview - ' +
            cand.First_Name__c +
            ' ' +
            cand.Last_Name__c,
          ActivityDate = completedDate,
          WhatId = cand.Id,
          OwnerId = conductorUserId, // Assign to the Sales Manager
          RecordTypeId = interviewRecordTypeId,
          Type = interviewType + ' Interview',
          Description = 'Migrated interview record. Conducted by: ' +
            conductedByClean,
          IsAllDayEvent = true
        );
        eventsToInsert.add(evt);
      } else {
        res.warnings.add(
          'SF Sales Manager "' + conductedByClean + '" not found in User cache'
        );
        res.eventsSkipped++;
      }
    } else {
      // Non-SF Sales Manager - skip Event creation (no calendar clutter)
      res.eventsSkipped++;
    }
  }

  private static Boolean isSalesforceSalesManager(String name) {
    if (name == null)
      return false;
    return SF_SALES_MANAGERS.contains(name.trim());
  }

  private static Id resolveUser(String name, Map<String, Id> userCache) {
    if (name == null)
      return null;
    String normalized = name.trim().toLowerCase();
    return userCache.get(normalized);
  }

  private static Map<String, Id> buildUserCache() {
    Map<String, Id> cache = new Map<String, Id>();
    for (User u : [
      SELECT Id, Name, FirstName, LastName
      FROM User
      WHERE IsActive = TRUE
    ]) {
      cache.put(u.Name.toLowerCase(), u.Id);
      if (u.FirstName != null && u.LastName != null) {
        cache.put((u.FirstName + ' ' + u.LastName).toLowerCase(), u.Id);

        // Handle common name variations
        if (u.FirstName == 'Bradley') {
          cache.put(('Brad ' + u.LastName).toLowerCase(), u.Id);
        }
      }
    }

    // Explicit mapping for Brad Sofonia → Bradley Sofonia
    for (User u : [
      SELECT Id
      FROM User
      WHERE Name = 'Bradley Sofonia' AND IsActive = TRUE
      LIMIT 1
    ]) {
      cache.put('brad sofonia', u.Id);
    }

    return cache;
  }

  private static List<Candidate__c> queryCandidates(List<Id> candidateIds) {
    String query =
      'SELECT Id, First_Name__c, Last_Name__c, ' +
      'AI_Conducted_By__c, Attraction_Interview_Date_Completed__c ' +
      'FROM Candidate__c';

    if (candidateIds != null && !candidateIds.isEmpty()) {
      Set<Id> idSet = new Set<Id>(candidateIds);
      query += ' WHERE Id IN :idSet';
    }

    return Database.query(query);
  }
}
