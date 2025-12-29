// Verify SummaryCardMetricsController exists and check Tim's profile
User tim = [SELECT Id, Name, Username, Profile.Name FROM User WHERE Username = 'tdenton@financialguide.com.recruiting' LIMIT 1];
System.debug('Tim Denton: ' + tim.Name + ', Profile: ' + tim.Profile.Name);

ApexClass cls = [SELECT Id, Name, ApiVersion, Status FROM ApexClass WHERE Name = 'SummaryCardMetricsController' LIMIT 1];
System.debug('Apex Class: ' + cls.Name + ', Status: ' + cls.Status + ', API Version: ' + cls.ApiVersion);

// Test if the method can be called
try {
    Map<String, Object> result = SummaryCardMetricsController.getMetrics();
    System.debug('SUCCESS: Method executed. Result: ' + result);
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
