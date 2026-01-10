@isTest
private class CandidateLayoutControllerTest {
  @TestSetup
  static void setup() {
    // Create test candidate
    Candidate__c testCandidate = new Candidate__c(
      First_Name__c = 'Test',
      Last_Name__c = 'Candidate',
      Status__c = 'Recruit',
      Type__c = 'Candidate',
      personal_email__c = 'test@example.com',
      Mobile__c = '555-1234'
    );
    insert testCandidate;
  }

  @isTest
  static void testGetPageLayoutFields_Success() {
    // Get test candidate
    Candidate__c testCandidate = [SELECT Id FROM Candidate__c LIMIT 1];

    Test.startTest();
    Map<String, Object> result = CandidateLayoutController.getPageLayoutFields(
      testCandidate.Id
    );
    Test.stopTest();

    // Verify results
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals(true, result.get('success'), 'Success should be true');
    System.assert(
      result.containsKey('allFields'),
      'Should contain allFields key'
    );

    List<String> fields = (List<String>) result.get('allFields');
    System.assert(fields.size() > 0, 'Should return fields');

    // Verify some expected fields are present
    System.assert(
      fields.contains('First_Name__c'),
      'Should contain First_Name__c'
    );
    System.assert(
      fields.contains('Last_Name__c'),
      'Should contain Last_Name__c'
    );
    System.assert(fields.contains('Status__c'), 'Should contain Status__c');

    // Verify fields are sorted
    List<String> sortedFields = new List<String>(fields);
    sortedFields.sort();
    System.assertEquals(
      sortedFields,
      fields,
      'Fields should be sorted alphabetically'
    );
  }

  @isTest
  static void testGetPageLayoutFields_WithNullId() {
    Test.startTest();
    Map<String, Object> result = CandidateLayoutController.getPageLayoutFields(
      null
    );
    Test.stopTest();

    // Should still return field list even with null ID
    // since we're just describing the object
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assert(
      result.containsKey('allFields'),
      'Should contain allFields key'
    );
  }

  @isTest
  static void testGetFieldMetadata_Success() {
    // Get test candidate
    Candidate__c testCandidate = [SELECT Id FROM Candidate__c LIMIT 1];

    Test.startTest();
    Map<String, Object> result = CandidateLayoutController.getFieldMetadata(
      testCandidate.Id
    );
    Test.stopTest();

    // Verify results
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals(true, result.get('success'), 'Success should be true');
    System.assert(
      result.containsKey('fieldMetadata'),
      'Should contain fieldMetadata key'
    );

    Map<String, Map<String, String>> fieldMetadata = (Map<String, Map<String, String>>) result.get(
      'fieldMetadata'
    );
    System.assert(fieldMetadata.size() > 0, 'Should return field metadata');

    // Verify field metadata structure
    if (fieldMetadata.containsKey('First_Name__c')) {
      Map<String, String> firstNameMeta = fieldMetadata.get('First_Name__c');
      System.assert(firstNameMeta.containsKey('label'), 'Should contain label');
      System.assert(firstNameMeta.containsKey('type'), 'Should contain type');
      System.assert(
        firstNameMeta.containsKey('apiName'),
        'Should contain apiName'
      );
    }
  }

  @isTest
  static void testGetFieldMetadata_WithNullId() {
    Test.startTest();
    Map<String, Object> result = CandidateLayoutController.getFieldMetadata(
      null
    );
    Test.stopTest();

    // Should still return metadata even with null ID
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assert(
      result.containsKey('fieldMetadata'),
      'Should contain fieldMetadata key'
    );
  }

  @isTest
  static void testFieldsAreUpdateable() {
    // Get test candidate
    Candidate__c testCandidate = [SELECT Id FROM Candidate__c LIMIT 1];

    Test.startTest();
    Map<String, Object> result = CandidateLayoutController.getPageLayoutFields(
      testCandidate.Id
    );
    Test.stopTest();

    List<String> fields = (List<String>) result.get('allFields');

    // Verify system fields are excluded
    System.assert(!fields.contains('Id'), 'Should not contain Id field');
    System.assert(
      !fields.contains('CreatedDate'),
      'Should not contain CreatedDate'
    );
    System.assert(
      !fields.contains('LastModifiedDate'),
      'Should not contain LastModifiedDate'
    );
    System.assert(
      !fields.contains('SystemModstamp'),
      'Should not contain SystemModstamp'
    );
  }

  @isTest
  static void testFieldAccessibility() {
    // Get test candidate
    Candidate__c testCandidate = [SELECT Id FROM Candidate__c LIMIT 1];

    Test.startTest();
    Map<String, Object> result = CandidateLayoutController.getPageLayoutFields(
      testCandidate.Id
    );
    Test.stopTest();

    List<String> fields = (List<String>) result.get('allFields');

    // All returned fields should be accessible and updateable
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Candidate__c.fields.getMap();

    for (String fieldName : fields) {
      Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName)
        .getDescribe();
      System.assert(
        fieldDescribe.isAccessible(),
        fieldName + ' should be accessible'
      );
      System.assert(
        fieldDescribe.isUpdateable(),
        fieldName + ' should be updateable'
      );
    }
  }

  @isTest
  static void testBulkFieldRetrieval() {
    // Get test candidate
    Candidate__c testCandidate = [SELECT Id FROM Candidate__c LIMIT 1];

    // Test that method can handle multiple rapid calls
    List<Map<String, Object>> results = new List<Map<String, Object>>();

    Test.startTest();
    for (Integer i = 0; i < 10; i++) {
      results.add(
        CandidateLayoutController.getPageLayoutFields(testCandidate.Id)
      );
    }
    Test.stopTest();

    // All calls should return consistent results
    System.assertEquals(10, results.size(), 'Should have 10 results');

    List<String> firstResult = (List<String>) results[0].get('allFields');
    for (Map<String, Object> result : results) {
      List<String> currentResult = (List<String>) result.get('allFields');
      System.assertEquals(
        firstResult.size(),
        currentResult.size(),
        'All results should have same field count'
      );
    }
  }
}
