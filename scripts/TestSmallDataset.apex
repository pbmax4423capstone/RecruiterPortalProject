// Small test - create just 5 candidates to verify flow behavior
TestDataFactory factory = new TestDataFactory();

// Test with minimal data
System.debug('Testing with small dataset...');

// We'll need to see if we need to disable flows or adjust the approach
Account testAccount = [SELECT Id FROM Account WHERE Name = 'Capstone Partners' LIMIT 1];
System.debug('Account: ' + testAccount.Id);

// Test creating just 1 contact and candidate
Contact testContact = new Contact(
    FirstName = 'Test',
    LastName = 'SmallTest',
    Email = 'smalltest@example.com',
    AccountId = testAccount.Id
);
insert testContact;
System.debug('Created Contact: ' + testContact.Id);

Candidate__c testCandidate = new Candidate__c(
    Contact__c = testContact.Id,
    First_Name__c = 'Test',
    Last_Name__c = 'SmallTest',
    Email__c = 'smalltest@example.com',
    Status__c = 'Active/In Process'
);
insert testCandidate;
System.debug('Created Candidate: ' + testCandidate.Id);
System.debug('Test successful!');
