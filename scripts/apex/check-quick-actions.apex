// Query for QuickAction metadata
List<QuickAction> actions = [SELECT Id, DeveloperName, SobjectType FROM QuickAction WHERE SobjectType = 'Candidate__c'];
System.debug('QuickActions found for Candidate__c: ' + actions.size());
for (QuickAction qa : actions) {
    System.debug('  - ' + qa.DeveloperName);
}
