// Analyze the Interviewer__c records to see what names we have
List<Interviewer__c> interviewers = [SELECT Id, Name FROM Interviewer__c ORDER BY Name];

System.debug('=== ANALYZING ' + interviewers.size() + ' INTERVIEWER RECORDS ===');
System.debug('');

// Group by similar names (case variations, typos, etc.)
Map<String, List<String>> nameClusters = new Map<String, List<String>>();

for (Interviewer__c interviewer : interviewers) {
    String normalized = interviewer.Name.trim().toLowerCase().replaceAll('[^a-z ]', '');
    
    if (!nameClusters.containsKey(normalized)) {
        nameClusters.put(normalized, new List<String>());
    }
    nameClusters.get(normalized).add(interviewer.Name);
}

System.debug('Unique normalized names: ' + nameClusters.size());
System.debug('');

// Show names with variations
System.debug('=== NAMES WITH MULTIPLE VARIATIONS ===');
Integer variationCount = 0;
for (String normalized : nameClusters.keySet()) {
    List<String> variations = nameClusters.get(normalized);
    if (variations.size() > 1) {
        System.debug(normalized + ' (' + variations.size() + ' variations):');
        for (String var : variations) {
            System.debug('  - "' + var + '"');
        }
        variationCount++;
    }
}
System.debug('');
System.debug('Names with variations: ' + variationCount);
System.debug('');

// Sample of first 50 names
System.debug('=== FIRST 50 INTERVIEWER NAMES ===');
for (Integer i = 0; i < Math.min(50, interviewers.size()); i++) {
    System.debug((i+1) + '. "' + interviewers[i].Name + '"');
}
