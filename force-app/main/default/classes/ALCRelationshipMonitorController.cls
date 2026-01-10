/**
 * Controller for ALC Relationship Monitor Dashboard LWC
 * Provides monitoring and troubleshooting capabilities for ALC automation
 *
 * @group ALC Automation
 * @date 2026-01-08
 */
public with sharing class ALCRelationshipMonitorController {
  /**
   * Wrapper class for relationship gap data
   */
  public class RelationshipGap {
    @AuraEnabled
    public Id alcId { get; set; }
    @AuraEnabled
    public String alcName { get; set; }
    @AuraEnabled
    public String firstName { get; set; }
    @AuraEnabled
    public String lastName { get; set; }
    @AuraEnabled
    public String recordType { get; set; }
    @AuraEnabled
    public Boolean hasContact { get; set; }
    @AuraEnabled
    public Boolean hasCandidate { get; set; }
    @AuraEnabled
    public DateTime createdDate { get; set; }
  }

  /**
   * Wrapper class for Candidate without Contact
   */
  public class CandidateGap {
    @AuraEnabled
    public Id candidateId { get; set; }
    @AuraEnabled
    public String candidateName { get; set; }
    @AuraEnabled
    public String email { get; set; }
    @AuraEnabled
    public String phone { get; set; }
    @AuraEnabled
    public Id alcId { get; set; }
    @AuraEnabled
    public String alcName { get; set; }
  }

  /**
   * Get ALCs with relationship gaps (missing Contact or Career without Candidate)
   * @return List of relationship gap wrappers
   */
  @AuraEnabled(cacheable=true)
  public static List<RelationshipGap> getRelationshipGaps() {
    try {
      List<ALC__c> gapALCs = [
        SELECT
          Id,
          Name,
          First_Name__c,
          Last_Name__c,
          Contact__c,
          Candidate__c,
          RecordType.DeveloperName,
          CreatedDate
        FROM ALC__c
        WHERE
          Contact__c = NULL
          OR (RecordType.DeveloperName = 'Career'
          AND Candidate__c = NULL)
        ORDER BY CreatedDate DESC
        LIMIT 100
      ];

      List<RelationshipGap> gaps = new List<RelationshipGap>();
      for (ALC__c alc : gapALCs) {
        RelationshipGap gap = new RelationshipGap();
        gap.alcId = alc.Id;
        gap.alcName = alc.Name;
        gap.firstName = alc.First_Name__c;
        gap.lastName = alc.Last_Name__c;
        gap.recordType = alc.RecordType.DeveloperName;
        gap.hasContact = alc.Contact__c != null;
        gap.hasCandidate = alc.Candidate__c != null;
        gap.createdDate = alc.CreatedDate;
        gaps.add(gap);
      }

      return gaps;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error fetching relationship gaps: ' + e.getMessage()
      );
    }
  }

  /**
   * Get Candidates without linked Contacts
   * @return List of candidate gap wrappers
   */
  @AuraEnabled(cacheable=true)
  public static List<CandidateGap> getCandidatesWithoutContacts() {
    try {
      List<Candidate__c> gapCandidates = [
        SELECT
          Id,
          Name,
          First_Name__c,
          Last_Name__c,
          Email__c,
          personal_email__c,
          Phone__c,
          Contact__c,
          ALC__r.Id,
          ALC__r.Name
        FROM Candidate__c
        WHERE Contact__c = NULL
        ORDER BY CreatedDate DESC
        LIMIT 100
      ];

      List<CandidateGap> gaps = new List<CandidateGap>();
      for (Candidate__c candidate : gapCandidates) {
        CandidateGap gap = new CandidateGap();
        gap.candidateId = candidate.Id;
        gap.candidateName = candidate.Name;
        gap.email = candidate.Email__c != null
          ? candidate.Email__c
          : candidate.personal_email__c;
        gap.phone = candidate.Phone__c;
        gap.alcId = candidate.ALC__r?.Id;
        gap.alcName = candidate.ALC__r?.Name;
        gaps.add(gap);
      }

      return gaps;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error fetching candidates without contacts: ' + e.getMessage()
      );
    }
  }

  /**
   * Get recent audit logs
   * @param limitCount Number of logs to retrieve (default 50)
   * @return List of audit logs
   */
  @AuraEnabled(cacheable=true)
  public static List<ALC_Automation_Log__c> getRecentAuditLogs(
    Integer limitCount
  ) {
    try {
      if (limitCount == null || limitCount <= 0) {
        limitCount = 50;
      }

      return [
        SELECT
          Id,
          Name,
          Operation_Type__c,
          Success__c,
          Error_Type__c,
          Error_Message__c,
          Created_Date__c,
          CreatedDate,
          ALC__c,
          ALC__r.Name,
          Contact__c,
          Contact__r.Name,
          Candidate__c,
          Candidate__r.Name,
          Resolved__c,
          Resolved_By__r.Name,
          Resolution_Notes__c
        FROM ALC_Automation_Log__c
        ORDER BY Created_Date__c DESC
        LIMIT :limitCount
      ];
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error fetching audit logs: ' + e.getMessage()
      );
    }
  }

  /**
   * Mark an audit log as resolved
   * @param logId Audit log record Id
   * @param notes Resolution notes
   */
  @AuraEnabled
  public static void markLogResolved(Id logId, String notes) {
    try {
      ALC_Automation_Log__c log = [
        SELECT Id
        FROM ALC_Automation_Log__c
        WHERE Id = :logId
        LIMIT 1
      ];
      log.Resolved__c = true;
      log.Resolved_By__c = UserInfo.getUserId();
      log.Resolution_Notes__c = notes;
      update log;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error marking log resolved: ' + e.getMessage()
      );
    }
  }

  /**
   * Fix a Candidate's Contact relationship
   * @param candidateId Candidate record Id
   * @param contactId Contact record Id to link
   */
  @AuraEnabled
  public static void fixCandidateContact(Id candidateId, Id contactId) {
    try {
      Candidate__c candidate = [
        SELECT Id, Contact__c
        FROM Candidate__c
        WHERE Id = :candidateId
        LIMIT 1
      ];
      candidate.Contact__c = contactId;
      update candidate;

      // Create success audit log
      ALC_Automation_Log__c log = new ALC_Automation_Log__c();
      log.Operation_Type__c = 'Manual Fix';
      log.Candidate__c = candidateId;
      log.Contact__c = contactId;
      log.Success__c = true;
      log.Error_Message__c = 'Manually linked Candidate to Contact';
      insert log;
    } catch (Exception e) {
      // Create error audit log
      ALC_Automation_Log__c log = new ALC_Automation_Log__c();
      log.Operation_Type__c = 'Manual Fix';
      log.Candidate__c = candidateId;
      log.Success__c = false;
      log.Error_Type__c = 'Update Error';
      log.Error_Message__c = e.getMessage();
      log.Stack_Trace__c = e.getStackTraceString();
      insert log;

      throw new AuraHandledException(
        'Error fixing candidate contact: ' + e.getMessage()
      );
    }
  }

  /**
   * Get summary statistics for dashboard cards
   * @return Map of statistics
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Integer> getSummaryStatistics() {
    try {
      Map<String, Integer> stats = new Map<String, Integer>();

      // ALCs without Contacts
      stats.put(
        'alcsWithoutContacts',
        [SELECT COUNT() FROM ALC__c WHERE Contact__c = NULL]
      );

      // Career ALCs without Candidates
      stats.put(
        'careerWithoutCandidates',
        [
          SELECT COUNT()
          FROM ALC__c
          WHERE RecordType.DeveloperName = 'Career' AND Candidate__c = NULL
        ]
      );

      // Candidates without Contacts
      stats.put(
        'candidatesWithoutContacts',
        [SELECT COUNT() FROM Candidate__c WHERE Contact__c = NULL]
      );

      // Recent errors (last 7 days)
      DateTime sevenDaysAgo = DateTime.now().addDays(-7);
      stats.put(
        'recentErrors',
        [
          SELECT COUNT()
          FROM ALC_Automation_Log__c
          WHERE Success__c = FALSE AND Created_Date__c >= :sevenDaysAgo
        ]
      );

      // Unresolved errors
      stats.put(
        'unresolvedErrors',
        [
          SELECT COUNT()
          FROM ALC_Automation_Log__c
          WHERE Success__c = FALSE AND Resolved__c = FALSE
        ]
      );

      return stats;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error fetching statistics: ' + e.getMessage()
      );
    }
  }
}
