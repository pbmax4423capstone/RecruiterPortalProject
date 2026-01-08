// Test with CORRECT interview type values
List<Candidate__c> candidates = [SELECT Id, First_Name__c, Last_Name__c FROM Candidate__c WHERE First_Name__c = 'Sean' AND Last_Name__c = 'Montgomery' LIMIT 1];

if (candidates.isEmpty()) {
    candidates = [SELECT Id, First_Name__c, Last_Name__c FROM Candidate__c WHERE First_Name__c != null AND Last_Name__c != null LIMIT 1];
}

if (!candidates.isEmpty()) {
    Candidate__c testCandidate = candidates[0];
    System.debug('Testing with Candidate: ' + testCandidate.First_Name__c + ' ' + testCandidate.Last_Name__c);
    
    // Test with Ci-First (correct value)
    Interview__c testInterview = new Interview__c(
        Candidate__c = testCandidate.Id,
        Interview_Type__c = 'Ci-First',
        Interview_Status__c = 'Scheduled',
        Date_Time_Scheduled__c = System.now().addDays(3)
    );
    
    insert testInterview;
    
    Interview__c result = [SELECT Id, Name, Interview_Type__c FROM Interview__c WHERE Id = :testInterview.Id];
    
    System.debug('Interview Type: ' + result.Interview_Type__c);
    System.debug('Interview Name: ' + result.Name);
    System.debug('Expected: ' + testCandidate.First_Name__c + ' ' + testCandidate.Last_Name__c + ' - Ci-First');
    
    if (result.Name == testCandidate.First_Name__c + ' ' + testCandidate.Last_Name__c + ' - Ci-First') {
        System.debug('✓ SUCCESS: Interview Name is correctly formatted with valid interview type!');
    } else {
        System.debug('✗ ERROR: Interview Name format is incorrect: ' + result.Name);
    }
    
    delete result;
    System.debug('Test interview deleted');
}
