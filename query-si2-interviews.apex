// Query candidates with SI2 Date Completed populated
List<Candidate__c> si2Candidates = [
    SELECT Id, Name, 
           SI_2_Date_Completed__c,
           SI_2_Conducted_By__c,
           SI2_Conducted_by__c,
           SI_2_Interviewer__c
    FROM Candidate__c
    WHERE SI_2_Date_Completed__c != null
    ORDER BY SI_2_Date_Completed__c DESC
];

System.debug('=== SI2 INTERVIEW QUERY REPORT ===');
System.debug('Total SI2 interviews found: ' + si2Candidates.size());

// Filter for November 2025
Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

List<Candidate__c> novemberSI2 = new List<Candidate__c>();
Map<String, Integer> conductorCountMonth = new Map<String, Integer>();
Map<String, Integer> conductorCountWeek = new Map<String, Integer>();

// Calculate this week range (Nov 16-22, 2025)
Date thisWeekStart = Date.newInstance(2025, 11, 16);
Date thisWeekEnd = Date.newInstance(2025, 11, 22);

for (Candidate__c c : si2Candidates) {
    Date completedDate = c.SI_2_Date_Completed__c;
    
    // Check if in November 2025
    if (completedDate >= novemberStart && completedDate <= novemberEnd) {
        novemberSI2.add(c);
        
        // Get conductor name (check all possible fields)
        String conductor = c.SI_2_Conducted_By__c;
        if (String.isBlank(conductor)) {
            conductor = c.SI2_Conducted_by__c;
        }
        if (String.isBlank(conductor)) {
            conductor = c.SI_2_Interviewer__c;
        }
        if (String.isBlank(conductor)) {
            conductor = 'Unknown';
        }
        
        // Count for month
        if (!conductorCountMonth.containsKey(conductor)) {
            conductorCountMonth.put(conductor, 0);
        }
        conductorCountMonth.put(conductor, conductorCountMonth.get(conductor) + 1);
        
        // Count for this week
        if (completedDate >= thisWeekStart && completedDate <= thisWeekEnd) {
            if (!conductorCountWeek.containsKey(conductor)) {
                conductorCountWeek.put(conductor, 0);
            }
            conductorCountWeek.put(conductor, conductorCountWeek.get(conductor) + 1);
        }
    }
}

System.debug('\n=== NOVEMBER 2025 SI2 INTERVIEWS ===');
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

System.debug('\n--- NOVEMBER SI2 INTERVIEW DETAILS ---');
for (Candidate__c c : novemberSI2) {
    String conductor = c.SI_2_Conducted_By__c;
    if (String.isBlank(conductor)) {
        conductor = c.SI2_Conducted_by__c;
    }
    if (String.isBlank(conductor)) {
        conductor = c.SI_2_Interviewer__c;
    }
    if (String.isBlank(conductor)) {
        conductor = 'Unknown';
    }
    
    System.debug(c.SI_2_Date_Completed__c.format() + ' | ' + conductor + ' | ' + c.Name);
}

System.debug('\n=== SUMMARY ===');
System.debug('Total SI2 interviews all-time: ' + si2Candidates.size());
System.debug('Total SI2 interviews in November 2025: ' + novemberSI2.size());
