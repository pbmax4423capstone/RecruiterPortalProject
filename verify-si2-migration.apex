// Query all Align-2nd interviews to verify SI2 migration
List<Interview__c> alignInterviews = [
    SELECT Id, External_Id__c, Interview_Type__c, 
           Date_Time_Scheduled__c, Interviewer_s__c,
           Candidate__r.Name
    FROM Interview__c
    WHERE Interview_Type__c = 'Align-2nd'
    ORDER BY Date_Time_Scheduled__c DESC
];

System.debug('=== ALIGN-2ND INTERVIEW VERIFICATION REPORT ===');
System.debug('Total Align-2nd interviews in Interview object: ' + alignInterviews.size());

// Count by source (SI1 vs SI2 based on External_Id__c)
Integer si1Count = 0;
Integer si2Count = 0;
Integer otherCount = 0;

for (Interview__c interview : alignInterviews) {
    if (interview.External_Id__c != null) {
        if (interview.External_Id__c.contains('_Align-2nd')) {
            si1Count++;
        } else if (interview.External_Id__c.contains('_SI2-Align-2nd')) {
            si2Count++;
        } else {
            otherCount++;
        }
    } else {
        otherCount++;
    }
}

System.debug('\n--- BREAKDOWN BY SOURCE ---');
System.debug('From SI1 (External_Id contains "_Align-2nd"): ' + si1Count);
System.debug('From SI2 (External_Id contains "_SI2-Align-2nd"): ' + si2Count);
System.debug('Other/Legacy: ' + otherCount);

// Filter for November 2025
Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

List<Interview__c> novemberAlign = new List<Interview__c>();
Map<String, Integer> conductorCountMonth = new Map<String, Integer>();
Map<String, Integer> conductorCountWeek = new Map<String, Integer>();

// Calculate this week range (Nov 16-22, 2025)
Date thisWeekStart = Date.newInstance(2025, 11, 16);
Date thisWeekEnd = Date.newInstance(2025, 11, 22);

for (Interview__c interview : alignInterviews) {
    if (interview.Date_Time_Scheduled__c == null) continue;
    
    Date scheduledDate = interview.Date_Time_Scheduled__c.date();
    
    // Check if in November 2025
    if (scheduledDate >= novemberStart && scheduledDate <= novemberEnd) {
        novemberAlign.add(interview);
        
        String conductor = interview.Interviewer_s__c;
        if (String.isBlank(conductor)) {
            conductor = 'Unassigned';
        }
        
        // Count for month
        if (!conductorCountMonth.containsKey(conductor)) {
            conductorCountMonth.put(conductor, 0);
        }
        conductorCountMonth.put(conductor, conductorCountMonth.get(conductor) + 1);
        
        // Count for this week
        if (scheduledDate >= thisWeekStart && scheduledDate <= thisWeekEnd) {
            if (!conductorCountWeek.containsKey(conductor)) {
                conductorCountWeek.put(conductor, 0);
            }
            conductorCountWeek.put(conductor, conductorCountWeek.get(conductor) + 1);
        }
    }
}

System.debug('\n=== NOVEMBER 2025 ALIGN-2ND INTERVIEWS ===');
System.debug('Report Date: ' + Date.today().format());
System.debug('This Week: ' + thisWeekStart.format() + ' to ' + thisWeekEnd.format());
System.debug('This Month: ' + novemberStart.format() + ' to ' + novemberEnd.format());

System.debug('\n--- THIS WEEK (Nov 16-22, 2025) ---');
Integer weekTotal = 0;
for (String conductor : conductorCountWeek.keySet()) {
    Integer count = conductorCountWeek.get(conductor);
    weekTotal += count;
    System.debug(conductor + ': ' + count);
}
System.debug('Total This Week: ' + weekTotal);

System.debug('\n--- THIS MONTH (November 2025) ---');
Integer monthTotal = 0;
for (String conductor : conductorCountMonth.keySet()) {
    Integer count = conductorCountMonth.get(conductor);
    monthTotal += count;
    System.debug(conductor + ': ' + count);
}
System.debug('Total This Month: ' + monthTotal);

System.debug('\n=== MIGRATION VERIFICATION ===');
System.debug('Expected SI2 interviews migrated: 796');
System.debug('Actual SI2 interviews in Interview object: ' + si2Count);
System.debug('Match: ' + (si2Count == 796 ? 'YES ✓' : 'NO ✗'));
