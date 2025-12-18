// Test the leaderboard method as it would be called
System.debug('=== TESTING LEADERBOARD METHOD ===');
System.debug('Current User: ' + UserInfo.getName());
System.debug('Profile: ' + [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name);

try {
    Map<String, Object> result = RecruiterDashboardController.getInterviewTypeWithInterviewerStats();
    System.debug('SUCCESS! Result: ' + JSON.serializePretty(result));
    
    // Check if data is empty
    List<Map<String, Object>> attraction = (List<Map<String, Object>>)result.get('attractionByInterviewer');
    List<Map<String, Object>> si1 = (List<Map<String, Object>>)result.get('si1ByInterviewer');
    List<Map<String, Object>> si2 = (List<Map<String, Object>>)result.get('si2ByInterviewer');
    List<Map<String, Object>> si3 = (List<Map<String, Object>>)result.get('si3ByInterviewer');
    List<Map<String, Object>> career = (List<Map<String, Object>>)result.get('careerByInterviewer');
    
    System.debug('Attraction count: ' + (attraction != null ? attraction.size() : 0));
    System.debug('SI1 count: ' + (si1 != null ? si1.size() : 0));
    System.debug('SI2 count: ' + (si2 != null ? si2.size() : 0));
    System.debug('SI3 count: ' + (si3 != null ? si3.size() : 0));
    System.debug('Career count: ' + (career != null ? career.size() : 0));
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
}
