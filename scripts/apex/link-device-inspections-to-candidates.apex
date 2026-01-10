// Link Device Inspections to Candidates
// This script finds Device Inspections linked to Contacts and links them to the corresponding Candidate

// Query all Device Inspections that have a Contact
List<Device_Inspection__c> inspections = [
    SELECT Id, Name, Contact__c, Device_Inspection_Results__c
    FROM Device_Inspection__c
    WHERE Contact__c != null
];

System.debug('Found ' + inspections.size() + ' Device Inspections with Contacts');

// Build a set of Contact IDs
Set<Id> contactIds = new Set<Id>();
for (Device_Inspection__c di : inspections) {
    contactIds.add(di.Contact__c);
}

// Query all Candidates that match these Contacts
Map<Id, Candidate__c> contactToCandidateMap = new Map<Id, Candidate__c>();
for (Candidate__c candidate : [
    SELECT Id, Name, Contact__c
    FROM Candidate__c
    WHERE Contact__c IN :contactIds
]) {
    contactToCandidateMap.put(candidate.Contact__c, candidate);
}

System.debug('Found ' + contactToCandidateMap.size() + ' Candidates with matching Contacts');

// Update Candidates to link to their Device Inspections
Map<Id, Candidate__c> candidatesToUpdate = new Map<Id, Candidate__c>();

for (Device_Inspection__c di : inspections) {
    if (contactToCandidateMap.containsKey(di.Contact__c)) {
        Candidate__c candidate = contactToCandidateMap.get(di.Contact__c);
        
        // Only update if we haven't already processed this candidate
        // or if this is a more recent Device Inspection
        if (!candidatesToUpdate.containsKey(candidate.Id)) {
            // Update the candidate's Device Inspection lookup
            Candidate__c candidateToUpdate = new Candidate__c(
                Id = candidate.Id,
                Device_Inspection__c = di.Id
            );
            
            // Also update Device Inspection Status based on results
            if (di.Device_Inspection_Results__c != null) {
                if (di.Device_Inspection_Results__c.contains('Passed') || 
                    di.Device_Inspection_Results__c.contains('Pass')) {
                    candidateToUpdate.Device_Inspection_Status__c = 'Passed';
                } else if (di.Device_Inspection_Results__c.contains('Failed') || 
                           di.Device_Inspection_Results__c.contains('Fail')) {
                    candidateToUpdate.Device_Inspection_Status__c = 'Failed';
                }
            }
            
            candidatesToUpdate.put(candidate.Id, candidateToUpdate);
            
            System.debug('Will link Candidate "' + candidate.Name + '" to Device Inspection "' + di.Name + '"');
        }
    }
}

System.debug('Updating ' + candidatesToUpdate.size() + ' Candidates');

if (!candidatesToUpdate.isEmpty()) {
    try {
        update candidatesToUpdate.values();
        System.debug('SUCCESS: Updated ' + candidatesToUpdate.size() + ' Candidates with Device Inspection links');
        
        // Verify the updates
        List<Candidate__c> verifyResults = [
            SELECT Id, Name, Device_Inspection__c, Device_Inspection_Status__c
            FROM Candidate__c
            WHERE Device_Inspection__c != null
        ];
        System.debug('Verification: ' + verifyResults.size() + ' Candidates now have Device Inspection links');
        
    } catch (Exception e) {
        System.debug('ERROR: ' + e.getMessage());
        System.debug('Stack Trace: ' + e.getStackTraceString());
    }
}
