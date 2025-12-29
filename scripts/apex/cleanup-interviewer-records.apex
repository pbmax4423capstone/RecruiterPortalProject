// Clean up Interviewer__c records - consolidate variations and remove junk
List<Interviewer__c> allInterviewers = [SELECT Id, Name FROM Interviewer__c ORDER BY Name];

System.debug('=== CLEANING UP ' + allInterviewers.size() + ' INTERVIEWER RECORDS ===');
System.debug('');

// Map to track which names to keep (normalized -> best display name)
Map<String, String> normalizedToDisplay = new Map<String, String>();
Map<String, Id> normalizedToId = new Map<String, Id>();
List<Id> toDelete = new List<Id>();

for (Interviewer__c interviewer : allInterviewers) {
    String rawName = interviewer.Name;
    
    // Skip junk data
    if (rawName == null || rawName.trim() == '') {
        toDelete.add(interviewer.Id);
        continue;
    }
    
    // Remove dates embedded in names (common pattern: "Name MM/DD/YY")
    String cleanName = rawName.replaceAll('\\d{1,2}/\\d{1,2}/\\d{2,4}', '').trim();
    cleanName = cleanName.replaceAll(',\\s*$', ''); // Remove trailing commas
    cleanName = cleanName.replaceAll('\\s+', ' '); // Normalize whitespace
    
    // Skip if it's just a number or date
    Pattern numberPattern = Pattern.compile('^\\d+$');
    Pattern datePattern = Pattern.compile('^\\d{1,2}/\\d{1,2}.*');
    if (numberPattern.matcher(cleanName).matches() || datePattern.matcher(cleanName).matches()) {
        System.debug('DELETE (junk): "' + rawName + '"');
        toDelete.add(interviewer.Id);
        continue;
    }
    
    // Skip single letters or very short entries
    if (cleanName.length() <= 2) {
        System.debug('DELETE (too short): "' + rawName + '"');
        toDelete.add(interviewer.Id);
        continue;
    }
    
    // Normalize for comparison (lowercase, no punctuation)
    String normalized = cleanName.toLowerCase().replaceAll('[^a-z ]', '').trim();
    
    if (normalized == '' || normalized.length() <= 2) {
        System.debug('DELETE (empty after normalization): "' + rawName + '"');
        toDelete.add(interviewer.Id);
        continue;
    }
    
    // Check if we've seen this normalized name before
    if (normalizedToDisplay.containsKey(normalized)) {
        // Keep the one with proper capitalization (has uppercase letter)
        String existingDisplay = normalizedToDisplay.get(normalized);
        
        // Prefer names with proper capitalization
        Boolean currentHasUpper = cleanName.toLowerCase() != cleanName;
        Boolean existingHasUpper = existingDisplay.toLowerCase() != existingDisplay;
        
        if (currentHasUpper && !existingHasUpper) {
            // Current is better - mark existing for deletion, keep current
            Id oldId = normalizedToId.get(normalized);
            toDelete.add(oldId);
            normalizedToDisplay.put(normalized, cleanName);
            normalizedToId.put(normalized, interviewer.Id);
            System.debug('REPLACE: "' + existingDisplay + '" -> "' + cleanName + '"');
        } else {
            // Keep existing, delete current duplicate
            toDelete.add(interviewer.Id);
            System.debug('DELETE (duplicate of "' + existingDisplay + '"): "' + rawName + '"');
        }
    } else {
        // First time seeing this normalized name - keep it
        normalizedToDisplay.put(normalized, cleanName);
        normalizedToId.put(normalized, interviewer.Id);
    }
}

System.debug('');
System.debug('=== CLEANUP SUMMARY ===');
System.debug('Original records: ' + allInterviewers.size());
System.debug('Unique interviewers to keep: ' + normalizedToDisplay.size());
System.debug('Records to delete: ' + toDelete.size());
System.debug('');

// Show what we're keeping
System.debug('=== KEEPING THESE INTERVIEWERS ===');
List<String> keepNames = new List<String>(normalizedToDisplay.values());
keepNames.sort();
for (Integer i = 0; i < Math.min(50, keepNames.size()); i++) {
    System.debug((i+1) + '. "' + keepNames[i] + '"');
}
if (keepNames.size() > 50) {
    System.debug('... and ' + (keepNames.size() - 50) + ' more');
}

// Delete duplicates and junk
if (!toDelete.isEmpty()) {
    System.debug('');
    System.debug('Deleting ' + toDelete.size() + ' records...');
    List<Interviewer__c> toDeleteRecords = [SELECT Id FROM Interviewer__c WHERE Id IN :toDelete];
    delete toDeleteRecords;
    System.debug('✓ Deletion complete');
}

System.debug('');
System.debug('=== FINAL COUNT ===');
System.debug('Interviewer records remaining: ' + [SELECT COUNT() FROM Interviewer__c]);
