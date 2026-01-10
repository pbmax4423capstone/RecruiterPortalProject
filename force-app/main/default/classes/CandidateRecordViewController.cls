public with sharing class CandidateRecordViewController {
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getCandidateData(Id recordId) {
    try {
      // Check object access
      if (!Schema.sObjectType.Candidate__c.isAccessible()) {
        throw new AuraHandledException('No access to Candidate records');
      }

      // Get only accessible fields dynamically
      List<String> accessibleFields = getAccessibleCandidateFields();

      // Build query with only accessible fields
      String query = 'SELECT ' + String.join(accessibleFields, ', ');

      // Try to add Contact relationship fields if accessible
      if (Schema.sObjectType.Contact.isAccessible()) {
        query += ', Contact__r.Phone, Contact__r.Email, Contact__r.MobilePhone';
      }

      query += ' FROM Candidate__c WHERE Id = :recordId LIMIT 1';

      List<Candidate__c> candidates = Database.query(query);

      if (candidates.isEmpty()) {
        throw new AuraHandledException('Candidate record not found');
      }

      // Apply FLS security - strip inaccessible fields
      SObjectAccessDecision decision = Security.stripInaccessible(
        AccessType.READABLE,
        candidates
      );

      List<Candidate__c> securedCandidates = decision.getRecords();
      if (securedCandidates.isEmpty()) {
        throw new AuraHandledException('No access to this candidate record');
      }

      // Convert to map to handle null fields gracefully
      Candidate__c candidate = securedCandidates[0];
      Map<String, Object> result = new Map<String, Object>();

      // Get all populated fields that user has access to
      Map<String, Object> populatedFields = candidate.getPopulatedFieldsAsMap();
      result.putAll(populatedFields);
      result.put('Id', candidate.Id);

      // Add Contact relationship data if available and accessible
      try {
        if (candidate.Contact__r != null) {
          Map<String, Object> contactData = new Map<String, Object>();
          contactData.put('Phone', candidate.Contact__r.Phone);
          contactData.put('Email', candidate.Contact__r.Email);
          contactData.put('MobilePhone', candidate.Contact__r.MobilePhone);
          result.put('Contact__r', contactData);
        }
      } catch (Exception contactEx) {
        System.debug(
          'Unable to access Contact fields: ' + contactEx.getMessage()
        );
      }

      return result;
    } catch (Exception e) {
      System.debug('Error loading candidate: ' + e.getMessage());
      throw new AuraHandledException(
        'Error loading candidate: ' + e.getMessage()
      );
    }
  }

  private static List<String> getAccessibleCandidateFields() {
    // Get field describe info to check accessibility
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Candidate__c.fields.getMap();

    // List of fields we want to query (excluding relationship fields which are handled separately)
    List<String> desiredFields = new List<String>{
      'Id',
      'Name',
      'Type__c',
      'First_Name__c',
      'Nickname__c',
      'Middle_Name_or_Initial__c',
      'Last_Name__c',
      'Suffix__c',
      'Status__c',
      'Email__c',
      'Phone__c',
      'Mobile__c',
      'Contact__c',
      'Personal_Email_Formula__c',
      'Position__c',
      'Sales_Manager__c',
      'RecruiterPicklist__c',
      'Office_Location_Picklist__c',
      'Highest_Level_Achieved__c',
      'Agency__c',
      'Target_Market__c',
      'Recruiting_Source__c',
      'Recruiting_Sub_Source__c',
      'Gender__c',
      'Website__c',
      'MDE200__c',
      'MS_10__c',
      'Career_Presentation_ppt__c',
      'Next_Step__c',
      'Next_Meeting_Date__c',
      'Studying_for_Life_Health__c',
      'Registered__c',
      'Insurance_Licensed__c',
      'Date_of_Birth__c',
      'RELATIONSHIPS__c',
      'Offer_Accepted__c',
      'Device_Inspection__c',
      'Device_Inspection_Status__c',
      'Candidate_Summary__c',
      'Notes__c'
    };

    List<String> accessibleFields = new List<String>();

    for (String fieldName : desiredFields) {
      String lowerFieldName = fieldName.toLowerCase();
      if (fieldMap.containsKey(lowerFieldName)) {
        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(lowerFieldName)
          .getDescribe();
        if (fieldDescribe.isAccessible()) {
          accessibleFields.add(fieldName);
        }
      }
    }

    // Always include Id if not already there
    if (!accessibleFields.contains('Id')) {
      accessibleFields.add(0, 'Id');
    }

    return accessibleFields;
  }

  @AuraEnabled(cacheable=true)
  public static List<Interview__c> getInterviews(Id candidateId) {
    try {
      // Check object access
      if (!Schema.sObjectType.Interview__c.isAccessible()) {
        return new List<Interview__c>();
      }

      List<Interview__c> interviews = [
        SELECT
          Id,
          Name,
          Interview_Type__c,
          Interview_Status__c,
          Date_Time_Scheduled__c,
          Date_Completed__c,
          Outcome__c,
          Interviewer_s__c,
          Notes__c
        FROM Interview__c
        WHERE Candidate__c = :candidateId
        ORDER BY Date_Time_Scheduled__c DESC
      ];

      // Strip inaccessible fields
      SObjectAccessDecision decision = Security.stripInaccessible(
        AccessType.READABLE,
        interviews
      );

      return decision.getRecords();
    } catch (Exception e) {
      System.debug('Error loading interviews: ' + e.getMessage());
      // Return empty list instead of throwing to prevent page from breaking
      return new List<Interview__c>();
    }
  }
}
