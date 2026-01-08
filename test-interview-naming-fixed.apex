// Test Interview Name generation after flow deactivation
// Get Sean Montgomery's candidate record
List<Candidate__c> candidates = [SELECT Id, First_Name__c, Last_Name__c FROM Candidate__c WHERE First_Name__c = 'Sean' AND Last_Name__c = 'Montgomery' LIMIT 1];

if (candidates.isEmpty()) {
    System.debug('ERROR: Sean Montgomery not found, using any candidate');
    candidates = [SELECT Id, First_Name__c, Last_Name__c FROM Candidate__c WHERE First_Name__c != null AND Last_Name__c != null LIMIT 1];
}

if (!candidates.isEmpty()) {
    Candidate__c testCandidate = candidates[0];
    System.debug('Using Candidate: ' + testCandidate.First_Name__c + ' ' + testCandidate.Last_Name__c + ' (ID: ' + testCandidate.Id + ')');
    
    // Create test interview WITHOUT setting the Name field
    Interview__c testInterview = new Interview__c(
        Candidate__c = testCandidate.Id,
        Interview_Type__c = 'SI2',
        Interview_Status__c = 'Scheduled',
        Date_Time_Scheduled__c = System.now().addDays(2)
    );
    
    System.debug('BEFORE INSERT - Interview Name: ' + testInterview.Name);
    
    insert testInterview;
    
    // Query it back to see the auto-populated Name
    Interview__c result = [SELECT Id, Name, Interview_Type__c FROM Interview__c WHERE Id = :testInterview.Id];
    
    System.debug('AFTER INSERT - Interview Name: ' + result.Name);
    System.debug('Expected Format: ' + testCandidate.First_Name__c + ' ' + testCandidate.Last_Name__c + ' - ' + result.Interview_Type__c);
    
    // Check if it's the correct format or still showing record ID
    if (result.Name.contains(testCandidate.Last_Name__c)) {
        System.debug('✓ SUCCESS: Interview Name is correctly formatted!');
    } else if (result.Name.startsWith('a0')) {
        System.debug('✗ ERROR: Interview Name is still showing as record ID: ' + result.Name);
    } else {
        System.debug('? UNEXPECTED: Interview Name is: ' + result.Name);
    }
    
    // Clean up test data
    delete result;
    System.debug('Test interview deleted successfully');
} else {
    System.debug('ERROR: No candidates found in org');
}
