public with sharing class CandidateLayoutController {
  /**
   * @description Gets all editable fields from the Candidate__c object
   * @param recordId The Candidate record ID
   * @return Map containing list of all editable field API names
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getPageLayoutFields(Id recordId) {
    Map<String, Object> result = new Map<String, Object>();
    List<String> allFields = new List<String>();

    try {
      // Get all fields from Candidate__c object
      Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Candidate__c.fields.getMap();

      for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

        // Only include updateable, non-calculated fields
        // Exclude system fields and auto-number fields
        if (
          fieldDescribe.isUpdateable() &&
          !fieldDescribe.isCalculated() &&
          !fieldDescribe.isAutoNumber() &&
          fieldDescribe.isAccessible()
        ) {
          allFields.add(fieldDescribe.getName());
        }
      }

      // Sort alphabetically for consistent UI
      allFields.sort();

      result.put('allFields', allFields);
      result.put('success', true);
    } catch (Exception e) {
      result.put('success', false);
      result.put('error', e.getMessage());
      System.debug('Error in getPageLayoutFields: ' + e.getMessage());
    }

    return result;
  }

  /**
   * @description Gets field metadata including labels and types for dynamic rendering
   * @param recordId The Candidate record ID
   * @return Map containing field metadata
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getFieldMetadata(Id recordId) {
    Map<String, Object> result = new Map<String, Object>();
    Map<String, Map<String, String>> fieldMetadata = new Map<String, Map<String, String>>();

    try {
      // Get all fields from Candidate__c object
      Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Candidate__c.fields.getMap();

      for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

        // Only include updateable fields
        if (
          fieldDescribe.isUpdateable() &&
          !fieldDescribe.isCalculated() &&
          !fieldDescribe.isAutoNumber() &&
          fieldDescribe.isAccessible()
        ) {
          Map<String, String> metadata = new Map<String, String>();
          metadata.put('label', fieldDescribe.getLabel());
          metadata.put('type', String.valueOf(fieldDescribe.getType()));
          metadata.put('apiName', fieldDescribe.getName());

          fieldMetadata.put(fieldDescribe.getName(), metadata);
        }
      }

      result.put('fieldMetadata', fieldMetadata);
      result.put('success', true);
    } catch (Exception e) {
      result.put('success', false);
      result.put('error', e.getMessage());
      System.debug('Error in getFieldMetadata: ' + e.getMessage());
    }

    return result;
  }
}
