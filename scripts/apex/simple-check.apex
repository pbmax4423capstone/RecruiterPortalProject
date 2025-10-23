// Simple check - does our controller work in this org?
try {
    String result = RecruiterDashboardController.getInterviewStatsByType().toString();
    System.debug('SUCCESS: Controller works! Result length: ' + result.length());
    System.debug('First 500 chars: ' + result.substring(0, Math.min(500, result.length())));
    
    Integer interviews = [SELECT COUNT() FROM Interview__c];
    System.debug('Interview records: ' + interviews);
    
    if (interviews > 0) {
        System.debug('SUCCESS: Data exists and controller works!');
    } else {
        System.debug('WARNING: No interview data found');
    }
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}