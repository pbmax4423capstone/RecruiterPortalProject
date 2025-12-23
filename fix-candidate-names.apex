// Fix Candidate Names - set Name = First_Name__c + ' ' + Last_Name__c
List<Candidate__c> candidates = [SELECT Id, Name, First_Name__c, Last_Name__c FROM Candidate__c];

List<Candidate__c> toUpdate = new List<Candidate__c>();

for (Candidate__c c : candidates) {
    String expectedName = '';
    if (String.isNotBlank(c.First_Name__c) && String.isNotBlank(c.Last_Name__c)) {
        expectedName = c.First_Name__c + ' ' + c.Last_Name__c;
    } else if (String.isNotBlank(c.First_Name__c)) {
        expectedName = c.First_Name__c;
    } else if (String.isNotBlank(c.Last_Name__c)) {
        expectedName = c.Last_Name__c;
    }
    
    if (String.isNotBlank(expectedName) && c.Name != expectedName) {
        System.debug('Updating: ' + c.Name + ' -> ' + expectedName);
        c.Name = expectedName;
        toUpdate.add(c);
    }
}

if (!toUpdate.isEmpty()) {
    update toUpdate;
    System.debug('Updated ' + toUpdate.size() + ' candidates');
}

// Verify
System.debug('');
System.debug('=== VERIFICATION ===');
for (Candidate__c c : [SELECT Id, Name, First_Name__c, Last_Name__c FROM Candidate__c LIMIT 20]) {
    System.debug(c.Name + ' | First: ' + c.First_Name__c + ' | Last: ' + c.Last_Name__c);
}
