/**
 * EmailBodyParserTest - Test class for EmailBodyParser and EmailMessageTrigger
 * Provides comprehensive test coverage for email parsing functionality
 *
 * @author Patrick Baker
 * @date 2025-11-19
 */
@isTest
private class EmailBodyParserTest {
  @testSetup
  static void setupTestData() {
    // Create test Case
    Case testCase = new Case(
      Subject = 'Test Email Case',
      Status = 'New',
      Origin = 'Email'
    );
    insert testCase;
  }

  @isTest
  static void testCleanEmailBody_RemovesSignatures() {
    // Test data with signature
    String emailWithSignature =
      'Hi there,\n\n' +
      'This is the actual email content.\n\n' +
      'Thank you,\n\n' +
      'John Doe\n' +
      'Agency Technology Specialist\n' +
      'Practice Development Specialist\n' +
      'Capstone Partners Financial and Insurance Services, LLC\n' +
      'Direct: 702-856-2339';

    Test.startTest();
    String cleaned = EmailBodyParser.cleanEmailBody(emailWithSignature);
    Test.stopTest();

    // Verify signature was removed but content remains
    System.assert(
      cleaned.contains('This is the actual email content'),
      'Email content should be preserved'
    );
    System.assert(
      !cleaned.contains('Agency Technology Specialist'),
      'Signature should be removed'
    );
    System.assert(
      !cleaned.contains('Direct:'),
      'Contact info should be removed'
    );
  }

  @isTest
  static void testCleanEmailBody_RemovesHtml() {
    // Test data with HTML
    String htmlEmail =
      '<html><body><p>Hello,</p><p>This is a <b>test</b> email.</p>' +
      '<p>Thank you</p></body></html>';

    Test.startTest();
    String cleaned = EmailBodyParser.cleanEmailBody(htmlEmail);
    Test.stopTest();

    // Verify HTML was stripped
    System.assert(!cleaned.contains('<html>'), 'HTML tags should be removed');
    System.assert(!cleaned.contains('<p>'), 'HTML tags should be removed');
    System.assert(cleaned.contains('Hello'), 'Content should be preserved');
    System.assert(cleaned.contains('test'), 'Content should be preserved');
  }

  @isTest
  static void testCleanEmailBody_HandlesBlankInput() {
    Test.startTest();
    String cleaned1 = EmailBodyParser.cleanEmailBody('');
    String cleaned2 = EmailBodyParser.cleanEmailBody(null);
    Test.stopTest();

    System.assertEquals('', cleaned1, 'Empty string should return empty');
    System.assertEquals('', cleaned2, 'Null should return empty');
  }

  @isTest
  static void testCleanEmailBody_RemovesCalendlyLinks() {
    String emailWithCalendly =
      'Please schedule a meeting.\n\n' +
      'Calendly - A157 Support\n' +
      'Choose your meeting type or use below:\n' +
      'Encrypt New Computer Device - 2 hour meeting\n' +
      'Chat With Me In Teams\n' +
      'Tech Support help? Email help@capstonetechsupport.com';

    Test.startTest();
    String cleaned = EmailBodyParser.cleanEmailBody(emailWithCalendly);
    Test.stopTest();

    System.assert(
      !cleaned.contains('Calendly'),
      'Calendly references should be removed'
    );
    System.assert(
      !cleaned.contains('Chat With Me In Teams'),
      'Teams link should be removed'
    );
  }

  @isTest
  static void testCreateEmailThreadSummary_SingleEmail() {
    Case testCase = [SELECT Id FROM Case LIMIT 1];

    EmailMessage em = new EmailMessage(
      ParentId = testCase.Id,
      FromAddress = 'test@example.com',
      ToAddress = 'support@example.com',
      Subject = 'Test Subject',
      TextBody = 'This is a test email body.',
      MessageDate = DateTime.now(),
      Incoming = true
    );
    insert em;

    List<EmailMessage> emails = [
      SELECT
        Id,
        FromAddress,
        ToAddress,
        Subject,
        TextBody,
        HtmlBody,
        MessageDate
      FROM EmailMessage
      WHERE ParentId = :testCase.Id
    ];

    Test.startTest();
    String summary = EmailBodyParser.createEmailThreadSummary(emails);
    Test.stopTest();

    System.assert(
      summary.contains('From: test@example.com'),
      'Should include From address'
    );
    System.assert(
      summary.contains('Subject: Test Subject'),
      'Should include Subject'
    );
    System.assert(
      summary.contains('This is a test email body'),
      'Should include body content'
    );
  }

  @isTest
  static void testCreateEmailThreadSummary_MultipleEmails() {
    Case testCase = [SELECT Id FROM Case LIMIT 1];

    List<EmailMessage> emails = new List<EmailMessage>();

    // Create multiple emails with different dates
    for (Integer i = 0; i < 3; i++) {
      EmailMessage em = new EmailMessage(
        ParentId = testCase.Id,
        FromAddress = 'user' + i + '@example.com',
        ToAddress = 'support@example.com',
        Subject = 'RE: Test Subject',
        TextBody = 'Email number ' + i,
        MessageDate = DateTime.now().addDays(-i),
        Incoming = true
      );
      emails.add(em);
    }
    insert emails;

    List<EmailMessage> queriedEmails = [
      SELECT
        Id,
        FromAddress,
        ToAddress,
        Subject,
        TextBody,
        HtmlBody,
        MessageDate
      FROM EmailMessage
      WHERE ParentId = :testCase.Id
      ORDER BY MessageDate ASC
    ];

    Test.startTest();
    String summary = EmailBodyParser.createEmailThreadSummary(queriedEmails);
    Test.stopTest();

    // Verify all emails are in summary
    System.assert(
      summary.contains('user0@example.com'),
      'Should include first sender'
    );
    System.assert(
      summary.contains('user1@example.com'),
      'Should include second sender'
    );
    System.assert(
      summary.contains('user2@example.com'),
      'Should include third sender'
    );

    // Verify separator is present
    System.assert(
      summary.contains('====='),
      'Should include separators between emails'
    );
  }

  @isTest
  static void testCreateEmailThreadSummary_EmptyList() {
    Test.startTest();
    String summary = EmailBodyParser.createEmailThreadSummary(
      new List<EmailMessage>()
    );
    Test.stopTest();

    System.assertEquals('', summary, 'Empty list should return empty string');
  }

  @isTest
  static void testEmailMessageTrigger_NonCaseParent() {
    // Create an email with a non-Case parent (should not error)
    EmailMessage em = new EmailMessage(
      FromAddress = 'test@example.com',
      ToAddress = 'someone@example.com',
      Subject = 'Test',
      TextBody = 'Test body',
      MessageDate = DateTime.now(),
      Status = '0'
    );

    Test.startTest();
    // This should not throw an error even though there's no Case
    insert em;
    Test.stopTest();

    // Verify email was created
    EmailMessage inserted = [SELECT Id FROM EmailMessage WHERE Id = :em.Id];
    System.assertNotEquals(
      null,
      inserted,
      'Email should be inserted successfully'
    );
  }

  @isTest
  static void testEmailMessageTrigger_SubsequentEmailCreatesCaseComment() {
    Case testCase = [SELECT Id FROM Case LIMIT 1];

    // Create first email - should update Description
    EmailMessage em1 = new EmailMessage(
      ParentId = testCase.Id,
      FromAddress = 'customer@example.com',
      ToAddress = 'support@example.com',
      Subject = 'Initial Question',
      TextBody = 'This is my initial question.\n\nThank you,\nJohn\nDirect: 555-1234',
      MessageDate = DateTime.now().addHours(-2),
      Incoming = true,
      Status = '0'
    );
    insert em1;

    // Verify Description was updated
    Case updatedCase1 = [
      SELECT Id, Description
      FROM Case
      WHERE Id = :testCase.Id
    ];
    System.assert(
      updatedCase1.Description.contains('This is my initial question'),
      'First email should update Description'
    );
    System.assert(
      !updatedCase1.Description.contains('Direct: 555-1234'),
      'Signature should be removed from Description'
    );

    // Count existing comments before inserting second email
    Integer existingComments = [
      SELECT COUNT()
      FROM CaseComment
      WHERE ParentId = :testCase.Id
    ];

    // Create second email - should create CaseComment
    EmailMessage em2 = new EmailMessage(
      ParentId = testCase.Id,
      FromAddress = 'support@example.com',
      ToAddress = 'customer@example.com',
      Subject = 'RE: Initial Question',
      TextBody = 'Thank you for reaching out.\n\nBest regards,\nSupport Team\nDirect: 555-5678',
      MessageDate = DateTime.now(),
      Incoming = false,
      Status = '3'
    );

    Test.startTest();
    insert em2;
    Test.stopTest();

    // Verify Case Description was NOT overwritten
    Case updatedCase2 = [
      SELECT Id, Description
      FROM Case
      WHERE Id = :testCase.Id
    ];
    System.assert(
      updatedCase2.Description.contains('This is my initial question'),
      'Description should still contain first email'
    );
    System.assert(
      !updatedCase2.Description.contains('Thank you for reaching out'),
      'Description should NOT contain second email'
    );

    // Verify CaseComment was created for second email
    List<CaseComment> comments = [
      SELECT Id, CommentBody
      FROM CaseComment
      WHERE
        ParentId = :testCase.Id
        AND CommentBody LIKE '%Thank you for reaching out%'
      ORDER BY CreatedDate DESC
    ];

    System.assert(
      comments.size() >= 1,
      'Should have created at least 1 new CaseComment for second email'
    );

    // Debug logging for troubleshooting
    System.debug('CaseComment Body: ' + comments[0].CommentBody);

    System.assert(
      comments[0].CommentBody.contains('Thank you for reaching out'),
      'CaseComment should contain second email body'
    );
    System.assert(
      comments[0].CommentBody.contains('support@example.com'),
      'CaseComment should include sender email address'
    );
    System.assert(
      !comments[0].CommentBody.contains('Direct: 555-5678'),
      'Signature should be removed from CaseComment'
    );
  }

  @isTest
  static void testEmailMessageTrigger_ThirdEmailAlsoCreatesCaseComment() {
    Case testCase = [SELECT Id FROM Case LIMIT 1];

    // Create first two emails
    EmailMessage em1 = new EmailMessage(
      ParentId = testCase.Id,
      FromAddress = 'customer@example.com',
      ToAddress = 'support@example.com',
      Subject = 'Question',
      TextBody = 'First email',
      MessageDate = DateTime.now().addHours(-2),
      Incoming = true,
      Status = '0'
    );
    insert em1;

    EmailMessage em2 = new EmailMessage(
      ParentId = testCase.Id,
      FromAddress = 'support@example.com',
      ToAddress = 'customer@example.com',
      Subject = 'RE: Question',
      TextBody = 'Second email response',
      MessageDate = DateTime.now().addHours(-1),
      Incoming = false,
      Status = '3'
    );
    insert em2;

    // Count comments before third email
    Integer commentsBefore = [
      SELECT COUNT()
      FROM CaseComment
      WHERE ParentId = :testCase.Id
    ];

    // Create third email
    EmailMessage em3 = new EmailMessage(
      ParentId = testCase.Id,
      FromAddress = 'customer@example.com',
      ToAddress = 'support@example.com',
      Subject = 'RE: Question',
      TextBody = 'Third email follow-up',
      MessageDate = DateTime.now(),
      Incoming = true,
      Status = '0'
    );

    Test.startTest();
    insert em3;
    Test.stopTest();

    // Verify 2 CaseComments exist (for 2nd and 3rd emails)
    List<CaseComment> comments = [
      SELECT Id, CommentBody
      FROM CaseComment
      WHERE ParentId = :testCase.Id
      ORDER BY CreatedDate ASC
    ];

    System.assert(
      comments.size() >= 2,
      'Should have at least 2 CaseComments for 2nd and 3rd emails'
    );

    // Find our specific comments by content
    Boolean foundSecond = false;
    Boolean foundThird = false;
    for (CaseComment cc : comments) {
      if (cc.CommentBody.contains('Second email response')) {
        foundSecond = true;
      }
      if (cc.CommentBody.contains('Third email follow-up')) {
        foundThird = true;
      }
    }

    System.assert(foundSecond, 'Should find comment for second email');
    System.assert(foundThird, 'Should find comment for third email');
  }

  @isTest
  static void testCaseAfterUpdateCleaning() {
    // Create a new Case with a dirty description simulating downstream overwrite
    Case dirty = new Case(
      Origin = 'Email',
      Status = 'New',
      Subject = 'Dirty Case',
      Description = 'This is the actual email content.\n\nThanks\nPat Baker\nCapstone Partners Website\nDirect: 555-1212'
    );
    insert dirty;
    // Update description to trigger after update cleaning
    dirty.Description = dirty.Description + '\nExtra trailing line';
    update dirty;
    Case cleaned = [SELECT Id, Description FROM Case WHERE Id = :dirty.Id];
    System.assert(
      cleaned.Description.contains('This is the actual email content'),
      'Email content should be preserved'
    );
    System.assert(
      !cleaned.Description.contains('Direct: 555-1212'),
      'Signature phone line should be stripped'
    );
    System.assert(
      !cleaned.Description.contains('Capstone Partners Website'),
      'Company line should be stripped'
    );
    System.assert(
      cleaned.Description.contains('[[CLEANED]]'),
      'Marker should be appended'
    );
  }

  @isTest
  static void testEmailMessageTrigger_ForwardedThreadInDescription() {
    // Get test Case
    Case testCase = [SELECT Id FROM Case LIMIT 1];

    // Create EmailMessage with forwarded thread content
    String forwardedThread =
      'Please see the email thread below:\n\n' +
      '---------- Forwarded message ---------\n' +
      'From: Jane Smith <jane@example.com>\n' +
      'Date: Mon, Jan 15, 2024 at 3:00 PM\n' +
      'Subject: Re: Original Question\n\n' +
      'Here is my response to the question.\n\n' +
      'On Mon, Jan 15, 2024 at 2:30 PM John Doe <john@example.com> wrote:\n' +
      '> This is the original question.\n' +
      '> Can you help?\n\n' +
      'Thanks,\n\n' +
      'Jane Smith\n' +
      'Sales Director\n' +
      'Example Company\n' +
      'Direct: 555-1234';

    EmailMessage firstEmail = new EmailMessage(
      ParentId = testCase.Id,
      FromAddress = 'customer@example.com',
      Subject = 'Fwd: Original Question',
      TextBody = forwardedThread,
      MessageDate = DateTime.now()
    );

    Test.startTest();
    insert firstEmail;
    Test.stopTest();

    // Verify Case Description contains the forwarded thread (minus signature)
    Case updatedCase = [SELECT Description FROM Case WHERE Id = :testCase.Id];
    System.assertNotEquals(
      null,
      updatedCase.Description,
      'Description should be populated'
    );
    System.assert(
      updatedCase.Description.contains(
        '---------- Forwarded message ---------'
      ),
      'Forwarded header should be preserved'
    );
    System.assert(
      updatedCase.Description.contains('From: Jane Smith'),
      'Thread From line should be preserved'
    );
    System.assert(
      updatedCase.Description.contains('Date: Mon, Jan 15, 2024'),
      'Thread Date line should be preserved'
    );
    System.assert(
      updatedCase.Description.contains('This is the original question'),
      'Quoted original content should be preserved'
    );
    System.assert(
      !updatedCase.Description.contains('Direct: 555-1234'),
      'Signature phone should be removed'
    );
  }
}
