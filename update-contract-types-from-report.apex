// Update Contract Types based on LADL Sales Experience from report
// More than 2 years = Contract A
// Less than 2 years or None = Contract B

// Contract A - More than 2 years LADL experience
Set<String> contractANames = new Set<String>{
    'David Bennett',       // More than 2 years
    'Craig Lytle',         // More than 2 years
    'Jonathan Espinoza',   // More than 2 years
    'Preston Lee'          // More than 2 years
};

// Contract B - Less than 2 years or None
Set<String> contractBNames = new Set<String>{
    'Michelle Mayer',           // None
    'Rodrigo Gonzalez',         // None
    'Salina Bouasangouane',     // None
    'Roderick Jackson',         // Less than 2 years
    'Pierre Perez',             // None
    'Sabrina Moya',             // None
    'John McKee',               // Less than 2 years
    'Washington Ibarra',        // None
    'Alec Bucklen',             // None
    'Easton Kimura',            // None
    'Robert Wilson',            // None
    'Gwyneth Landaburu',        // None
    'Mitchell Kallick',         // Less than 2 years
    'Gagandeep Singh',          // None
    'Samuel Frombgen',          // None
    'Darius Shepard',           // None
    'Sandra Soltero',           // (empty - treat as less)
    'Katerina Minevich',        // None
    'Marcus Filardi',           // Less than 2 years
    'Michael Donatucci',        // None
    'David Robbins',            // None (Seraphim Helias)
    'Kristopher Galvan',        // None
    'Lawrence Gabriel Cadena Jr.',  // (empty)
    'Anthony Clayton',          // (empty)
    'Calix Boldt',              // (empty)
    'Jacob Pesicka',            // (empty)
    'Paras Bengco',             // (empty)
    'Yvonne Garcia',            // (empty)
    'Jason Richardson',         // (empty)
    'Mehrasa Mazandarani'       // (empty)
};

// Update Contract A
List<Candidate__c> contractACandidates = [SELECT Id, Name, Contract_Type__c FROM Candidate__c WHERE Name IN :contractANames];
for (Candidate__c c : contractACandidates) {
    c.Contract_Type__c = 'Contract A';
}
if (!contractACandidates.isEmpty()) {
    update contractACandidates;
    System.debug('Updated ' + contractACandidates.size() + ' candidates to Contract A: ');
    for (Candidate__c c : contractACandidates) {
        System.debug('  - ' + c.Name);
    }
}

// Update Contract B
List<Candidate__c> contractBCandidates = [SELECT Id, Name, Contract_Type__c FROM Candidate__c WHERE Name IN :contractBNames];
for (Candidate__c c : contractBCandidates) {
    c.Contract_Type__c = 'Contract B';
}
if (!contractBCandidates.isEmpty()) {
    update contractBCandidates;
    System.debug('Updated ' + contractBCandidates.size() + ' candidates to Contract B: ');
    for (Candidate__c c : contractBCandidates) {
        System.debug('  - ' + c.Name);
    }
}

// Verification
System.debug('');
System.debug('=== VERIFICATION ===');
for (AggregateResult ar : [SELECT Contract_Type__c, COUNT(Id) cnt FROM Candidate__c GROUP BY Contract_Type__c ORDER BY Contract_Type__c]) {
    System.debug(ar.get('Contract_Type__c') + ': ' + ar.get('cnt'));
}
