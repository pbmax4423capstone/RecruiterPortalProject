// Check if components exist in Integrated Sandbox
System.debug('Interview object exists: ' + Schema.getGlobalDescribe().containsKey('Interview__c'));

// Check for LWC component metadata
try {
    Integer interviewCount = [SELECT COUNT() FROM Interview__c];
    System.debug('Interview records found: ' + interviewCount);
} catch (Exception e) {
    System.debug('Error querying Interview__c: ' + e.getMessage());
}

// Check if RecruiterDashboardController exists
try {
    String result = RecruiterDashboardController.getInterviewStatsByType().toString();
    System.debug('Controller method works: ' + (result.length() > 0));
} catch (Exception e) {
    System.debug('Error calling controller: ' + e.getMessage());
}