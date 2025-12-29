// Create candidates and interviews for Tim Denton
User tim = [SELECT Id, Name FROM User WHERE Username = 'tdenton@financialguide.com.recruiting' LIMIT 1];
System.debug('Creating data for Tim Denton (ID: ' + tim.Id + ')');

// Get active users for interviewer assignment
List<User> interviewers = [SELECT Id, Name FROM User WHERE IsActive = true AND UserType = 'Standard' LIMIT 10];
System.debug('Found ' + interviewers.size() + ' active users for interviewer assignment');

// Create 20 candidates for Tim
List<Candidate__c> candidates = new List<Candidate__c>();
String[] firstNames = new String[]{'Sarah', 'James', 'Emma', 'Michael', 'Olivia', 'William', 'Ava', 'David', 'Sophia', 'John', 'Isabella', 'Robert', 'Mia', 'Daniel', 'Charlotte', 'Joseph', 'Amelia', 'Thomas', 'Harper', 'Christopher'};
String[] lastNames = new String[]{'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'};
String[] statuses = new String[]{'New Lead', 'Qualified', 'Phone Screen', 'Interview', 'Interview', 'Interview', 'Phone Screen', 'Qualified', 'New Lead', 'Interview', 'Phone Screen', 'Qualified', 'Interview', 'New Lead', 'Phone Screen', 'Interview', 'Qualified', 'Interview', 'Phone Screen', 'New Lead'};

for (Integer i = 0; i < 20; i++) {
    Candidate__c c = new Candidate__c();
    c.First_Name__c = firstNames[i];
    c.Last_Name__c = lastNames[i];
    c.Name = firstNames[i] + ' ' + lastNames[i];
    c.Email__c = firstNames[i].toLowerCase() + '.' + lastNames[i].toLowerCase() + '@test.com';
    c.Phone__c = '555-010-' + String.valueOf(1000 + i);
    c.Status__c = statuses[i];
    c.OwnerId = tim.Id;
    candidates.add(c);
}

insert candidates;
System.debug('Created ' + candidates.size() + ' candidates for Tim');

// Create 10 scheduled interviews for Tim's candidates
List<Interview__c> interviews = new List<Interview__c>();
String[] interviewTypes = new String[]{'Attraction', 'SI1', 'SI2', 'SI3', 'Career'};

for (Integer i = 0; i < 10; i++) {
    Interview__c interview = new Interview__c();
    interview.Candidate__c = candidates[i].Id;
    Integer typeIndex = Math.mod(i, 5);
    interview.Interview_Type__c = interviewTypes[typeIndex];
    interview.Interview_Status__c = 'Scheduled';
    interview.Date_Time_Scheduled__c = Datetime.now().addDays(i + 1);
    Integer interviewerIndex = Math.mod(i, interviewers.size());
    interview.Conducted_By__c = interviewers[interviewerIndex].Id;
    interview.Notes__c = 'Test interview for ' + candidates[i].Name;
    interviews.add(interview);
}

insert interviews;
System.debug('SUCCESS: Created ' + interviews.size() + ' scheduled interviews for Tim''s candidates');

// Verify
System.debug('=== VERIFICATION ===');
System.debug('Total Candidates for Tim: ' + [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :tim.Id]);
System.debug('Upcoming Interviews for Tim: ' + [SELECT COUNT() FROM Interview__c WHERE Interview_Status__c = 'Scheduled' AND Candidate__r.OwnerId = :tim.Id]);
System.debug('Active Pipeline for Tim: ' + [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :tim.Id AND Status__c NOT IN ('Hired', 'Inactive')]);
