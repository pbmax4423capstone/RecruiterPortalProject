System.debug('=== Deleting Test Data ===');
List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE CreatedDate = TODAY];
delete opps;
System.debug('Deleted ' + opps.size() + ' Opportunities');

List<Interview__c> interviews = [SELECT Id FROM Interview__c WHERE CreatedDate = TODAY];
delete interviews;
System.debug('Deleted ' + interviews.size() + ' Interviews');

List<ALC__c> alcs = [SELECT Id FROM ALC__c WHERE CreatedDate = TODAY];
delete alcs;
System.debug('Deleted ' + alcs.size() + ' ALCs');

List<Candidate__c> candidates = [SELECT Id FROM Candidate__c WHERE CreatedDate = TODAY];
delete candidates;
System.debug('Deleted ' + candidates.size() + ' Candidates');

System.debug('=== Cleanup Complete ===');