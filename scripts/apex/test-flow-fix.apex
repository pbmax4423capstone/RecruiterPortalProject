// Test the fixed Set_Interview_Name flow by creating a new Interview
// Using stephanie alatorre who has Highest_Level_Achieved = '0-Prequal'

// Get stephanie alatorre's ID
Candidate__c candidate = [SELECT Id, First_Name__c, Last_Name__c, Highest_Level_Achieved__c 
                          FROM Candidate__c 
                          WHERE First_Name__c = 'stephanie' 
                          AND Last_Name__c = 'alatorre' 
                          LIMIT 1];

System.debug('Candidate: ' + candidate.First_Name__c + ' ' + candidate.Last_Name__c);
System.debug('Highest Level Achieved: ' + candidate.Highest_Level_Achieved__c);

// Create new Interview - flow should auto-set Interview_Type to 'SI1' and Name to 'stephanie alatorre - SI1'
Interview__c testInterview = new Interview__c(
    Candidate__c = candidate.Id,
    Conducted_By__c = '005Vo00000fcekpIAA', // Bradley Sofonia
    Interview_Status__c = 'Scheduled',
    Date_Time_Scheduled__c = DateTime.now().addDays(1),
    Notes__c = 'Test interview to verify flow fix'
);

insert testInterview;

// Query the created Interview to see if flow worked
Interview__c created = [SELECT Id, Name, Interview_Type__c, Candidate__r.First_Name__c, 
                               Candidate__r.Last_Name__c, Candidate__r.Highest_Level_Achieved__c
                        FROM Interview__c 
                        WHERE Id = :testInterview.Id];

System.debug('=== FLOW TEST RESULTS ===');
System.debug('Interview ID: ' + created.Id);
System.debug('Interview Name: ' + created.Name);
System.debug('Interview Type: ' + created.Interview_Type__c);
System.debug('Expected Name: stephanie alatorre - SI1');
System.debug('Expected Type: SI1');
System.debug('=========================');

if (created.Interview_Type__c == 'SI1' && created.Name == 'stephanie alatorre - SI1') {
    System.debug('✅ SUCCESS! Flow is working correctly!');
} else {
    System.debug('❌ FAILURE: Flow did not set values correctly');
}
