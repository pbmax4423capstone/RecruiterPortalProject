// Check the most recent interview created
List<Interview__c> recentInterviews = [
    SELECT Id, 
           Name,
           Candidate__c,
           Candidate__r.Name,
           Interview_Type__c,
           Interviewer_s__c,
           Date_Time_Scheduled__c,
           CreatedDate
    FROM Interview__c
    ORDER BY CreatedDate DESC
    LIMIT 5
];

System.debug('=== MOST RECENT INTERVIEWS ===');
for (Interview__c interview : recentInterviews) {
    System.debug('Interview: ' + interview.Name);
    System.debug('  ID: ' + interview.Id);
    System.debug('  Candidate ID: ' + interview.Candidate__c);
    System.debug('  Candidate Name: ' + interview.Candidate__r.Name);
    System.debug('  Interview Type: ' + interview.Interview_Type__c);
    System.debug('  Interviewers: ' + interview.Interviewer_s__c);
    System.debug('  Scheduled: ' + interview.Date_Time_Scheduled__c);
    System.debug('  Created: ' + interview.CreatedDate);
    System.debug('---');
}
