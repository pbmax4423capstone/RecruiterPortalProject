/**
 * @description Migrates historical interview data from Candidate__c fields to Interview__c records
 * Handles all 5 interview types: Ci-First, Align-2nd, Plan-3rd, Optional-5th, Present-4th
 * Infers interview status (Scheduled/Completed) and outcomes based on subsequent interviews
 * Uses External_Id__c for idempotent migrations (safe to re-run)
 */
public with sharing class InterviewHistoricalMigration {
    
    public class Result {
        public Integer candidatesProcessed = 0;
        public Integer interviewsCreated = 0;
        public Integer interviewsUpdated = 0;
        public Map<String, Integer> interviewsByType = new Map<String, Integer>{
            'Ci-First' => 0,
            'Align-2nd' => 0,
            'Plan-3rd' => 0,
            'Present-4th' => 0,
            'Optional-5th' => 0
        };
        public List<String> warnings = new List<String>();
        public List<String> errors = new List<String>();
    }
    
    // Interview type sequence for outcome determination
    private static final List<String> INTERVIEW_SEQUENCE = new List<String>{
        'Ci-First', 'Align-2nd', 'Plan-3rd', 'Present-4th', 'Optional-5th'
    };
    
    // User cache for conductor resolution
    private static Map<String, Id> userCache;
    
    /**
     * @description Main entry point for migration
     * @param candidates List of Candidate__c records with all interview fields populated
     * @return Result object with migration statistics
     */
    public static Result migrateInterviewsForCandidates(List<Candidate__c> candidates) {
        Result res = new Result();
        res.candidatesProcessed = candidates.size();
        
        // Build user cache once for all candidates
        userCache = buildUserCache();
        
        // Process each candidate and collect Interview__c records
        List<Interview__c> interviewsToUpsert = new List<Interview__c>();
        
        for (Candidate__c cand : candidates) {
            try {
                List<Interview__c> candidateInterviews = processCandidate(cand);
                interviewsToUpsert.addAll(candidateInterviews);
            } catch (Exception e) {
                res.errors.add('Error processing candidate ' + cand.Id + ': ' + e.getMessage());
            }
        }
        
        // Upsert all interviews using External_Id__c for idempotency
        if (!interviewsToUpsert.isEmpty()) {
            try {
                Database.UpsertResult[] results = Database.upsert(
                    interviewsToUpsert, 
                    Interview__c.External_Id__c, 
                    false
                );
                
                // Analyze results
                for (Integer i = 0; i < results.size(); i++) {
                    Database.UpsertResult result = results[i];
                    Interview__c interview = interviewsToUpsert[i];
                    
                    if (result.isSuccess()) {
                        if (result.isCreated()) {
                            res.interviewsCreated++;
                        } else {
                            res.interviewsUpdated++;
                        }
                        // Track by type
                        Integer count = res.interviewsByType.get(interview.Interview_Type__c);
                        res.interviewsByType.put(interview.Interview_Type__c, count + 1);
                    } else {
                        String errorMsg = 'Failed to upsert interview ' + interview.External_Id__c + ': ';
                        for (Database.Error err : result.getErrors()) {
                            errorMsg += err.getMessage() + '; ';
                        }
                        res.errors.add(errorMsg);
                    }
                }
            } catch (Exception e) {
                res.errors.add('Bulk upsert error: ' + e.getMessage());
            }
        }
        
        return res;
    }
    
    /**
     * @description Process all 5 interview types for a single candidate
     * @param candidate Candidate__c record with interview fields populated
     * @return List of Interview__c records to upsert
     */
    private static List<Interview__c> processCandidate(Candidate__c candidate) {
        List<Interview__c> interviews = new List<Interview__c>();
        
        // Track which interviews are completed for outcome determination
        Map<String, Boolean> completedMap = new Map<String, Boolean>();
        
        // First pass: Identify which interviews are completed
        completedMap.put('Ci-First', isInterviewCompleted(
            candidate.AI_Completed_Date_Time__c, 
            candidate.Attraction_Interview_Date_Completed__c
        ));
        completedMap.put('Align-2nd', candidate.SI_1_Date_Completed__c != null);
        completedMap.put('Plan-3rd', candidate.SI_2_Date_Completed__c != null);
        completedMap.put('Present-4th', candidate.Career_Presentation_Date_Completed__c != null);
        completedMap.put('Optional-5th', candidate.SI_3_Completed__c != null);
        
        // Process Ci-First (Attraction Interview)
        Interview__c ciFirst = processAttractionInterview(candidate, completedMap);
        if (ciFirst != null) interviews.add(ciFirst);
        
        // Process Align-2nd (SI1)
        Interview__c alignSecond = processSI1Interview(candidate, completedMap);
        if (alignSecond != null) interviews.add(alignSecond);
        
        // Process Plan-3rd (SI2)
        Interview__c planThird = processSI2Interview(candidate, completedMap);
        if (planThird != null) interviews.add(planThird);
        
        // Process Present-4th (Career Presentation)
        Interview__c presentFourth = processCareerPresentationInterview(candidate, completedMap);
        if (presentFourth != null) interviews.add(presentFourth);
        
        // Process Optional-5th (SI3)
        Interview__c optionalFifth = processSI3Interview(candidate, completedMap);
        if (optionalFifth != null) interviews.add(optionalFifth);
        
        return interviews;
    }
    
    /**
     * @description Process Ci-First (Attraction Interview)
     */
    private static Interview__c processAttractionInterview(
        Candidate__c candidate, 
        Map<String, Boolean> completedMap
    ) {
        Date scheduledDate = candidate.Attraction_Interview_Date_Scheduled__c;
        DateTime completedDateTime = candidate.AI_Completed_Date_Time__c;
        Date completedDate = candidate.Attraction_Interview_Date_Completed__c;
        
        // Check conductor fields in priority order
        String conductor = getFirstNonNull(new List<String>{
            candidate.AI_Conducted_By__c,
            candidate.Attraction_Interview_Conducted_By__c,
            candidate.Attraction_Conducted_by__c
        });
        
        return createInterviewRecord(
            candidate.Id,
            'Ci-First',
            scheduledDate,
            completedDateTime,
            completedDate,
            conductor,
            completedMap
        );
    }
    
    /**
     * @description Process Align-2nd (SI1)
     */
    private static Interview__c processSI1Interview(
        Candidate__c candidate,
        Map<String, Boolean> completedMap
    ) {
        Date scheduledDate = candidate.SI_1_Date_Scheduled__c;
        Date completedDate = candidate.SI_1_Date_Completed__c;
        
        // Check conductor fields in priority order
        String conductor = getFirstNonNull(new List<String>{
            candidate.SI_1_Conducted_By__c,
            candidate.SI_1_Interview_Conducted_by__c,
            candidate.SI1_Conducted_by__c
        });
        
        return createInterviewRecord(
            candidate.Id,
            'Align-2nd',
            scheduledDate,
            null, // No DateTime field for SI1
            completedDate,
            conductor,
            completedMap
        );
    }
    
    /**
     * @description Process Plan-3rd (SI2)
     */
    private static Interview__c processSI2Interview(
        Candidate__c candidate,
        Map<String, Boolean> completedMap
    ) {
        Date scheduledDate = candidate.SI_2_Date_Scheduled__c;
        Date completedDate = candidate.SI_2_Date_Completed__c;
        
        // Check conductor fields in priority order
        String conductor = getFirstNonNull(new List<String>{
            candidate.SI_2_Conducted_By__c,
            candidate.SI2_Conducted_by__c,
            candidate.SI_2_Interviewer__c
        });
        
        return createInterviewRecord(
            candidate.Id,
            'Plan-3rd',
            scheduledDate,
            null, // No DateTime field for SI2
            completedDate,
            conductor,
            completedMap
        );
    }
    
    /**
     * @description Process Present-4th (Career Presentation)
     */
    private static Interview__c processCareerPresentationInterview(
        Candidate__c candidate,
        Map<String, Boolean> completedMap
    ) {
        Date scheduledDate = candidate.Career_Presentation_Date_Scheduled__c;
        Date completedDate = candidate.Career_Presentation_Date_Completed__c;
        
        // Check conductor fields in priority order
        String conductor = getFirstNonNull(new List<String>{
            candidate.CP_Conducted_By__c,
            candidate.Career_Presentation_Conducted_By__c
        });
        
        return createInterviewRecord(
            candidate.Id,
            'Present-4th',
            scheduledDate,
            null, // No DateTime field for Career
            completedDate,
            conductor,
            completedMap
        );
    }
    
    /**
     * @description Process Optional-5th (SI3)
     */
    private static Interview__c processSI3Interview(
        Candidate__c candidate,
        Map<String, Boolean> completedMap
    ) {
        Date scheduledDate = candidate.SI_3_Scheduled__c;
        Date completedDate = candidate.SI_3_Completed__c;
        
        // Check conductor fields in priority order
        String conductor = getFirstNonNull(new List<String>{
            candidate.SI_3_Conducted_By__c,
            candidate.SI3_Conducted_by__c,
            candidate.SI_3_Interviewer__c
        });
        
        return createInterviewRecord(
            candidate.Id,
            'Optional-5th',
            scheduledDate,
            null, // No DateTime field for SI3
            completedDate,
            conductor,
            completedMap
        );
    }
    
    /**
     * @description Create Interview__c record with proper status and outcome
     */
    private static Interview__c createInterviewRecord(
        Id candidateId,
        String interviewType,
        Date scheduledDate,
        DateTime completedDateTime,
        Date completedDate,
        String conductorFieldValue,
        Map<String, Boolean> completedMap
    ) {
        // Determine if we have a completed date (prefer DateTime if available)
        Boolean isCompleted = false;
        DateTime finalCompletedDateTime = null;
        
        if (completedDateTime != null) {
            isCompleted = true;
            finalCompletedDateTime = completedDateTime;
        } else if (completedDate != null) {
            isCompleted = true;
            // Convert Date to DateTime with noon (12:00 PM) as default
            finalCompletedDateTime = DateTime.newInstance(
                completedDate.year(), 
                completedDate.month(), 
                completedDate.day(), 
                12, 0, 0
            );
        }
        
        // Skip if no scheduled or completed date
        if (!isCompleted && scheduledDate == null) {
            return null;
        }
        
        // Determine scheduled DateTime
        DateTime scheduledDateTime;
        if (isCompleted && scheduledDate == null) {
            // If only completed date exists, use it as scheduled date too
            scheduledDateTime = finalCompletedDateTime;
        } else if (scheduledDate != null) {
            // Convert scheduled Date to DateTime with noon (12:00 PM)
            scheduledDateTime = DateTime.newInstance(
                scheduledDate.year(),
                scheduledDate.month(),
                scheduledDate.day(),
                12, 0, 0
            );
        } else {
            // Should not reach here, but safety check
            return null;
        }
        
        // Determine interview status
        String status = isCompleted ? 'Completed' : 'Scheduled';
        
        // Determine outcome (only for completed interviews)
        String outcome = null;
        if (isCompleted) {
            Boolean hasSubsequentCompletedInterview = hasSubsequentCompleted(interviewType, completedMap);
            if (hasSubsequentCompletedInterview) {
                outcome = 'Proceed';
            }
            // Otherwise leave null (last interview or scheduled)
        }
        
        // Resolve conductor to User and interviewer string
        Id conductorUserId = null;
        String interviewerString = null;
        if (String.isNotBlank(conductorFieldValue)) {
            // Parse multi-select picklist (semicolon-separated) and get first conductor
            List<String> conductors = conductorFieldValue.split(';');
            String primaryConductor = conductors[0].trim();
            
            conductorUserId = resolveConductorToUser(primaryConductor);
            interviewerString = primaryConductor;
        }
        
        // Build notes
        String notes = 'Migrated from Candidate record on ' + System.today().format() + '\n';
        if (String.isNotBlank(interviewerString)) {
            notes += 'Conductor: ' + interviewerString + '\n';
        }
        if (scheduledDate != null) {
            notes += 'Scheduled: ' + scheduledDate.format() + '\n';
        }
        if (isCompleted) {
            notes += 'Completed: ' + (completedDate != null ? completedDate.format() : finalCompletedDateTime.format()) + '\n';
        }
        
        // Create Interview__c record
        Interview__c interview = new Interview__c(
            External_Id__c = candidateId + '_' + interviewType,
            Candidate__c = candidateId,
            Interview_Type__c = interviewType,
            Date_Time_Scheduled__c = scheduledDateTime,
            Date_Completed__c = isCompleted ? (completedDate != null ? completedDate : finalCompletedDateTime.date()) : null,
            Interview_Status__c = status,
            Outcome__c = outcome,
            Conducted_By__c = conductorUserId,
            Interviewer_s__c = interviewerString,
            Notes__c = notes
        );
        
        return interview;
    }
    
    /**
     * @description Check if any subsequent interview in the sequence is completed
     * @param currentType Current interview type
     * @param completedMap Map of interview type to completion status
     * @return true if any subsequent interview is completed
     */
    private static Boolean hasSubsequentCompleted(
        String currentType, 
        Map<String, Boolean> completedMap
    ) {
        Boolean foundCurrent = false;
        for (String type : INTERVIEW_SEQUENCE) {
            if (foundCurrent) {
                // Check if this subsequent interview is completed
                if (completedMap.get(type) == true) {
                    return true;
                }
            }
            if (type == currentType) {
                foundCurrent = true;
            }
        }
        return false;
    }
    
    /**
     * @description Resolve conductor name to User ID
     * @param conductorName Name of the conductor
     * @return User ID if found, null otherwise
     */
    private static Id resolveConductorToUser(String conductorName) {
        if (String.isBlank(conductorName)) {
            return null;
        }
        
        // Normalize name
        String normalized = normalizeConductorName(conductorName);
        
        // Look up in user cache
        return userCache.get(normalized.toLowerCase());
    }
    
    /**
     * @description Normalize conductor names for consistent lookup
     * Handles common variations like "Brad" -> "Bradley"
     */
    private static String normalizeConductorName(String name) {
        if (name == null) return null;
        String normalized = name.trim();
        
        // Handle Brad -> Bradley
        if (normalized.equalsIgnoreCase('Brad Sofonia')) {
            return 'Bradley Sofonia';
        }
        
        return normalized;
    }
    
    /**
     * @description Build User cache for efficient conductor resolution
     * @return Map of lowercase user name to User ID
     */
    private static Map<String, Id> buildUserCache() {
        Map<String, Id> cache = new Map<String, Id>();
        
        for (User u : [SELECT Id, Name, FirstName, LastName FROM User WHERE IsActive = true]) {
            cache.put(u.Name.toLowerCase(), u.Id);
            
            if (u.FirstName != null && u.LastName != null) {
                String fullName = (u.FirstName + ' ' + u.LastName).toLowerCase();
                cache.put(fullName, u.Id);
                
                // Handle common name variations
                if (u.FirstName == 'Bradley') {
                    cache.put(('Brad ' + u.LastName).toLowerCase(), u.Id);
                }
            }
        }
        
        // Explicit mapping for Brad Sofonia -> Bradley Sofonia
        for (User u : [SELECT Id FROM User WHERE Name = 'Bradley Sofonia' AND IsActive = true LIMIT 1]) {
            cache.put('brad sofonia', u.Id);
        }
        
        return cache;
    }
    
    /**
     * @description Get first non-null/non-blank value from list
     */
    private static String getFirstNonNull(List<String> values) {
        for (String val : values) {
            if (String.isNotBlank(val)) {
                return val;
            }
        }
        return null;
    }
    
    /**
     * @description Check if Attraction Interview is completed
     * Handles both DateTime and Date fields
     */
    private static Boolean isInterviewCompleted(DateTime completedDateTime, Date completedDate) {
        return completedDateTime != null || completedDate != null;
    }
}
