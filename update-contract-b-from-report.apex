// Update/Create Contract B candidates from the Candidate Complete report
// These are candidates who have been contracted as Contract B this year

// Data from the report - Candidate Name, Contract Effective Date, Start Date
List<Map<String, Object>> candidateData = new List<Map<String, Object>>{
    new Map<String, Object>{'name' => 'Samuel Fenstermacher', 'contractEffective' => Date.newInstance(2025, 7, 1), 'startDate' => Date.newInstance(2025, 7, 1)},
    new Map<String, Object>{'name' => 'Malarie Martin', 'contractEffective' => null, 'startDate' => Date.newInstance(2025, 8, 18)},
    new Map<String, Object>{'name' => 'Alexzander Gonzales', 'contractEffective' => null, 'startDate' => Date.newInstance(2025, 4, 15)},
    new Map<String, Object>{'name' => 'Aaron Diaz', 'contractEffective' => Date.newInstance(2025, 5, 8), 'startDate' => Date.newInstance(2025, 8, 18)},
    new Map<String, Object>{'name' => 'Jordyn Manrique', 'contractEffective' => Date.newInstance(2025, 10, 14), 'startDate' => Date.newInstance(2025, 10, 14)},
    new Map<String, Object>{'name' => 'Gee Na Park', 'contractEffective' => null, 'startDate' => Date.newInstance(2025, 10, 20)},
    new Map<String, Object>{'name' => 'Brandon Arnett', 'contractEffective' => null, 'startDate' => Date.newInstance(2025, 8, 15)},
    new Map<String, Object>{'name' => 'Marc Clark', 'contractEffective' => null, 'startDate' => Date.newInstance(2025, 8, 12)},
    new Map<String, Object>{'name' => 'Stone Sinek', 'contractEffective' => null, 'startDate' => Date.newInstance(2025, 8, 20)},
    new Map<String, Object>{'name' => 'Anthony Balzano', 'contractEffective' => Date.newInstance(2025, 10, 29), 'startDate' => null},
    new Map<String, Object>{'name' => 'Alicia Johnson', 'contractEffective' => Date.newInstance(2025, 11, 11), 'startDate' => Date.newInstance(2025, 11, 11)}
};

// Get all names to search for
Set<String> candidateNames = new Set<String>();
for (Map<String, Object> data : candidateData) {
    candidateNames.add((String)data.get('name'));
}

// Query existing candidates
Map<String, Candidate__c> existingCandidates = new Map<String, Candidate__c>();
for (Candidate__c c : [SELECT Id, Name, First_Name__c, Last_Name__c, Contract_Type__c, Status__c, Start_Date__c, Highest_Level_Achieved__c
                       FROM Candidate__c 
                       WHERE Name IN :candidateNames]) {
    existingCandidates.put(c.Name, c);
}

System.debug('Found ' + existingCandidates.size() + ' existing candidates');

List<Candidate__c> toUpdate = new List<Candidate__c>();
List<Candidate__c> toCreate = new List<Candidate__c>();

for (Map<String, Object> data : candidateData) {
    String name = (String)data.get('name');
    Date contractEffective = (Date)data.get('contractEffective');
    Date startDate = (Date)data.get('startDate');
    
    // Use contract effective date if available, otherwise use start date
    Date effectiveStartDate = contractEffective != null ? contractEffective : startDate;
    
    if (existingCandidates.containsKey(name)) {
        // Update existing candidate
        Candidate__c c = existingCandidates.get(name);
        c.Contract_Type__c = 'Contract B';
        c.Status__c = 'Contracted- Contract B';
        c.Highest_Level_Achieved__c = '7-Contracted';
        if (effectiveStartDate != null) {
            c.Start_Date__c = effectiveStartDate;
        }
        toUpdate.add(c);
        System.debug('Will update: ' + name + ' | Start: ' + effectiveStartDate);
    } else {
        // Create new candidate
        String firstName = name.contains(' ') ? name.substring(0, name.indexOf(' ')) : name;
        String lastName = name.contains(' ') ? name.substring(name.indexOf(' ') + 1) : 'Unknown';
        
        Candidate__c c = new Candidate__c();
        c.Name = name;
        c.First_Name__c = firstName;
        c.Last_Name__c = lastName;
        c.Contract_Type__c = 'Contract B';
        c.Status__c = 'Contracted- Contract B';
        c.Highest_Level_Achieved__c = '7-Contracted';
        if (effectiveStartDate != null) {
            c.Start_Date__c = effectiveStartDate;
        }
        toCreate.add(c);
        System.debug('Will create: ' + name + ' | Start: ' + effectiveStartDate);
    }
}

// Perform updates
if (!toUpdate.isEmpty()) {
    update toUpdate;
    System.debug('Updated ' + toUpdate.size() + ' candidates');
}

// Perform inserts
if (!toCreate.isEmpty()) {
    insert toCreate;
    System.debug('Created ' + toCreate.size() + ' candidates');
}

// Verification
System.debug('');
System.debug('=== ALL CONTRACTED CONTRACT B CANDIDATES ===');
for (Candidate__c c : [SELECT Name, Contract_Type__c, Status__c, Start_Date__c, Highest_Level_Achieved__c
                       FROM Candidate__c 
                       WHERE Status__c = 'Contracted- Contract B'
                       ORDER BY Start_Date__c ASC]) {
    System.debug(c.Name + ' | Type: ' + c.Contract_Type__c + ' | Status: ' + c.Status__c + ' | Start: ' + c.Start_Date__c);
}
