// Update Interview records based on the report data
// Maps Highest Level Achieved to Interview Type and sets Sales Manager as Conducted By

// Map of candidate names to their data from report
Map<String, Map<String, String>> reportData = new Map<String, Map<String, String>>();

// Ci(1st) - 23 candidates
reportData.put('Andrew Moran', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Son Le'});
reportData.put('Tyler Jones', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
reportData.put('Jacob Pesicka', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
reportData.put('Alonso Maciel', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
reportData.put('Matt Diamond', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
reportData.put('Heather Hackett', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Van Hess'});
reportData.put('Preston Lee', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Robert Wilson', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Alec Bucklen', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Michael Madsen', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Washington Ibarra', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Angie Larson', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Mary', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
reportData.put('Christopher', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
reportData.put('Vanina', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
reportData.put('Cassandra', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
reportData.put('Mason', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
reportData.put('Neil', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
reportData.put('Tom', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
reportData.put('Emily Pendleton', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
reportData.put('Pierre Perez', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
reportData.put('Daisa Alvarez', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
reportData.put('Kim Tapia', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});

// Align (2nd) - 13 candidates
reportData.put('Marisol ONeil', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Son Le'});
reportData.put('Calix Boldt', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Tim Denton'});
reportData.put('Yvonne Garcia', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Tim Denton'});
reportData.put('Michael Donatucci', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Tim Denton'});
reportData.put('Spencer', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
reportData.put('Jim', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
reportData.put('Ikem', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
reportData.put('Blake', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
reportData.put('Niell', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
reportData.put('Mitch', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
reportData.put('Nolan', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
reportData.put('Jesse Goldberg', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});
reportData.put('Pierre Marcel Perez', new Map<String, String>{'stage' => 'Align-2nd', 'manager' => 'Elizabeth Kagele'});

// Plan (3rd) - 3 candidates
reportData.put('Paras Bengco', new Map<String, String>{'stage' => 'Plan-3rd', 'manager' => 'Tim Denton'});
reportData.put('Sabrina Moya', new Map<String, String>{'stage' => 'Plan-3rd', 'manager' => 'Tim Denton'});
reportData.put('Marcus Filardi', new Map<String, String>{'stage' => 'Plan-3rd', 'manager' => 'Elizabeth Kagele'});

// Present(4th) - 6 candidates
reportData.put('Joseph Ramirez SL', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Tim Denton'});
reportData.put('Katerina Minevich', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Tim Denton'});
reportData.put('Faye Ferguson', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Elizabeth Kagele'});
reportData.put('Ryan', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Elizabeth Kagele'});
reportData.put('Allan', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Elizabeth Kagele'});
reportData.put('Roger Olson', new Map<String, String>{'stage' => 'Present-4th', 'manager' => 'Elizabeth Kagele'});

// Optional (5th) - 6 candidates
reportData.put('Jonathan Espinoza', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Tim Denton'});
reportData.put('Craig Lytle', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Tim Denton'});
reportData.put('Adam Pryor', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Tim Denton'});
reportData.put('Paula', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Elizabeth Kagele'});
reportData.put('Joseph', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Elizabeth Kagele'});
reportData.put('Matt Stewart CFP', new Map<String, String>{'stage' => 'Optional-5th', 'manager' => 'Elizabeth Kagele'});

// 4-SI_3 - 1 candidate (keeping as special stage)
reportData.put('Gwyneth Landaburu', new Map<String, String>{'stage' => 'Plan-3rd', 'manager' => 'Elizabeth Kagele'});

// 1-Attr Int - 14 candidates (converting to Ci-First per user request)
reportData.put('Salina Bouasangouane', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Son Le'});
reportData.put('Zack Jones', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
reportData.put('Mary Beth Jackson', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
reportData.put('Dominic McLaughlin', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Tim Denton'});
reportData.put('David Robbins', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Toby Taylor', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Travis Jorgensen', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Colton Livingston', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Kyle Ouellette', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Skyler Fleming', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Monte Soderquist', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('David Smith', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Brad Sofonia'});
reportData.put('Jennifer Ronquillo', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});
reportData.put('Raymond Yin', new Map<String, String>{'stage' => 'Ci-First', 'manager' => 'Elizabeth Kagele'});

// Get all Sales Managers (Users)
Map<String, Id> managerNameToId = new Map<String, Id>();
for (User u : [SELECT Id, Name FROM User WHERE Name IN ('Son Le', 'Tim Denton', 'Van Hess', 'Brad Sofonia', 'Elizabeth Kagele') AND IsActive = true]) {
    managerNameToId.put(u.Name, u.Id);
}
System.debug('Found managers: ' + managerNameToId.keySet());

// Get all candidate names from report
Set<String> candidateNames = reportData.keySet();

// Query existing Candidates
Map<String, Candidate__c> candidatesByName = new Map<String, Candidate__c>();
for (Candidate__c c : [SELECT Id, Name FROM Candidate__c WHERE Name IN :candidateNames]) {
    candidatesByName.put(c.Name, c);
}
System.debug('Found ' + candidatesByName.size() + ' candidates in database');

// Query existing Interviews for these candidates
Map<Id, List<Interview__c>> interviewsByCandidate = new Map<Id, List<Interview__c>>();
Set<Id> candidateIds = new Set<Id>();
for (Candidate__c c : candidatesByName.values()) {
    candidateIds.add(c.Id);
}

for (Interview__c i : [SELECT Id, Name, Interview_Type__c, Conducted_By__c, Candidate__c, Candidate__r.Name 
                       FROM Interview__c 
                       WHERE Candidate__c IN :candidateIds]) {
    if (!interviewsByCandidate.containsKey(i.Candidate__c)) {
        interviewsByCandidate.put(i.Candidate__c, new List<Interview__c>());
    }
    interviewsByCandidate.get(i.Candidate__c).add(i);
}

// Update or create Interview records
List<Interview__c> interviewsToUpdate = new List<Interview__c>();
List<Interview__c> interviewsToInsert = new List<Interview__c>();
Integer updatedCount = 0;
Integer createdCount = 0;

for (String candName : reportData.keySet()) {
    Map<String, String> data = reportData.get(candName);
    String targetStage = data.get('stage');
    String managerName = data.get('manager');
    Id managerId = managerNameToId.get(managerName);
    
    if (!candidatesByName.containsKey(candName)) {
        System.debug('Candidate not found: ' + candName);
        continue;
    }
    
    Candidate__c cand = candidatesByName.get(candName);
    List<Interview__c> existingInterviews = interviewsByCandidate.get(cand.Id);
    
    Boolean foundMatchingInterview = false;
    
    if (existingInterviews != null) {
        for (Interview__c interview : existingInterviews) {
            // Update the interview if it matches the stage or is the only one
            if (interview.Interview_Type__c == targetStage || existingInterviews.size() == 1) {
                interview.Interview_Type__c = targetStage;
                interview.Conducted_By__c = managerId;
                interviewsToUpdate.add(interview);
                foundMatchingInterview = true;
                updatedCount++;
                System.debug('Updating interview for ' + candName + ' to stage ' + targetStage + ' with manager ' + managerName);
                break;
            }
        }
    }
    
    // If no existing interview found, create one
    if (!foundMatchingInterview && (existingInterviews == null || existingInterviews.isEmpty())) {
        Interview__c newInterview = new Interview__c();
        newInterview.Candidate__c = cand.Id;
        newInterview.Interview_Type__c = targetStage;
        newInterview.Conducted_By__c = managerId;
        newInterview.Interview_Status__c = 'Completed';
        newInterview.Date_Time_Scheduled__c = DateTime.now().addDays(-30); // Set to past date for completed interviews
        newInterview.Date_Completed__c = Date.today().addDays(-30);
        interviewsToInsert.add(newInterview);
        createdCount++;
        System.debug('Creating new interview for ' + candName + ' with stage ' + targetStage + ' and manager ' + managerName);
    }
}

// Perform updates
if (!interviewsToUpdate.isEmpty()) {
    update interviewsToUpdate;
    System.debug('Updated ' + interviewsToUpdate.size() + ' interviews');
}

if (!interviewsToInsert.isEmpty()) {
    insert interviewsToInsert;
    System.debug('Created ' + interviewsToInsert.size() + ' interviews');
}

System.debug('=== SUMMARY ===');
System.debug('Total candidates in report: ' + reportData.size());
System.debug('Candidates found in database: ' + candidatesByName.size());
System.debug('Interviews updated: ' + updatedCount);
System.debug('Interviews created: ' + createdCount);
