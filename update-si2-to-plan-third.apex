// Update SI2 interviews from Align-2nd to Plan-3rd type
System.debug('=== UPDATING SI2 INTERVIEWS TO PLAN-3RD ===');

// Query SI2 interviews (those with External_Id ending in _SI2-Align-2nd)
List<Interview__c> si2Interviews = [
    SELECT Id, Name, Interview_Type__c, External_Id__c, Interviewer_s__c, 
           Date_Time_Scheduled__c, Candidate__r.Name
    FROM Interview__c
    WHERE External_Id__c LIKE '%_SI2-Align-2nd'
];

System.debug('Found ' + si2Interviews.size() + ' SI2 interviews to update');

// Update them to Plan-3rd type
for (Interview__c interview : si2Interviews) {
    interview.Interview_Type__c = 'Plan-3rd';
}

if (si2Interviews.size() > 0) {
    try {
        update si2Interviews;
        System.debug('Successfully updated ' + si2Interviews.size() + ' interviews to Plan-3rd');
        
        // Show November interviews that were updated
        System.debug('\n=== NOVEMBER SI2 INTERVIEWS NOW AS PLAN-3RD ===');
        for (Interview__c interview : si2Interviews) {
            if (interview.Date_Time_Scheduled__c != null && 
                interview.Date_Time_Scheduled__c.month() == 11 && 
                interview.Date_Time_Scheduled__c.year() == 2025) {
                System.debug(interview.Date_Time_Scheduled__c.format() + ' | ' + 
                           interview.Interviewer_s__c + ' | ' + 
                           interview.Candidate__r.Name);
            }
        }
        
    } catch (Exception e) {
        System.debug('ERROR: ' + e.getMessage());
    }
} else {
    System.debug('No SI2 interviews found to update');
}
