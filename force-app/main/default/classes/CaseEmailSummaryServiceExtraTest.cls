@IsTest
private class CaseEmailSummaryServiceExtraTest {

    @IsTest
    static void testProcessEmail_updatesCaseDescription() {
        // Create a Case to attach the email to
        Case c = new Case(Subject = 'Support Request', Origin = 'Phone');
        insert c;

        // Create an incoming EmailMessage with HTML and quoted history/signature patterns
        String html = '<p>Hello Support,</p><p>My app is not loading properly.</p>' +
                      '<p>Best regards,</p><p>John Doe</p>' +
                      '<p>On Jan 1, 2020, Someone wrote:</p><blockquote>older content</blockquote>';
        EmailMessage em = new EmailMessage(
            ParentId = c.Id,
            Incoming = true,
            FromAddress = 'customer@example.com',
            ToAddress = 'support@example.com',
            Subject = 'Problem Loading App',
            HtmlBody = html,
            TextBody = null
        );
        insert em;

        Test.startTest();
        CaseEmailSummaryService.SummaryResult result = CaseEmailSummaryService.processEmail(em.Id, null);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected a summary result');
        System.assertEquals(c.Id, result.caseId, 'Expected the case to be detected');
        System.assert(!String.isBlank(result.summary), 'Summary should be non-blank');

        // Case.Description should be set by the service
        Case cAfter = [SELECT Id, Description FROM Case WHERE Id = :c.Id];
        System.assert(!String.isBlank(cAfter.Description), 'Case.Description should be updated');
    }
}