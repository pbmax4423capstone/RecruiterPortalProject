// Check what interviews exist for current month (November 2025)
System.debug('=== CHECKING CURRENT MONTH INTERVIEWS ===');
System.debug('Date: ' + Date.today());

// Query all interviews for THIS_MONTH
List<Interview__c> allMonthInterviews = [
    SELECT Id, Name, Interview_Type__c, Interviewer_s__c, Date_Time_Scheduled__c, Candidate__r.Name
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_MONTH
    ORDER BY Interview_Type__c, Date_Time_Scheduled__c
];

System.debug('Total interviews THIS_MONTH: ' + allMonthInterviews.size());

// Count by type
Map<String, Integer> typeCount = new Map<String, Integer>();
Map<String, List<Interview__c>> typeInterviews = new Map<String, List<Interview__c>>();

for (Interview__c interview : allMonthInterviews) {
    String type = interview.Interview_Type__c != null ? interview.Interview_Type__c : 'NULL';
    
    if (!typeCount.containsKey(type)) {
        typeCount.put(type, 0);
        typeInterviews.put(type, new List<Interview__c>());
    }
    typeCount.put(type, typeCount.get(type) + 1);
    typeInterviews.get(type).add(interview);
}

System.debug('\n=== BY TYPE ===');
for (String type : typeCount.keySet()) {
    System.debug(type + ': ' + typeCount.get(type));
}

// Show Align-2nd details
System.debug('\n=== ALIGN-2ND INTERVIEWS ===');
if (typeInterviews.containsKey('Align-2nd')) {
    for (Interview__c interview : typeInterviews.get('Align-2nd')) {
        System.debug(interview.Date_Time_Scheduled__c.format() + ' | ' + 
                     interview.Interviewer_s__c + ' | ' + 
                     interview.Candidate__r.Name + ' | ' + 
                     interview.Id);
    }
}

// Show Plan-3rd details
System.debug('\n=== PLAN-3RD INTERVIEWS ===');
if (typeInterviews.containsKey('Plan-3rd')) {
    for (Interview__c interview : typeInterviews.get('Plan-3rd')) {
        System.debug(interview.Date_Time_Scheduled__c.format() + ' | ' + 
                     interview.Interviewer_s__c + ' | ' + 
                     interview.Candidate__r.Name + ' | ' + 
                     interview.Id);
    }
}

// Count by conductor for Align-2nd
System.debug('\n=== ALIGN-2ND BY CONDUCTOR ===');
Map<String, Integer> conductorCount = new Map<String, Integer>();
if (typeInterviews.containsKey('Align-2nd')) {
    for (Interview__c interview : typeInterviews.get('Align-2nd')) {
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
}

for (String conductor : conductorCount.keySet()) {
    System.debug(conductor + ': ' + conductorCount.get(conductor));
}

// Check for SI1 or SI2 types (legacy)
System.debug('\n=== CHECKING LEGACY TYPES ===');
List<AggregateResult> legacyInterviews = [
    SELECT Interview_Type__c, COUNT(Id) cnt
    FROM Interview__c
    WHERE Date_Time_Scheduled__c = THIS_MONTH
    AND (Interview_Type__c = 'SI1' OR Interview_Type__c = 'SI2' OR Interview_Type__c = 'SI3')
    GROUP BY Interview_Type__c
];
for (AggregateResult ar : legacyInterviews) {
    System.debug(ar.get('Interview_Type__c') + ': ' + ar.get('cnt'));
}
