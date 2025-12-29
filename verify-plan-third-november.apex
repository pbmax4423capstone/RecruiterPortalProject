// Query Plan-3rd interviews for November 2025
List<Interview__c> planThirdInterviews = [
    SELECT Id, Name, External_Id__c, Interview_Type__c, Interviewer_s__c, 
           Date_Time_Scheduled__c, Candidate__r.Name
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_MONTH
    AND Interview_Type__c = 'Plan-3rd'
    ORDER BY Date_Time_Scheduled__c
];

System.debug('=== PLAN-3RD INTERVIEWS - NOVEMBER 2025 ===');
System.debug('Total: ' + planThirdInterviews.size());
System.debug('\n');

// Separate by source (SI2 vs SI3)
List<Interview__c> si2Source = new List<Interview__c>();
List<Interview__c> si3Source = new List<Interview__c>();

for (Interview__c interview : planThirdInterviews) {
    if (interview.External_Id__c != null && interview.External_Id__c.contains('_SI2-')) {
        si2Source.add(interview);
    } else if (interview.External_Id__c != null && interview.External_Id__c.contains('_Plan-3rd')) {
        si3Source.add(interview);
    }
}

System.debug('=== SI2 INTERVIEWS (now showing as Plan-3rd) ===');
System.debug('Count: ' + si2Source.size());
for (Interview__c interview : si2Source) {
    System.debug(interview.Date_Time_Scheduled__c.format() + ' | ' + 
                 interview.Interviewer_s__c + ' | ' + 
                 interview.Candidate__r.Name + ' | ' + 
                 interview.External_Id__c);
}

System.debug('\n=== SI3 INTERVIEWS (Plan-3rd) ===');
System.debug('Count: ' + si3Source.size());
for (Interview__c interview : si3Source) {
    System.debug(interview.Date_Time_Scheduled__c.format() + ' | ' + 
                 interview.Interviewer_s__c + ' | ' + 
                 interview.Candidate__r.Name + ' | ' + 
                 interview.External_Id__c);
}

System.debug('\n=== SUMMARY ===');
System.debug('SI2 (from Candidate SI_2 fields): ' + si2Source.size());
System.debug('SI3 (from Candidate SI_3 fields): ' + si3Source.size());
System.debug('TOTAL Plan-3rd: ' + planThirdInterviews.size());

// Count by conductor
Map<String, Integer> conductorCount = new Map<String, Integer>();
for (Interview__c interview : planThirdInterviews) {
    String conductors = interview.Interviewer_s__c;
    if (String.isBlank(conductors)) {
        conductors = 'UNASSIGNED';
    }
    
    List<String> conductorList = conductors.split(';');
    for (String conductor : conductorList) {
        conductor = conductor.trim();
        if (!conductorCount.containsKey(conductor)) {
            conductorCount.put(conductor, 0);
        }
        conductorCount.put(conductor, conductorCount.get(conductor) + 1);
    }
}

System.debug('\n=== BY CONDUCTOR ===');
for (String conductor : conductorCount.keySet()) {
    System.debug(conductor + ': ' + conductorCount.get(conductor));
}
