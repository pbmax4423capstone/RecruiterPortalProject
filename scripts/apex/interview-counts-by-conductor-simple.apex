// Interview Counts by Conductor - Condensed Report

System.debug('===== CIT (1st) THIS WEEK =====');
Map<String, Integer> citW = new Map<String, Integer>();
for (Candidate__c c : [SELECT AI_Conducted_By__c FROM Candidate__c WHERE (AI_Completed_Date_Time__c = THIS_WEEK OR Attraction_Interview_Date_Completed__c = THIS_WEEK) AND AI_Conducted_By__c != null]) {
    for (String name : c.AI_Conducted_By__c.split(';')) {
        String n = name.trim();
        citW.put(n, citW.containsKey(n) ? citW.get(n) + 1 : 1);
    }
}
for (String k : citW.keySet()) {
    System.debug(k + ': ' + citW.get(k));
}

System.debug('\n===== CIT (1st) THIS MONTH =====');
Map<String, Integer> citM = new Map<String, Integer>();
for (Candidate__c c : [SELECT AI_Conducted_By__c FROM Candidate__c WHERE (AI_Completed_Date_Time__c = THIS_MONTH OR Attraction_Interview_Date_Completed__c = THIS_MONTH) AND AI_Conducted_By__c != null]) {
    for (String name : c.AI_Conducted_By__c.split(';')) {
        String n = name.trim();
        citM.put(n, citM.containsKey(n) ? citM.get(n) + 1 : 1);
    }
}
for (String k : citM.keySet()) {
    System.debug(k + ': ' + citM.get(k));
}

System.debug('\n===== CIT (1st) THIS YEAR =====');
Map<String, Integer> citY = new Map<String, Integer>();
for (Candidate__c c : [SELECT AI_Conducted_By__c FROM Candidate__c WHERE (AI_Completed_Date_Time__c = THIS_YEAR OR Attraction_Interview_Date_Completed__c = THIS_YEAR) AND AI_Conducted_By__c != null]) {
    for (String name : c.AI_Conducted_By__c.split(';')) {
        String n = name.trim();
        citY.put(n, citY.containsKey(n) ? citY.get(n) + 1 : 1);
    }
}
for (String k : citY.keySet()) {
    System.debug(k + ': ' + citY.get(k));
}

System.debug('\n===== ALIGN (2nd) THIS WEEK =====');
Map<String, Integer> al2W = new Map<String, Integer>();
for (Candidate__c c : [SELECT SI_1_Conducted_By__c FROM Candidate__c WHERE SI_1_Date_Completed__c = THIS_WEEK AND SI_1_Conducted_By__c != null]) {
    String n = c.SI_1_Conducted_By__c.trim();
    al2W.put(n, al2W.containsKey(n) ? al2W.get(n) + 1 : 1);
}
for (String k : al2W.keySet()) {
    System.debug(k + ': ' + al2W.get(k));
}

System.debug('\n===== ALIGN (2nd) THIS MONTH =====');
Map<String, Integer> al2M = new Map<String, Integer>();
for (Candidate__c c : [SELECT SI_1_Conducted_By__c FROM Candidate__c WHERE SI_1_Date_Completed__c = THIS_MONTH AND SI_1_Conducted_By__c != null]) {
    String n = c.SI_1_Conducted_By__c.trim();
    al2M.put(n, al2M.containsKey(n) ? al2M.get(n) + 1 : 1);
}
for (String k : al2M.keySet()) {
    System.debug(k + ': ' + al2M.get(k));
}

System.debug('\n===== ALIGN (2nd) THIS YEAR =====');
Map<String, Integer> al2Y = new Map<String, Integer>();
for (Candidate__c c : [SELECT SI_1_Conducted_By__c FROM Candidate__c WHERE SI_1_Date_Completed__c = THIS_YEAR AND SI_1_Conducted_By__c != null]) {
    String n = c.SI_1_Conducted_By__c.trim();
    al2Y.put(n, al2Y.containsKey(n) ? al2Y.get(n) + 1 : 1);
}
for (String k : al2Y.keySet()) {
    System.debug(k + ': ' + al2Y.get(k));
}

System.debug('\n===== PLAN (3rd) THIS WEEK (SI_2_Interviewer__c) =====');
Map<String, Integer> pl3W = new Map<String, Integer>();
for (Candidate__c c : [SELECT SI_2_Interviewer__c FROM Candidate__c WHERE SI_2_Date_Completed__c = THIS_WEEK AND SI_2_Interviewer__c != null]) {
    String n = c.SI_2_Interviewer__c.trim();
    pl3W.put(n, pl3W.containsKey(n) ? pl3W.get(n) + 1 : 1);
}
for (String k : pl3W.keySet()) {
    System.debug(k + ': ' + pl3W.get(k));
}

System.debug('\n===== PLAN (3rd) THIS MONTH (SI_2_Interviewer__c) =====');
Map<String, Integer> pl3M = new Map<String, Integer>();
for (Candidate__c c : [SELECT SI_2_Interviewer__c FROM Candidate__c WHERE SI_2_Date_Completed__c = THIS_MONTH AND SI_2_Interviewer__c != null]) {
    String n = c.SI_2_Interviewer__c.trim();
    pl3M.put(n, pl3M.containsKey(n) ? pl3M.get(n) + 1 : 1);
}
for (String k : pl3M.keySet()) {
    System.debug(k + ': ' + pl3M.get(k));
}

System.debug('\n===== PLAN (3rd) THIS YEAR (SI_2_Interviewer__c) =====');
Map<String, Integer> pl3Y = new Map<String, Integer>();
for (Candidate__c c : [SELECT SI_2_Interviewer__c FROM Candidate__c WHERE SI_2_Date_Completed__c = THIS_YEAR AND SI_2_Interviewer__c != null]) {
    String n = c.SI_2_Interviewer__c.trim();
    pl3Y.put(n, pl3Y.containsKey(n) ? pl3Y.get(n) + 1 : 1);
}
for (String k : pl3Y.keySet()) {
    System.debug(k + ': ' + pl3Y.get(k));
}

System.debug('\n===== PRESENT (4th) THIS WEEK (SI_3_Conducted_By__c) =====');
Map<String, Integer> pr4W = new Map<String, Integer>();
for (Candidate__c c : [SELECT SI_3_Conducted_By__c FROM Candidate__c WHERE SI_3_Completed__c = THIS_WEEK AND SI_3_Conducted_By__c != null]) {
    String n = c.SI_3_Conducted_By__c.trim();
    pr4W.put(n, pr4W.containsKey(n) ? pr4W.get(n) + 1 : 1);
}
for (String k : pr4W.keySet()) {
    System.debug(k + ': ' + pr4W.get(k));
}

System.debug('\n===== PRESENT (4th) THIS MONTH (SI_3_Conducted_By__c) =====');
Map<String, Integer> pr4M = new Map<String, Integer>();
for (Candidate__c c : [SELECT SI_3_Conducted_By__c FROM Candidate__c WHERE SI_3_Completed__c = THIS_MONTH AND SI_3_Conducted_By__c != null]) {
    String n = c.SI_3_Conducted_By__c.trim();
    pr4M.put(n, pr4M.containsKey(n) ? pr4M.get(n) + 1 : 1);
}
for (String k : pr4M.keySet()) {
    System.debug(k + ': ' + pr4M.get(k));
}

System.debug('\n===== PRESENT (4th) THIS YEAR (SI_3_Conducted_By__c) =====');
Map<String, Integer> pr4Y = new Map<String, Integer>();
for (Candidate__c c : [SELECT SI_3_Conducted_By__c FROM Candidate__c WHERE SI_3_Completed__c = THIS_YEAR AND SI_3_Conducted_By__c != null]) {
    String n = c.SI_3_Conducted_By__c.trim();
    pr4Y.put(n, pr4Y.containsKey(n) ? pr4Y.get(n) + 1 : 1);
}
for (String k : pr4Y.keySet()) {
    System.debug(k + ': ' + pr4Y.get(k));
}

System.debug('\n===== OPTIONAL (5th) THIS WEEK =====');
Map<String, Integer> cpW = new Map<String, Integer>();
for (Candidate__c c : [SELECT CP_Conducted_by__c FROM Candidate__c WHERE Career_Presentation_Date_Completed__c = THIS_WEEK AND CP_Conducted_by__c != null]) {
    for (String name : c.CP_Conducted_by__c.split(';')) {
        String n = name.trim();
        cpW.put(n, cpW.containsKey(n) ? cpW.get(n) + 1 : 1);
    }
}
for (String k : cpW.keySet()) {
    System.debug(k + ': ' + cpW.get(k));
}

System.debug('\n===== OPTIONAL (5th) THIS MONTH =====');
Map<String, Integer> cpM = new Map<String, Integer>();
for (Candidate__c c : [SELECT CP_Conducted_by__c FROM Candidate__c WHERE Career_Presentation_Date_Completed__c = THIS_MONTH AND CP_Conducted_by__c != null]) {
    for (String name : c.CP_Conducted_by__c.split(';')) {
        String n = name.trim();
        cpM.put(n, cpM.containsKey(n) ? cpM.get(n) + 1 : 1);
    }
}
for (String k : cpM.keySet()) {
    System.debug(k + ': ' + cpM.get(k));
}

System.debug('\n===== OPTIONAL (5th) THIS YEAR =====');
Map<String, Integer> cpY = new Map<String, Integer>();
for (Candidate__c c : [SELECT CP_Conducted_by__c FROM Candidate__c WHERE Career_Presentation_Date_Completed__c = THIS_YEAR AND CP_Conducted_by__c != null]) {
    for (String name : c.CP_Conducted_by__c.split(';')) {
        String n = name.trim();
        cpY.put(n, cpY.containsKey(n) ? cpY.get(n) + 1 : 1);
    }
}
for (String k : cpY.keySet()) {
    System.debug(k + ': ' + cpY.get(k));
}
