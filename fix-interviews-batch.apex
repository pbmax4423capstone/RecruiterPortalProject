// Fix interviews in batches - first 200
List<Interview__c> wrongInterviews = [SELECT Id, Name, Candidate__c, Candidate__r.First_Name__c, Candidate__r.Last_Name__c, Interview_Type__c FROM Interview__c WHERE Name LIKE 'a0%' AND Candidate__c != null LIMIT 200];

System.debug('Found ' + wrongInterviews.size() + ' interviews to fix in this batch');

for (Interview__c interview : wrongInterviews) {
    // Update with correct name format
    String correctName = interview.Candidate__r.First_Name__c + ' ' + interview.Candidate__r.Last_Name__c + ' - ' + interview.Interview_Type__c;
    interview.Name = correctName;
}

if (!wrongInterviews.isEmpty()) {
    update wrongInterviews;
    System.debug('✓ Updated ' + wrongInterviews.size() + ' interview(s)');
} else {
    System.debug('No more interviews to fix');
}
