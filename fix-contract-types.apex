// RESET all candidates to null Contract Type first
List<Candidate__c> allCandidates = [SELECT Id, Contract_Type__c FROM Candidate__c WHERE Contract_Type__c != null];
for (Candidate__c c : allCandidates) {
    c.Contract_Type__c = null;
}
if (!allCandidates.isEmpty()) {
    update allCandidates;
    System.debug('Reset ' + allCandidates.size() + ' candidates to null Contract Type');
}

// Now update from the report - Contract Type B candidates
Set<String> contractBNames = new Set<String>{
    'Michelle Mayer',
    'Rodrigo Gonzalez',
    'Preston Lee',
    'Salina Bouasangouane'
};

// Contract Type A candidates
Set<String> contractANames = new Set<String>{
    'Brady Murray',
    'David Bennett'
};

// Update Contract B
List<Candidate__c> contractBCandidates = [SELECT Id, Name, Contract_Type__c FROM Candidate__c WHERE Name IN :contractBNames];
for (Candidate__c c : contractBCandidates) {
    c.Contract_Type__c = 'Contract B';
}
if (!contractBCandidates.isEmpty()) {
    update contractBCandidates;
    System.debug('Updated ' + contractBCandidates.size() + ' candidates to Contract Type B');
}

// Update Contract A
List<Candidate__c> contractACandidates = [SELECT Id, Name, Contract_Type__c FROM Candidate__c WHERE Name IN :contractANames];
for (Candidate__c c : contractACandidates) {
    c.Contract_Type__c = 'Contract A';
}
if (!contractACandidates.isEmpty()) {
    update contractACandidates;
    System.debug('Updated ' + contractACandidates.size() + ' candidates to Contract Type A');
}

// Verification
System.debug('');
System.debug('=== VERIFICATION ===');
for (AggregateResult ar : [SELECT Contract_Type__c, COUNT(Id) cnt FROM Candidate__c GROUP BY Contract_Type__c]) {
    System.debug(ar.get('Contract_Type__c') + ': ' + ar.get('cnt'));
}
