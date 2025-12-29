// Delete all Interview__c records in batches
List<Interview__c> allInterviews = [SELECT Id FROM Interview__c LIMIT 10000];
System.debug('Deleting ' + allInterviews.size() + ' Interview__c records...');
delete allInterviews;
System.debug('Deleted successfully');

// Check if more exist
Integer remaining = [SELECT COUNT() FROM Interview__c];
System.debug('Remaining Interview__c records: ' + remaining);
