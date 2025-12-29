// Check Tim Denton's data
User tim = [SELECT Id, Name FROM User WHERE Username = 'tdenton@financialguide.com.recruiting' LIMIT 1];
System.debug('=== TIM DENTON DATA ===');
System.debug('User ID: ' + tim.Id);

// Total Candidates
Integer totalCandidates = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :tim.Id];
System.debug('Total Candidates: ' + totalCandidates);

// Active Pipeline
Integer activePipeline = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :tim.Id AND Status__c NOT IN ('Hired', 'Inactive')];
System.debug('Active Pipeline: ' + activePipeline);

// Get some candidate names
List<Candidate__c> candidates = [SELECT Id, Name, Status__c FROM Candidate__c WHERE OwnerId = :tim.Id LIMIT 10];
System.debug('First 10 candidates:');
for (Candidate__c c : candidates) {
    System.debug('  - ' + c.Name + ' (Status: ' + c.Status__c + ')');
}

// Upcoming Interviews for Tim's candidates
Integer upcomingInterviews = [
    SELECT COUNT() 
    FROM Interview__c 
    WHERE Interview_Status__c = 'Scheduled' 
    AND Candidate__r.OwnerId = :tim.Id
];
System.debug('Upcoming Interviews: ' + upcomingInterviews);

// Check all interviews for Tim's candidates
List<Interview__c> interviews = [
    SELECT Id, Candidate__r.Name, Interview_Type__c, Interview_Status__c, Date_Time_Scheduled__c
    FROM Interview__c 
    WHERE Candidate__r.OwnerId = :tim.Id
    LIMIT 10
];
System.debug('Tim\'s candidate interviews:');
for (Interview__c i : interviews) {
    System.debug('  - ' + i.Candidate__r.Name + ': ' + i.Interview_Type__c + ' (' + i.Interview_Status__c + ')');
}
