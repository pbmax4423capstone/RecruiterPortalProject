// Set the 7 candidates with null contract type to Contract A
List<String> names = new List<String>{
    'Brian Barney', 'Calix Boldt', 'David Tsymbal', 'Jacob Pesicka', 
    'Michael McKnight', 'Paras Bengco', 'Yvonne Garcia'
};

List<Candidate__c> candidates = [SELECT Id, Name FROM Candidate__c WHERE Name IN :names];
for (Candidate__c c : candidates) {
    c.Contract_Type__c = 'Contract A';
}
update candidates;

System.debug('Updated ' + candidates.size() + ' candidates to Contract A');
for (Candidate__c c : candidates) {
    System.debug(c.Name + ' -> Contract A');
}
