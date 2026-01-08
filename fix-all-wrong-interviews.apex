// Fix all interviews that have ID-like names (start with 'a0')
List<Interview__c> wrongInterviews = [SELECT Id, Name, Candidate__c, Candidate__r.First_Name__c, Candidate__r.Last_Name__c, Interview_Type__c FROM Interview__c WHERE Name LIKE 'a0%' AND Candidate__c != null];

System.debug('Found ' + wrongInterviews.size() + ' interviews with wrong name format');

for (Interview__c interview : wrongInterviews) {
    System.debug('Current Name: ' + interview.Name);
    System.debug('Candidate: ' + interview.Candidate__r.First_Name__c + ' ' + interview.Candidate__r.Last_Name__c);
    System.debug('Interview Type: ' + interview.Interview_Type__c);
    
    // Update with correct name format
    String correctName = interview.Candidate__r.First_Name__c + ' ' + interview.Candidate__r.Last_Name__c + ' - ' + interview.Interview_Type__c;
    interview.Name = correctName;
    System.debug('New Name: ' + correctName);
    System.debug('---');
}

if (!wrongInterviews.isEmpty()) {
    update wrongInterviews;
    System.debug('✓ Updated ' + wrongInterviews.size() + ' interview(s)');
} else {
    System.debug('No interviews found with wrong name format');
}
