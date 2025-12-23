// Fix candidate names for Prequal candidates
// Name should be First_Name__c + ' ' + Last_Name__c

// Find all candidates in Prequal stage with incorrect names (showing as ID instead of name)
List<Candidate__c> prequalCandidates = [
    SELECT Id, Name, First_Name__c, Last_Name__c, Highest_Level_Achieved__c
    FROM Candidate__c
    WHERE Highest_Level_Achieved__c = '0-Prequal'
];

System.debug('=== PREQUAL CANDIDATES ===');
System.debug('Total found: ' + prequalCandidates.size());

List<Candidate__c> toUpdate = new List<Candidate__c>();

for (Candidate__c c : prequalCandidates) {
    String expectedName = '';
    if (String.isNotBlank(c.First_Name__c)) {
        expectedName = c.First_Name__c;
    }
    if (String.isNotBlank(c.Last_Name__c)) {
        expectedName += (String.isNotBlank(expectedName) ? ' ' : '') + c.Last_Name__c;
    }
    
    System.debug('Current Name: ' + c.Name + ' | First: ' + c.First_Name__c + ' | Last: ' + c.Last_Name__c + ' | Expected: ' + expectedName);
    
    // Check if name is wrong (shows as ID like a02dh00000xxx)
    if (c.Name != expectedName && String.isNotBlank(expectedName)) {
        // Name field is usually auto-generated, but let's see what we can do
        toUpdate.add(c);
    }
}

System.debug('');
System.debug('Candidates needing name fix: ' + toUpdate.size());

// The Name field might be an auto-number or formula field
// Let's check if it's updateable
Schema.DescribeFieldResult nameField = Candidate__c.Name.getDescribe();
System.debug('Name field is updateable: ' + nameField.isUpdateable());
System.debug('Name field type: ' + nameField.getType());
