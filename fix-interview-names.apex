// Fix Interview Names - set Name = Candidate Name + ' - ' + Interview Type
List<Interview__c> interviews = [SELECT Id, Name, Candidate__c, Candidate__r.Name, Interview_Type__c FROM Interview__c];

List<Interview__c> toUpdate = new List<Interview__c>();

for (Interview__c i : interviews) {
    String expectedName = '';
    if (String.isNotBlank(i.Candidate__r.Name) && String.isNotBlank(i.Interview_Type__c)) {
        expectedName = i.Candidate__r.Name + ' - ' + i.Interview_Type__c;
    } else if (String.isNotBlank(i.Candidate__r.Name)) {
        expectedName = i.Candidate__r.Name;
    }
    
    if (String.isNotBlank(expectedName) && i.Name != expectedName) {
        System.debug('Updating: ' + i.Name + ' -> ' + expectedName);
        i.Name = expectedName;
        toUpdate.add(i);
    }
}

if (!toUpdate.isEmpty()) {
    update toUpdate;
    System.debug('Updated ' + toUpdate.size() + ' interviews');
}

// Verify
System.debug('');
System.debug('=== VERIFICATION ===');
for (Interview__c i : [SELECT Id, Name, Candidate__r.Name, Interview_Type__c FROM Interview__c LIMIT 10]) {
    System.debug(i.Name);
}

System.debug('');
System.debug('Total interviews: ' + [SELECT COUNT() FROM Interview__c]);
