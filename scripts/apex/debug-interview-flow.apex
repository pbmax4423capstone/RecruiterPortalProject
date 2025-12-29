// Check the interview that was just created
List<Interview__c> interviews = [SELECT Id, Name, Interview_Type__c, Candidate__c, 
                                  Candidate__r.Name, Candidate__r.First_Name__c, 
                                  Candidate__r.Last_Name__c, Candidate__r.Highest_Level_Achieved__c
                                  FROM Interview__c 
                                  ORDER BY CreatedDate DESC
                                  LIMIT 1];

if (!interviews.isEmpty()) {
    Interview__c interview = interviews[0];
    System.debug('Interview ID: ' + interview.Id);
    System.debug('Interview Name: ' + interview.Name);
    System.debug('Interview Type: ' + interview.Interview_Type__c);
    System.debug('Candidate: ' + interview.Candidate__r.Name);
    System.debug('Candidate First Name: ' + interview.Candidate__r.First_Name__c);
    System.debug('Candidate Last Name: ' + interview.Candidate__r.Last_Name__c);
    System.debug('Candidate Highest Level Achieved: ' + interview.Candidate__r.Highest_Level_Achieved__c);
} else {
    System.debug('No interviews found');
}
