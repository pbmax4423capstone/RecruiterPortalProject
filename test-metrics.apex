// Test the updated metrics logic
User elizabeth = [SELECT Id, Name FROM User WHERE Username = 'ekagele@financialguide.com.recruiting' LIMIT 1];
User tim = [SELECT Id, Name FROM User WHERE Username = 'tdenton@financialguide.com.recruiting' LIMIT 1];

System.debug('=== TESTING METRICS ===');

// Manually run the queries for Elizabeth
System.debug('ELIZABETH KAGELE:');
Integer elizTotal = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :elizabeth.Id];
System.debug('  Total Candidates: ' + elizTotal);

Integer elizInterviews = [SELECT COUNT() FROM Interview__c WHERE Interview_Status__c = 'Scheduled' AND Candidate__r.OwnerId = :elizabeth.Id];
System.debug('  Upcoming Interviews: ' + elizInterviews);

Integer elizActive = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :elizabeth.Id AND Status__c NOT IN ('Hired', 'Inactive')];
System.debug('  Active Pipeline: ' + elizActive);

Integer elizContractB = [SELECT COUNT() FROM ALC__c WHERE Candidate__r.OwnerId = :elizabeth.Id AND Contract_Type__c = 'B' AND Stage__c NOT IN ('Contracted', 'COMPLETE', 'TERMINATED', 'CANCELED')];
System.debug('  On Contract B: ' + elizContractB);

Integer elizHired = [SELECT COUNT() FROM ALC__c WHERE Candidate__r.OwnerId = :elizabeth.Id AND Stage__c = 'Contracted' AND LastModifiedDate = THIS_MONTH];
System.debug('  Hired This Month: ' + elizHired);

System.debug('TIM DENTON:');
Integer timTotal = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :tim.Id];
System.debug('  Total Candidates: ' + timTotal);

Integer timInterviews = [SELECT COUNT() FROM Interview__c WHERE Interview_Status__c = 'Scheduled' AND Candidate__r.OwnerId = :tim.Id];
System.debug('  Upcoming Interviews: ' + timInterviews);

Integer timActive = [SELECT COUNT() FROM Candidate__c WHERE OwnerId = :tim.Id AND Status__c NOT IN ('Hired', 'Inactive')];
System.debug('  Active Pipeline: ' + timActive);

Integer timContractB = [SELECT COUNT() FROM ALC__c WHERE Candidate__r.OwnerId = :tim.Id AND Contract_Type__c = 'B' AND Stage__c NOT IN ('Contracted', 'COMPLETE', 'TERMINATED', 'CANCELED')];
System.debug('  On Contract B: ' + timContractB);

Integer timHired = [SELECT COUNT() FROM ALC__c WHERE Candidate__r.OwnerId = :tim.Id AND Stage__c = 'Contracted' AND LastModifiedDate = THIS_MONTH];
System.debug('  Hired This Month: ' + timHired);
