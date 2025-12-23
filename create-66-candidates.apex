// Create 66 Candidates and their Interviews in recruiting sandbox
// Data from the two reports

// First, create all candidates
List<Candidate__c> candidatesToCreate = new List<Candidate__c>();

// Helper function to parse name
// Returns map with firstName, lastName

// All 66 candidates from the reports
// Map: Name -> Map of (stage, manager)
Map<String, Map<String, String>> allCandidates = new Map<String, Map<String, String>>();

// From Report 1 - 66 candidates with Highest Level Achieved and Sales Manager
// Ci(1st) - 23 candidates
allCandidates.put('Andrew Moran', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Son Le'});
allCandidates.put('Tyler Jones', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
allCandidates.put('Jacob Pesicka', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
allCandidates.put('Alonso Maciel', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
allCandidates.put('Matt Diamond', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
allCandidates.put('Heather Hackett', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Van Hess'});
allCandidates.put('Preston Lee', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Robert Wilson', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Alec Bucklen', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Michael Madsen', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Washington Ibarra', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Angie Larson', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Mary Candidate', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Christopher Candidate', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Vanina Candidate', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Cassandra Candidate', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Mason Candidate', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Neil Candidate', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Tom Candidate', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Emily Pendleton', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Pierre Perez', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Daisa Alvarez', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Kim Tapia', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});

// Align (2nd) - 13 candidates
allCandidates.put('Marisol ONeil', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Son Le'});
allCandidates.put('Calix Boldt', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Tim Denton'});
allCandidates.put('Yvonne Garcia', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Tim Denton'});
allCandidates.put('Michael Donatucci', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Tim Denton'});
allCandidates.put('Spencer Candidate', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Jim Candidate', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Ikem Candidate', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Blake Candidate', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Niell Candidate', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Mitch Candidate', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Nolan Candidate', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Jesse Goldberg', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Pierre Marcel Perez', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});

// Plan (3rd) - 4 candidates
allCandidates.put('Paras Bengco', new Map<String, String>{'stage' => 'Plan-3rd', 'manager' => 'Tim Denton'});
allCandidates.put('Sabrina Moya', new Map<String, String>{'stage' => 'Plan-3rd', 'manager' => 'Tim Denton'});
allCandidates.put('Marcus Filardi', new Map<String, String>{'stage' => 'Plan-3rd', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Gwyneth Landaburu', new Map<String, String>{'stage' => 'Plan-3rd', 'manager' => 'Elizabeth Kagele'});

// Present(4th) - 6 candidates
allCandidates.put('Joseph Ramirez', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Tim Denton'});
allCandidates.put('Katerina Minevich', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Tim Denton'});
allCandidates.put('Faye Ferguson', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Ryan Candidate', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Allan Candidate', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Roger Olson', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Elizabeth Kagele'});

// Optional (5th) - 6 candidates
allCandidates.put('Jonathan Espinoza', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Tim Denton'});
allCandidates.put('Craig Lytle', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Tim Denton'});
allCandidates.put('Adam Pryor', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Tim Denton'});
allCandidates.put('Paula Candidate', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Joseph Candidate', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Matt Stewart', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Elizabeth Kagele'});

// 1-Attr Int - 14 candidates 
allCandidates.put('Salina Bouasangouane', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Son Le'});
allCandidates.put('Zack Jones', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
allCandidates.put('Mary Beth Jackson', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
allCandidates.put('Dominic McLaughlin', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
allCandidates.put('David Robbins', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Toby Taylor', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Travis Jorgensen', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Colton Livingston', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Kyle Ouellette', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Skyler Fleming', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Monte Soderquist', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('David Smith', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
allCandidates.put('Jennifer Ronquillo', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
allCandidates.put('Raymond Yin', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});

System.debug('Total candidates to create: ' + allCandidates.size());

// Create candidate records
for (String fullName : allCandidates.keySet()) {
    Map<String, String> data = allCandidates.get(fullName);
    
    // Parse first and last name
    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts[0];
    String lastName = nameParts.size() > 1 ? nameParts[nameParts.size() - 1] : 'Unknown';
    
    // Handle multi-part names
    if (nameParts.size() > 2) {
        // Last name is everything after first name
        lastName = '';
        for (Integer i = 1; i < nameParts.size(); i++) {
            lastName += (i > 1 ? ' ' : '') + nameParts[i];
        }
    }
    
    Candidate__c newCand = new Candidate__c();
    newCand.First_Name__c = firstName;
    newCand.Last_Name__c = lastName;
    newCand.Name = fullName;
    newCand.Sales_Manager__c = data.get('manager');
    newCand.Status__c = 'Active';
    
    candidatesToCreate.add(newCand);
}

// Insert candidates
insert candidatesToCreate;
System.debug('Created ' + candidatesToCreate.size() + ' candidates');

// Create a map of candidate names to IDs
Map<String, Id> candidateNameToId = new Map<String, Id>();
for (Candidate__c c : candidatesToCreate) {
    candidateNameToId.put(c.Name, c.Id);
}

// Now create interviews based on their stage
List<Interview__c> interviewsToCreate = new List<Interview__c>();

// Map Sales_Manager names to Interviewer_s__c names (they use different values for Brad/Bradley)
Map<String, String> managerToInterviewer = new Map<String, String>{
    'Brad Sofonia' => 'Bradley Sofonia',
    'Son Le' => 'Son Le',
    'Tim Denton' => 'Tim Denton',
    'Van Hess' => 'Van Hess',
    'Elizabeth Kagele' => 'Elizabeth Kagele'
};

for (String fullName : allCandidates.keySet()) {
    Map<String, String> data = allCandidates.get(fullName);
    String stage = data.get('stage');
    String manager = data.get('manager');
    String interviewer = managerToInterviewer.get(manager);
    Id candId = candidateNameToId.get(fullName);
    
    if (candId == null) continue;
    
    // Create interview at their highest level achieved
    Interview__c newInterview = new Interview__c();
    newInterview.Candidate__c = candId;
    newInterview.Interview_Type__c = stage;
    newInterview.Interviewer_s__c = interviewer;
    newInterview.Interview_Status__c = 'Completed';
    newInterview.Date_Completed__c = Date.today().addDays(-7); // Default to a week ago
    newInterview.Date_Time_Scheduled__c = DateTime.now().addDays(-7);
    
    interviewsToCreate.add(newInterview);
}

// Insert interviews
insert interviewsToCreate;
System.debug('Created ' + interviewsToCreate.size() + ' interviews');

// VERIFICATION REPORT
System.debug('');
System.debug('========== VERIFICATION REPORT ==========');
System.debug('Total Candidates: ' + [SELECT COUNT() FROM Candidate__c]);
System.debug('Total Interviews: ' + [SELECT COUNT() FROM Interview__c]);

// Count by stage
List<AggregateResult> stageCounts = [SELECT Interview_Type__c, COUNT(Id) cnt 
                                      FROM Interview__c 
                                      GROUP BY Interview_Type__c 
                                      ORDER BY Interview_Type__c];
System.debug('');
System.debug('Interviews by Stage:');
for (AggregateResult ar : stageCounts) {
    System.debug('  ' + ar.get('Interview_Type__c') + ': ' + ar.get('cnt'));
}

// Count by interviewer (manual since multipicklist)
Map<String, Integer> interviewerCounts = new Map<String, Integer>();
for (Interview__c i : [SELECT Interviewer_s__c FROM Interview__c]) {
    String interviewer = i.Interviewer_s__c != null ? i.Interviewer_s__c : 'NULL';
    if (!interviewerCounts.containsKey(interviewer)) {
        interviewerCounts.put(interviewer, 0);
    }
    interviewerCounts.put(interviewer, interviewerCounts.get(interviewer) + 1);
}
System.debug('');
System.debug('Interviews by Interviewer:');
for (String interviewer : interviewerCounts.keySet()) {
    System.debug('  ' + interviewer + ': ' + interviewerCounts.get(interviewer));
}

System.debug('========================================');

