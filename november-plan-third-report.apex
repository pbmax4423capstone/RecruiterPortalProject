// Query Plan-3rd interviews for November 2025
List<Interview__c> planThirdNovember = [
    SELECT Id, External_Id__c, Interview_Type__c, 
           Date_Time_Scheduled__c, Interviewer_s__c,
           Candidate__r.Name, Candidate__c
    FROM Interview__c
    WHERE Interview_Type__c = 'Plan-3rd'
    AND Date_Time_Scheduled__c >= 2025-11-01T00:00:00Z
    AND Date_Time_Scheduled__c <= 2025-11-30T23:59:59Z
    ORDER BY Date_Time_Scheduled__c ASC
];

System.debug('=== PLAN-3RD INTERVIEWS - NOVEMBER 2025 REPORT ===');
System.debug('Total Plan-3rd interviews in November 2025: ' + planThirdNovember.size());
System.debug('Report generated: ' + DateTime.now().format());
System.debug('\n');

if (planThirdNovember.size() == 0) {
    System.debug('NO PLAN-3RD INTERVIEWS FOUND IN NOVEMBER 2025');
} else {
    System.debug('--- COMPLETE LIST ---');
    System.debug('Date | Conductor | Candidate Name | Interview ID');
    System.debug('---------------------------------------------------------------');
    
    for (Interview__c interview : planThirdNovember) {
        String dateStr = interview.Date_Time_Scheduled__c != null 
            ? interview.Date_Time_Scheduled__c.format('MM/dd/yyyy hh:mm a') 
            : 'NO DATE';
        
        String conductor = interview.Interviewer_s__c;
        if (String.isBlank(conductor)) {
            conductor = 'UNASSIGNED';
        }
        
        String candidateName = interview.Candidate__r.Name != null 
            ? interview.Candidate__r.Name 
            : 'NO NAME';
        
        System.debug(dateStr + ' | ' + conductor + ' | ' + candidateName + ' | ' + interview.Id);
    }
}

// Count by conductor
Map<String, Integer> conductorCount = new Map<String, Integer>();
for (Interview__c interview : planThirdNovember) {
    String conductor = interview.Interviewer_s__c;
    if (String.isBlank(conductor)) {
        conductor = 'UNASSIGNED';
    }
    
    if (!conductorCount.containsKey(conductor)) {
        conductorCount.put(conductor, 0);
    }
    conductorCount.put(conductor, conductorCount.get(conductor) + 1);
}

System.debug('\n--- SUMMARY BY CONDUCTOR ---');
for (String conductor : conductorCount.keySet()) {
    System.debug(conductor + ': ' + conductorCount.get(conductor));
}
System.debug('\nTOTAL: ' + planThirdNovember.size());
