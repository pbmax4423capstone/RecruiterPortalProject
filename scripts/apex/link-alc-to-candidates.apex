// Link ALC records to their corresponding Candidate records by matching Name
List<ALC__c> unlinkedALCs = [
    SELECT Id, Name, Candidate__c 
    FROM ALC__c 
    WHERE RecordType.DeveloperName = 'Career' 
    AND Candidate__c = null 
    AND Stage__c NOT IN ('Candidate Complete', 'CANCELED', 'TERMINATED', 'CANCELLED', 'To do')
];

System.debug('Found ' + unlinkedALCs.size() + ' unlinked ALC records');

// Get all candidate names we need to match
Set<String> alcNames = new Set<String>();
for (ALC__c alc : unlinkedALCs) {
    alcNames.add(alc.Name);
}

// Query candidates that match the ALC names
Map<String, Id> candidateNameToId = new Map<String, Id>();
List<Candidate__c> candidates = [
    SELECT Id, Name 
    FROM Candidate__c 
    WHERE Name IN :alcNames
];

for (Candidate__c c : candidates) {
    candidateNameToId.put(c.Name, c.Id);
}

System.debug('Found ' + candidates.size() + ' matching candidates');

// Update ALC records with matching Candidate
List<ALC__c> alcsToUpdate = new List<ALC__c>();
List<String> notFound = new List<String>();

for (ALC__c alc : unlinkedALCs) {
    if (candidateNameToId.containsKey(alc.Name)) {
        alc.Candidate__c = candidateNameToId.get(alc.Name);
        alcsToUpdate.add(alc);
        System.debug('Linking: ' + alc.Name + ' -> ' + candidateNameToId.get(alc.Name));
    } else {
        notFound.add(alc.Name);
        System.debug('No match found for: ' + alc.Name);
    }
}

if (!alcsToUpdate.isEmpty()) {
    update alcsToUpdate;
    System.debug('Successfully updated ' + alcsToUpdate.size() + ' ALC records');
}

System.debug('ALC records not matched: ' + notFound.size());
for (String name : notFound) {
    System.debug('  - ' + name);
}
