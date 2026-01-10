public with sharing class CandidateToEventInterviewMigration {
  public class Result {
    public Integer candidatesProcessed = 0;
    public Integer eventsUpserted = 0;
    public Integer eventsSkipped = 0;
    public List<String> warnings = new List<String>();
    public List<String> errors = new List<String>();
    public override String toString() {
      return 'Processed=' +
        candidatesProcessed +
        ', Upserted=' +
        eventsUpserted +
        ', Skipped=' +
        eventsSkipped +
        ', Warnings=' +
        warnings.size() +
        ', Errors=' +
        errors.size();
    }
  }

  public enum InterviewType {
    AI,
    CP,
    SI1,
    SI2,
    SI3
  }

  @AuraEnabled
  public static Result migrate(
    List<Id> candidateIds,
    Boolean dryRun,
    Time startTimeDefault,
    Integer durationMinutes
  ) {
    // Time parameters are ignored per requirements (date-only, all-day events)
    Result res = new Result();

    // Get Interview RecordType ID
    Id interviewRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName()
      .get('Interview')
      .getRecordTypeId();

    // Build SOQL field list and query Candidates
    // NOTE: Using dynamic field tokens to avoid compile errors if some fields don't exist in sandbox variants.
    // Replace with strongly-typed fields if all exist in your org.
    String baseQuery =
      'SELECT Id, OwnerId, First_Name__c, Last_Name__c, ' +
      'Attraction_Interview_Date_Scheduled__c, ' +
      'AI_Completed_Date_Time__c, Attraction_Interview_Date_Completed__c, ' +
      'AI_Conducted_By__c, Attraction_Conducted_by__c, Attraction_Interview_Conducted_By__c, ' +
      'Career_Presentation_Date_Scheduled__c, Career_Presentation_Date_Completed__c, ' +
      'Career_Conducted_by__c, Career_Presentation_Conducted_By__c, ' +
      'SI_1_Date_Scheduled__c, SI_1_Date_Completed__c, ' +
      'SI_1_Interview_Conducted_by__c, SI_1_Conducted_By__c, SI1_Conducted_by__c, ' +
      'SI_2_Date_Scheduled__c, SI_2_Date_Completed__c, ' +
      'SI_2_Conducted_By__c, SI2_Conducted_by__c, SI_2_Interviewer__c, ' +
      'SI_3_Scheduled__c, SI_3_Completed__c, ' +
      'SI_3_Interviewer__c, SI_3_Conducted_By__c, SI3_Conducted_by__c ' +
      'FROM Candidate__c';
    if (candidateIds != null && !candidateIds.isEmpty()) {
      // Convert List to Set for IN clause
      Set<Id> candidateIdSet = new Set<Id>(candidateIds);
      baseQuery += ' WHERE Id IN :candidateIdSet';
    }
    List<SObject> genericCandidates = Database.query(baseQuery);
    List<Candidate__c> candidates = new List<Candidate__c>();
    for (SObject sob : genericCandidates) {
      candidates.add((Candidate__c) sob);
    }

    res.candidatesProcessed = candidates.size();

    // BULK QUERY OPTIMIZATION: Pre-load all Contacts, Users, and Interviewers to avoid repeated queries
    Map<String, Id> contactCache = buildContactCache();
    Map<String, Id> userCache = buildUserCache();
    Map<String, Id> interviewerCache = buildInterviewerCache();

    List<Event> toUpsert = new List<Event>();
    Map<String, Event> extKeyToEvent = new Map<String, Event>();

    for (Candidate__c c : candidates) {
      // Process each interview type - pass caches and recordTypeId
      processInterview(
        c,
        InterviewType.AI,
        startTimeDefault,
        durationMinutes,
        res,
        toUpsert,
        extKeyToEvent,
        contactCache,
        userCache,
        interviewerCache,
        interviewRecordTypeId
      );
      processInterview(
        c,
        InterviewType.CP,
        startTimeDefault,
        durationMinutes,
        res,
        toUpsert,
        extKeyToEvent,
        contactCache,
        userCache,
        interviewerCache,
        interviewRecordTypeId
      );
      processInterview(
        c,
        InterviewType.SI1,
        startTimeDefault,
        durationMinutes,
        res,
        toUpsert,
        extKeyToEvent,
        contactCache,
        userCache,
        interviewerCache,
        interviewRecordTypeId
      );
      processInterview(
        c,
        InterviewType.SI2,
        startTimeDefault,
        durationMinutes,
        res,
        toUpsert,
        extKeyToEvent,
        contactCache,
        userCache,
        interviewerCache,
        interviewRecordTypeId
      );
      processInterview(
        c,
        InterviewType.SI3,
        startTimeDefault,
        durationMinutes,
        res,
        toUpsert,
        extKeyToEvent,
        contactCache,
        userCache,
        interviewerCache,
        interviewRecordTypeId
      );
    }

    if (dryRun) {
      // No DML, just report
      res.warnings.add(
        'Dry run: would upsert ' + toUpsert.size() + ' Event(s).'
      );
      return res;
    }

    if (!toUpsert.isEmpty()) {
      // Upsert on Id for idempotency in USER_MODE (no External_Id__c field available)
      Database.UpsertResult[] upsr = Database.upsert(
        toUpsert,
        AccessLevel.USER_MODE
      );
      for (Database.UpsertResult r : upsr) {
        if (r.isSuccess()) {
          res.eventsUpserted++;
        } else {
          for (Database.Error e : r.getErrors()) {
            res.errors.add(
              'Event upsert failed: ' +
                e.getStatusCode() +
                ' - ' +
                e.getMessage()
            );
          }
        }
      }
    }
    return res;
  }

  private static void processInterview(
    Candidate__c c,
    InterviewType type,
    Time startTimeDefault,
    Integer durationMinutes,
    Result res,
    List<Event> toUpsert,
    Map<String, Event> extKeyToEvent,
    Map<String, Id> contactCache,
    Map<String, Id> userCache,
    Map<String, Id> interviewerCache,
    Id interviewRecordTypeId
  ) {
    // Determine sources based on type
    Date scheduledDate = null;
    Date completedDate = null;
    String status = null;
    String typeLabel = null;
    String subject = null;

    // Interviewer resolution inputs (could be lookup(Contact) via Id or free text)
    Id interviewerContactId = null;
    String interviewerRaw = null;

    switch on type {
      when AI {
        typeLabel = 'CI (First)';
        subject = 'CI (First)';
        scheduledDate = c.Attraction_Interview_Date_Scheduled__c;
        // Completed: either AI_Completed_Date_Time__c (Datetime) or Attraction_Interview_Date_Completed__c (Date)
        if (c.AI_Completed_Date_Time__c != null) {
          completedDate = Date.valueOf(c.AI_Completed_Date_Time__c.date());
        } else if (c.Attraction_Interview_Date_Completed__c != null) {
          completedDate = c.Attraction_Interview_Date_Completed__c;
        }
        // Interviewer precedence
        interviewerRaw = coalesceText(
          getTextFromAny(c.get('Attraction_Interview_Conducted_By__c')),
          getTextFromAny(c.get('Attraction_Conducted_by__c')),
          getTextFromAny(c.get('AI_Conducted_By__c'))
        );
      }
      when CP {
        typeLabel = 'Optional (5th)';
        subject = 'Optional (5th)';
        scheduledDate = (Date) c.get('Career_Presentation_Date_Scheduled__c');
        Date cpCompleted = (Date) c.get(
          'Career_Presentation_Date_Completed__c'
        );
        if (cpCompleted != null) {
          completedDate = cpCompleted;
        }
        interviewerRaw = coalesceText(
          getTextFromAny(c.get('Career_Presentation_Conducted_By__c')),
          getTextFromAny(c.get('Career_Conducted_by__c'))
        );
      }
      when SI1 {
        typeLabel = 'Align (2nd)';
        subject = 'Align (2nd)';
        scheduledDate = c.SI_1_Date_Scheduled__c;
        completedDate = c.SI_1_Date_Completed__c;
        interviewerRaw = coalesceText(
          getTextFromAny(c.get('SI_1_Interview_Conducted_by__c')),
          getTextFromAny(c.get('SI_1_Conducted_By__c')),
          getTextFromAny(c.get('SI1_Conducted_by__c'))
        );
      }
      when SI2 {
        typeLabel = 'Plan (3rd)';
        subject = 'Plan (3rd)';
        scheduledDate = c.SI_2_Date_Scheduled__c;
        completedDate = c.SI_2_Date_Completed__c;
        // Allow existing lookup(Contact) field to be used directly if present
        Object maybeLookup = c.get('SI_2_Interviewer__c');
        if (maybeLookup instanceof Id)
          interviewerContactId = (Id) maybeLookup;
        // Also consider text variants
        if (interviewerContactId == null) {
          interviewerRaw = coalesceText(
            getTextFromAny(c.get('SI_2_Conducted_By__c')),
            getTextFromAny(c.get('SI2_Conducted_by__c'))
          );
        }
      }
      when SI3 {
        typeLabel = 'Present (4th)';
        subject = 'Present (4th)';
        scheduledDate = (Date) c.get('SI_3_Scheduled__c');
        completedDate = (Date) c.get('SI_3_Completed__c');
        // Accept lookup(Contact) if exists
        Object maybeLookup3 = c.get('SI_3_Interviewer__c');
        if (maybeLookup3 instanceof Id)
          interviewerContactId = (Id) maybeLookup3;
        // Also consider conducted by text variants
        if (interviewerContactId == null) {
          interviewerRaw = coalesceText(
            getTextFromAny(c.get('SI_3_Conducted_By__c')),
            getTextFromAny(c.get('SI3_Conducted_by__c'))
          );
        }
      }
    }

    // Determine status
    if (completedDate != null) {
      status = 'Complete';
    } else if (scheduledDate != null) {
      status = 'Scheduled';
    } else {
      res.eventsSkipped++;
      return;
    }

    // Compute ActivityDate only (all-day events, no time)
    // Use completed date if available (historical accurate date), otherwise scheduled date
    Date activityDate = completedDate != null ? completedDate : scheduledDate;

    // Resolve interviewer Contact
    if (interviewerContactId == null && interviewerRaw != null) {
      interviewerContactId = resolveContactFromCache(
        interviewerRaw,
        contactCache
      );
      if (interviewerContactId == null) {
        // Log a warning; we will leave Interviewer__c blank and add a note
        res.warnings.add(
          'Contact not resolved for Candidate ' +
            c.Id +
            ' (' +
            typeLabel +
            '): ' +
            interviewerRaw
        );
      }
    }

    // Build External Id
    // Deterministic External Id per Candidate + Stage (no date component)
    String extKey =
      'Candidate:' +
      String.valueOf(c.Id) +
      ':Stage:' +
      type.name();

    // Build candidate name
    String candidateName = '';
    if (c.First_Name__c != null && c.Last_Name__c != null) {
      candidateName = c.First_Name__c + ' ' + c.Last_Name__c;
    } else if (c.Last_Name__c != null) {
      candidateName = c.Last_Name__c;
    }

    // Determine event owner and interviewer lookup
    Id eventOwnerId = UserInfo.getUserId(); // Default to current user
    Id interviewerUserId = null;
    Id interviewerLookupId = null; // For Interviewer__c custom object lookup
    String interviewerName = null; // Track interviewer name for Description field

    if (interviewerRaw != null) {
      interviewerName = interviewerRaw; // Store for Description

      // Check if interviewer is a Salesforce user
      interviewerUserId = resolveUserFromCache(interviewerRaw, userCache);

      if (interviewerUserId != null) {
        // Interviewer is a Salesforce user - assign as owner
        eventOwnerId = interviewerUserId;
      } else {
        // Not a Salesforce user - keep current user as owner
        res.warnings.add(
          'Interviewer "' +
            interviewerRaw +
            '" is not a Salesforce user. Event owned by current user.'
        );
      }

      // Look up Interviewer__c record for the lookup field
      interviewerLookupId = resolveInterviewerFromCache(
        interviewerRaw,
        interviewerCache
      );
    }

    // Create Event with candidate name in subject
    Event e = new Event();
    e.RecordTypeId = interviewRecordTypeId;
    e.Subject = subject + (candidateName != '' ? ' - ' + candidateName : '');
    e.Type = subject; // Type field uses same picklist values as Subject (without candidate name)
    e.ActivityDate = activityDate;
    e.IsAllDayEvent = true;
    // Do not set StartDateTime/EndDateTime for historical all-day records
    e.OwnerId = eventOwnerId;

    // Relate event to Candidate record using WhatId
    e.WhatId = c.Id;

    // Link to Candidate's Contact as WhoId if present (field may not exist in all orgs)
    try {
      Object whoCandidateContact = c.get('Candidate_Contact__c');
      if (whoCandidateContact instanceof Id) {
        e.WhoId = (Id) whoCandidateContact;
      }
    } catch (Exception ex) {
      // Field doesn't exist, skip
    }
    // Set Sales_Manager_Interviewer__c lookup field to link to the Interviewer__c custom object
    if (interviewerLookupId != null) {
      e.put('Sales_Manager_Interviewer__c', interviewerLookupId);
    }
    String note =
      'Migrated from Candidate on ' +
      Date.today().format() +
      ' (' +
      typeLabel +
      ')';
    if (candidateName != '') {
      note += ' | Candidate: ' + candidateName;
    }
    if (interviewerName != null) {
      note += ' | Conducted By: ' + interviewerName;
      if (interviewerUserId != null) {
        note += ' (Assigned to Salesforce user)';
      } else {
        note += ' (Not a Salesforce user - event owned by migration user)';
      }
    }
    // e.put('Notes__c', note);
    e.Description = note; // Use standard Description field instead

    // De-dup within run using extKey
    if (!extKeyToEvent.containsKey(extKey)) {
      extKeyToEvent.put(extKey, e);
      toUpsert.add(e);
    }
  }
  // Return first non-null non-empty string
  private static String coalesceText(String a, String b) {
    for (String s : new List<String>{ a, b }) {
      if (s != null && s.trim().length() > 0)
        return s.trim();
    }
    return null;
  }

  private static String coalesceText(String a, String b, String c) {
    for (String s : new List<String>{ a, b, c }) {
      if (s != null && s.trim().length() > 0)
        return s.trim();
    }
    return null;
  }

  // Extract text value from dynamic field that could be Id/Text/Null
  private static String getTextFromAny(Object val) {
    if (val == null)
      return null;
    if (val instanceof String)
      return (String) val;
    if (val instanceof Id)
      return (String) val;
    return String.valueOf(val);
  }

  // BULK OPTIMIZATION: Build a cache of all Contacts once
  private static Map<String, Id> buildContactCache() {
    Map<String, Id> cache = new Map<String, Id>();

    // Query all Contacts with Email and Name in one go
    List<Contact> allContacts = [
      SELECT Id, Email, FirstName, LastName
      FROM Contact
      WHERE Email != NULL OR (FirstName != NULL AND LastName != NULL)
      LIMIT 10000
    ];

    for (Contact c : allContacts) {
      // Cache by email (lowercase for case-insensitive matching)
      if (c.Email != null && c.Email.trim().length() > 0) {
        String emailKey = c.Email.trim().toLowerCase();
        if (!cache.containsKey(emailKey)) {
          cache.put(emailKey, c.Id);
        }
      }

      // Cache by full name (lowercase for case-insensitive matching)
      if (c.FirstName != null && c.LastName != null) {
        String nameKey = (c.FirstName.trim() +
          ' ' +
          c.LastName.trim())
          .toLowerCase();
        if (!cache.containsKey(nameKey)) {
          cache.put(nameKey, c.Id);
        }
      }
    }

    return cache;
  }

  // Resolve Contact from pre-built cache
  @TestVisible
  private static Id resolveContactFromCache(
    String raw,
    Map<String, Id> contactCache
  ) {
    if (raw == null || contactCache == null)
      return null;
    String s = raw.trim().toLowerCase();

    // Direct lookup in cache (handles both email and full name)
    if (contactCache.containsKey(s)) {
      return contactCache.get(s);
    }

    return null;
  }

  // DEPRECATED: Old method kept for backward compatibility with tests
  // Best-effort Contact resolution: try Email exact, then First Last exact (case-insensitive)
  @TestVisible
  private static Id resolveContact(String raw) {
    if (raw == null)
      return null;

    // Build cache and use new method
    Map<String, Id> cache = buildContactCache();
    return resolveContactFromCache(raw, cache);
  }

  // BULK OPTIMIZATION: Build a cache of all active Salesforce Users once
  private static Map<String, Id> buildUserCache() {
    Map<String, Id> cache = new Map<String, Id>();

    // Query all active Users with Name in one go
    List<User> allUsers = [
      SELECT Id, Name, FirstName, LastName
      FROM User
      WHERE IsActive = TRUE
      LIMIT 10000
    ];

    for (User u : allUsers) {
      // Cache by full name (lowercase for case-insensitive matching)
      if (u.Name != null && u.Name.trim().length() > 0) {
        String nameKey = u.Name.trim().toLowerCase();
        if (!cache.containsKey(nameKey)) {
          cache.put(nameKey, u.Id);
        }
      }

      // Also cache by FirstName LastName if available
      if (u.FirstName != null && u.LastName != null) {
        String altNameKey = (u.FirstName.trim() +
          ' ' +
          u.LastName.trim())
          .toLowerCase();
        if (!cache.containsKey(altNameKey)) {
          cache.put(altNameKey, u.Id);
        }
      }
    }

    return cache;
  }

  // Resolve User from pre-built cache
  @TestVisible
  private static Id resolveUserFromCache(
    String raw,
    Map<String, Id> userCache
  ) {
    if (raw == null || userCache == null)
      return null;
    String s = raw.trim().toLowerCase();

    // Direct lookup in cache (handles full name)
    if (userCache.containsKey(s)) {
      return userCache.get(s);
    }

    return null;
  }

  // Build Interviewer cache - query all Interviewer__c records
  @TestVisible
  private static Map<String, Id> buildInterviewerCache() {
    Map<String, Id> cache = new Map<String, Id>();

    // Query all Interviewer__c records
    for (Interviewer__c interviewer : [SELECT Id, Name FROM Interviewer__c]) {
      if (interviewer.Name != null) {
        String key = interviewer.Name.trim().toLowerCase();
        cache.put(key, interviewer.Id);
      }
    }

    return cache;
  }

  // Resolve Interviewer from pre-built cache
  @TestVisible
  private static Id resolveInterviewerFromCache(
    String raw,
    Map<String, Id> interviewerCache
  ) {
    if (raw == null || interviewerCache == null)
      return null;
    String s = raw.trim().toLowerCase();

    // Direct lookup in cache
    if (interviewerCache.containsKey(s)) {
      return interviewerCache.get(s);
    }

    return null;
  }
}
