// Reassign all interviews from Diljeet and Scott specifically to Bradley Sofonia (Sales Manager)
User bradleySofonia = [SELECT Id, Name FROM User WHERE Name = 'Bradley Sofonia' AND IsActive = true LIMIT 1];
System.debug('Found Bradley Sofonia: ' + bradleySofonia.Name);

List<Interview__c> interviewsToReassign = [
    SELECT Id, Conducted_By__c, Conducted_By__r.Name, Interview_Type__c
    FROM Interview__c 
    WHERE Conducted_By__r.Name IN ('Diljeet Masuda', 'Scott Primm')
];

System.debug('Found interviews to reassign from Diljeet/Scott: ' + interviewsToReassign.size());

List<Interview__c> updatedInterviews = new List<Interview__c>();
for(Interview__c interview : interviewsToReassign) {
    String oldConductor = interview.Conducted_By__r.Name;
    interview.Conducted_By__c = bradleySofonia.Id;
    updatedInterviews.add(interview);
    System.debug('Reassigning ' + interview.Interview_Type__c + ' interview from ' + oldConductor + ' to Bradley Sofonia');
}

if(updatedInterviews.size() > 0) {
    update updatedInterviews;
    System.debug('Successfully reassigned ' + updatedInterviews.size() + ' interviews to Bradley Sofonia');
} else {
    System.debug('No interviews found to reassign from Diljeet/Scott');
}