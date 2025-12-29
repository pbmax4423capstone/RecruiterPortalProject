// Check total Interview__c records
Integer total = [SELECT COUNT() FROM Interview__c];
System.debug('Total Interview__c records: ' + total);

Integer thisMonth = [SELECT COUNT() FROM Interview__c WHERE Date_Time_Scheduled__c = THIS_MONTH];
System.debug('THIS_MONTH records: ' + thisMonth);

Integer thisWeek = [SELECT COUNT() FROM Interview__c WHERE Date_Time_Scheduled__c = THIS_WEEK];
System.debug('THIS_WEEK records: ' + thisWeek);

// Check Attraction specifically
Integer attractionMonth = [SELECT COUNT() FROM Interview__c WHERE Date_Time_Scheduled__c = THIS_MONTH AND Interview_Type__c = 'Attraction'];
System.debug('Attraction THIS_MONTH: ' + attractionMonth);

Integer attractionWeek = [SELECT COUNT() FROM Interview__c WHERE Date_Time_Scheduled__c = THIS_WEEK AND Interview_Type__c = 'Attraction'];
System.debug('Attraction THIS_WEEK: ' + attractionWeek);
