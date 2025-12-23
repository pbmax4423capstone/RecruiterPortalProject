// Update Contract B candidates from report to show as contracted
// Status should be "Contracted- Contract B" for them to appear in Active Contract B Progress

// Contract B candidates from report who should be marked as contracted:
// Michelle Mayer - B, Contract Eff: 9/16/2025, Contract B Exp: 1/13/2026
// Rodrigo Gonzalez - B, Contract Eff: 8/29/2025, Contract B Exp: 12/26/2025
// Preston Lee - B, Start: 9/8/2025 (already set to Contract A, need to change?)
// Salina Bouasangouane - B

// First, find and update existing candidates
List<String> contractBNames = new List<String>{
    'Michelle Mayer',
    'Rodrigo Gonzalez',
    'Salina Bouasangouane'
};

// Preston Lee should stay Contract A per the LADL experience data

// Query existing candidates
List<Candidate__c> existingCandidates = [
    SELECT Id, Name, Contract_Type__c, Status__c, Highest_Level_Achieved__c, Start_Date__c
    FROM Candidate__c 
    WHERE Name IN :contractBNames
];

System.debug('=== FOUND CANDIDATES ===');
for (Candidate__c c : existingCandidates) {
    System.debug(c.Name + ' | Status: ' + c.Status__c + ' | HLA: ' + c.Highest_Level_Achieved__c + ' | Type: ' + c.Contract_Type__c);
}

// Build map for start dates
Map<String, Date> startDates = new Map<String, Date>{
    'Michelle Mayer' => Date.newInstance(2025, 9, 16),
    'Rodrigo Gonzalez' => Date.newInstance(2025, 8, 29)
};

// Update existing candidates to be contracted Contract B
List<Candidate__c> toUpdate = new List<Candidate__c>();
for (Candidate__c c : existingCandidates) {
    c.Contract_Type__c = 'Contract B';
    c.Status__c = 'Contracted- Contract B';
    c.Highest_Level_Achieved__c = '7-Contracted';
    
    if (startDates.containsKey(c.Name)) {
        c.Start_Date__c = startDates.get(c.Name);
    }
    
    toUpdate.add(c);
}

if (!toUpdate.isEmpty()) {
    update toUpdate;
    System.debug('Updated ' + toUpdate.size() + ' candidates to contracted Contract B');
}

// Check for missing candidates that need to be created
Set<String> foundNames = new Set<String>();
for (Candidate__c c : existingCandidates) {
    foundNames.add(c.Name);
}

List<Candidate__c> toCreate = new List<Candidate__c>();
for (String name : contractBNames) {
    if (!foundNames.contains(name)) {
        System.debug('Need to create: ' + name);
        
        // Parse name
        String firstName = name.contains(' ') ? name.substring(0, name.indexOf(' ')) : name;
        String lastName = name.contains(' ') ? name.substring(name.indexOf(' ') + 1) : 'Unknown';
        
        Candidate__c c = new Candidate__c();
        c.First_Name__c = firstName;
        c.Last_Name__c = lastName;
        c.Contract_Type__c = 'Contract B';
        c.Status__c = 'Contracted- Contract B';
        c.Highest_Level_Achieved__c = '7-Contracted';
        
        if (startDates.containsKey(name)) {
            c.Start_Date__c = startDates.get(name);
        }
        
        toCreate.add(c);
    }
}

if (!toCreate.isEmpty()) {
    insert toCreate;
    System.debug('Created ' + toCreate.size() + ' new contracted Contract B candidates');
}

// Verification
System.debug('');
System.debug('=== VERIFICATION - CONTRACT B CONTRACTED ===');
for (Candidate__c c : [SELECT Name, Status__c, Highest_Level_Achieved__c, Contract_Type__c, Start_Date__c 
                       FROM Candidate__c 
                       WHERE Contract_Type__c = 'Contract B' 
                       AND (Status__c = 'Contracted- Contract B' OR Highest_Level_Achieved__c = '7-Contracted')]) {
    System.debug(c.Name + ' | Status: ' + c.Status__c + ' | HLA: ' + c.Highest_Level_Achieved__c + ' | Start: ' + c.Start_Date__c);
}
