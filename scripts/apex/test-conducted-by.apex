// Simple test to access Conducted_By__c field
try {
    List<Interview__c> interviews = [SELECT Id, Name, Conducted_By__c FROM Interview__c LIMIT 1];
    System.debug('SUCCESS: Conducted_By__c field is accessible');
    if (!interviews.isEmpty() && interviews[0].Conducted_By__c != null) {
        System.debug('First interview conducted by ID: ' + interviews[0].Conducted_By__c);
    }
} catch (Exception e) {
    System.debug('ERROR accessing Conducted_By__c: ' + e.getMessage());
}