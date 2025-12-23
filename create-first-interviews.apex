// Create First Interviews (Ci-First) for candidates from Attraction Interview report
// 34 candidates total

// Map of candidate names to their data
Map<String, Map<String, String>> reportData = new Map<String, Map<String, String>>();

// Brad Sofonia - 19 candidates
reportData.put('David Robbins', new Map<String, String>{'date' => '2025-12-05', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Angie Larson', new Map<String, String>{'date' => '2025-12-01', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Brock Payne', new Map<String, String>{'date' => '2025-12-11', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Colton Livingston', new Map<String, String>{'date' => '2025-12-01', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Chriag Shah', new Map<String, String>{'date' => '2025-12-10', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Marquice B', new Map<String, String>{'date' => '2025-12-04', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Kyle Ouellette', new Map<String, String>{'date' => '2025-12-08', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Benjamin Jacquez', new Map<String, String>{'date' => '2025-12-08', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Dallin Speigler', new Map<String, String>{'date' => '2025-12-08', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Donovan Atherley', new Map<String, String>{'date' => '2025-12-08', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Matthew Cain', new Map<String, String>{'date' => '2025-12-08', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Cannon Collins', new Map<String, String>{'date' => '2025-12-08', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Alessandro Corro', new Map<String, String>{'date' => '2025-12-12', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Ron Geddes', new Map<String, String>{'date' => '2025-12-12', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Monte Soderquist', new Map<String, String>{'date' => '2025-12-16', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Haley Horrocks', new Map<String, String>{'date' => '2025-12-15', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Jacob Adams', new Map<String, String>{'date' => '2025-12-18', 'interviewer' => 'Bradley Sofonia'});
reportData.put('David Smith', new Map<String, String>{'date' => '2025-12-18', 'interviewer' => 'Bradley Sofonia'});
reportData.put('Brandon Wiggins', new Map<String, String>{'date' => '2025-12-18', 'interviewer' => 'Bradley Sofonia'});

// Elizabeth Kagele - 2 candidates
reportData.put('LaDonnia Petersen', new Map<String, String>{'date' => '2025-12-11', 'interviewer' => 'Elizabeth Kagele'});
reportData.put('Raymond Yin', new Map<String, String>{'date' => '2025-12-17', 'interviewer' => 'Elizabeth Kagele'});

// Rachyll Tenny - 12 candidates
reportData.put('Sarah Thompson', new Map<String, String>{'date' => '2025-12-10', 'interviewer' => 'Rachyll Tenny'});
reportData.put('Alexander Antione ? Goeas', new Map<String, String>{'date' => '2025-12-11', 'interviewer' => 'Rachyll Tenny'});
reportData.put('Trevon Anderson', new Map<String, String>{'date' => '2025-12-04', 'interviewer' => 'Rachyll Tenny'});
reportData.put('Benjamin Stuenkel', new Map<String, String>{'date' => '2025-12-04', 'interviewer' => 'Rachyll Tenny'});
reportData.put('Yolanda Yang', new Map<String, String>{'date' => '2025-12-02', 'interviewer' => 'Rachyll Tenny'});
reportData.put('Isaiah Abbott', new Map<String, String>{'date' => '2025-12-02', 'interviewer' => 'Rachyll Tenny'});
reportData.put('Lewis Dudley', new Map<String, String>{'date' => '2025-12-05', 'interviewer' => 'Rachyll Tenny'});
reportData.put('Constanza Maria Lupotti', new Map<String, String>{'date' => '2025-12-05', 'interviewer' => 'Rachyll Tenny'});
reportData.put('Alex Rosales', new Map<String, String>{'date' => '2025-12-05', 'interviewer' => 'Rachyll Tenny'});
reportData.put('Skyler Fleming', new Map<String, String>{'date' => '2025-12-09', 'interviewer' => 'Rachyll Tenny'});
reportData.put('Dominic McLaughlin', new Map<String, String>{'date' => '2025-12-17', 'interviewer' => 'Rachyll Tenny'});
reportData.put('Anais Tadlaoui', new Map<String, String>{'date' => '2025-12-15', 'interviewer' => 'Rachyll Tenny'});

// Son Le - 1 candidate
reportData.put('Salina Bouasangouane', new Map<String, String>{'date' => '2025-12-04', 'interviewer' => 'Son Le'});

System.debug('Total candidates in report: ' + reportData.size());

// Get candidate names
Set<String> candidateNames = reportData.keySet();

// Query existing Candidates - try exact match first, then LIKE for partial matches
Map<String, Candidate__c> candidatesByName = new Map<String, Candidate__c>();
for (Candidate__c c : [SELECT Id, Name, Contact__c FROM Candidate__c WHERE Name IN :candidateNames]) {
    candidatesByName.put(c.Name, c);
}

// For names with special characters or spacing issues, try fuzzy match
Set<String> notFoundNames = new Set<String>();
for (String name : candidateNames) {
    if (!candidatesByName.containsKey(name)) {
        notFoundNames.add(name);
    }
}

// Try to find candidates with similar names (handle spacing issues)
if (!notFoundNames.isEmpty()) {
    for (Candidate__c c : [SELECT Id, Name, Contact__c FROM Candidate__c]) {
        String normalizedDbName = c.Name.replaceAll('\\s+', ' ').trim();
        for (String reportName : notFoundNames) {
            String normalizedReportName = reportName.replaceAll('\\s+', ' ').trim();
            // Also try removing special characters
            String cleanReportName = normalizedReportName.replaceAll('[^a-zA-Z ]', '').trim();
            String cleanDbName = normalizedDbName.replaceAll('[^a-zA-Z ]', '').trim();
            
            if (normalizedDbName.equalsIgnoreCase(normalizedReportName) || 
                cleanDbName.equalsIgnoreCase(cleanReportName) ||
                normalizedDbName.containsIgnoreCase(normalizedReportName.split(' ')[0])) {
                if (!candidatesByName.containsKey(reportName)) {
                    candidatesByName.put(reportName, c);
                    System.debug('Fuzzy matched: ' + reportName + ' -> ' + c.Name);
                }
            }
        }
    }
}

System.debug('Found ' + candidatesByName.size() + ' candidates in database');

// Log which candidates were not found
for (String name : candidateNames) {
    if (!candidatesByName.containsKey(name)) {
        System.debug('CANDIDATE NOT FOUND: ' + name);
    }
}

// Get candidate IDs
Set<Id> candidateIds = new Set<Id>();
for (Candidate__c c : candidatesByName.values()) {
    candidateIds.add(c.Id);
}

// Query existing Ci-First interviews for these candidates
Map<Id, Interview__c> existingInterviews = new Map<Id, Interview__c>();
for (Interview__c i : [SELECT Id, Candidate__c, Interview_Type__c, Date_Completed__c, Interviewer_s__c, Conducted_By__c
                       FROM Interview__c 
                       WHERE Candidate__c IN :candidateIds AND Interview_Type__c = 'Ci-First']) {
    existingInterviews.put(i.Candidate__c, i);
}

System.debug('Found ' + existingInterviews.size() + ' existing Ci-First interviews');

// Prepare lists for DML
List<Interview__c> interviewsToUpdate = new List<Interview__c>();
List<Interview__c> interviewsToInsert = new List<Interview__c>();

for (String candName : reportData.keySet()) {
    if (!candidatesByName.containsKey(candName)) {
        continue;
    }
    
    Map<String, String> data = reportData.get(candName);
    String dateStr = data.get('date');
    String interviewer = data.get('interviewer');
    
    // Parse date (format: YYYY-MM-DD)
    List<String> dateParts = dateStr.split('-');
    Date completedDate = Date.newInstance(
        Integer.valueOf(dateParts[0]),
        Integer.valueOf(dateParts[1]),
        Integer.valueOf(dateParts[2])
    );
    
    Candidate__c cand = candidatesByName.get(candName);
    
    if (existingInterviews.containsKey(cand.Id)) {
        // Update existing interview
        Interview__c interview = existingInterviews.get(cand.Id);
        interview.Date_Completed__c = completedDate;
        interview.Interviewer_s__c = interviewer;
        interview.Interview_Status__c = 'Completed';
        interviewsToUpdate.add(interview);
        System.debug('Updating interview for: ' + candName + ' with interviewer: ' + interviewer);
    } else {
        // Create new interview
        Interview__c newInterview = new Interview__c();
        newInterview.Candidate__c = cand.Id;
        newInterview.Interview_Type__c = 'Ci-First';
        newInterview.Date_Completed__c = completedDate;
        newInterview.Date_Time_Scheduled__c = DateTime.newInstance(completedDate, Time.newInstance(9, 0, 0, 0));
        newInterview.Interviewer_s__c = interviewer;
        newInterview.Interview_Status__c = 'Completed';
        interviewsToInsert.add(newInterview);
        System.debug('Creating interview for: ' + candName + ' with interviewer: ' + interviewer);
    }
}

// Perform DML
if (!interviewsToUpdate.isEmpty()) {
    update interviewsToUpdate;
    System.debug('Updated ' + interviewsToUpdate.size() + ' interviews');
}

if (!interviewsToInsert.isEmpty()) {
    insert interviewsToInsert;
    System.debug('Created ' + interviewsToInsert.size() + ' interviews');
}

// VERIFICATION REPORT
System.debug('');
System.debug('========== VERIFICATION REPORT ==========');

// Count interviews by type
List<AggregateResult> typeCounts = [SELECT Interview_Type__c, COUNT(Id) cnt 
                                     FROM Interview__c 
                                     GROUP BY Interview_Type__c 
                                     ORDER BY Interview_Type__c];
System.debug('Interview counts by type:');
for (AggregateResult ar : typeCounts) {
    System.debug('  ' + ar.get('Interview_Type__c') + ': ' + ar.get('cnt'));
}

// Count Ci-First interviews by interviewer (manually since multipicklist can't be grouped)
Map<String, Integer> interviewerCountMap = new Map<String, Integer>();
for (Interview__c i : [SELECT Interviewer_s__c FROM Interview__c WHERE Interview_Type__c = 'Ci-First']) {
    String interviewer = i.Interviewer_s__c != null ? i.Interviewer_s__c : 'NULL';
    if (!interviewerCountMap.containsKey(interviewer)) {
        interviewerCountMap.put(interviewer, 0);
    }
    interviewerCountMap.put(interviewer, interviewerCountMap.get(interviewer) + 1);
}
System.debug('');
System.debug('Ci-First interviews by interviewer:');
for (String interviewer : interviewerCountMap.keySet()) {
    System.debug('  ' + interviewer + ': ' + interviewerCountMap.get(interviewer));
}

// Verify all 34 candidates have interviews
Integer totalCiFirst = [SELECT COUNT() FROM Interview__c WHERE Interview_Type__c = 'Ci-First'];
System.debug('');
System.debug('Total Ci-First interviews: ' + totalCiFirst);
System.debug('Expected: 34');
System.debug('Match: ' + (totalCiFirst == 34 ? 'YES' : 'NO - MISMATCH!'));

// Verify all interviews have candidates linked
Integer interviewsWithCandidate = [SELECT COUNT() FROM Interview__c WHERE Interview_Type__c = 'Ci-First' AND Candidate__c != null];
System.debug('');
System.debug('Ci-First interviews with linked candidate: ' + interviewsWithCandidate);

// Verify all interviews have interviewer set
Integer interviewsWithInterviewer = [SELECT COUNT() FROM Interview__c WHERE Interview_Type__c = 'Ci-First' AND Interviewer_s__c != null];
System.debug('Ci-First interviews with interviewer set: ' + interviewsWithInterviewer);

System.debug('========================================');
