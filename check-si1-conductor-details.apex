// Check SI1 conductor values including empty/blank
System.debug('=== SI1 CONDUCTOR DETAILS ===');

// Check for truly NULL
Integer nullCount = [SELECT COUNT() FROM Candidate__c WHERE SI_1_Date_Completed__c != null AND SI_1_Conducted_By__c = null];
System.debug('NULL conductors: ' + nullCount);

// Check for empty string
Integer emptyCount = [SELECT COUNT() FROM Candidate__c WHERE SI_1_Date_Completed__c != null AND SI_1_Conducted_By__c = ''];
System.debug('Empty string conductors: ' + emptyCount);

// Get sample of what's in those fields
List<Candidate__c> samples = [
    SELECT Id, Name, SI_1_Conducted_By__c 
    FROM Candidate__c 
    WHERE SI_1_Date_Completed__c != null 
    LIMIT 20
];

System.debug('\n=== SAMPLE SI1 CONDUCTORS ===');
for (Candidate__c c : samples) {
    String val = c.SI_1_Conducted_By__c;
    if (val == null) {
        System.debug(c.Name + ': NULL');
    } else if (val == '') {
        System.debug(c.Name + ': EMPTY STRING');
    } else {
        System.debug(c.Name + ': "' + val + '"');
    }
}

// Total with any value
Integer withValue = [SELECT COUNT() FROM Candidate__c WHERE SI_1_Date_Completed__c != null AND SI_1_Conducted_By__c != null AND SI_1_Conducted_By__c != ''];
System.debug('\nWith actual conductor value: ' + withValue);
