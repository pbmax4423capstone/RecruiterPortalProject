// Get ALL unique conductor names for November Attraction interviews
Set<String> allConductors = new Set<String>();
for (Candidate__c c : [
    SELECT AI_Conducted_By__c 
    FROM Candidate__c 
    WHERE Attraction_Interview_Date_Completed__c = THIS_MONTH 
    AND AI_Conducted_By__c != null
]) {
    allConductors.add(c.AI_Conducted_By__c);
}

System.debug('=== All Unique AI_Conducted_By__c values (November) ===');
List<String> sortedNames = new List<String>(allConductors);
sortedNames.sort();
for (String name : sortedNames) {
    System.debug('  "' + name + '"');
}

System.debug('\nTotal unique names: ' + allConductors.size());

// Check how many match SF Sales Managers
Set<String> sfManagers = new Set<String>{'Andrew Moore', 'Bradley Sofonia', 'Brooke Ianni', 'Elizabeth Kagele', 'Rachyll Tenny', 'Tim Denton', 'Van Hess', 'Brad Sofonia'};
Integer matchCount = 0;
for (String conductor : allConductors) {
    if (sfManagers.contains(conductor)) {
        matchCount++;
        System.debug('MATCH: ' + conductor);
    }
}
System.debug('\nMatching SF Sales Managers: ' + matchCount + '/' + allConductors.size());
