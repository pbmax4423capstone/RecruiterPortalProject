// Query all interviews without a valid conductor
List<Interview__c> interviewsNoConductor = [
    SELECT Id, External_Id__c, Interview_Type__c, 
           Date_Time_Scheduled__c, Interviewer_s__c,
           Candidate__r.Name, Candidate__c,
           Interview_Status__c
    FROM Interview__c
    WHERE Interviewer_s__c = null
    ORDER BY Interview_Type__c, Date_Time_Scheduled__c DESC
];

System.debug('=== INTERVIEWS WITHOUT VALID CONDUCTOR ===');
System.debug('Total interviews without conductor: ' + interviewsNoConductor.size());

// Count by type
Map<String, Integer> typeCount = new Map<String, Integer>();
for (Interview__c interview : interviewsNoConductor) {
    String type = interview.Interview_Type__c;
    if (String.isBlank(type)) {
        type = 'No Type';
    }
    
    if (!typeCount.containsKey(type)) {
        typeCount.put(type, 0);
    }
    typeCount.put(type, typeCount.get(type) + 1);
}

System.debug('\n--- BREAKDOWN BY INTERVIEW TYPE ---');
for (String type : typeCount.keySet()) {
    System.debug(type + ': ' + typeCount.get(type));
}

// Show sample of first 50 interviews without conductor
System.debug('\n--- SAMPLE: FIRST 50 INTERVIEWS WITHOUT CONDUCTOR ---');
Integer count = 0;
for (Interview__c interview : interviewsNoConductor) {
    if (count >= 50) break;
    
    String dateStr = interview.Date_Time_Scheduled__c != null 
        ? interview.Date_Time_Scheduled__c.format() 
        : 'No Date';
    String type = interview.Interview_Type__c != null 
        ? interview.Interview_Type__c 
        : 'No Type';
    String candidateName = interview.Candidate__r.Name != null 
        ? interview.Candidate__r.Name 
        : 'Unknown';
    
    System.debug(dateStr + ' | ' + type + ' | ' + candidateName + ' | ' + interview.Id);
    count++;
}

// Count by External_Id pattern (source system)
Integer fromSI1 = 0;
Integer fromSI2 = 0;
Integer fromCiFirst = 0;
Integer other = 0;

for (Interview__c interview : interviewsNoConductor) {
    if (interview.External_Id__c != null) {
        if (interview.External_Id__c.contains('_Align-2nd')) {
            fromSI1++;
        } else if (interview.External_Id__c.contains('_SI2-Align-2nd')) {
            fromSI2++;
        } else if (interview.External_Id__c.contains('_Ci-First')) {
            fromCiFirst++;
        } else {
            other++;
        }
    } else {
        other++;
    }
}

System.debug('\n--- BREAKDOWN BY SOURCE ---');
System.debug('From SI1 migration: ' + fromSI1);
System.debug('From SI2 migration: ' + fromSI2);
System.debug('From Ci-First migration: ' + fromCiFirst);
System.debug('Other/Manual: ' + other);

System.debug('\n=== SUMMARY ===');
System.debug('Total interviews without conductor: ' + interviewsNoConductor.size());
System.debug('These interviews need conductor data populated in Interviewer_s__c field');
