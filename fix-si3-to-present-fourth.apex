// Fix SI3 interviews - they should be Present-4th, not Plan-3rd
System.debug('=== FIXING SI3 INTERVIEWS TO PRESENT-4TH ===');

// Query SI3 interviews (those with External_Id ending in _Plan-3rd)
List<Interview__c> si3Interviews = [
    SELECT Id, Name, Interview_Type__c, External_Id__c, Interviewer_s__c, 
           Date_Time_Scheduled__c, Candidate__r.Name
    FROM Interview__c
    WHERE External_Id__c LIKE '%_Plan-3rd'
];

System.debug('Found ' + si3Interviews.size() + ' SI3 interviews to update from Plan-3rd to Present-4th');

// Update them to Present-4th type
for (Interview__c interview : si3Interviews) {
    System.debug('Updating: ' + interview.External_Id__c + ' | ' + interview.Candidate__r.Name);
    interview.Interview_Type__c = 'Present-4th';
}

if (si3Interviews.size() > 0) {
    try {
        update si3Interviews;
        System.debug('Successfully updated ' + si3Interviews.size() + ' SI3 interviews to Present-4th');
        
        // Show November interviews that were updated
        System.debug('\n=== NOVEMBER SI3 INTERVIEWS NOW AS PRESENT-4TH ===');
        Integer novCount = 0;
        for (Interview__c interview : si3Interviews) {
            if (interview.Date_Time_Scheduled__c != null && 
                interview.Date_Time_Scheduled__c.month() == 11 && 
                interview.Date_Time_Scheduled__c.year() == 2025) {
                novCount++;
                System.debug(interview.Date_Time_Scheduled__c.format() + ' | ' + 
                           interview.Interviewer_s__c + ' | ' + 
                           interview.Candidate__r.Name);
            }
        }
        System.debug('November SI3 count: ' + novCount);
        
    } catch (Exception e) {
        System.debug('ERROR: ' + e.getMessage());
    }
}

// Now verify Plan-3rd only has SI2
System.debug('\n=== VERIFYING PLAN-3RD NOW ONLY HAS SI2 ===');
List<Interview__c> planThird = [
    SELECT Id, External_Id__c, Interview_Type__c
    FROM Interview__c
    WHERE Interview_Type__c = 'Plan-3rd'
    AND Date_Time_Scheduled__c = THIS_MONTH
];
System.debug('Plan-3rd interviews in November: ' + planThird.size());
for (Interview__c interview : planThird) {
    System.debug('  ' + interview.External_Id__c);
}
