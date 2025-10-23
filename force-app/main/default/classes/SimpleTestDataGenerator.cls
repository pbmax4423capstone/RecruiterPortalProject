public class SimpleTestDataGenerator {
    
    @AuraEnabled
    public static String generateSimpleTestData() {
        try {
            // Just return a success message to verify the class works
            return 'SUCCESS: Simple test data generator class is working properly.';
        } catch (Exception e) {
            return 'ERROR: ' + e.getMessage();
        }
    }
}
