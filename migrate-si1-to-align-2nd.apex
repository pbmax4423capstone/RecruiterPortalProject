// Migration Script: SI1 → Align-2nd Interviews
// Migrate SI1 data from Candidate__c to Interview__c object

// Query all Candidates with SI1 data
List<Candidate__c> candidates = [
    SELECT Id, Name,
           SI_1_Date_Completed__c,
           SI_1_Conducted_By__c,
           SI1_Conducted_by__c,
           SI_1_Interview_Conducted_by__c
    FROM Candidate__c
    WHERE SI_1_Date_Completed__c != null
    ORDER BY SI_1_Date_Completed__c
];

System.debug('=== FOUND ' + candidates.size() + ' CANDIDATES WITH SI1 DATA ===');

// Build user cache to avoid SOQL in loop
Map<String, Id> userNameToIdMap = new Map<String, Id>();
for (User u : [SELECT Id, Name FROM User WHERE IsActive = true]) {
    userNameToIdMap.put(u.Name, u.Id);
    // Also add common name variations (e.g., "Brad" → "Bradley")
    if (u.Name == 'Bradley Sofonia') {
        userNameToIdMap.put('Brad', u.Id);
        userNameToIdMap.put('Bradley', u.Id);
    }
}

List<Interview__c> interviewsToInsert = new List<Interview__c>();
Integer processedCount = 0;
Integer skippedCount = 0;

for (Candidate__c cand : candidates) {
    // Determine conductor - check multiple fields
    String conductor = null;
    if (String.isNotBlank(cand.SI_1_Conducted_By__c)) {
        conductor = cand.SI_1_Conducted_By__c;
    } else if (String.isNotBlank(cand.SI1_Conducted_by__c)) {
        conductor = cand.SI1_Conducted_by__c;
    } else if (String.isNotBlank(cand.SI_1_Interview_Conducted_by__c)) {
        conductor = cand.SI_1_Interview_Conducted_by__c;
    }
    
    if (String.isBlank(conductor)) {
        System.debug('SKIPPED: ' + cand.Name + ' - No conductor found');
        skippedCount++;
        continue;
    }
    
    // Find User by name from cache
    Id conductorId = userNameToIdMap.get(conductor);
    if (conductorId == null) {
        System.debug('SKIPPED: ' + cand.Name + ' - Conductor not found: ' + conductor);
        skippedCount++;
        continue;
    }
    
    // Create Interview record
    Interview__c interview = new Interview__c();
    interview.Candidate__c = cand.Id;
    interview.Interview_Type__c = 'Align-2nd';
    interview.Conducted_By__c = conductorId;
    interview.Date_Time_Scheduled__c = cand.SI_1_Date_Completed__c;
    interview.Interview_Status__c = 'Completed';
    
    // Generate unique external ID
    String extId = 'SI1_' + cand.Id + '_' + String.valueOf(cand.SI_1_Date_Completed__c).replace(' ', '_');
    interview.External_Id__c = extId;
    
    interviewsToInsert.add(interview);
    processedCount++;
    
    System.debug('MIGRATING: ' + cand.Name + ' | Conductor: ' + conductor + ' | Date: ' + cand.SI_1_Date_Completed__c);
}

System.debug('\n=== MIGRATION SUMMARY ===');
System.debug('Total Candidates with SI1 Data: ' + candidates.size());
System.debug('Processed for Migration: ' + processedCount);
System.debug('Skipped (no conductor): ' + skippedCount);
System.debug('Interviews to Insert: ' + interviewsToInsert.size());

// Insert interviews
if (!interviewsToInsert.isEmpty()) {
    try {
        insert interviewsToInsert;
        System.debug('\n✅ SUCCESS: Inserted ' + interviewsToInsert.size() + ' Align-2nd interviews');
    } catch (Exception e) {
        System.debug('\n❌ ERROR: ' + e.getMessage());
        System.debug('Line: ' + e.getLineNumber());
    }
} else {
    System.debug('\n⚠️ No interviews to insert');
}
