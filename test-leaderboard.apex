List<Interview__c> interviews = [SELECT Id, Name, Interview_Status__c, Date_Completed__c, Interview_Type__c, Interviewer_s__c FROM Interview__c WHERE Date_Completed__c = THIS_MONTH AND Interview_Status__c = 'Completed' AND Interview_Type__c != null];
System.debug('Total completed interviews this month: ' + interviews.size());
