/**
 * Controller for ALC Relationship Backfill Wizard LWC
 * Provides @AuraEnabled methods for interactive backfill UI
 *
 * @group ALC Automation
 * @date 2026-01-08
 */
public with sharing class ALCBackfillWizardController {
  /**
   * Wrapper class for ALC data to send to LWC
   */
  public class ALCWrapper {
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String firstName { get; set; }
    @AuraEnabled
    public String lastName { get; set; }
    @AuraEnabled
    public String email { get; set; }
    @AuraEnabled
    public String phone { get; set; }
    @AuraEnabled
    public String recordType { get; set; }
  }

  /**
   * Wrapper class for Contact match results
   */
  public class MatchWrapper {
    @AuraEnabled
    public Id contactId { get; set; }
    @AuraEnabled
    public String contactName { get; set; }
    @AuraEnabled
    public String contactEmail { get; set; }
    @AuraEnabled
    public String contactPhone { get; set; }
    @AuraEnabled
    public Decimal similarityScore { get; set; }
    @AuraEnabled
    public String matchType { get; set; }
  }

  /**
   * Get unlinked ALCs for a specific record type
   * @param recordTypeName Record type developer name (Career, Broker, NRF, Registration)
   * @return List of ALC wrappers
   */
  @AuraEnabled(cacheable=true)
  public static List<ALCWrapper> getUnlinkedALCs(String recordTypeName) {
    try {
      List<ALC__c> alcs = String.isBlank(recordTypeName)
        ? ALCRelationshipBackfillService.findUnlinkedALCs()
        : ALCRelationshipBackfillService.findUnlinkedALCsByType(recordTypeName);

      List<ALCWrapper> wrappers = new List<ALCWrapper>();
      for (ALC__c alc : alcs) {
        ALCWrapper wrapper = new ALCWrapper();
        wrapper.id = alc.Id;
        wrapper.name = alc.Name;
        wrapper.firstName = alc.First_Name__c;
        wrapper.lastName = alc.Last_Name__c;
        wrapper.email = alc.Personal_Email_Address__c;
        wrapper.phone = alc.Mobile__c;
        wrapper.recordType = alc.RecordType.DeveloperName;
        wrappers.add(wrapper);
      }

      return wrappers;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error fetching unlinked ALCs: ' + e.getMessage()
      );
    }
  }

  /**
   * Get matching Contacts for a specific ALC
   * @param alcId ALC record Id
   * @return List of match wrappers with similarity scores
   */
  @AuraEnabled
  public static List<MatchWrapper> getMatchingContacts(Id alcId) {
    try {
      ALC__c alc = [
        SELECT
          Id,
          First_Name__c,
          Last_Name__c,
          Mobile__c,
          Personal_Email_Address__c,
          RecordType.DeveloperName
        FROM ALC__c
        WHERE Id = :alcId
        LIMIT 1
      ];

      List<ALCRelationshipBackfillService.ContactMatchResult> matches = ALCRelationshipBackfillService.findMatchingContacts(
        alc
      );

      List<MatchWrapper> wrappers = new List<MatchWrapper>();
      for (ALCRelationshipBackfillService.ContactMatchResult match : matches) {
        MatchWrapper wrapper = new MatchWrapper();
        wrapper.contactId = match.matchedContact.Id;
        wrapper.contactName =
          (match.matchedContact.FirstName != null
            ? match.matchedContact.FirstName + ' '
            : '') + match.matchedContact.LastName;
        wrapper.contactEmail = match.matchedContact.Email != null
          ? match.matchedContact.Email
          : match.matchedContact.Personal_Email__c;
        wrapper.contactPhone = match.matchedContact.MobilePhone;
        wrapper.similarityScore = match.similarityScore;
        wrapper.matchType = match.matchType;
        wrappers.add(wrapper);
      }

      return wrappers;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error fetching matching contacts: ' + e.getMessage()
      );
    }
  }

  /**
   * Process batch of backfill decisions from UI
   * @param decisionsJson JSON string of decisions array
   * @return Result summary as JSON string
   */
  @AuraEnabled
  public static String processBackfillBatch(String decisionsJson) {
    try {
      List<Object> decisionsRaw = (List<Object>) JSON.deserializeUntyped(
        decisionsJson
      );
      List<ALCRelationshipBackfillService.BackfillDecision> decisions = new List<ALCRelationshipBackfillService.BackfillDecision>();

      for (Object decisionObj : decisionsRaw) {
        Map<String, Object> decisionMap = (Map<String, Object>) decisionObj;
        ALCRelationshipBackfillService.BackfillDecision decision = new ALCRelationshipBackfillService.BackfillDecision();
        decision.alcId = (Id) decisionMap.get('alcId');
        decision.selectedContactId = (Id) decisionMap.get('selectedContactId');
        decision.createNewContact = (Boolean) decisionMap.get(
          'createNewContact'
        );
        decisions.add(decision);
      }

      ALCRelationshipBackfillService.BackfillResult result = ALCRelationshipBackfillService.processBackfillDecisions(
        decisions
      );

      // Create audit log asynchronously
      createAuditLogAsync(
        result.contactsCreated,
        result.candidatesCreated,
        result.alcsUpdated,
        result.errors
      );

      Map<String, Object> resultMap = new Map<String, Object>{
        'contactsCreated' => result.contactsCreated,
        'candidatesCreated' => result.candidatesCreated,
        'alcsUpdated' => result.alcsUpdated,
        'errors' => result.errors
      };

      return JSON.serialize(resultMap);
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error processing backfill batch: ' + e.getMessage()
      );
    }
  }

  /**
   * Create audit log entry asynchronously
   */
  @future
  private static void createAuditLogAsync(
    Integer contactsCreated,
    Integer candidatesCreated,
    Integer alcsUpdated,
    List<String> errors
  ) {
    try {
      ALC_Automation_Log__c log = new ALC_Automation_Log__c();
      log.Operation_Type__c = 'Manual Backfill';
      log.Success__c = errors.isEmpty();
      log.Error_Message__c = errors.isEmpty()
        ? String.format(
            'Backfill completed: {0} Contacts, {1} Candidates, {2} ALCs updated',
            new List<Object>{ contactsCreated, candidatesCreated, alcsUpdated }
          )
        : String.join(errors, '\n');
      insert log;
    } catch (Exception e) {
      System.debug('Failed to create audit log: ' + e.getMessage());
    }
  }
}
