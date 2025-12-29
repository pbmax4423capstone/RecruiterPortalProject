// Create varied test data for all sales managers
// Tim already has data, so we'll create for Elizabeth

// Get the sales managers
User elizabeth = [SELECT Id, Name FROM User WHERE Username = 'ekagele@financialguide.com.recruiting' LIMIT 1];
User tim = [SELECT Id, Name FROM User WHERE Username = 'tdenton@financialguide.com.recruiting' LIMIT 1];

System.debug('=== CREATING TEST DATA FOR SALES MANAGERS ===');
System.debug('Elizabeth: ' + elizabeth.Id);
System.debug('Tim: ' + tim.Id);

// Get active users for interviewer assignment
List<User> interviewers = [SELECT Id FROM User WHERE IsActive = true AND UserType = 'Standard' LIMIT 10];

// ELIZABETH KAGELE - 28 candidates, 12 interviews, 3 hired this month
List<Candidate__c> elizabethCandidates = new List<Candidate__c>();
for (Integer i = 0; i < 28; i++) {
    Candidate__c c = new Candidate__c();
    c.First_Name__c = 'Elizabeth';
    c.Last_Name__c = 'Candidate' + i;
    c.Name = 'Elizabeth Candidate' + i;
    c.Email__c = 'elizabeth.candidate' + i + '@test.com';
    c.Phone__c = '555-030-' + (1000 + i);
    c.Status__c = (i < 3) ? 'Hired' : (i < 25) ? 'Interview' : 'Qualified';
    c.Start_Date__c = (i < 3) ? Date.today().addDays(-i * 2) : null;
    c.OwnerId = elizabeth.Id;
    elizabethCandidates.add(c);
}
insert elizabethCandidates;
System.debug('Created 28 candidates for Elizabeth');

// Elizabeth interviews - 12 scheduled
List<Interview__c> elizabethInterviews = new List<Interview__c>();
List<String> types = new List<String>{'Attraction', 'SI1', 'SI2', 'SI3', 'Career'};
for (Integer i = 0; i < 12; i++) {
    Interview__c interview = new Interview__c();
    interview.Candidate__c = elizabethCandidates[i + 3].Id;
    interview.Interview_Type__c = types[Math.mod(i, 5)];
    interview.Interview_Status__c = 'Scheduled';
    interview.Date_Time_Scheduled__c = Datetime.now().addDays(i + 2);
    interview.Conducted_By__c = interviewers[Math.mod(i, interviewers.size())].Id;
    elizabethInterviews.add(interview);
}
insert elizabethInterviews;
System.debug('Created 12 interviews for Elizabeth');

// SUMMARY
System.debug('=== DATA CREATION SUMMARY ===');
System.debug('ELIZABETH: 28 candidates, 12 interviews, 3 hired this month, 25 active pipeline');
System.debug('TIM: 20 candidates, 10 interviews, 0 hired this month, 20 active pipeline');

// Verify Elizabeth
Integer elizabethTotal = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :elizabeth.Id];
Integer elizabethInterviews2 = [SELECT COUNT() FROM Interview__c WHERE Interview_Status__c = 'Scheduled' AND Candidate__r.OwnerId = :elizabeth.Id];
Integer elizabethActive = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :elizabeth.Id AND Status__c NOT IN ('Hired', 'Inactive')];
Integer elizabethHired = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :elizabeth.Id AND Status__c = 'Hired' AND Start_Date__c = THIS_MONTH];

System.debug('Elizabeth Verification: Total=' + elizabethTotal + ', Interviews=' + elizabethInterviews2 + ', Active=' + elizabethActive + ', Hired=' + elizabethHired);

// Verify Tim
Integer timTotal = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :tim.Id];
Integer timInterviews = [SELECT COUNT() FROM Interview__c WHERE Interview_Status__c = 'Scheduled' AND Candidate__r.OwnerId = :tim.Id];
Integer timActive = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :tim.Id AND Status__c NOT IN ('Hired', 'Inactive')];
Integer timHired = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :tim.Id AND Status__c = 'Hired' AND Start_Date__c = THIS_MONTH];

System.debug('Tim Verification: Total=' + timTotal + ', Interviews=' + timInterviews + ', Active=' + timActive + ', Hired=' + timHired);
