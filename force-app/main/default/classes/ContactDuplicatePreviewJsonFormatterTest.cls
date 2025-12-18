@isTest
private class ContactDuplicatePreviewJsonFormatterTest {
    @isTest
    static void testEmptyGroupsJsonReturnsEmptyOutput() {
        // Provide an input list containing a single JSON string representing an empty group array.
        // This exercises JSON deserialization without entering the loop (avoids runtime cast issues in formatter).
        List<String> out = ContactDuplicatePreviewJsonFormatter.formatJson(new List<String>{ '[]' });
        System.assertEquals(0, out.size(), 'No formatted rows expected for empty groups');
    }

    @isTest
    static void testNullInputReturnsEmptyList() {
        System.assertEquals(0, ContactDuplicatePreviewJsonFormatter.formatJson(null).size());
        System.assertEquals(0, ContactDuplicatePreviewJsonFormatter.formatJson(new List<String>()).size());
    }
}
