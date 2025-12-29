// Create ALC records for Contract B and Hired candidates

// Get sales managers
User elizabeth = [SELECT Id FROM User WHERE Username = 'ekagele@financialguide.com.recruiting' LIMIT 1];
User tim = [SELECT Id FROM User WHERE Username = 'tdenton@financialguide.com.recruiting' LIMIT 1];

System.debug('=== CREATING ALC RECORDS ===');

// Get Elizabeth's candidates
List<Candidate__c> elizabethCandidates = [SELECT Id, Name FROM Candidate__c WHERE OwnerId = :elizabeth.Id ORDER BY Name LIMIT 28];

// Create 5 ALC records for Elizabeth - Contract B (in contracting process)
List<ALC__c> elizabethContractB = new List<ALC__c>();
for (Integer i = 0; i < 5; i++) {
    ALC__c alc = new ALC__c();
    alc.Name = 'ALC-' + elizabethCandidates[i + 10].Name;
    alc.Candidate__c = elizabethCandidates[i + 10].Id;
    alc.Contract_Type__c = 'B';
    alc.Stage__c = 'Contract Codes (A/B) & DocuSign';
    elizabethContractB.add(alc);
}
insert elizabethContractB;
System.debug('Created 5 Contract B ALCs for Elizabeth');

// Create 3 ALC records for Elizabeth - Hired this month (Contracted stage)
List<ALC__c> elizabethHired = new List<ALC__c>();
for (Integer i = 0; i < 3; i++) {
    ALC__c alc = new ALC__c();
    alc.Name = 'ALC-' + elizabethCandidates[i].Name;
    alc.Candidate__c = elizabethCandidates[i].Id;
    alc.Contract_Type__c = 'A';
    alc.Stage__c = 'Contracted';
    elizabethHired.add(alc);
}
insert elizabethHired;
System.debug('Created 3 Contracted ALCs for Elizabeth');

// Get Tim's candidates
List<Candidate__c> timCandidates = [SELECT Id, Name FROM Candidate__c WHERE OwnerId = :tim.Id ORDER BY Name LIMIT 20];

// Create 2 ALC records for Tim - Contract B
List<ALC__c> timContractB = new List<ALC__c>();
for (Integer i = 0; i < 2; i++) {
    ALC__c alc = new ALC__c();
    alc.Name = 'ALC-' + timCandidates[i + 5].Name;
    alc.Candidate__c = timCandidates[i + 5].Id;
    alc.Contract_Type__c = 'B';
    alc.Stage__c = 'Sent To Compliance';
    timContractB.add(alc);
}
insert timContractB;
System.debug('Created 2 Contract B ALCs for Tim');

// Create 1 ALC for Tim - Hired this month
ALC__c timHired = new ALC__c();
timHired.Name = 'ALC-' + timCandidates[0].Name;
timHired.Candidate__c = timCandidates[0].Id;
timHired.Contract_Type__c = 'A';
timHired.Stage__c = 'Contracted';
insert timHired;
System.debug('Created 1 Contracted ALC for Tim');

System.debug('=== SUMMARY ===');
System.debug('Elizabeth: 5 on Contract B, 3 hired this month');
System.debug('Tim: 2 on Contract B, 1 hired this month');

// Verify counts
Integer elizabethContractBCount = [SELECT COUNT() FROM ALC__c WHERE Candidate__r.OwnerId = :elizabeth.Id AND Contract_Type__c = 'B'];
Integer elizabethHiredCount = [SELECT COUNT() FROM ALC__c WHERE Candidate__r.OwnerId = :elizabeth.Id AND Stage__c = 'Contracted' AND LastModifiedDate = THIS_MONTH];
Integer timContractBCount = [SELECT COUNT() FROM ALC__c WHERE Candidate__r.OwnerId = :tim.Id AND Contract_Type__c = 'B'];
Integer timHiredCount = [SELECT COUNT() FROM ALC__c WHERE Candidate__r.OwnerId = :tim.Id AND Stage__c = 'Contracted' AND LastModifiedDate = THIS_MONTH];

System.debug('Elizabeth Verification: ContractB=' + elizabethContractBCount + ', Hired=' + elizabethHiredCount);
System.debug('Tim Verification: ContractB=' + timContractBCount + ', Hired=' + timHiredCount);
