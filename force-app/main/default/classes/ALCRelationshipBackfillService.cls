/**
 * Service class for managing ALC Contact/Candidate relationship backfill operations
 * Provides methods for finding unlinked ALCs, matching with existing Contacts,
 * and creating/linking Contact and Candidate records
 *
 * @group ALC Automation
 * @date 2026-01-08
 */
public class ALCRelationshipBackfillService {
  // Constants
  private static final Integer NAME_SIMILARITY_THRESHOLD = 80;
  private static final Integer MAX_MATCH_RESULTS = 5;

  /**
   * Wrapper class to hold Contact match results with similarity scoring
   */
  public class ContactMatchResult {
    public Contact matchedContact { get; set; }
    public Decimal similarityScore { get; set; }
    public String matchType { get; set; }

    public ContactMatchResult(Contact contact, Decimal score, String type) {
      this.matchedContact = contact;
      this.similarityScore = score;
      this.matchType = type;
    }
  }

  /**
   * Wrapper class for backfill decisions from the UI
   */
  public class BackfillDecision {
    public Id alcId { get; set; }
    public Id selectedContactId { get; set; }
    public Boolean createNewContact { get; set; }
  }

  /**
   * Wrapper class for backfill processing results
   */
  public class BackfillResult {
    public Integer contactsCreated { get; set; }
    public Integer candidatesCreated { get; set; }
    public Integer alcsUpdated { get; set; }
    public List<String> errors { get; set; }

    public BackfillResult() {
      this.contactsCreated = 0;
      this.candidatesCreated = 0;
      this.alcsUpdated = 0;
      this.errors = new List<String>();
    }
  }

  /**
   * Calculate Levenshtein distance between two strings using dynamic programming
   * @param s1 First string
   * @param s2 Second string
   * @return Edit distance as Integer
   */
  @TestVisible
  private static Integer calculateLevenshteinDistance(String s1, String s2) {
    // Handle null/empty strings
    if (String.isBlank(s1)) {
      return String.isBlank(s2) ? 0 : s2.length();
    }
    if (String.isBlank(s2)) {
      return s1.length();
    }

    // Convert to lowercase for case-insensitive comparison
    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    Integer len1 = s1.length();
    Integer len2 = s2.length();

    // Create 2D matrix for dynamic programming
    List<List<Integer>> matrix = new List<List<Integer>>();

    // Initialize matrix
    for (Integer i = 0; i <= len1; i++) {
      List<Integer> row = new List<Integer>();
      for (Integer j = 0; j <= len2; j++) {
        row.add(0);
      }
      matrix.add(row);
    }

    // Fill first column (distance from empty string)
    for (Integer i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }

    // Fill first row (distance from empty string)
    for (Integer j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    // Calculate edit distance using dynamic programming
    for (Integer i = 1; i <= len1; i++) {
      for (Integer j = 1; j <= len2; j++) {
        Integer cost = s1.substring(i - 1, i) == s2.substring(j - 1, j) ? 0 : 1;

        Integer deletion = matrix[i - 1][j] + 1;
        Integer insertion = matrix[i][j - 1] + 1;
        Integer substitution = matrix[i - 1][j - 1] + cost;

        matrix[i][j] = Math.min(Math.min(deletion, insertion), substitution);
      }
    }

    return matrix[len1][len2];
  }

  /**
   * Calculate name similarity percentage using Levenshtein distance
   * @param name1 First name string
   * @param name2 Second name string
   * @return Similarity percentage (0-100)
   */
  @TestVisible
  private static Decimal calculateNameSimilarity(String name1, String name2) {
    if (String.isBlank(name1) || String.isBlank(name2)) {
      return 0;
    }

    Integer distance = calculateLevenshteinDistance(name1, name2);
    Integer maxLength = Math.max(name1.length(), name2.length());

    if (maxLength == 0) {
      return 100;
    }

    Decimal similarity =
      (1 - (Decimal.valueOf(distance) / Decimal.valueOf(maxLength))) * 100;
    return similarity.setScale(2);
  }

  /**
   * Standardize phone number to 10-digit format for US numbers
   * @param phone Phone number string
   * @return Standardized 10-digit phone or null
   */
  @TestVisible
  private static String standardizePhone(String phone) {
    if (String.isBlank(phone)) {
      return null;
    }

    // Remove all non-numeric characters
    String digitsOnly = phone.replaceAll('[^0-9]', '');

    // Handle US numbers with country code (1)
    if (digitsOnly.length() == 11 && digitsOnly.startsWith('1')) {
      digitsOnly = digitsOnly.substring(1);
    }

    // Return 10-digit phone or null if invalid
    return digitsOnly.length() == 10 ? digitsOnly : null;
  }

  /**
   * Find all ALCs without linked Contacts
   * @return List of ALC records missing Contact relationships
   */
  public static List<ALC__c> findUnlinkedALCs() {
    return [
      SELECT
        Id,
        Name,
        First_Name__c,
        Last_Name__c,
        Mobile__c,
        Personal_Email_Address__c,
        Contact__c,
        Candidate__c,
        RecordType.DeveloperName
      FROM ALC__c
      WHERE Contact__c = NULL
      ORDER BY CreatedDate DESC
      LIMIT 1000
    ];
  }

  /**
   * Find all ALCs with specific record type and no Contact
   * @param recordTypeName Developer name of record type
   * @return List of ALC records for that type without Contacts
   */
  public static List<ALC__c> findUnlinkedALCsByType(String recordTypeName) {
    return [
      SELECT
        Id,
        Name,
        First_Name__c,
        Last_Name__c,
        Mobile__c,
        Personal_Email_Address__c,
        Contact__c,
        Candidate__c,
        RecordType.DeveloperName
      FROM ALC__c
      WHERE Contact__c = NULL AND RecordType.DeveloperName = :recordTypeName
      ORDER BY CreatedDate DESC
      LIMIT 1000
    ];
  }

  /**
   * Find matching Contacts for an ALC using fuzzy name matching, email, and phone
   * @param alc ALC record to find matches for
   * @return List of ContactMatchResult ordered by similarity score
   */
  public static List<ContactMatchResult> findMatchingContacts(ALC__c alc) {
    List<ContactMatchResult> results = new List<ContactMatchResult>();

    if (alc == null) {
      return results;
    }

    String firstName = alc.First_Name__c;
    String lastName = alc.Last_Name__c;
    String email = alc.Personal_Email_Address__c;
    String phone = standardizePhone(alc.Mobile__c);

    // Build dynamic WHERE clause
    List<String> conditions = new List<String>();

    if (String.isNotBlank(lastName)) {
      conditions.add(
        'LastName LIKE \'%' + String.escapeSingleQuotes(lastName) + '%\''
      );
    }

    if (String.isNotBlank(email)) {
      conditions.add(
        '(Email = \'' +
          String.escapeSingleQuotes(email) +
          '\' OR Personal_Email__c = \'' +
          String.escapeSingleQuotes(email) +
          '\')'
      );
    }

    if (conditions.isEmpty()) {
      return results;
    }

    // Query potential Contact matches
    String query =
      'SELECT Id, FirstName, LastName, Email, MobilePhone, Personal_Email__c ' +
      'FROM Contact WHERE ' +
      String.join(conditions, ' OR ') +
      ' LIMIT 50';

    List<Contact> potentialMatches = Database.query(query);

    // Pre-build standardized phone map for efficiency
    Map<Id, String> contactIdToStandardizedPhone = new Map<Id, String>();
    if (String.isNotBlank(phone)) {
      for (Contact c : potentialMatches) {
        String stdPhone = standardizePhone(c.MobilePhone);
        if (stdPhone != null) {
          contactIdToStandardizedPhone.put(c.Id, stdPhone);
        }
      }
    }

    // Score each potential match
    for (Contact c : potentialMatches) {
      String matchType = '';
      Decimal score = 0;

      // 1. Check for email exact match (highest priority)
      if (String.isNotBlank(email)) {
        if (
          email.equalsIgnoreCase(c.Email) ||
          email.equalsIgnoreCase(c.Personal_Email__c)
        ) {
          matchType = 'Email Match';
          score = 100;
        }
      }

      // 2. Check for phone match (high priority)
      if (score < 100 && String.isNotBlank(phone)) {
        String contactStdPhone = contactIdToStandardizedPhone.get(c.Id);
        if (contactStdPhone != null && phone == contactStdPhone) {
          matchType = 'Phone Match';
          score = 95;
        }
      }

      // 3. Name fuzzy matching (fallback)
      if (score < 95) {
        String alcFullName =
          (firstName != null ? firstName + ' ' : '') +
          (lastName != null ? lastName : '');
        String contactFullName =
          (c.FirstName != null ? c.FirstName + ' ' : '') +
          (c.LastName != null ? c.LastName : '');

        Decimal nameSimilarity = calculateNameSimilarity(
          alcFullName.trim(),
          contactFullName.trim()
        );

        if (nameSimilarity >= NAME_SIMILARITY_THRESHOLD) {
          matchType = 'Name Match';
          score = nameSimilarity;
        }
      }

      // Add to results if above threshold
      if (score >= NAME_SIMILARITY_THRESHOLD) {
        results.add(new ContactMatchResult(c, score, matchType));
      }
    }

    // Sort by score descending (manual sort since Apex doesn't support comparator directly on lists)
    for (Integer i = 0; i < results.size(); i++) {
      for (Integer j = i + 1; j < results.size(); j++) {
        if (results[j].similarityScore > results[i].similarityScore) {
          ContactMatchResult temp = results[i];
          results[i] = results[j];
          results[j] = temp;
        }
      }
    }

    // Return top matches only
    if (results.size() > MAX_MATCH_RESULTS) {
      List<ContactMatchResult> topResults = new List<ContactMatchResult>();
      for (Integer i = 0; i < MAX_MATCH_RESULTS; i++) {
        topResults.add(results[i]);
      }
      return topResults;
    }

    return results;
  }

  /**
   * Process backfill decisions from the UI wizard
   * @param decisions List of user decisions for each ALC
   * @return BackfillResult with success counts and errors
   */
  public static BackfillResult processBackfillDecisions(
    List<BackfillDecision> decisions
  ) {
    BackfillResult result = new BackfillResult();

    if (decisions == null || decisions.isEmpty()) {
      result.errors.add('No decisions provided');
      return result;
    }

    // Get all ALC IDs from decisions
    Set<Id> alcIds = new Set<Id>();
    for (BackfillDecision decision : decisions) {
      alcIds.add(decision.alcId);
    }

    // Bulk query ALCs (SOQL best practice)
    Map<Id, ALC__c> alcMap = new Map<Id, ALC__c>(
      [
        SELECT
          Id,
          Name,
          First_Name__c,
          Last_Name__c,
          Mobile__c,
          Personal_Email_Address__c,
          Contact__c,
          Candidate__c,
          RecordType.DeveloperName
        FROM ALC__c
        WHERE Id IN :alcIds
      ]
    );

    // Get selected Contact IDs for bulk query
    Set<Id> contactIds = new Set<Id>();
    for (BackfillDecision decision : decisions) {
      if (decision.selectedContactId != null) {
        contactIds.add(decision.selectedContactId);
      }
    }

    // Bulk query Contacts
    Map<Id, Contact> contactMap = new Map<Id, Contact>();
    if (!contactIds.isEmpty()) {
      contactMap = new Map<Id, Contact>(
        [
          SELECT Id, FirstName, LastName, Email, MobilePhone, Personal_Email__c
          FROM Contact
          WHERE Id IN :contactIds
        ]
      );
    }

    // Process each decision
    List<Contact> contactsToInsert = new List<Contact>();
    List<Candidate__c> candidatesToInsert = new List<Candidate__c>();
    List<ALC__c> alcsToUpdate = new List<ALC__c>();
    Map<Integer, Id> indexToContactId = new Map<Integer, Id>();
    Map<Integer, Id> indexToCandidateId = new Map<Integer, Id>();

    Integer index = 0;
    for (BackfillDecision decision : decisions) {
      ALC__c alc = alcMap.get(decision.alcId);

      if (alc == null) {
        result.errors.add('ALC not found: ' + decision.alcId);
        continue;
      }

      Id contactId;

      if (decision.createNewContact) {
        // Create new Contact
        Contact newContact = new Contact();
        newContact.FirstName = alc.First_Name__c;
        newContact.LastName = alc.Last_Name__c != null
          ? alc.Last_Name__c
          : 'Unknown';
        newContact.Personal_Email__c = alc.Personal_Email_Address__c;
        newContact.MobilePhone = alc.Mobile__c;

        contactsToInsert.add(newContact);
        indexToContactId.put(index, null); // Will update after insert
        index++;
      } else if (decision.selectedContactId != null) {
        // Use existing Contact
        contactId = decision.selectedContactId;
        indexToContactId.put(index, contactId);
        index++;
      } else {
        result.errors.add('No decision made for ALC: ' + alc.Name);
        continue;
      }
    }

    // Insert new Contacts
    if (!contactsToInsert.isEmpty()) {
      try {
        insert contactsToInsert;
        result.contactsCreated = contactsToInsert.size();

        // Update index map with new Contact IDs
        Integer contactIndex = 0;
        for (Integer i : indexToContactId.keySet()) {
          if (
            indexToContactId.get(i) == null &&
            contactIndex < contactsToInsert.size()
          ) {
            indexToContactId.put(i, contactsToInsert[contactIndex].Id);
            contactIndex++;
          }
        }
      } catch (DmlException e) {
        result.errors.add('Error inserting Contacts: ' + e.getMessage());
        return result;
      }
    }

    // Now process Candidates and ALC updates
    index = 0;
    for (BackfillDecision decision : decisions) {
      ALC__c alc = alcMap.get(decision.alcId);

      if (alc == null || !indexToContactId.containsKey(index)) {
        index++;
        continue;
      }

      Id contactId = indexToContactId.get(index);
      alc.Contact__c = contactId;

      // Create Candidate for Career type ALCs
      if (
        alc.RecordType.DeveloperName == 'Career' &&
        alc.Candidate__c == null
      ) {
        Candidate__c newCandidate = new Candidate__c();
        newCandidate.First_Name__c = alc.First_Name__c;
        newCandidate.Last_Name__c = alc.Last_Name__c;
        newCandidate.personal_email__c = alc.Personal_Email_Address__c;
        newCandidate.Phone__c = alc.Mobile__c;
        newCandidate.Contact__c = contactId;
        newCandidate.Status__c = 'Contract Sent';

        candidatesToInsert.add(newCandidate);
        indexToCandidateId.put(index, null); // Will update after insert
      }

      alcsToUpdate.add(alc);
      index++;
    }

    // Insert new Candidates
    if (!candidatesToInsert.isEmpty()) {
      try {
        insert candidatesToInsert;
        result.candidatesCreated = candidatesToInsert.size();

        // Update ALC Candidate relationships
        Integer candidateIndex = 0;
        for (Integer i : indexToCandidateId.keySet()) {
          if (
            indexToCandidateId.get(i) == null &&
            candidateIndex < candidatesToInsert.size()
          ) {
            ALC__c alc = alcsToUpdate[i];
            alc.Candidate__c = candidatesToInsert[candidateIndex].Id;
            candidateIndex++;
          }
        }
      } catch (DmlException e) {
        result.errors.add('Error inserting Candidates: ' + e.getMessage());
      }
    }

    // Update ALCs with Contact and Candidate relationships
    if (!alcsToUpdate.isEmpty()) {
      try {
        update alcsToUpdate;
        result.alcsUpdated = alcsToUpdate.size();
      } catch (DmlException e) {
        result.errors.add('Error updating ALCs: ' + e.getMessage());
      }
    }

    return result;
  }
}
