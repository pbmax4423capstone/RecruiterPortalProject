// November 2025 - Count COMPLETED interviews (not scheduled)
// This matches the user's reporting which shows completed dates

Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

// Build manager list
List<User> managers = [
    SELECT Id, Name
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

Set<String> managerNames = new Set<String>();
for (User mgr : managers) {
    managerNames.add(mgr.Name);
}

// Query all candidates with COMPLETED interviews in November
List<Candidate__c> candidates = [
    SELECT Id, Name,
        AI_Completed_Date_Time__c,
        Attraction_Interview_Date_Completed__c,
        SI_1_Date_Completed__c,
        SI_2_Date_Completed__c,
        SI_3_Completed__c,
        Career_Presentation_Date_Completed__c,
        AI_Conducted_By__c,
        Attraction_Conducted_by__c,
        SI_1_Conducted_By__c,
        SI1_Conducted_by__c,
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

System.debug('Total candidates with completed interviews in November: ' + candidates.size());
System.debug('');

// Count by type and conductor
Map<String, Integer> citCounts = new Map<String, Integer>();
Map<String, Integer> alignCounts = new Map<String, Integer>();
Map<String, Integer> planCounts = new Map<String, Integer>();
Map<String, Integer> presentCounts = new Map<String, Integer>();
Map<String, Integer> optionalCounts = new Map<String, Integer>();

for (User mgr : managers) {
    citCounts.put(mgr.Name, 0);
    alignCounts.put(mgr.Name, 0);
    planCounts.put(mgr.Name, 0);
    presentCounts.put(mgr.Name, 0);
    optionalCounts.put(mgr.Name, 0);
}

for (Candidate__c cand : candidates) {
    // CIT - check COMPLETED date
    if ((cand.AI_Completed_Date_Time__c >= novemberStart && cand.AI_Completed_Date_Time__c <= novemberEnd)
        || (cand.Attraction_Interview_Date_Completed__c >= novemberStart && cand.Attraction_Interview_Date_Completed__c <= novemberEnd)) {
        String conductor = cand.AI_Conducted_By__c;
        if (conductor == null || conductor == '') {
            conductor = cand.Attraction_Conducted_by__c;
        }
        
        if (conductor != null && conductor != '') {
            // Try exact match or last name match
            if (managerNames.contains(conductor)) {
                citCounts.put(conductor, citCounts.get(conductor) + 1);
            } else {
                for (User mgr : managers) {
                    List<String> mgrParts = mgr.Name.split(' ');
                    List<String> condParts = conductor.split(' ');
                    if (mgrParts.size() >= 2 && condParts.size() >= 2) {
                        if (mgrParts[mgrParts.size()-1].equalsIgnoreCase(condParts[condParts.size()-1])) {
                            citCounts.put(mgr.Name, citCounts.get(mgr.Name) + 1);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // ALIGN - check COMPLETED date
    if (cand.SI_1_Date_Completed__c >= novemberStart && cand.SI_1_Date_Completed__c <= novemberEnd) {
        String conductor = cand.SI_1_Conducted_By__c;
        if (conductor == null || conductor == '') {
            conductor = cand.SI1_Conducted_by__c;
        }
        
        if (conductor != null && conductor != '') {
            if (managerNames.contains(conductor)) {
                alignCounts.put(conductor, alignCounts.get(conductor) + 1);
            } else {
                for (User mgr : managers) {
                    List<String> mgrParts = mgr.Name.split(' ');
                    List<String> condParts = conductor.split(' ');
                    if (mgrParts.size() >= 2 && condParts.size() >= 2) {
                        if (mgrParts[mgrParts.size()-1].equalsIgnoreCase(condParts[condParts.size()-1])) {
                            alignCounts.put(mgr.Name, alignCounts.get(mgr.Name) + 1);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // PLAN - check COMPLETED date
    if (cand.SI_2_Date_Completed__c >= novemberStart && cand.SI_2_Date_Completed__c <= novemberEnd) {
        String conductor = cand.SI_2_Interviewer__c;
        if (conductor == null || conductor == '') {
            conductor = cand.SI2_Conducted_by__c;
        }
        
        if (conductor != null && conductor != '') {
            if (managerNames.contains(conductor)) {
                planCounts.put(conductor, planCounts.get(conductor) + 1);
            } else {
                for (User mgr : managers) {
                    List<String> mgrParts = mgr.Name.split(' ');
                    List<String> condParts = conductor.split(' ');
                    if (mgrParts.size() >= 2 && condParts.size() >= 2) {
                        if (mgrParts[mgrParts.size()-1].equalsIgnoreCase(condParts[condParts.size()-1])) {
                            planCounts.put(mgr.Name, planCounts.get(mgr.Name) + 1);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // PRESENT - check COMPLETED date
    if (cand.SI_3_Completed__c >= novemberStart && cand.SI_3_Completed__c <= novemberEnd) {
        String conductor = cand.SI_3_Conducted_By__c;
        if (conductor == null || conductor == '') {
            conductor = cand.SI_3_Interviewer__c;
        }
        if (conductor == null || conductor == '') {
            conductor = cand.SI3_Conducted_by__c;
        }
        
        if (conductor != null && conductor != '') {
            if (managerNames.contains(conductor)) {
                presentCounts.put(conductor, presentCounts.get(conductor) + 1);
            } else {
                for (User mgr : managers) {
                    List<String> mgrParts = mgr.Name.split(' ');
                    List<String> condParts = conductor.split(' ');
                    if (mgrParts.size() >= 2 && condParts.size() >= 2) {
                        if (mgrParts[mgrParts.size()-1].equalsIgnoreCase(condParts[condParts.size()-1])) {
                            presentCounts.put(mgr.Name, presentCounts.get(mgr.Name) + 1);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // OPTIONAL - check COMPLETED date
    if (cand.Career_Presentation_Date_Completed__c >= novemberStart && cand.Career_Presentation_Date_Completed__c <= novemberEnd) {
        String conductor = cand.Career_Presentation_Conducted_By__c;
        if (conductor == null || conductor == '') {
            conductor = cand.CP_Conducted_By__c;
        }
        if (conductor == null || conductor == '') {
            conductor = cand.CP_Interviewer__c;
        }
        
        if (conductor != null && conductor != '') {
            if (managerNames.contains(conductor)) {
                optionalCounts.put(conductor, optionalCounts.get(conductor) + 1);
            } else {
                for (User mgr : managers) {
                    List<String> mgrParts = mgr.Name.split(' ');
                    List<String> condParts = conductor.split(' ');
                    if (mgrParts.size() >= 2 && condParts.size() >= 2) {
                        if (mgrParts[mgrParts.size()-1].equalsIgnoreCase(condParts[condParts.size()-1])) {
                            optionalCounts.put(mgr.Name, optionalCounts.get(mgr.Name) + 1);
                            break;
                        }
                    }
                }
            }
        }
    }
}

System.debug('=== COMPLETED INTERVIEWS IN NOVEMBER 2025 ===');
System.debug('');
for (User mgr : managers) {
    Integer cit = citCounts.get(mgr.Name);
    Integer align = alignCounts.get(mgr.Name);
    Integer plan = planCounts.get(mgr.Name);
    Integer present = presentCounts.get(mgr.Name);
    Integer optional = optionalCounts.get(mgr.Name);
    
    if (cit > 0 || align > 0 || plan > 0 || present > 0 || optional > 0) {
        System.debug(mgr.Name + ':');
        System.debug('  CIT: ' + cit + ' | ALIGN: ' + align + ' | PLAN: ' + plan + ' | PRES: ' + present + ' | OPT: ' + optional);
    }
}
