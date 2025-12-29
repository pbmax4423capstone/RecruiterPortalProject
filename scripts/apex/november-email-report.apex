// Email-Ready Interview and Call Report for November 2025
// Output formatted for email to Recruiting Director

// Get all Sales Managers (any status) and Active Recruiters
List<User> managers = [
    SELECT Id, Name, UserRole.Name, Profile.Name
    FROM User
    WHERE (
        UserRole.Name LIKE '%Sales Manager%'
        OR Profile.Name LIKE '%Sales Manager%'
    )
    OR (
        IsActive = true
        AND (
            UserRole.Name LIKE '%Recruiter%'
            OR Profile.Name LIKE '%Recruiter%'
        )
    )
    ORDER BY Name
];

// Date ranges for November 2025
Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

// Build Set of manager IDs and names for efficient querying
Set<Id> managerIds = new Set<Id>();
Set<String> managerNames = new Set<String>();
for (User mgr : managers) {
    managerIds.add(mgr.Id);
    managerNames.add(mgr.Name);
}

// Build maps to store counts per manager NAME (since conductor fields are text)
Map<String, Integer> citCounts = new Map<String, Integer>();
Map<String, Integer> alignCounts = new Map<String, Integer>();
Map<String, Integer> planCounts = new Map<String, Integer>();
Map<String, Integer> presentCounts = new Map<String, Integer>();
Map<String, Integer> optionalCounts = new Map<String, Integer>();
Map<Id, Integer> callCounts = new Map<Id, Integer>();

// Initialize all counts to 0
for (User mgr : managers) {
    citCounts.put(mgr.Name, 0);
    alignCounts.put(mgr.Name, 0);
    planCounts.put(mgr.Name, 0);
    presentCounts.put(mgr.Name, 0);
    optionalCounts.put(mgr.Name, 0);
    callCounts.put(mgr.Id, 0);
}

// Query all candidates with COMPLETED interviews in November
List<Candidate__c> candidates = [
    SELECT Id,
        AI_Completed_Date_Time__c,
        Attraction_Interview_Date_Completed__c,
        SI_1_Date_Completed__c,
        SI_2_Date_Completed__c,
        SI_3_Completed__c,
        Career_Presentation_Date_Completed__c,
        AI_Conducted_By__c,
        Attraction_Conducted_by__c,
        Attraction_Interview_Conducted_By__c,
        SI_1_Conducted_By__c,
        SI1_Conducted_by__c,
        SI_2_Conducted_By__c,
        SI_2_Interviewer__c,
        SI2_Conducted_by__c,
        SI_3_Conducted_By__c,
        SI_3_Interviewer__c,
        SI3_Conducted_by__c,
        Career_Presentation_Conducted_By__c,
        CP_Conducted_By__c,
        CP_Interviewer__c
    FROM Candidate__c
    WHERE (
        (AI_Completed_Date_Time__c >= :novemberStart AND AI_Completed_Date_Time__c <= :novemberEnd)
        OR (Attraction_Interview_Date_Completed__c >= :novemberStart AND Attraction_Interview_Date_Completed__c <= :novemberEnd)
        OR (SI_1_Date_Completed__c >= :novemberStart AND SI_1_Date_Completed__c <= :novemberEnd)
        OR (SI_2_Date_Completed__c >= :novemberStart AND SI_2_Date_Completed__c <= :novemberEnd)
        OR (SI_3_Completed__c >= :novemberStart AND SI_3_Completed__c <= :novemberEnd)
        OR (Career_Presentation_Date_Completed__c >= :novemberStart AND Career_Presentation_Date_Completed__c <= :novemberEnd)
    )
];

// Process candidates and count interviews by conductor NAME (using COMPLETED dates)
for (Candidate__c cand : candidates) {
    // CIT - check COMPLETED date and conductor field
    if ((cand.AI_Completed_Date_Time__c >= novemberStart && cand.AI_Completed_Date_Time__c <= novemberEnd)
        || (cand.Attraction_Interview_Date_Completed__c >= novemberStart && cand.Attraction_Interview_Date_Completed__c <= novemberEnd)) {
        String conductorName = null;
        if (cand.AI_Conducted_By__c != null && cand.AI_Conducted_By__c != '') {
            conductorName = cand.AI_Conducted_By__c;
        } else if (cand.Attraction_Conducted_by__c != null && cand.Attraction_Conducted_by__c != '') {
            conductorName = cand.Attraction_Conducted_by__c;
        } else if (cand.Attraction_Interview_Conducted_By__c != null && cand.Attraction_Interview_Conducted_By__c != '') {
            conductorName = cand.Attraction_Interview_Conducted_By__c;
        }
        
        if (conductorName != null) {
            if (managerNames.contains(conductorName)) {
                citCounts.put(conductorName, citCounts.get(conductorName) + 1);
            } else {
                for (User mgr : managers) {
                    List<String> managerNameParts = mgr.Name.split(' ');
                    List<String> conductorNameParts = conductorName.split(' ');
                    if (managerNameParts.size() >= 2 && conductorNameParts.size() >= 2) {
                        String managerLastName = managerNameParts[managerNameParts.size() - 1];
                        String conductorLastName = conductorNameParts[conductorNameParts.size() - 1];
                        if (managerLastName.equalsIgnoreCase(conductorLastName)) {
                            citCounts.put(mgr.Name, citCounts.get(mgr.Name) + 1);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // ALIGN (SI 1) - check COMPLETED date and conductor field
    if (cand.SI_1_Date_Completed__c >= novemberStart && cand.SI_1_Date_Completed__c <= novemberEnd) {
        String conductorName = null;
        if (cand.SI_1_Conducted_By__c != null && cand.SI_1_Conducted_By__c != '') {
            conductorName = cand.SI_1_Conducted_By__c;
        } else if (cand.SI1_Conducted_by__c != null && cand.SI1_Conducted_by__c != '') {
            conductorName = cand.SI1_Conducted_by__c;
        }
        
        if (conductorName != null) {
            if (managerNames.contains(conductorName)) {
                alignCounts.put(conductorName, alignCounts.get(conductorName) + 1);
            } else {
                for (User mgr : managers) {
                    List<String> managerNameParts = mgr.Name.split(' ');
                    List<String> conductorNameParts = conductorName.split(' ');
                    if (managerNameParts.size() >= 2 && conductorNameParts.size() >= 2) {
                        String managerLastName = managerNameParts[managerNameParts.size() - 1];
                        String conductorLastName = conductorNameParts[conductorNameParts.size() - 1];
                        if (managerLastName.equalsIgnoreCase(conductorLastName)) {
                            alignCounts.put(mgr.Name, alignCounts.get(mgr.Name) + 1);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // PLAN (SI 2) - check COMPLETED date and conductor field
    if (cand.SI_2_Date_Completed__c >= novemberStart && cand.SI_2_Date_Completed__c <= novemberEnd) {
        String conductorName = null;
        if (cand.SI_2_Conducted_By__c != null && cand.SI_2_Conducted_By__c != '') {
            conductorName = cand.SI_2_Conducted_By__c;
        } else if (cand.SI_2_Interviewer__c != null && cand.SI_2_Interviewer__c != '') {
            conductorName = cand.SI_2_Interviewer__c;
        } else if (cand.SI2_Conducted_by__c != null && cand.SI2_Conducted_by__c != '') {
            conductorName = cand.SI2_Conducted_by__c;
        }
        
        if (conductorName != null) {
            if (managerNames.contains(conductorName)) {
                planCounts.put(conductorName, planCounts.get(conductorName) + 1);
            } else {
                for (User mgr : managers) {
                    List<String> managerNameParts = mgr.Name.split(' ');
                    List<String> conductorNameParts = conductorName.split(' ');
                    if (managerNameParts.size() >= 2 && conductorNameParts.size() >= 2) {
                        String managerLastName = managerNameParts[managerNameParts.size() - 1];
                        String conductorLastName = conductorNameParts[conductorNameParts.size() - 1];
                        if (managerLastName.equalsIgnoreCase(conductorLastName)) {
                            planCounts.put(mgr.Name, planCounts.get(mgr.Name) + 1);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // PRESENT (SI 3) - check COMPLETED date and conductor field
    if (cand.SI_3_Completed__c >= novemberStart && cand.SI_3_Completed__c <= novemberEnd) {
        String conductorName = null;
        if (cand.SI_3_Conducted_By__c != null && cand.SI_3_Conducted_By__c != '') {
            conductorName = cand.SI_3_Conducted_By__c;
        } else if (cand.SI_3_Interviewer__c != null && cand.SI_3_Interviewer__c != '') {
            conductorName = cand.SI_3_Interviewer__c;
        } else if (cand.SI3_Conducted_by__c != null && cand.SI3_Conducted_by__c != '') {
            conductorName = cand.SI3_Conducted_by__c;
        }
        
        if (conductorName != null) {
            if (managerNames.contains(conductorName)) {
                presentCounts.put(conductorName, presentCounts.get(conductorName) + 1);
            } else {
                for (User mgr : managers) {
                    List<String> managerNameParts = mgr.Name.split(' ');
                    List<String> conductorNameParts = conductorName.split(' ');
                    if (managerNameParts.size() >= 2 && conductorNameParts.size() >= 2) {
                        String managerLastName = managerNameParts[managerNameParts.size() - 1];
                        String conductorLastName = conductorNameParts[conductorNameParts.size() - 1];
                        if (managerLastName.equalsIgnoreCase(conductorLastName)) {
                            presentCounts.put(mgr.Name, presentCounts.get(mgr.Name) + 1);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // OPTIONAL (Career Presentation) - check COMPLETED date and conductor field
    if (cand.Career_Presentation_Date_Completed__c >= novemberStart && cand.Career_Presentation_Date_Completed__c <= novemberEnd) {
        String conductorName = null;
        if (cand.Career_Presentation_Conducted_By__c != null && cand.Career_Presentation_Conducted_By__c != '') {
            conductorName = cand.Career_Presentation_Conducted_By__c;
        } else if (cand.CP_Conducted_By__c != null && cand.CP_Conducted_By__c != '') {
            conductorName = cand.CP_Conducted_By__c;
        } else if (cand.CP_Interviewer__c != null && cand.CP_Interviewer__c != '') {
            conductorName = cand.CP_Interviewer__c;
        }
        
        if (conductorName != null) {
            if (managerNames.contains(conductorName)) {
                optionalCounts.put(conductorName, optionalCounts.get(conductorName) + 1);
            } else {
                for (User mgr : managers) {
                    List<String> managerNameParts = mgr.Name.split(' ');
                    List<String> conductorNameParts = conductorName.split(' ');
                    if (managerNameParts.size() >= 2 && conductorNameParts.size() >= 2) {
                        String managerLastName = managerNameParts[managerNameParts.size() - 1];
                        String conductorLastName = conductorNameParts[conductorNameParts.size() - 1];
                        if (managerLastName.equalsIgnoreCase(conductorLastName)) {
                            optionalCounts.put(mgr.Name, optionalCounts.get(mgr.Name) + 1);
                            break;
                        }
                    }
                }
            }
        }
    }
}

// Query all closed tasks for November using aggregate
for (AggregateResult ar : [
    SELECT OwnerId owner, COUNT(Id) cnt
    FROM Task
    WHERE OwnerId IN :managerIds
    AND IsClosed = true
    AND ActivityDate >= :novemberStart
    AND ActivityDate <= :novemberEnd
    GROUP BY OwnerId
]) {
    Id ownerId = (Id)ar.get('owner');
    Integer count = (Integer)ar.get('cnt');
    callCounts.put(ownerId, count);
}

// Calculate totals
Integer totalCIT = 0;
Integer totalAlign = 0;
Integer totalPlan = 0;
Integer totalPresent = 0;
Integer totalOptional = 0;
Integer totalCalls = 0;

for (User mgr : managers) {
    totalCIT += citCounts.get(mgr.Name);
    totalAlign += alignCounts.get(mgr.Name);
    totalPlan += planCounts.get(mgr.Name);
    totalPresent += presentCounts.get(mgr.Name);
    totalOptional += optionalCounts.get(mgr.Name);
    totalCalls += callCounts.get(mgr.Id);
}

// Build email-ready output
System.debug('===== START EMAIL CONTENT =====\n');
System.debug('Interview & Call Activity Report - November 2025\n');
System.debug('Team Performance Summary\n');
System.debug('Manager/Recruiter          CI  ALIGN  PLAN  PRESENT  OPTIONAL  CALLS');
System.debug('----------------------------------------------------------------------');

for (User manager : managers) {
    Integer citCount = citCounts.get(manager.Name);
    Integer alignCount = alignCounts.get(manager.Name);
    Integer planCount = planCounts.get(manager.Name);
    Integer presentCount = presentCounts.get(manager.Name);
    Integer optionalCount = optionalCounts.get(manager.Name);
    Integer callsMonth = callCounts.get(manager.Id);
    
    // Only show rows with activity
    if (citCount > 0 || alignCount > 0 || planCount > 0 || presentCount > 0 || optionalCount > 0 || callsMonth > 0) {
        String managerName = manager.Name;
        if (managerName.length() > 25) {
            managerName = managerName.substring(0, 22) + '...';
        }
        
        String row = String.format(
            '{0}  {1}    {2}    {3}      {4}    {5}    {6}',
            new List<String>{
                managerName.rightPad(25),
                String.valueOf(citCount).leftPad(2),
                String.valueOf(alignCount).leftPad(3),
                String.valueOf(planCount).leftPad(2),
                String.valueOf(presentCount).leftPad(1),
                String.valueOf(optionalCount).leftPad(6),
                String.valueOf(callsMonth).leftPad(3)
            }
        );
        System.debug(row);
    }
}

System.debug('----------------------------------------------------------------------');
String totalRow = String.format(
    '{0}  {1}    {2}    {3}      {4}    {5}    {6}',
    new List<String>{
        'TOTALS'.rightPad(25),
        String.valueOf(totalCIT).leftPad(2),
        String.valueOf(totalAlign).leftPad(3),
        String.valueOf(totalPlan).leftPad(2),
        String.valueOf(totalPresent).leftPad(1),
        String.valueOf(totalOptional).leftPad(6),
        String.valueOf(totalCalls).leftPad(3)
    }
);
System.debug(totalRow);

System.debug('\nInterview Types:');
System.debug('  CI       = Attraction Interview (1st interview)');
System.debug('  ALIGN    = SI 1 (2nd interview)');
System.debug('  PLAN     = SI 2 (3rd interview)');
System.debug('  PRESENT  = SI 3 (4th interview)');
System.debug('  OPTIONAL = Career Presentation (Optional interview)');
System.debug('\nNote: All counts based on completed interview dates in November 2025.');
System.debug('\n===== END EMAIL CONTENT =====');
