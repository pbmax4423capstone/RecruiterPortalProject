// Create test candidates with Active/In Process status
List<Candidate__c> testCandidates = new List<Candidate__c>();

// Add candidates with only writeable fields
testCandidates.add(new Candidate__c(
    Email__c = 'john.smith@email.com', 
    Phone__c = '555-0101', 
    Status__c = 'Active/In Process'
));

testCandidates.add(new Candidate__c(
    Email__c = 'sarah.johnson@email.com', 
    Phone__c = '555-0102', 
    Status__c = 'Active/In Process'
));

testCandidates.add(new Candidate__c(
    Email__c = 'mike.davis@email.com', 
    Phone__c = '555-0103', 
    Status__c = 'Active/In Process'
));

testCandidates.add(new Candidate__c(
    Email__c = 'lisa.chen@email.com', 
    Phone__c = '555-0104', 
    Status__c = 'Active/In Process'
));

testCandidates.add(new Candidate__c(
    Email__c = 'robert.wilson@email.com', 
    Phone__c = '555-0105', 
    Status__c = 'Active/In Process'
));

insert testCandidates;

System.debug('Created ' + testCandidates.size() + ' test candidates with Active/In Process status');

// Show the created records
for(Candidate__c candidate : testCandidates) {
    System.debug('Created candidate: ' + candidate.Id + ' - ' + candidate.Email__c);
}