// Create candidates and interviews for Tim Denton
User tim = [SELECT Id, Name FROM User WHERE Username = 'tdenton@financialguide.com.recruiting' LIMIT 1];
System.debug('Creating data for Tim Denton');

// Get active users for interviewer assignment
List<User> interviewers = [SELECT Id, Name FROM User WHERE IsActive = true AND UserType = 'Standard' LIMIT 10];

// Create 20 candidates for Tim
List<Candidate__c> candidates = new List<Candidate__c>();
for (Integer i = 0; i < 20; i++) {
    Candidate__c c = new Candidate__c();
    c.First_Name__c = 'Test';
    c.Last_Name__c = 'Candidate' + i;
    c.Name = 'Test Candidate' + i;
    c.Email__c = 'test.candidate' + i + '@test.com';
    c.Phone__c = '555-010-' + (1000 + i);
    c.Status__c = (i < 15) ? 'Interview' : 'New Lead';
    c.OwnerId = tim.Id;
    candidates.add(c);
}

insert candidates;
System.debug('Created ' + candidates.size() + ' candidates');

// Create 10 scheduled interviews
List<Interview__c> interviews = new List<Interview__c>();
List<String> types = new List<String>{'Attraction', 'SI1', 'SI2', 'SI3', 'Career'};

for (Integer i = 0; i < 10; i++) {
    Interview__c interview = new Interview__c();
    interview.Candidate__c = candidates[i].Id;
    interview.Interview_Type__c = types[Math.mod(i, 5)];
    interview.Interview_Status__c = 'Scheduled';
    interview.Date_Time_Scheduled__c = Datetime.now().addDays(i + 1);
    interview.Conducted_By__c = interviewers[Math.mod(i, interviewers.size())].Id;
    interviews.add(interview);
}

insert interviews;
System.debug('Created ' + interviews.size() + ' interviews');

// Verify
System.debug('Total Candidates: ' + [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :tim.Id]);
System.debug('Upcoming Interviews: ' + [SELECT COUNT() FROM Interview__c WHERE Interview_Status__c = 'Scheduled' AND Candidate__r.OwnerId = :tim.Id]);
System.debug('Active Pipeline: ' + [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :tim.Id AND Status__c NOT IN ('Hired', 'Inactive')]);
