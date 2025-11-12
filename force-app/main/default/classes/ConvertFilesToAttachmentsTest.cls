@isTest
private class ConvertFilesToAttachmentsTest {
    @isTest
    static void testConvertSingleFile() {
        // Create a parent record for linking
        Account a = new Account(Name = 'Parent');
        insert a;

        // Create a ContentVersion; this will also create a ContentDocument
        ContentVersion cv = new ContentVersion(
            Title = 'TestDoc',
            PathOnClient = 'TestDoc.txt',
            VersionData = Blob.valueOf('hello world'),
            Origin = 'H'
        );
        insert cv;

        // Query back to get the ContentDocumentId
        cv = [SELECT Id, ContentDocumentId, Title, FileType FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        // Link the document to our Account
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = a.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Build request
        ConvertFilesToAttachments.Request req = new ConvertFilesToAttachments.Request();
        req.curContentDocumentLinks = new List<ContentDocumentLink>{ cdl };

        Test.startTest();
        List<ConvertFilesToAttachments.Response> res = ConvertFilesToAttachments.convert(new List<ConvertFilesToAttachments.Request>{ req });
        Test.stopTest();

    System.assertNotEquals(null, res, 'Response list should not be null');
        System.assertEquals(1, res.size(), 'Expect one response');
        System.assertEquals(null, res[0].errors, 'Should not produce errors for valid input');
    System.assertNotEquals(null, res[0].curAttachments, 'Attachments should be returned');
        System.assertEquals(1, res[0].curAttachments.size(), 'One attachment expected');
        Attachment att = res[0].curAttachments[0];
        System.assert(att.Name.startsWith(cv.Title), 'Attachment name should start with title');
        System.assertNotEquals(null, att.Body, 'Attachment body should be set');
    }

    @isTest
    static void testNullInputHandled() {
        // Build request with null list per class behavior
        ConvertFilesToAttachments.Request req = new ConvertFilesToAttachments.Request();
        req.curContentDocumentLinks = null;

        List<ConvertFilesToAttachments.Response> res = ConvertFilesToAttachments.convert(new List<ConvertFilesToAttachments.Request>{ req });
        System.assertEquals(1, res.size());
        System.assert(res[0].errors != null && res[0].errors.contains('WARN'), 'Expect warning message when input is null');
    }
}
