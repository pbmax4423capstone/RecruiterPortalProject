// Verify Bradley Sophonia's test data and metrics

// Get Bradley
User bradley = [SELECT Id, Name, Username FROM User WHERE Name LIKE '%Brad%Sof%' OR Username LIKE '%sofonia%' LIMIT 1];
System.debug('Found user: ' + bradley.Name + ' (' + bradley.Username + ')');

// Check all metrics for Bradley
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
System.debug('Interview Rate: ' + interviewRate + '%');

System.debug('');
System.debug('===== DATA BREAKDOWN =====');

// Check candidates
List<Candidate__c> candidates = [SELECT Id, Name, Status__c FROM Candidate__c WHERE OwnerId = :bradley.Id];
System.debug('Candidates (' + candidates.size() + '):');
for (Candidate__c c : candidates) {
    System.debug('  - ' + c.Name + ' (Status: ' + c.Status__c + ')');
}

// Check interviews
List<Interview__c> interviews = [SELECT Id, Candidate__r.Name, Interview_Type__c, Interview_Status__c, Date_Completed__c 
                                  FROM Interview__c 
                                  WHERE Candidate__r.OwnerId = :bradley.Id];
System.debug('');
System.debug('Interviews (' + interviews.size() + '):');
for (Interview__c i : interviews) {
    System.debug('  - ' + i.Candidate__r.Name + ': ' + i.Interview_Type__c + ' (' + i.Interview_Status__c + ')');
}

// Check ALC records
List<ALC__c> alcs = [SELECT Id, Candidate__r.Name, Contract_Type__c, Stage__c, LastModifiedDate 
                     FROM ALC__c 
                     WHERE Candidate__r.OwnerId = :bradley.Id];
System.debug('');
System.debug('ALC Records (' + alcs.size() + '):');
for (ALC__c alc : alcs) {
    System.debug('  - ' + alc.Candidate__r.Name + ': Type=' + alc.Contract_Type__c + ', Stage=' + alc.Stage__c + ', Modified=' + alc.LastModifiedDate.format());
}

if (totalCandidates == 0) {
    System.debug('');
    System.debug('⚠️ WARNING: Bradley has NO test data. Need to create candidates, interviews, and ALC records.');
}
