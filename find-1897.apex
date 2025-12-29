// What adds up to 1897?
// Sum recent months
Integer sum = 44 + 87 + 82 + 86 + 90 + 83 + 89 + 77 + 142 + 104 + 95 + 105 + 103 + 169 + 135 + 128 + 147 + 152 + 174 + 165;
System.debug('Sum of months shown: ' + sum);

// Try THIS_YEAR
Integer thisYear = [SELECT COUNT() FROM Interview__c WHERE Date_Time_Scheduled__c = THIS_YEAR];
System.debug('THIS_YEAR count: ' + thisYear);

// Try LAST_N_DAYS:365
Integer last365 = [SELECT COUNT() FROM Interview__c WHERE Date_Time_Scheduled__c = LAST_N_DAYS:365];
System.debug('LAST_N_DAYS:365 count: ' + last365);

// Check total Attraction
Integer totalAttraction = [SELECT COUNT() FROM Interview__c WHERE Interview_Type__c = 'Attraction'];
System.debug('Total Attraction interviews: ' + totalAttraction);
