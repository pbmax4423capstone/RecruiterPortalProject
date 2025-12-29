// Delete ALL migrated interview records to start fresh
System.debug('=== DELETING ALL MIGRATED INTERVIEWS ===');

// Query all Interview records that were migrated (have External_Id__c set)
List<Interview__c> allMigratedInterviews = [
    SELECT Id, Name, External_Id__c, Interview_Type__c
    FROM Interview__c
    WHERE External_Id__c != null
];

System.debug('Found ' + allMigratedInterviews.size() + ' migrated interviews to delete');

// Count by type before deletion
Map<String, Integer> typeCount = new Map<String, Integer>();
for (Interview__c interview : allMigratedInterviews) {
    String type = interview.Interview_Type__c != null ? interview.Interview_Type__c : 'NULL';
    if (!typeCount.containsKey(type)) {
        typeCount.put(type, 0);
    }
    typeCount.put(type, typeCount.get(type) + 1);
}

System.debug('\n=== INTERVIEWS TO DELETE BY TYPE ===');
for (String type : typeCount.keySet()) {
    System.debug(type + ': ' + typeCount.get(type));
}

if (allMigratedInterviews.size() > 0) {
    try {
        delete allMigratedInterviews;
        System.debug('\n=== DELETION COMPLETE ===');
        System.debug('Successfully deleted ' + allMigratedInterviews.size() + ' interviews');
    } catch (Exception e) {
        System.debug('ERROR: ' + e.getMessage());
        System.debug('Line: ' + e.getLineNumber());
    }
} else {
    System.debug('No interviews to delete');
}
