@isTest
private class ContactDuplicatePreviewJsonTest {
    @isTest
    static void testPreviewDuplicatesBuildsGroups() {
        // Create two contacts sharing the same local-part of the email
        Contact c1 = new Contact(LastName = 'One', Email = 'john@example.com');
        Contact c2 = new Contact(LastName = 'Two', Email = 'john@sample.org');
        Contact c3 = new Contact(LastName = 'Three', Email = 'alice@example.com');
        insert new List<Contact>{ c1, c2, c3 };

        List<String> out = ContactDuplicatePreviewJson.previewDuplicates(new List<String>{ 'x' });
        System.assertEquals(1, out.size(), 'Should return one JSON string');

        // Deserialize and validate structure
        List<Object> groups = (List<Object>) JSON.deserializeUntyped(out[0]);
        System.assert(groups.size() > 0, 'At least one group expected');

        Boolean found = false;
        for (Object o : groups) {
            Map<String, Object> grp = (Map<String, Object>) o;
            if ((String)grp.get('groupKey') == 'john') {
                List<Object> ids = (List<Object>) grp.get('contactIds');
                Set<String> idSet = new Set<String>();
                for (Object idVal : ids) idSet.add((String)idVal);
                System.assert(idSet.contains(c1.Id), 'Group should include first contact');
                System.assert(idSet.contains(c2.Id), 'Group should include second contact');
                found = true;
            }
        }
        System.assert(found, 'Expected to find group for key john');
    }
}