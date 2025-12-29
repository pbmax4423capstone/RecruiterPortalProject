// Check what's already in Interview object
System.debug('=== CURRENT INTERVIEW OBJECT STATUS ===');

Integer ciFirst = [SELECT COUNT() FROM Interview__c WHERE Interview_Type__c = 'Ci-First'];
Integer alignSecond = [SELECT COUNT() FROM Interview__c WHERE Interview_Type__c = 'Align-2nd'];
Integer planThird = [SELECT COUNT() FROM Interview__c WHERE Interview_Type__c = 'Plan-3rd'];
Integer optionalFifth = [SELECT COUNT() FROM Interview__c WHERE Interview_Type__c = 'Optional-5th'];
Integer presentFourth = [SELECT COUNT() FROM Interview__c WHERE Interview_Type__c = 'Present-4th'];

System.debug('Ci-First: ' + ciFirst);
System.debug('Align-2nd: ' + alignSecond);
System.debug('Plan-3rd: ' + planThird);
System.debug('Optional-5th: ' + optionalFifth);
System.debug('Present-4th: ' + presentFourth);
System.debug('TOTAL: ' + (ciFirst + alignSecond + planThird + optionalFifth + presentFourth));
