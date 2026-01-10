/**
 * EmailBodyParser - Utility class to parse and clean email bodies from EmailMessage records
 * Removes signatures, headers, footers, and extracts clean conversation threads
 * for use in Case descriptions.
 *
 * @author Patrick Baker
 * @date 2025-11-19
 */
public with sharing class EmailBodyParser {
  // Common signature patterns to identify and remove
  private static final List<String> SIGNATURE_PATTERNS = new List<String>{
    'Direct:',
    'Direct ',
    'CA Insurance License',
    'Capstone Partners Website',
    'MassMutual',
    'Schedule time to meet',
    'Calendly',
    'Chat With Me In Teams',
    'Tech Support help?',
    'Visit us on:',
    'Interested in a career',
    'This e-mail transmission may contain',
    'This message was sent via secure encryption'
  };

  private static final List<String> FOOTER_PATTERNS = new List<String>{
    'Practice Development Specialist',
    'Agency Technology Specialist',
    'Administrative Director',
    'Financial and Insurance Services'
  };

  /**
   * Parse and clean email body from EmailMessage
   * @param emailBody - The raw email body (TextBody preferred, HtmlBody as fallback)
   * @return Cleaned email body without signatures and footers
   */
  public static String cleanEmailBody(String emailBody) {
    if (String.isBlank(emailBody)) {
      return '';
    }

    String cleanedBody = emailBody;

    // Remove HTML tags if present
    cleanedBody = stripHtml(cleanedBody);

    // Remove signature blocks
    cleanedBody = removeSignatures(cleanedBody);

    // Remove excessive whitespace
    cleanedBody = normalizeWhitespace(cleanedBody);

    return cleanedBody.trim();
  }

  /**
   * Extract email thread from forwarded email and create summary
   * @param emailMessages - List of EmailMessage records related to a Case
   * @return Formatted summary of email thread
   */
  public static String createEmailThreadSummary(
    List<EmailMessage> emailMessages
  ) {
    if (emailMessages == null || emailMessages.isEmpty()) {
      return '';
    }

    List<String> emailBodies = new List<String>();

    // Sort by MessageDate ascending (oldest first)
    emailMessages.sort();

    for (EmailMessage em : emailMessages) {
      String body = String.isNotBlank(em.TextBody) ? em.TextBody : em.HtmlBody;
      if (String.isNotBlank(body)) {
        String cleanBody = cleanEmailBody(body);
        if (String.isNotBlank(cleanBody)) {
          // Add email metadata and body
          String emailEntry = 'From: ' + em.FromAddress + '\n';
          emailEntry += 'Date: ' + em.MessageDate.format('MMM d, yyyy') + '\n';
          if (String.isNotBlank(em.Subject)) {
            emailEntry += 'Subject: ' + em.Subject + '\n';
          }
          emailEntry += '\n' + cleanBody;
          emailBodies.add(emailEntry);
        }
      }
    }

    // Join all email bodies with separators
    return String.join(emailBodies, '\n\n' + '='.repeat(50) + '\n\n');
  }

  /**
   * Strip HTML tags from email body
   * @param htmlContent - HTML content
   * @return Plain text content
   */
  private static String stripHtml(String htmlContent) {
    if (String.isBlank(htmlContent) || !htmlContent.contains('<')) {
      return htmlContent;
    }

    String plainText = htmlContent;

    // Remove style and script tags with their content
    plainText = plainText.replaceAll('(?i)<style[^>]*>.*?</style>', '');
    plainText = plainText.replaceAll('(?i)<script[^>]*>.*?</script>', '');

    // Remove HTML comments
    plainText = plainText.replaceAll('<!--.*?-->', '');

    // Convert common HTML entities
    plainText = plainText.replaceAll('&nbsp;', ' ');
    plainText = plainText.replaceAll('&#8211;', '-');
    plainText = plainText.replaceAll('&#8217;', '\'');
    plainText = plainText.replaceAll('&amp;', '&');
    plainText = plainText.replaceAll('&lt;', '<');
    plainText = plainText.replaceAll('&gt;', '>');
    plainText = plainText.replaceAll('&quot;', '"');

    // Replace <br> and </p> with newlines
    plainText = plainText.replaceAll('(?i)<br\\s*/?>', '\n');
    plainText = plainText.replaceAll('(?i)</p>', '\n');

    // Remove all remaining HTML tags
    plainText = plainText.replaceAll('<[^>]+>', '');

    return plainText;
  }

  /**
   * Remove signature blocks from email body
   * @param emailBody - Email body text
   * @return Email body without signatures
   */
  private static String removeSignatures(String emailBody) {
    String result = emailBody;

    // Find the earliest occurrence of any signature pattern
    Integer earliestIndex = result.length();

    for (String pattern : SIGNATURE_PATTERNS) {
      Integer index = result.indexOf(pattern);
      if (index >= 0 && index < earliestIndex) {
        earliestIndex = index;
      }
    }

    // Also check for footer patterns
    for (String pattern : FOOTER_PATTERNS) {
      Integer index = result.indexOf(pattern);
      if (index >= 0 && index < earliestIndex) {
        earliestIndex = index;
      }
    }

    // Also look for common "From:" lines that indicate forwarded email headers
    // But preserve the actual email content before it
    List<String> lines = result.split('\n');
    Integer fromLineIndex = -1;

    for (Integer i = 0; i < lines.size(); i++) {
      String line = lines[i].trim();

      // Check if this looks like a signature line (name followed by title on next line)
      if (
        i < lines.size() - 1 &&
        line.length() > 0 &&
        line.length() < 50 &&
        !line.contains('@') &&
        isFirstCharUpper(line)
      ) {
        String nextLine = lines[i + 1].trim();
        for (String footerPattern : FOOTER_PATTERNS) {
          if (nextLine.contains(footerPattern)) {
            fromLineIndex = i;
            break;
          }
        }
      }

      if (fromLineIndex >= 0) {
        break;
      }
    }

    // Cut at signature
    if (earliestIndex < result.length()) {
      result = result.substring(0, earliestIndex);
    }

    // Also cut at signature line index if found
    if (fromLineIndex >= 0) {
      List<String> remainingLines = new List<String>();
      for (Integer i = 0; i < fromLineIndex && i < lines.size(); i++) {
        remainingLines.add(lines[i]);
      }
      String byLineResult = String.join(remainingLines, '\n');
      if (byLineResult.length() < result.length()) {
        result = byLineResult;
      }
    }

    // Secondary pass: remove blocks after common polite closings (Thanks, Thank you, Best, Regards, Sincerely)
    List<String> finalLines = result.split('\n');
    Integer closingIndex = -1;
    for (Integer i = 0; i < finalLines.size(); i++) {
      String l = finalLines[i].trim();
      if (
        Pattern.matches(
          '(?i)^(thanks|thank you|best|regards|sincerely)[, ]*$',
          l
        )
      ) {
        closingIndex = i;
        break;
      }
    }
    if (closingIndex >= 0) {
      // Determine extent of signature: subsequent lines that are short, have no sentence punctuation, and lack '@'
      Integer endSig = closingIndex + 1;
      while (endSig < finalLines.size()) {
        String sigLine = finalLines[endSig].trim();
        // Stop if blank line followed by apparent paragraph
        if (sigLine == '')
          break;
        Boolean hasPunct =
          sigLine.contains('.') ||
          sigLine.contains('?') ||
          sigLine.contains('!');
        Boolean looksSignature =
          sigLine.length() > 0 &&
          sigLine.length() <= 70 &&
          !sigLine.contains('@') &&
          !hasPunct;
        // Heuristic: company or title keywords
        if (
          looksSignature &&
          (sigLine.contains('Director') ||
          sigLine.contains('Manager') ||
          sigLine.contains('Technology') ||
          sigLine.contains('Capstone') ||
          sigLine.contains('Partners') ||
          sigLine.contains('Support') ||
          sigLine.contains('Team') ||
          sigLine.contains('Developer'))
        ) {
          endSig++;
          continue;
        }
        // Direct: line already removed earlier; if encountered treat as inside signature
        if (looksSignature && sigLine.startsWith('Direct')) {
          endSig++;
          continue;
        }
        // If line fails signature heuristic, stop
        break;
      }
      if (endSig > closingIndex) {
        List<String> keep = new List<String>();
        for (Integer i = 0; i < closingIndex; i++)
          keep.add(finalLines[i]);
        result = String.join(keep, '\n');
      }
    }

    return result;
  }

  /**
   * Normalize whitespace - remove excessive blank lines and spaces
   * @param text - Input text
   * @return Normalized text
   */
  private static String normalizeWhitespace(String text) {
    if (String.isBlank(text)) {
      return '';
    }

    // Replace multiple spaces with single space
    String result = text.replaceAll(' +', ' ');

    // Replace multiple newlines with maximum of 2
    result = result.replaceAll('[\r\n]{3,}', '\n\n');

    // Remove trailing spaces on each line
    List<String> lines = result.split('\n');
    List<String> trimmedLines = new List<String>();
    for (String line : lines) {
      trimmedLines.add(line.trim());
    }

    return String.join(trimmedLines, '\n');
  }

  /**
   * Helper to check if the first character of a string is an uppercase letter.
   */
  private static Boolean isFirstCharUpper(String s) {
    if (String.isBlank(s))
      return false;
    String first = s.substring(0, 1);
    // True if it's a letter and equals its uppercase form
    return (first == first.toUpperCase()) && (first != first.toLowerCase());
  }
}
