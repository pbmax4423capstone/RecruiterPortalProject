// Test Interview Name auto-population
// Get a real candidate from Production
List<Candidate__c> candidates = [SELECT Id, First_Name__c, Last_Name__c FROM Candidate__c WHERE First_Name__c != null AND Last_Name__c != null LIMIT 1];

if (candidates.isEmpty()) {
    System.debug('ERROR: No candidates found in org');
} else {
    Candidate__c testCandidate = candidates[0];
    System.debug('Using Candidate: ' + testCandidate.First_Name__c + ' ' + testCandidate.Last_Name__c);
    
    // Create test interview WITHOUT setting the Name field
    Interview__c testInterview = new Interview__c(
        Candidate__c = testCandidate.Id,
        Interview_Type__c = 'CI-First',
        Interview_Status__c = 'Scheduled',
        Date_Time_Scheduled__c = System.now().addDays(1)
    );
    
    System.debug('BEFORE INSERT - Interview Name: ' + testInterview.Name);
    
    insert testInterview;
    
    // Query it back to see the auto-populated Name
    Interview__c result = [SELECT Id, Name, Interview_Type__c FROM Interview__c WHERE Id = :testInterview.Id];
    
    System.debug('AFTER INSERT - Interview Name: ' + result.Name);
    System.debug('Expected Format: ' + testCandidate.First_Name__c + ' ' + testCandidate.Last_Name__c + ' - ' + result.Interview_Type__c);
    
    if (String.isBlank(result.Name)) {
        System.debug('ERROR: Interview Name is still blank after insert!');
    } else {
        System.debug('SUCCESS: Interview Name was auto-populated!');
    }
    
    // Clean up test data
    delete result;
    System.debug('Test interview deleted successfully');
}
