// Query candidates without contract type and their related ALC records for LADL Sales Experience
// Less than 2 years = Contract B
// 2+ years = Contract A

// Get candidates without contract type
List<Candidate__c> candidatesNoContractType = [
    SELECT Id, Name, Contract_Type__c, Status__c
    FROM Candidate__c
    WHERE Contract_Type__c = null
    AND Status__c = 'Completed'
];

System.debug('Candidates without Contract Type: ' + candidatesNoContractType.size());

// Get their IDs
Set<Id> candidateIds = new Set<Id>();
for (Candidate__c c : candidatesNoContractType) {
    candidateIds.add(c.Id);
}

// Query ALC records for these candidates
Map<Id, String> candidateToExperience = new Map<Id, String>();
for (ALC__c alc : [
    SELECT Id, Candidate__c, LADL_Sales_Experience__c 
    FROM ALC__c 
    WHERE Candidate__c IN :candidateIds
    AND LADL_Sales_Experience__c != null
]) {
    candidateToExperience.put(alc.Candidate__c, alc.LADL_Sales_Experience__c);
}

System.debug('ALC records with experience data: ' + candidateToExperience.size());

// Show unique experience values
Set<String> uniqueExperiences = new Set<String>(candidateToExperience.values());
System.debug('Unique LADL_Sales_Experience__c values: ' + uniqueExperiences);

// Categorize candidates
List<Candidate__c> contractAList = new List<Candidate__c>();
List<Candidate__c> contractBList = new List<Candidate__c>();
List<Candidate__c> noDataList = new List<Candidate__c>();

for (Candidate__c c : candidatesNoContractType) {
    String exp = candidateToExperience.get(c.Id);
    
    if (exp == null) {
        noDataList.add(c);
    } else if (exp.containsIgnoreCase('Less than 2') || exp.containsIgnoreCase('< 2') || exp == 'None') {
        c.Contract_Type__c = 'Contract B';
        contractBList.add(c);
        System.debug('Contract B: ' + c.Name + ' (' + exp + ')');
    } else {
        // 2+ years, 3+ years, etc.
        c.Contract_Type__c = 'Contract A';
        contractAList.add(c);
        System.debug('Contract A: ' + c.Name + ' (' + exp + ')');
    }
}

System.debug('');
System.debug('=== SUMMARY ===');
System.debug('Contract A (2+ years): ' + contractAList.size());
System.debug('Contract B (< 2 years): ' + contractBList.size());
System.debug('No ALC experience data: ' + noDataList.size());

// Update candidates with contract types
List<Candidate__c> allToUpdate = new List<Candidate__c>();
allToUpdate.addAll(contractAList);
allToUpdate.addAll(contractBList);

if (!allToUpdate.isEmpty()) {
    update allToUpdate;
    System.debug('Updated ' + allToUpdate.size() + ' candidates with contract types');
}
