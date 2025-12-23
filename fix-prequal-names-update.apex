// Fix candidate names for Prequal candidates
// Name should be First_Name__c + ' ' + Last_Name__c

List<Candidate__c> prequalCandidates = [
    SELECT Id, Name, First_Name__c, Last_Name__c
    FROM Candidate__c
    WHERE Highest_Level_Achieved__c = '0-Prequal'
];

System.debug('Total Prequal candidates: ' + prequalCandidates.size());

List<Candidate__c> toUpdate = new List<Candidate__c>();

for (Candidate__c c : prequalCandidates) {
    String newName = '';
    if (String.isNotBlank(c.First_Name__c)) {
        newName = c.First_Name__c;
    }
    if (String.isNotBlank(c.Last_Name__c)) {
        newName += (String.isNotBlank(newName) ? ' ' : '') + c.Last_Name__c;
    }
    
    // Only update if name is different and we have a valid new name
    if (c.Name != newName && String.isNotBlank(newName)) {
        c.Name = newName;
        toUpdate.add(c);
    }
}

if (!toUpdate.isEmpty()) {
    update toUpdate;
    System.debug('Updated ' + toUpdate.size() + ' candidate names');
}

// Verification
System.debug('');
System.debug('=== VERIFICATION ===');
for (Candidate__c c : [SELECT Id, Name, First_Name__c, Last_Name__c FROM Candidate__c WHERE Highest_Level_Achieved__c = '0-Prequal' LIMIT 10]) {
    System.debug(c.Name + ' | First: ' + c.First_Name__c + ' | Last: ' + c.Last_Name__c);
}
