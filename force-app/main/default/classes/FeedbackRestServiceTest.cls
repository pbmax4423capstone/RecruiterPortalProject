/**
 * @description Test class for FeedbackRestService
 */
@isTest
private class FeedbackRestServiceTest {
  @isTest
  static void testCreateFeedback_Success() {
    // Set up REST context
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/feedback/';
    req.httpMethod = 'POST';

    Map<String, Object> requestBody = new Map<String, Object>{
      'feedbackType' => 'Bug Report',
      'subject' => 'Test Subject',
      'description' => 'Test description of the feedback',
      'source' => 'Chrome Extension',
      'submittedBy' => 'test@example.com'
    };

    req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    FeedbackRestService.FeedbackResponse response = FeedbackRestService.createFeedback();
    Test.stopTest();

    System.assertEquals(
      true,
      response.success,
      'Response should be successful'
    );
    System.assertNotEquals(
      null,
      response.feedbackId,
      'Feedback ID should be populated'
    );
    System.assertEquals(201, res.statusCode, 'Status code should be 201');

    // Verify feedback was created
    List<Feedback__c> feedbacks = [
      SELECT Id, Subject__c, Feedback_Type__c, Description__c, Status__c
      FROM Feedback__c
    ];
    System.assertEquals(1, feedbacks.size(), 'Should have 1 feedback record');
    System.assertEquals(
      'Test Subject',
      feedbacks[0].Subject__c,
      'Subject should match'
    );
    System.assertEquals(
      'Bug Report',
      feedbacks[0].Feedback_Type__c,
      'Type should match'
    );
    System.assertEquals('New', feedbacks[0].Status__c, 'Status should be New');
    System.assert(
      feedbacks[0].Description__c.contains('Test description'),
      'Description should contain original text'
    );
    System.assert(
      feedbacks[0].Description__c.contains('test@example.com'),
      'Description should contain submitter'
    );
  }

  @isTest
  static void testCreateFeedback_MissingRequiredFields() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/feedback/';
    req.httpMethod = 'POST';

    // Missing description
    Map<String, Object> requestBody = new Map<String, Object>{
      'feedbackType' => 'Bug Report',
      'subject' => 'Test Subject'
    };

    req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    FeedbackRestService.FeedbackResponse response = FeedbackRestService.createFeedback();
    Test.stopTest();

    System.assertEquals(
      false,
      response.success,
      'Response should not be successful'
    );
    System.assert(
      response.message.contains('required'),
      'Message should mention required fields'
    );
    System.assertEquals(400, res.statusCode, 'Status code should be 400');
  }

  @isTest
  static void testCreateFeedback_WithoutOptionalFields() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/feedback/';
    req.httpMethod = 'POST';

    // Only required fields
    Map<String, Object> requestBody = new Map<String, Object>{
      'feedbackType' => 'Feature Request',
      'subject' => 'New Feature',
      'description' => 'Would be nice to have this feature'
    };

    req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    FeedbackRestService.FeedbackResponse response = FeedbackRestService.createFeedback();
    Test.stopTest();

    System.assertEquals(
      true,
      response.success,
      'Response should be successful'
    );
    System.assertNotEquals(
      null,
      response.feedbackId,
      'Feedback ID should be populated'
    );
    System.assertEquals(201, res.statusCode, 'Status code should be 201');
  }

  @isTest
  static void testCreateFeedback_LongSubject() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/feedback/';
    req.httpMethod = 'POST';

    // Subject longer than 255 characters
    String longSubject = 'This is a very long subject that exceeds the maximum length allowed for the subject field in Salesforce which is typically 255 characters so we need to test that the controller properly truncates this text to fit within the field length limit without causing any errors or exceptions';

    Map<String, Object> requestBody = new Map<String, Object>{
      'feedbackType' => 'Bug Report',
      'subject' => longSubject,
      'description' => 'Test description'
    };

    req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    FeedbackRestService.FeedbackResponse response = FeedbackRestService.createFeedback();
    Test.stopTest();

    System.assertEquals(
      true,
      response.success,
      'Response should be successful even with long subject'
    );

    // Verify subject was truncated
    Feedback__c feedback = [
      SELECT Subject__c
      FROM Feedback__c
      WHERE Id = :response.feedbackId
    ];
    System.assert(
      feedback.Subject__c.length() <= 255,
      'Subject should be truncated to 255 characters'
    );
  }
}
