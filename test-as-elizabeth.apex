// Run as Elizabeth Kagele
User elizabeth = [SELECT Id FROM User WHERE Id = '005Vo00000ktgovIAA'];
System.runAs(elizabeth) {
    System.debug('=== RUNNING AS ELIZABETH KAGELE ===');
    System.debug('Current User: ' + UserInfo.getName());
    System.debug('Profile: ' + [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name);
    
    try {
        Map<String, Object> result = RecruiterDashboardController.getInterviewTypeWithInterviewerStats();
        System.debug('SUCCESS! Result: ' + JSON.serializePretty(result));
        
        List<Map<String, Object>> attraction = (List<Map<String, Object>>)result.get('attractionByInterviewer');
        System.debug('Attraction count: ' + (attraction != null ? attraction.size() : 0));
        
    } catch (Exception e) {
        System.debug('ERROR: ' + e.getMessage());
        System.debug('Stack: ' + e.getStackTraceString());
    }
}
