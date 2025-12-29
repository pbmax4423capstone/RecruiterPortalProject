// Check SI1 vs SI2 interviews in November
List<Interview__c> alignInterviews = [
    SELECT Id, Name, External_Id__c, Interview_Type__c, Interviewer_s__c, 
           Date_Time_Scheduled__c, Candidate__r.Name
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_MONTH
    AND Interview_Type__c = 'Align-2nd'
    ORDER BY Date_Time_Scheduled__c
];

System.debug('=== NOVEMBER ALIGN-2ND INTERVIEWS ===');
System.debug('Total: ' + alignInterviews.size());

Integer si1Count = 0;
Integer si2Count = 0;

System.debug('\n=== SI1 INTERVIEWS (External_Id ends with _Align-2nd) ===');
for (Interview__c interview : alignInterviews) {
    if (interview.External_Id__c != null && interview.External_Id__c.endsWith('_Align-2nd')) {
        si1Count++;
        System.debug(interview.Date_Time_Scheduled__c.format() + ' | ' + 
                     interview.Interviewer_s__c + ' | ' + 
                     interview.Candidate__r.Name + ' | ' + 
                     interview.External_Id__c);
    }
}

System.debug('\n=== SI2 INTERVIEWS (External_Id ends with _SI2-Align-2nd) ===');
for (Interview__c interview : alignInterviews) {
    if (interview.External_Id__c != null && interview.External_Id__c.endsWith('_SI2-Align-2nd')) {
        si2Count++;
        System.debug(interview.Date_Time_Scheduled__c.format() + ' | ' + 
                     interview.Interviewer_s__c + ' | ' + 
                     interview.Candidate__r.Name + ' | ' + 
                     interview.External_Id__c);
    }
}

System.debug('\n=== SUMMARY ===');
System.debug('SI1 (original): ' + si1Count);
System.debug('SI2 (migrated): ' + si2Count);
System.debug('Total Align-2nd: ' + alignInterviews.size());
