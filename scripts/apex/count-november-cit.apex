// Count total CIT interviews scheduled in November 2025

Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

// Total CIT interviews scheduled in November
Integer totalCIT = [
    SELECT COUNT()
    FROM Candidate__c
    WHERE Attraction_Interview_Date_Scheduled__c >= :novemberStart
    AND Attraction_Interview_Date_Scheduled__c <= :novemberEnd
];

System.debug('Total CIT interviews scheduled in November 2025: ' + totalCIT);

// Query all with conductor names
List<Candidate__c> citList = [
    SELECT AI_Conducted_By__c, Attraction_Conducted_by__c, Attraction_Interview_Conducted_By__c
    FROM Candidate__c
    WHERE Attraction_Interview_Date_Scheduled__c >= :novemberStart
    AND Attraction_Interview_Date_Scheduled__c <= :novemberEnd
];

Map<String, Integer> conductorCounts = new Map<String, Integer>();
Integer nullConductor = 0;

for (Candidate__c cand : citList) {
    String conductor = null;
    if (cand.AI_Conducted_By__c != null && cand.AI_Conducted_By__c != '') {
        conductor = cand.AI_Conducted_By__c;
    } else if (cand.Attraction_Conducted_by__c != null && cand.Attraction_Conducted_by__c != '') {
        conductor = cand.Attraction_Conducted_by__c;
    } else if (cand.Attraction_Interview_Conducted_By__c != null && cand.Attraction_Interview_Conducted_By__c != '') {
        conductor = cand.Attraction_Interview_Conducted_By__c;
    }
    
    if (conductor != null) {
        if (!conductorCounts.containsKey(conductor)) {
            conductorCounts.put(conductor, 0);
        }
        conductorCounts.put(conductor, conductorCounts.get(conductor) + 1);
    } else {
        nullConductor++;
    }
}

System.debug('\n=== CIT Interviews by Conductor ===');
for (String conductor : conductorCounts.keySet()) {
    System.debug(conductor + ': ' + conductorCounts.get(conductor));
}
System.debug('(No conductor): ' + nullConductor);
