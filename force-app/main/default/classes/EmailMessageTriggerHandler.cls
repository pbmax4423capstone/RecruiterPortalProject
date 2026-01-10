/**
 * Updated EmailMessageTriggerHandler that integrates with existing CaseEmailSummaryService
 *
 * Logic:
 * - First email on Case: Populate Case Description with cleaned email body
 * - Subsequent emails: Create CaseComment with cleaned email body
 * - Uses EmailBodyParser for superior cleaning (removes signatures, footers, etc.)
 *
 * @author Patrick Baker
 * @date 2025-11-19
 */
public with sharing class EmailMessageTriggerHandler {
  /**
   * Handle after insert event - process emails based on whether they're first or subsequent
   * Integrates with existing CaseEmailSummaryService
   */
  public static void handleAfterInsert(List<EmailMessage> newEmailMessages) {
    // Collect Case IDs that need processing
    Set<Id> caseIds = new Set<Id>();
    Map<Id, EmailMessage> newEmailsByCase = new Map<Id, EmailMessage>();

    for (EmailMessage em : newEmailMessages) {
      // Only process emails related to Cases
      if (
        em.ParentId != null && String.valueOf(em.ParentId).startsWith('500')
      ) {
        caseIds.add(em.ParentId);
        newEmailsByCase.put(em.ParentId, em);
      }
    }

    if (caseIds.isEmpty()) {
      return;
    }

    // Query Cases to check if Description is already populated with actual content
    Map<Id, Case> casesMap = new Map<Id, Case>(
      [
        SELECT Id, Description
        FROM Case
        WHERE Id IN :caseIds
      ]
    );

    // Count emails per case to determine if this is the first
    Map<Id, Integer> emailCountByCase = new Map<Id, Integer>();

    for (AggregateResult ar : [
      SELECT ParentId, COUNT(Id) cnt
      FROM EmailMessage
      WHERE ParentId IN :caseIds
      GROUP BY ParentId
    ]) {
      Id caseId = (Id) ar.get('ParentId');
      Integer count = (Integer) ar.get('cnt');
      emailCountByCase.put(caseId, count);
    }

    // Process emails based on whether they're the first or subsequent
    List<Case> casesToUpdate = new List<Case>();
    List<CaseComment> commentsToInsert = new List<CaseComment>();

    for (Id caseId : newEmailsByCase.keySet()) {
      EmailMessage newEmail = newEmailsByCase.get(caseId);
      Integer emailCount = emailCountByCase.get(caseId);
      Case c = casesMap.get(caseId);

      // Check if this is the first email
      // Consider it first if: only 1 email exists, OR Description is blank/contains default text
      Boolean isFirstEmail =
        (emailCount == 1) ||
        String.isBlank(c.Description) ||
        c.Description.startsWith('Customer issue:') ||
        c.Description.startsWith('Customer reports:') ||
        c.Description.startsWith('Customer emailed');

      // Get raw body (preserve thread structure for first email)
      String rawBody = String.isNotBlank(newEmail.TextBody)
        ? newEmail.TextBody
        : newEmail.HtmlBody;

      if (String.isBlank(rawBody)) {
        continue; // Skip if no content
      }

      if (isFirstEmail) {
        // First email: Preserve entire thread/forwarded content, only clean signatures
        // Do NOT remove quoted text or thread markers like "From:", "On...", etc.
        String cleanedBody = EmailBodyParser.cleanEmailBody(rawBody);
        if (String.isNotBlank(cleanedBody)) {
          casesToUpdate.add(new Case(Id = caseId, Description = cleanedBody));
        }
      } else {
        // Subsequent email: Create CaseComment with cleaned body
        String cleanedBody = EmailBodyParser.cleanEmailBody(rawBody);
        if (String.isBlank(cleanedBody))
          continue;
        // Build robust header (ensure From always present; add To for clarity)
        String fromAddr = String.isNotBlank(newEmail.FromAddress)
          ? newEmail.FromAddress
          : '(unknown)';
        String toAddr = String.isNotBlank(newEmail.ToAddress)
          ? newEmail.ToAddress
          : '';
        String commentHeader = 'From: ' + fromAddr + '\n';
        if (String.isNotBlank(toAddr)) {
          commentHeader += 'To: ' + toAddr + '\n';
        }
        commentHeader +=
          'Date: ' +
          newEmail.MessageDate.format('MMM d, yyyy h:mm a') +
          '\n';
        if (String.isNotBlank(newEmail.Subject)) {
          commentHeader += 'Subject: ' + newEmail.Subject + '\n';
        }
        commentHeader += '\n';

        commentsToInsert.add(
          new CaseComment(
            ParentId = caseId,
            CommentBody = commentHeader + cleanedBody,
            IsPublished = false
          )
        );
      }
    }

    // Perform DML operations
    if (!casesToUpdate.isEmpty()) {
      update casesToUpdate;
    }

    if (!commentsToInsert.isEmpty()) {
      insert commentsToInsert;
    }
  }
}
