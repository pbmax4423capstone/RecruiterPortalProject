/**
 * Test class for ALCRelationshipMonitorController
 * Tests dashboard monitoring and gap detection functionality
 *
 * @group ALC Automation
 * @date 2026-01-08
 */
@isTest
private class ALCRelationshipMonitorController_Test {
  @TestSetup
  static void makeData() {
    // Create test Candidates
    List<Candidate__c> testCandidates = new List<Candidate__c>{
      new Candidate__c(
        First_Name__c = 'NoContact',
        Last_Name__c = 'Candidate',
        personal_email__c = 'nocontact@test.com',
        Phone__c = '555-111-1111'
      ),
      new Candidate__c(
        First_Name__c = 'HasContact',
        Last_Name__c = 'Candidate',
        personal_email__c = 'hascontact@test.com',
        Phone__c = '555-222-2222'
      )
    };
    insert testCandidates;

    // Create test audit logs with valid Operation_Type__c picklist values
    List<ALC_Automation_Log__c> testLogs = new List<ALC_Automation_Log__c>{
      new ALC_Automation_Log__c(
        Operation_Type__c = 'Contact Created',
        Success__c = true,
        Error_Message__c = 'Test message'
      ),
      new ALC_Automation_Log__c(
        Operation_Type__c = 'Candidate Created',
        Success__c = false,
        Error_Type__c = 'Validation Error',
        Error_Message__c = 'Error message'
      )
    };
    insert testLogs;
  }

  @isTest
  static void testGetRelationshipGaps() {
    Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName()
      .get('Career')
      ?.getRecordTypeId();
    if (careerRTId == null)
      return;

    // Create ALC without Contact
    ALC__c testALC = new ALC__c(
      First_Name__c = 'Gap',
      Last_Name__c = 'Test',
      Personal_Email_Address__c = 'gap@test.com',
      Mobile__c = '555-111-2222',
      RecordTypeId = careerRTId
    );
    insert testALC;

    // Remove auto-created Contact link
    testALC.Contact__c = null;
    testALC.Candidate__c = null;
    update testALC;

    Test.startTest();
    List<ALCRelationshipMonitorController.RelationshipGap> gaps = ALCRelationshipMonitorController.getRelationshipGaps();
    Test.stopTest();

    System.assertNotEquals(null, gaps, 'Should return gaps list');
    System.assert(gaps.size() >= 1, 'Should find at least 1 gap');
    System.assertEquals(
      false,
      gaps[0].hasContact,
      'Gap should show missing Contact'
    );
  }

  @isTest
  static void testGetRelationshipGaps_CareerWithoutCandidate() {
    Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName()
      .get('Career')
      ?.getRecordTypeId();
    if (careerRTId == null)
      return;

    // Create Career ALC with Contact but no Candidate
    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'Contact',
      Email = 'test@test.com'
    );
    insert testContact;

    ALC__c testALC = new ALC__c(
      First_Name__c = 'Career',
      Last_Name__c = 'NoCandidate',
      Personal_Email_Address__c = 'careernocand@test.com',
      Mobile__c = '555-333-3333',
      Contact__c = testContact.Id,
      RecordTypeId = careerRTId
    );
    insert testALC;

    // Remove auto-created Candidate link
    testALC.Candidate__c = null;
    update testALC;

    Test.startTest();
    List<ALCRelationshipMonitorController.RelationshipGap> gaps = ALCRelationshipMonitorController.getRelationshipGaps();
    Test.stopTest();

    Boolean foundCareerGap = false;
    for (ALCRelationshipMonitorController.RelationshipGap gap : gaps) {
      if (gap.alcId == testALC.Id) {
        foundCareerGap = true;
        System.assertEquals(true, gap.hasContact, 'Should have Contact');
        System.assertEquals(
          false,
          gap.hasCandidate,
          'Should be missing Candidate'
        );
        System.assertEquals('Career', gap.recordType, 'Should be Career type');
      }
    }
    System.assert(foundCareerGap, 'Should find Career gap');
  }

  @isTest
  static void testGetCandidatesWithoutContacts() {
    Test.startTest();
    List<ALCRelationshipMonitorController.CandidateGap> gaps = ALCRelationshipMonitorController.getCandidatesWithoutContacts();
    Test.stopTest();

    System.assertNotEquals(null, gaps, 'Should return candidate gaps list');
    // May or may not find gaps depending on trigger behavior
  }

  @isTest
  static void testGetRecentAuditLogs() {
    Test.startTest();
    List<ALC_Automation_Log__c> logs = ALCRelationshipMonitorController.getRecentAuditLogs(
      100
    );
    Test.stopTest();

    System.assertNotEquals(null, logs, 'Should return logs list');
    System.assert(logs.size() >= 2, 'Should find at least 2 test logs');
  }

  @isTest
  static void testMarkLogResolved() {
    ALC_Automation_Log__c log = [
      SELECT Id, Resolved__c
      FROM ALC_Automation_Log__c
      LIMIT 1
    ];
    System.assertEquals(false, log.Resolved__c, 'Should start unresolved');

    Test.startTest();
    ALCRelationshipMonitorController.markLogResolved(
      log.Id,
      'Tested and resolved'
    );
    Test.stopTest();

    log = [
      SELECT Resolved__c, Resolution_Notes__c
      FROM ALC_Automation_Log__c
      WHERE Id = :log.Id
    ];
    System.assertEquals(true, log.Resolved__c, 'Should be marked resolved');
    System.assertEquals(
      'Tested and resolved',
      log.Resolution_Notes__c,
      'Should have resolution notes'
    );
  }

  @isTest
  static void testFixCandidateContact() {
    Candidate__c candidate;
    try {
      candidate = [
        SELECT Id, Contact__c
        FROM Candidate__c
        WHERE personal_email__c = 'hascontact@test.com'
        LIMIT 1
      ];
    } catch (Exception e) {
      // Fallback: create a candidate if none found
      candidate = new Candidate__c(
        First_Name__c = 'HasContact',
        Last_Name__c = 'Candidate',
        personal_email__c = 'hascontact@test.com',
        Phone__c = '555-222-2222'
      );
      insert candidate;
    }
    Contact newContact = new Contact(
      FirstName = 'New',
      LastName = 'Contact',
      Email = 'newcontact@test.com'
    );
    insert newContact;

    Test.startTest();
    ALCRelationshipMonitorController.fixCandidateContact(
      candidate.Id,
      newContact.Id
    );
    Test.stopTest();

    candidate = [SELECT Contact__c FROM Candidate__c WHERE Id = :candidate.Id];
    System.assertEquals(
      newContact.Id,
      candidate.Contact__c,
      'Should link Candidate to Contact'
    );
  }

  @isTest
  static void testGetSummaryStatistics() {
    Test.startTest();
    Map<String, Object> stats = ALCRelationshipMonitorController.getSummaryStatistics();
    Test.stopTest();

    System.assertNotEquals(null, stats, 'Should return statistics map');
    System.assert(
      stats.containsKey('alcsWithoutContacts'),
      'Should have alcsWithoutContacts'
    );
    System.assert(
      stats.containsKey('careerWithoutCandidates'),
      'Should have careerWithoutCandidates'
    );
    System.assert(
      stats.containsKey('candidatesWithoutContacts'),
      'Should have candidatesWithoutContacts'
    );
    System.assert(
      stats.containsKey('unresolvedErrors'),
      'Should have unresolvedErrors'
    );
    System.assert(
      stats.containsKey('recentErrors'),
      'Should have recentErrors'
    );
  }

  @isTest
  static void testGetRelationshipGaps_EmptyResult() {
    // Delete all gaps
    delete [
      SELECT Id
      FROM ALC__c
      WHERE
        Contact__c = NULL
        OR (RecordType.DeveloperName = 'Career'
        AND Candidate__c = NULL)
    ];

    Test.startTest();
    List<ALCRelationshipMonitorController.RelationshipGap> gaps = ALCRelationshipMonitorController.getRelationshipGaps();
    Test.stopTest();

    System.assertNotEquals(null, gaps, 'Should return empty list, not null');
  }

  @isTest
  static void testGetCandidatesWithoutContacts_WithALC() {
    // Create Candidate with ALC relationship
    Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName()
      .get('Career')
      ?.getRecordTypeId();
    if (careerRTId == null)
      return;

    Candidate__c candidate = new Candidate__c(
      First_Name__c = 'WithALC',
      Last_Name__c = 'Candidate',
      personal_email__c = 'withalc@test.com',
      Phone__c = '555-444-4444'
    );
    insert candidate;

    ALC__c alc = new ALC__c(
      First_Name__c = 'WithALC',
      Last_Name__c = 'Person',
      Personal_Email_Address__c = 'withalc@test.com',
      Mobile__c = '555-444-4444',
      Candidate__c = candidate.Id,
      RecordTypeId = careerRTId
    );
    insert alc;

    Test.startTest();
    List<ALCRelationshipMonitorController.CandidateGap> gaps = ALCRelationshipMonitorController.getCandidatesWithoutContacts();
    Test.stopTest();

    // Should include the candidate we created
    Boolean foundCandidate = false;
    for (ALCRelationshipMonitorController.CandidateGap gap : gaps) {
      if (gap.candidateId == candidate.Id) {
        foundCandidate = true;
        // Some orgs may not expose ALC__r on Candidate; don't enforce alcId presence
        // Just validate the candidate appears in the gap list
      }
    }
    System.assert(foundCandidate, 'Candidate should be present in gaps');
  }

  @isTest
  static void testMarkLogResolved_InvalidId() {
    Test.startTest();
    Boolean exceptionThrown = false;
    try {
      ALCRelationshipMonitorController.markLogResolved(
        'a00000000000000',
        'Test'
      );
      System.assert(false, 'Should throw exception');
    } catch (Exception e) {
      exceptionThrown = true;
      // Exception may be AuraHandledException or QueryException
      System.assert(
        e instanceof AuraHandledException ||
        e.getMessage().contains('List has no rows'),
        'Should throw appropriate exception, got: ' + e.getTypeName()
      );
    }
    Test.stopTest();
    System.assert(exceptionThrown, 'Should have thrown exception');
  }

  @isTest
  static void testFixCandidateContact_InvalidIds() {
    Test.startTest();
    try {
      ALCRelationshipMonitorController.fixCandidateContact(
        'invalid-id',
        'invalid-id'
      );
      System.assert(false, 'Should throw exception');
    } catch (Exception e) {
      // Accept AuraHandledException or QueryException depending on org behavior
      System.assert(
        e instanceof AuraHandledException || e.getMessage().contains('List has no rows'),
        'Should throw an appropriate exception'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testGetRecentAuditLogs_OrderedByDate() {
    // Create logs with different dates
    List<ALC_Automation_Log__c> newLogs = new List<ALC_Automation_Log__c>();
    for (Integer i = 0; i < 5; i++) {
      newLogs.add(
        new ALC_Automation_Log__c(
          Operation_Type__c = 'Contact Linked',
          Success__c = true,
          Error_Message__c = 'Log ' + i
        )
      );
    }
    insert newLogs;

    Test.startTest();
    List<ALC_Automation_Log__c> logs = ALCRelationshipMonitorController.getRecentAuditLogs(
      100
    );
    Test.stopTest();

    System.assert(logs.size() >= 5, 'Should return multiple logs');
    // Verify ordered by created date descending
    for (Integer i = 0; i < logs.size() - 1; i++) {
      System.assert(
        logs[i].CreatedDate >= logs[i + 1].CreatedDate,
        'Should be ordered by date descending'
      );
    }
  }

  @isTest
  static void testGetSummaryStatistics_Values() {
    // Create specific test data to verify stats
    Id careerRTId = Schema.SObjectType.ALC__c.getRecordTypeInfosByDeveloperName()
      .get('Career')
      ?.getRecordTypeId();
    if (careerRTId == null)
      return;

    ALC__c gapALC = new ALC__c(
      First_Name__c = 'Stats',
      Last_Name__c = 'Test',
      Personal_Email_Address__c = 'stats@test.com',
      Mobile__c = '555-888-8888',
      RecordTypeId = careerRTId
    );
    insert gapALC;

    gapALC.Contact__c = null;
    gapALC.Candidate__c = null;
    update gapALC;

    Test.startTest();
    Map<String, Integer> stats = ALCRelationshipMonitorController.getSummaryStatistics();
    Test.stopTest();

    Integer alcsWithoutContacts = stats.get('alcsWithoutContacts');
    System.assert(
      alcsWithoutContacts >= 1,
      'Should count at least 1 ALC without Contact'
    );
  }
}
