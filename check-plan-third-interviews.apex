// Query Plan-3rd interviews
List<Interview__c> planThirdInterviews = [
    SELECT Id, External_Id__c, Interview_Type__c, 
           Date_Time_Scheduled__c, Interviewer_s__c,
           Candidate__r.Name
    FROM Interview__c
    WHERE Interview_Type__c = 'Plan-3rd'
    ORDER BY Date_Time_Scheduled__c DESC
];

System.debug('=== PLAN-3RD INTERVIEWS REPORT ===');
System.debug('Total Plan-3rd interviews: ' + planThirdInterviews.size());

// Count for November 2025
Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);
Date thisWeekStart = Date.newInstance(2025, 11, 16);
Date thisWeekEnd = Date.newInstance(2025, 11, 22);

Integer novemberCount = 0;
Integer weekCount = 0;
Map<String, Integer> conductorMonth = new Map<String, Integer>();

for (Interview__c interview : planThirdInterviews) {
    if (interview.Date_Time_Scheduled__c == null) continue;
    
    Date schedDate = interview.Date_Time_Scheduled__c.date();
    
    if (schedDate >= novemberStart && schedDate <= novemberEnd) {
        novemberCount++;
        
        String conductor = interview.Interviewer_s__c;
        if (String.isBlank(conductor)) {
            conductor = 'Unassigned';
        }
        
        if (!conductorMonth.containsKey(conductor)) {
            conductorMonth.put(conductor, 0);
        }
        conductorMonth.put(conductor, conductorMonth.get(conductor) + 1);
        
        if (schedDate >= thisWeekStart && schedDate <= thisWeekEnd) {
            weekCount++;
        }
    }
}

System.debug('\n--- NOVEMBER 2025 ---');
System.debug('This Week: ' + weekCount);
System.debug('This Month: ' + novemberCount);

if (novemberCount > 0) {
    System.debug('\nBy Conductor:');
    for (String conductor : conductorMonth.keySet()) {
        System.debug(conductor + ': ' + conductorMonth.get(conductor));
    }
}

System.debug('\n=== SUMMARY ===');
System.debug('The controller already supports Plan-3rd interviews.');
System.debug('Current count: ' + planThirdInterviews.size());
System.debug('November count: ' + novemberCount);
