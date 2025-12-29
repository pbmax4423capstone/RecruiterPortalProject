// Check what Present-4th interviews exist in November
List<Interview__c> present4thInterviews = [
    SELECT Id, Name, External_Id__c, Interview_Type__c, Interviewer_s__c, 
           Date_Time_Scheduled__c, Candidate__r.Name
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_MONTH
    AND Interview_Type__c = 'Present-4th'
    ORDER BY Date_Time_Scheduled__c
];

System.debug('=== PRESENT-4TH INTERVIEWS - NOVEMBER 2025 ===');
System.debug('Total: ' + present4thInterviews.size());
System.debug('\n');

System.debug('Date | Conductor | Candidate Name | External ID');
System.debug('-----------------------------------------------------------');

for (Interview__c interview : present4thInterviews) {
    System.debug(interview.Date_Time_Scheduled__c.format() + ' | ' + 
                 interview.Interviewer_s__c + ' | ' + 
                 interview.Candidate__r.Name + ' | ' + 
                 interview.External_Id__c);
}

// Count by conductor
Map<String, Integer> conductorCount = new Map<String, Integer>();
for (Interview__c interview : present4thInterviews) {
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
