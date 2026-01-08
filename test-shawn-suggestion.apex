// Test interview suggestion for Shawn Montmeny
Id candidateId = [SELECT Id FROM Candidate__c WHERE First_Name__c = 'Shawn' AND Last_Name__c = 'Montmeny' LIMIT 1].Id;

// Get current highest level
Candidate__c candidate = [SELECT Id, Highest_Level_Achieved__c FROM Candidate__c WHERE Id = :candidateId];
System.debug('Highest Level Achieved: ' + candidate.Highest_Level_Achieved__c);

// Get completed interviews
List<Interview__c> completedInterviews = [
    SELECT Id, Interview_Type__c, Interview_Status__c 
    FROM Interview__c 
    WHERE Candidate__c = :candidateId 
    AND Interview_Status__c = 'Completed'
    ORDER BY CreatedDate DESC
];

System.debug('Completed Interviews: ' + completedInterviews.size());
for (Interview__c interview : completedInterviews) {
    System.debug('  - ' + interview.Interview_Type__c);
}

// Calculate next suggestion
List<String> INTERVIEW_SEQUENCE = new List<String>{'Ci-First', 'Align-2nd', 'Plan-3rd', 'Present-4th', 'Optional-5th'};
String nextType = null;

if (completedInterviews.isEmpty()) {
    nextType = 'Ci-First';
} else {
    Set<String> completedTypes = new Set<String>();
    for (Interview__c interview : completedInterviews) {
        completedTypes.add(interview.Interview_Type__c);
    }
    
    for (String type : INTERVIEW_SEQUENCE) {
        if (!completedTypes.contains(type)) {
            nextType = type;
            break;
        }
    }
}

System.debug('Suggested Next Interview Type: ' + nextType);
System.debug('Expected: Align-2nd');
