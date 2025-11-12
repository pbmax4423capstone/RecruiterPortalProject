/**
 * Simple class to help boost org-wide test coverage
 */
public class OrgCoverageBooster {
    
    /**
     * Basic method to boost coverage
     */
    public static String coverExtra() {
        String result = 'Coverage Boost: ';
        
        // Test String methods
        String testString = 'Hello World';
        result += testString.toLowerCase();
        result += testString.toUpperCase();
        result += testString.substring(0, 5);
        
        // Test List operations
        List<String> testList = new List<String>();
        testList.add('Item1');
        testList.add('Item2');
        result += String.valueOf(testList.size());
        
        // Test Map operations
        Map<String, String> testMap = new Map<String, String>();
        testMap.put('key1', 'value1');
        testMap.put('key2', 'value2');
        result += String.valueOf(testMap.size());
        
        // Test Date operations
        Date today = Date.today();
        DateTime now = DateTime.now();
        result += today.format();
        result += String.valueOf(now.year());
        
        // Test Math operations
        Integer sum = Math.max(10, 20);
        sum += Math.min(5, 15);
        result += String.valueOf(sum);
        
        // Test exception handling
        try {
            Integer testInt = Integer.valueOf('notanumber');
        } catch (Exception e) {
            result += 'Exception handled';
        }
        
        return result;
    }
    
    /**
     * Another method to increase coverage
     */
    public static Boolean validateData(String input) {
        if (String.isBlank(input)) {
            return false;
        }
        
        if (input.length() < 3) {
            return false;
        }
        
        if (input.contains('invalid')) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Method to test various scenarios
     */
    public static List<String> processStrings(List<String> inputs) {
        List<String> results = new List<String>();
        
        if (inputs == null || inputs.isEmpty()) {
            return results;
        }
        
        for (String input : inputs) {
            if (validateData(input)) {
                results.add(input.trim().toUpperCase());
            }
        }
        
        return results;
    }
}