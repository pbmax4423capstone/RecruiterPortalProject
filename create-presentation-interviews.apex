// Create Present-4th (presentation meeting) interviews for Elizabeth and Tim this month
// This will demonstrate the new interview rate calculation

// Get users
User elizabeth = [SELECT Id FROM User WHERE Username = 'ekagele@financialguide.com.recruiting' LIMIT 1];
User tim = [SELECT Id FROM User WHERE Username = 'tdenton@financialguide.com.recruiting' LIMIT 1];

// Get some of Elizabeth's candidates
List<Candidate__c> elizabethCandidates = [SELECT Id, Name FROM Candidate__c WHERE OwnerId = :elizabeth.Id LIMIT 8];

// Get some of Tim's candidates  
List<Candidate__c> timCandidates = [SELECT Id, Name FROM Candidate__c WHERE OwnerId = :tim.Id LIMIT 5];

List<Interview__c> interviewsToCreate = new List<Interview__c>();

// Create 8 Present-4th interviews for Elizabeth (she has 3 hired this month)
// So rate should be 3/8 = 37.5% ≈ 38%
Integer counter = 0;
for (Candidate__c cand : elizabethCandidates) {
    Interview__c interview = new Interview__c();
    interview.Candidate__c = cand.Id;
    interview.Interview_Type__c = 'Present-4th';
    interview.Interview_Status__c = 'Completed';
    interview.Date_Completed__c = Date.today().addDays(-counter * 3);
    interview.Date_Time_Scheduled__c = DateTime.newInstance(Date.today().addDays(-counter * 3), Time.newInstance(14, 0, 0, 0));
    interview.Conducted_By__c = elizabeth.Id;
    interviewsToCreate.add(interview);
    counter++;
}

// Create 5 Present-4th interviews for Tim (he has 1 hired this month)
// So rate should be 1/5 = 20%
counter = 0;
for (Candidate__c cand : timCandidates) {
    Interview__c interview = new Interview__c();
    interview.Candidate__c = cand.Id;
    interview.Interview_Type__c = 'Present-4th';
    interview.Interview_Status__c = 'Completed';
    interview.Date_Completed__c = Date.today().addDays(-counter * 2);
    interview.Date_Time_Scheduled__c = DateTime.newInstance(Date.today().addDays(-counter * 2), Time.newInstance(10, 0, 0, 0));
    interview.Conducted_By__c = tim.Id;
    interviewsToCreate.add(interview);
    counter++;
}

insert interviewsToCreate;
System.debug('Created ' + interviewsToCreate.size() + ' Present-4th interviews');

// Verify the data
Integer elizabethPresentations = [SELECT COUNT() FROM Interview__c 
                                   WHERE Candidate__r.OwnerId = :elizabeth.Id 
                                   AND Interview_Type__c = 'Present-4th'
                                   AND Date_Completed__c = THIS_MONTH];
Integer elizabethHired = [SELECT COUNT() FROM ALC__c 
                          WHERE Candidate__r.OwnerId = :elizabeth.Id 
                          AND Stage__c = 'Contracted'
                          AND LastModifiedDate = THIS_MONTH];

Integer timPresentations = [SELECT COUNT() FROM Interview__c 
                            WHERE Candidate__r.OwnerId = :tim.Id 
                            AND Interview_Type__c = 'Present-4th'
                            AND Date_Completed__c = THIS_MONTH];
Integer timHired = [SELECT COUNT() FROM ALC__c 
                    WHERE Candidate__r.OwnerId = :tim.Id 
                    AND Stage__c = 'Contracted'
                    AND LastModifiedDate = THIS_MONTH];

System.debug('===== ELIZABETH KAGELE =====');
System.debug('Present-4th meetings: ' + elizabethPresentations);
System.debug('Hired this month: ' + elizabethHired);
Decimal elizabethRate = elizabethPresentations > 0 ? 
    (Decimal.valueOf(elizabethHired) / Decimal.valueOf(elizabethPresentations) * 100).setScale(0) : 0;
System.debug('Interview Rate: ' + elizabethRate + '%');

System.debug('===== TIM DENTON =====');
System.debug('Present-4th meetings: ' + timPresentations);
System.debug('Hired this month: ' + timHired);
Decimal timRate = timPresentations > 0 ? 
    (Decimal.valueOf(timHired) / Decimal.valueOf(timPresentations) * 100).setScale(0) : 0;
System.debug('Interview Rate: ' + timRate + '%');
