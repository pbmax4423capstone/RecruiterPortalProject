// Direct test of getNextInterviewType for Shawn Montmeny
Id candidateId = [SELECT Id FROM Candidate__c WHERE First_Name__c = 'Shawn' AND Last_Name__c = 'Montmeny' LIMIT 1].Id;

System.debug('Testing getNextInterviewType for candidate: ' + candidateId);

// Simulate what the Apex method does
List<Interview__c> completedInterviews = [
    SELECT Id, Interview_Type__c
    FROM Interview__c
    WHERE Candidate__c = :candidateId
    AND Interview_Status__c = 'Completed'
    ORDER BY CreatedDate DESC
];

System.debug('Found ' + completedInterviews.size() + ' completed interviews');
for (Interview__c interview : completedInterviews) {
    System.debug('  Completed: ' + interview.Interview_Type__c);
}

List<String> INTERVIEW_SEQUENCE = new List<String>{'Ci-First', 'Align-2nd', 'Plan-3rd', 'Present-4th', 'Optional-5th'};

if (completedInterviews.isEmpty()) {
    System.debug('Result: Ci-First (no completed interviews)');
} else {
    Set<String> completedTypes = new Set<String>();
    for (Interview__c interview : completedInterviews) {
        completedTypes.add(interview.Interview_Type__c);
    }
    
    System.debug('Completed types set: ' + completedTypes);
    
    String nextType = null;
    for (String type : INTERVIEW_SEQUENCE) {
        System.debug('Checking if ' + type + ' is completed...');
        if (!completedTypes.contains(type)) {
            nextType = type;
            System.debug('  -> Not completed! This is the next one.');
            break;
        } else {
            System.debug('  -> Already completed, skip.');
        }
    }
    
    if (nextType != null) {
        System.debug('Result: ' + nextType);
    } else {
        System.debug('Result: null (all interviews completed)');
    }
}
