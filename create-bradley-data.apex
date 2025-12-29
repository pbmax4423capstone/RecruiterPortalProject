// Create comprehensive test data for Bradley Sophonia

// Get Bradley
User bradley = [SELECT Id, Name FROM User WHERE Name LIKE '%Brad%Sof%' LIMIT 1];
System.debug('Creating test data for: ' + bradley.Name);

// Create 25 candidates with varied statuses
List<Candidate__c> candidates = new List<Candidate__c>();
String[] firstNames = new String[]{'Alex', 'Jordan', 'Morgan', 'Casey', 'Riley', 'Avery', 'Quinn', 'Peyton', 'Cameron', 'Dakota', 'Skylar', 'Reese', 'Taylor', 'Parker', 'Harper', 'Rowan', 'Sage', 'River', 'Phoenix', 'Blake', 'Drew', 'Charlie', 'Finley', 'Sawyer', 'Emerson'};
String[] lastNames = new String[]{'Anderson', 'Johnson', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Garcia', 'Martinez', 'Robinson', 'Clark', 'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young'};
String[] statuses = new String[]{'Interview', 'Interview', 'Interview', 'Interview', 'Interview', 'New Lead', 'New Lead', 'Qualified', 'Qualified', 'Qualified', 'Inactive', 'Inactive', 'Hired', 'Hired', 'Hired', 'Hired', 'Interview', 'New Lead', 'Qualified', 'Interview', 'New Lead', 'Qualified', 'Interview', 'Qualified', 'Interview'};

for (Integer i = 0; i < 25; i++) {
    Candidate__c c = new Candidate__c();
    c.First_Name__c = firstNames[i];
    c.Last_Name__c = lastNames[i];
    c.Email__c = firstNames[i].toLowerCase() + '.' + lastNames[i].toLowerCase() + '@example.com';
    c.Status__c = statuses[i];
    c.OwnerId = bradley.Id;
    
    // Set Start_Date__c for Hired candidates to be this month
    if (c.Status__c == 'Hired') {
        c.Start_Date__c = Date.today().addDays(-i * 3);
    }
    
    candidates.add(c);
}

insert candidates;
System.debug('Created ' + candidates.size() + ' candidates for Bradley');

// Create 15 scheduled interviews
List<Interview__c> interviews = new List<Interview__c>();
String[] interviewTypes = new String[]{'Ci-First', 'Align-2nd', 'Plan-3rd', 'Present-4th', 'Optional-5th'};

for (Integer i = 0; i < 15; i++) {
    Interview__c interview = new Interview__c();
    interview.Candidate__c = candidates[i].Id;
    interview.Interview_Type__c = interviewTypes[Math.mod(i, 5)];
    interview.Interview_Status__c = 'Scheduled';
    interview.Date_Time_Scheduled__c = DateTime.newInstance(Date.today().addDays(i + 1), Time.newInstance(9 + Math.mod(i, 8), 0, 0, 0));
    interview.Conducted_By__c = bradley.Id;
    interviews.add(interview);
}

insert interviews;
System.debug('Created ' + interviews.size() + ' scheduled interviews for Bradley');

// Create 6 Present-4th interviews this month (completed)
List<Interview__c> presentInterviews = new List<Interview__c>();
for (Integer i = 0; i < 6; i++) {
    Interview__c interview = new Interview__c();
    interview.Candidate__c = candidates[15 + i].Id;
    interview.Interview_Type__c = 'Present-4th';
    interview.Interview_Status__c = 'Completed';
    interview.Date_Completed__c = Date.today().addDays(-i * 2);
    interview.Date_Time_Scheduled__c = DateTime.newInstance(Date.today().addDays(-i * 2), Time.newInstance(14, 0, 0, 0));
    interview.Conducted_By__c = bradley.Id;
    presentInterviews.add(interview);
}

insert presentInterviews;
System.debug('Created ' + presentInterviews.size() + ' Present-4th interviews for Bradley');

// Create 3 Contract B ALC records
List<ALC__c> contractBAlcs = new List<ALC__c>();
for (Integer i = 0; i < 3; i++) {
    ALC__c alc = new ALC__c();
    alc.Candidate__c = candidates[i].Id;
    alc.Contract_Type__c = 'B';
    alc.Stage__c = 'Sent To Compliance';
    contractBAlcs.add(alc);
}

insert contractBAlcs;
System.debug('Created ' + contractBAlcs.size() + ' Contract B ALC records for Bradley');

// Create 4 Contracted (Hired) ALC records this month
List<ALC__c> hiredAlcs = new List<ALC__c>();
for (Integer i = 0; i < 4; i++) {
    ALC__c alc = new ALC__c();
    alc.Candidate__c = candidates[12 + i].Id; // Use the Hired candidates
    alc.Contract_Type__c = 'A';
    alc.Stage__c = 'Contracted';
    hiredAlcs.add(alc);
}

insert hiredAlcs;
System.debug('Created ' + hiredAlcs.size() + ' Contracted ALC records for Bradley');

// Verify all metrics
System.debug('');
System.debug('===== BRADLEY SOPHONIA METRICS =====');

Integer totalCandidates = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :bradley.Id];
System.debug('Total Candidates: ' + totalCandidates);

Integer upcomingInterviews = [SELECT COUNT() FROM Interview__c 
                               WHERE Interview_Status__c = 'Scheduled' 
                               AND Candidate__r.OwnerId = :bradley.Id];
System.debug('Upcoming Interviews: ' + upcomingInterviews);

Integer activePipeline = [SELECT COUNT() FROM Candidate__c 
                          WHERE OwnerId = :bradley.Id 
                          AND Status__c NOT IN ('Hired', 'Inactive')];
System.debug('Active Pipeline: ' + activePipeline);

Integer onContractB = [SELECT COUNT() FROM ALC__c 
                       WHERE Candidate__r.OwnerId = :bradley.Id 
                       AND Contract_Type__c = 'B'
                       AND Stage__c NOT IN ('Contracted', 'COMPLETE', 'TERMINATED', 'CANCELED')];
System.debug('On Contract B: ' + onContractB);

Integer hiredThisMonth = [SELECT COUNT() FROM ALC__c 
                          WHERE Candidate__r.OwnerId = :bradley.Id 
                          AND Stage__c = 'Contracted'
                          AND LastModifiedDate = THIS_MONTH];
System.debug('Hired This Month: ' + hiredThisMonth);

Integer presentationMeetingsThisMonth = [SELECT COUNT() FROM Interview__c 
                                         WHERE Candidate__r.OwnerId = :bradley.Id 
                                         AND Interview_Type__c = 'Present-4th'
                                         AND (Date_Completed__c = THIS_MONTH OR Date_Time_Scheduled__c = THIS_MONTH)];
System.debug('Present-4th Meetings This Month: ' + presentationMeetingsThisMonth);

Decimal interviewRate = 0;
if (presentationMeetingsThisMonth > 0) {
    interviewRate = (Decimal.valueOf(hiredThisMonth) / Decimal.valueOf(presentationMeetingsThisMonth) * 100).setScale(0);
}
System.debug('Interview Rate: ' + interviewRate + '% (Hired: ' + hiredThisMonth + ' / Presentations: ' + presentationMeetingsThisMonth + ')');
