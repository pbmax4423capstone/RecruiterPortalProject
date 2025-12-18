public with sharing class CandidateToEventInterviewMigration {
    public class Result {
        public Integer candidatesProcessed = 0;
        public Integer eventsUpserted = 0;
        public Integer eventsSkipped = 0;
        public List<String> warnings = new List<String>();
        public List<String> errors = new List<String>();
        public override String toString() {
            return 'Processed=' + candidatesProcessed + ', Upserted=' + eventsUpserted + ', Skipped=' + eventsSkipped +
                ', Warnings=' + warnings.size() + ', Errors=' + errors.size();
        }
    }

    public enum InterviewType {
        AI, CP, SI1, SI2, SI3
    }

    @AuraEnabled
    public static Result migrate(Set<Id> candidateIds, Boolean dryRun, Time startTimeDefault, Integer durationMinutes) {
        if (startTimeDefault == null) startTimeDefault = Time.newInstance(9, 0, 0, 0);
        if (durationMinutes == null) durationMinutes = 60;
        Result res = new Result();

        // Build SOQL field list and query Candidates
        // NOTE: Using dynamic field tokens to avoid compile errors if some fields don't exist in sandbox variants.
        // Replace with strongly-typed fields if all exist in your org.
        String baseQuery = 'SELECT Id, OwnerId, ' +
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
            baseQuery += ' WHERE Id IN :candidateIds';
        }
        List<SObject> genericCandidates = Database.query(baseQuery);
        List<Candidate__c> candidates = new List<Candidate__c>();
        for (SObject sob : genericCandidates) {
            candidates.add((Candidate__c)sob);
        }

        res.candidatesProcessed = candidates.size();
        List<Event> toUpsert = new List<Event>();
        Map<String, Event> extKeyToEvent = new Map<String, Event>();

        for (Candidate__c c : candidates) {
            // Process each interview type
            processInterview(c, InterviewType.AI, startTimeDefault, durationMinutes, res, toUpsert, extKeyToEvent);
            processInterview(c, InterviewType.CP, startTimeDefault, durationMinutes, res, toUpsert, extKeyToEvent);
            processInterview(c, InterviewType.SI1, startTimeDefault, durationMinutes, res, toUpsert, extKeyToEvent);
            processInterview(c, InterviewType.SI2, startTimeDefault, durationMinutes, res, toUpsert, extKeyToEvent);
            processInterview(c, InterviewType.SI3, startTimeDefault, durationMinutes, res, toUpsert, extKeyToEvent);
        }

        if (dryRun) {
            // No DML, just report
            res.warnings.add('Dry run: would upsert ' + toUpsert.size() + ' Event(s).');
            return res;
        }

        if (!toUpsert.isEmpty()) {
            // Upsert on External_Id__c for idempotency
            Database.UpsertResult[] upsr = Database.upsert(toUpsert, Event.External_Id__c, false);
            for (Database.UpsertResult r : upsr) {
                if (r.isSuccess()) {
                    res.eventsUpserted++;
                } else {
                    for (Database.Error e : r.getErrors()) {
                        res.errors.add('Event upsert failed: ' + e.getStatusCode() + ' - ' + e.getMessage());
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
        Map<String, Event> extKeyToEvent
    ) {
        // Determine sources based on type
        Date scheduledDate = null;
        Datetime scheduledDt = null;
        Date completedDate = null;
        Datetime completedDt = null;
        String status = null;
        String typeLabel = null;
        String subject = null;

        // Interviewer resolution inputs (could be lookup(Contact) via Id or free text)
        Id interviewerContactId = null;
        String interviewerRaw = null;

        switch on type {
            when AI {
                typeLabel = 'Attraction (AI)';
                subject = 'Interview - Attraction (AI)';
                scheduledDate = c.Attraction_Interview_Date_Scheduled__c;
                // Completed: either AI_Completed_Date_Time__c (Datetime) or Attraction_Interview_Date_Completed__c (Date)
                if (c.AI_Completed_Date_Time__c != null) {
                    completedDt = c.AI_Completed_Date_Time__c;
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
                typeLabel = 'Career Presentation (CP)';
                subject = 'Interview - Career Presentation';
                scheduledDate = (Date) c.get('Career_Presentation_Date_Scheduled__c');
                Date cpCompleted = (Date) c.get('Career_Presentation_Date_Completed__c');
                if (cpCompleted != null) {
                    completedDate = cpCompleted;
                }
                interviewerRaw = coalesceText(
                    getTextFromAny(c.get('Career_Presentation_Conducted_By__c')),
                    getTextFromAny(c.get('Career_Conducted_by__c'))
                );
            }
            when SI1 {
                typeLabel = 'SI 1';
                subject = 'Interview - SI 1';
                scheduledDate = c.SI_1_Date_Scheduled__c;
                completedDate = c.SI_1_Date_Completed__c;
                interviewerRaw = coalesceText(
                    getTextFromAny(c.get('SI_1_Interview_Conducted_by__c')),
                    getTextFromAny(c.get('SI_1_Conducted_By__c')),
                    getTextFromAny(c.get('SI1_Conducted_by__c'))
                );
            }
            when SI2 {
                typeLabel = 'SI 2';
                subject = 'Interview - SI 2';
                scheduledDate = c.SI_2_Date_Scheduled__c;
                completedDate = c.SI_2_Date_Completed__c;
                // Allow existing lookup(Contact) field to be used directly if present
                Object maybeLookup = c.get('SI_2_Interviewer__c');
                if (maybeLookup instanceof Id) interviewerContactId = (Id) maybeLookup;
                // Also consider text variants
                if (interviewerContactId == null) {
                    interviewerRaw = coalesceText(
                        getTextFromAny(c.get('SI_2_Conducted_By__c')),
                        getTextFromAny(c.get('SI2_Conducted_by__c'))
                    );
                }
            }
            when SI3 {
                typeLabel = 'SI 3';
                subject = 'Interview - SI 3';
                scheduledDate = (Date) c.get('SI_3_Scheduled__c');
                completedDate = (Date) c.get('SI_3_Completed__c');
                // Accept lookup(Contact) if exists
                Object maybeLookup3 = c.get('SI_3_Interviewer__c');
                if (maybeLookup3 instanceof Id) interviewerContactId = (Id) maybeLookup3;
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
        if (completedDt != null || completedDate != null) {
            status = 'Complete';
        } else if (scheduledDate != null || scheduledDt != null) {
            status = 'Scheduled';
        } else {
            res.eventsSkipped++;
            return;
        }

        // Compute ActivityDate and Start/End
        Date activityDate = scheduledDate;
        Datetime startDT = null;
        Datetime endDT = null;

        if (scheduledDt != null) {
            startDT = scheduledDt;
        } else if (scheduledDate != null) {
            startDT = Datetime.newInstance(scheduledDate, startTimeDefault);
        } else if (completedDt != null) {
            // Use completed as fallback for key when no scheduled
            startDT = completedDt;
            activityDate = date.valueOf(completedDt.date());
        } else if (completedDate != null) {
            startDT = Datetime.newInstance(completedDate, startTimeDefault);
            activityDate = completedDate;
        }

        if (startDT != null) {
            endDT = startDT.addMinutes(durationMinutes);
        }

        // Resolve interviewer Contact
        if (interviewerContactId == null && interviewerRaw != null) {
            interviewerContactId = resolveContact(interviewerRaw);
            if (interviewerContactId == null) {
                // Log a warning; we will leave Interviewer__c blank and add a note
                res.warnings.add('Contact not resolved for Candidate ' + c.Id + ' (' + typeLabel + '): ' + interviewerRaw);
            }
        }

        // Build External Id
        String keyDateStr;
        if (activityDate != null) {
            keyDateStr = activityDate.formatGmt('yyyyMMdd');
        } else if (startDT != null) {
            keyDateStr = startDT.formatGmt('yyyyMMdd');
        } else {
            keyDateStr = Datetime.now().formatGmt('yyyyMMddHHmmss');
        }
        String extKey = String.valueOf(c.Id) + '|' + type.name() + '|' + keyDateStr;

        // Create Event
        Event e = new Event();
        e.Subject = subject;
        e.ActivityDate = activityDate;
        if (startDT != null) e.StartDateTime = startDT;
        if (endDT != null) e.EndDateTime = endDT;
        e.OwnerId = c.OwnerId; // default owner rule
        // Custom interview fields on Event
        e.put('Interview_Type__c', typeLabel);
        e.put('Interview_Status__c', status);
        e.put('External_Id__c', extKey);
        e.put('Candidate__c', c.Id);
        if (interviewerContactId != null) {
            e.put('Interviewer__c', interviewerContactId);
        }
        String note = 'Migrated from Candidate on ' + Date.today().format() + ' (' + typeLabel + ')';
        e.put('Notes__c', note);

        // De-dup within run using extKey
        if (!extKeyToEvent.containsKey(extKey)) {
            extKeyToEvent.put(extKey, e);
            toUpsert.add(e);
        }
    }

    // Return first non-null non-empty string
    private static String coalesceText(String a, String b, String c) {
        for (String s : new List<String>{a, b, c}) {
            if (s != null && s.trim().length() > 0) return s.trim();
        }
        return null;
    }

    // Extract text value from dynamic field that could be Id/Text/Null
    private static String getTextFromAny(Object val) {
        if (val == null) return null;
        if (val instanceof String) return (String)val;
        if (val instanceof Id) return (String)val;
        return String.valueOf(val);
    }

    // Best-effort Contact resolution: try Email exact, then First Last exact (case-insensitive)
    @TestVisible private static Id resolveContact(String raw) {
        if (raw == null) return null;
        String s = raw.trim();
        // Email?
        if (s.contains('@')) {
            List<Contact> byEmail = [SELECT Id FROM Contact WHERE Email = :s LIMIT 2];
            if (!byEmail.isEmpty() && byEmail.size() == 1) return byEmail[0].Id;
            return null;
        }
        // Full name: split by space
        List<String> parts = s.split('\\s+');
        if (parts.size() >= 2) {
            String first = parts[0];
            String last = parts[parts.size()-1];
            List<Contact> byName = [
                SELECT Id FROM Contact
                WHERE LOWER(FirstName) = :first.toLowerCase()
                AND LOWER(LastName) = :last.toLowerCase()
                LIMIT 2
            ];
            if (!byName.isEmpty() && byName.size() == 1) return byName[0].Id;
        }
        return null;
    }
}
