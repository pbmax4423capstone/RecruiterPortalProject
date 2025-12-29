// Verify Plan-3rd migration
List<Interview__c> planThirdInterviews = [
    SELECT Id, External_Id__c, Interview_Type__c, 
           Date_Time_Scheduled__c, Interviewer_s__c,
           Candidate__r.Name
    FROM Interview__c
    WHERE Interview_Type__c = 'Plan-3rd'
    ORDER BY Date_Time_Scheduled__c DESC
];

System.debug('=== PLAN-3RD MIGRATION VERIFICATION ===');
System.debug('Total Plan-3rd interviews: ' + planThirdInterviews.size());

// Count for November 2025
Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);
Date thisWeekStart = Date.newInstance(2025, 11, 16);
Date thisWeekEnd = Date.newInstance(2025, 11, 22);

List<Interview__c> novemberInterviews = new List<Interview__c>();
Map<String, Integer> conductorMonth = new Map<String, Integer>();
Map<String, Integer> conductorWeek = new Map<String, Integer>();

for (Interview__c interview : planThirdInterviews) {
    if (interview.Date_Time_Scheduled__c == null) continue;
    
    Date schedDate = interview.Date_Time_Scheduled__c.date();
    
    if (schedDate >= novemberStart && schedDate <= novemberEnd) {
        novemberInterviews.add(interview);
        
        String conductor = interview.Interviewer_s__c;
        if (String.isBlank(conductor)) {
            conductor = 'Unassigned';
        }
        
        if (!conductorMonth.containsKey(conductor)) {
            conductorMonth.put(conductor, 0);
        }
        conductorMonth.put(conductor, conductorMonth.get(conductor) + 1);
        
        if (schedDate >= thisWeekStart && schedDate <= thisWeekEnd) {
            if (!conductorWeek.containsKey(conductor)) {
                conductorWeek.put(conductor, 0);
            }
            conductorWeek.put(conductor, conductorWeek.get(conductor) + 1);
        }
    }
}

System.debug('\n=== NOVEMBER 2025 PLAN-3RD INTERVIEWS ===');
System.debug('Report Date: ' + Date.today().format());
System.debug('This Week: ' + thisWeekStart.format() + ' to ' + thisWeekEnd.format());
System.debug('This Month: ' + novemberStart.format() + ' to ' + novemberEnd.format());

System.debug('\n--- THIS WEEK (Nov 16-22, 2025) ---');
Integer weekTotal = 0;
for (String conductor : conductorWeek.keySet()) {
    Integer count = conductorWeek.get(conductor);
    weekTotal += count;
    System.debug(conductor + ': ' + count);
}
System.debug('Total This Week: ' + weekTotal);

System.debug('\n--- THIS MONTH (November 2025) ---');
Integer monthTotal = 0;
for (String conductor : conductorMonth.keySet()) {
    Integer count = conductorMonth.get(conductor);
    monthTotal += count;
    System.debug(conductor + ': ' + count);
}
System.debug('Total This Month: ' + monthTotal);

if (novemberInterviews.size() > 0) {
    System.debug('\n--- NOVEMBER PLAN-3RD DETAILS ---');
    for (Interview__c interview : novemberInterviews) {
        String conductor = interview.Interviewer_s__c;
        if (String.isBlank(conductor)) conductor = 'Unassigned';
        System.debug(interview.Date_Time_Scheduled__c.format() + ' | ' + conductor + ' | ' + interview.Candidate__r.Name);
    }
}

System.debug('\n=== MIGRATION SUCCESS ===');
System.debug('Expected SI3 migrated: 124');
System.debug('Actual Plan-3rd in Interview object: ' + planThirdInterviews.size());
System.debug('Match: ' + (planThirdInterviews.size() == 124 ? 'YES ✓' : 'NO ✗'));
