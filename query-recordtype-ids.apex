// Query all Record Types for Candidate__c and ALC__c
System.debug('=== CANDIDATE__C RECORD TYPES ===');
List<RecordType> candidateRTs = [
    SELECT Id, Name, DeveloperName, IsActive 
    FROM RecordType 
    WHERE SObjectType = 'Candidate__c'
    ORDER BY Name
];
for (RecordType rt : candidateRTs) {
    System.debug(rt.DeveloperName + ' (' + rt.Name + '): ' + rt.Id + ' | Active: ' + rt.IsActive);
}

System.debug('\n=== ALC__C RECORD TYPES ===');
List<RecordType> alcRTs = [
    SELECT Id, Name, DeveloperName, IsActive 
    FROM RecordType 
    WHERE SObjectType = 'ALC__c'
    ORDER BY Name
];
for (RecordType rt : alcRTs) {
    System.debug(rt.DeveloperName + ' (' + rt.Name + '): ' + rt.Id + ' | Active: ' + rt.IsActive);
}
