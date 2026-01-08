// Fix the existing interview with wrong name format
// Find the interview with ID in the Name field
Interview__c wrongInterview = [SELECT Id, Name, Candidate__c, Candidate__r.First_Name__c, Candidate__r.Last_Name__c, Interview_Type__c FROM Interview__c WHERE Id = 'a0Hvo00000gpLH' LIMIT 1];

System.debug('Current Name: ' + wrongInterview.Name);
System.debug('Candidate: ' + wrongInterview.Candidate__r.First_Name__c + ' ' + wrongInterview.Candidate__r.Last_Name__c);
System.debug('Interview Type: ' + wrongInterview.Interview_Type__c);

// Update with correct name format
String correctName = wrongInterview.Candidate__r.First_Name__c + ' ' + wrongInterview.Candidate__r.Last_Name__c + ' - ' + wrongInterview.Interview_Type__c;
wrongInterview.Name = correctName;

update wrongInterview;

System.debug('✓ Updated Interview Name to: ' + correctName);
