// Create 15 scheduled interviews for testing Summary Card Metrics component
// Interviews scheduled over next 2 weeks with sales managers as interviewees

// Get active users to assign as interviewers
List<User> activeUsers = [
    SELECT Id, Name 
    FROM User 
    WHERE IsActive = true 
    AND UserType = 'Standard'
    LIMIT 10
];

if (activeUsers.isEmpty()) {
    System.debug('ERROR: No active users found for interview assignment');
    return;
}

System.debug('Found ' + activeUsers.size() + ' active users for interviewer assignment');

// Get candidates
List<Candidate__c> candidates = [
    SELECT Id, Name 
    FROM Candidate__c 
    LIMIT 15
];

if (candidates.isEmpty()) {
    System.debug('ERROR: No candidates found');
    return;
}

System.debug('Found ' + candidates.size() + ' candidates');

// Interview types to cycle through (using correct field API names)
List<String> interviewTypes = new List<String>{
    'Attraction',
    'SI1',
    'SI2', 
    'SI3',
    'Career'
};

List<Interview__c> interviewsToInsert = new List<Interview__c>();

// Create 15 interviews scheduled over next 2 weeks
for (Integer i = 0; i < 15 && i < candidates.size(); i++) {
    Candidate__c candidate = candidates[i];
    
    // Cycle through interview types
    String interviewType = interviewTypes[Math.mod(i, interviewTypes.size())];
    
    // Cycle through users for conducted_by
    User interviewer = activeUsers[Math.mod(i, activeUsers.size())];
    
    // Distribute dates over next 14 days
    Integer daysFromNow = Math.mod(i, 14) + 1; // Days 1-14
    Date interviewDate = Date.today().addDays(daysFromNow);
    
    // Create interview record
    Interview__c interview = new Interview__c(
        Candidate__c = candidate.Id,
        Interview_Type__c = interviewType,
        Interview_Status__c = 'Scheduled',
        Date_Time_Scheduled__c = Datetime.newInstance(interviewDate, Time.newInstance(10, 0, 0, 0)),
        Conducted_By__c = interviewer.Id,
        Notes__c = 'Test interview for Summary Card Metrics - ' + interviewType
    );
    
    interviewsToInsert.add(interview);
    
    System.debug('Interview ' + (i + 1) + ': ' + candidate.Name + ' - ' + interviewType + ' - ' + interviewDate + ' - ' + interviewer.Name);
}

// Insert all interviews
try {
    insert interviewsToInsert;
    System.debug('SUCCESS: Created ' + interviewsToInsert.size() + ' scheduled interviews');
    
    // Verify creation
    List<Interview__c> verifyInterviews = [
        SELECT Id, Candidate__r.Name, Interview_Type__c, Interview_Status__c, Date_Time_Scheduled__c, Conducted_By__r.Name
        FROM Interview__c 
        WHERE Id IN :interviewsToInsert
        ORDER BY Date_Time_Scheduled__c
    ];
    
    System.debug('=== VERIFICATION ===');
    for (Interview__c iv : verifyInterviews) {
        System.debug(iv.Date_Time_Scheduled__c + ' | ' + iv.Interview_Type__c + ' | ' + iv.Candidate__r.Name + ' | ' + iv.Conducted_By__r.Name);
    }
    
    // Count scheduled interviews
    Integer scheduledCount = [
        SELECT COUNT() 
        FROM Interview__c 
        WHERE Interview_Status__c = 'Scheduled'
    ];
    System.debug('Total Scheduled Interviews in system: ' + scheduledCount);
    
} catch (Exception e) {
    System.debug('ERROR creating interviews: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
