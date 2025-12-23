@RestResource(urlMapping='/feedback/*')
global without sharing class FeedbackRestService {
    
    @HttpPost
    global static FeedbackResponse createFeedback() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        FeedbackResponse response = new FeedbackResponse();
        
        try {
            // Parse the request body
            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            
            String feedbackType = (String) requestBody.get('feedbackType');
            String subject = (String) requestBody.get('subject');
            String description = (String) requestBody.get('description');
            String source = requestBody.containsKey('source') ? (String) requestBody.get('source') : '';
            String submittedBy = requestBody.containsKey('submittedBy') ? (String) requestBody.get('submittedBy') : '';
            
            // Validate required fields
            if (String.isBlank(feedbackType) || String.isBlank(subject) || String.isBlank(description)) {
                response.success = false;
                response.message = 'Missing required fields: feedbackType, subject, and description are required';
                res.statusCode = 400;
                return response;
            }
            
            // Build full description with submitter and source info
            String fullDescription = description;
            if (String.isNotBlank(submittedBy)) {
                fullDescription += '\n\n--- Submitted By: ' + submittedBy + ' ---';
            }
            if (String.isNotBlank(source)) {
                fullDescription += '\n--- Source: ' + source + ' ---';
            }
            
            // Create the Feedback record
            Feedback__c feedback = new Feedback__c();
            feedback.Subject__c = subject.length() > 255 ? subject.substring(0, 255) : subject;
            feedback.Feedback_Type__c = feedbackType;
            feedback.Description__c = fullDescription;
            feedback.Status__c = 'New';
            
            insert feedback;
            
            response.success = true;
            response.message = 'Feedback submitted successfully';
            response.feedbackId = feedback.Id;
            res.statusCode = 201;
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error creating feedback: ' + e.getMessage();
            res.statusCode = 500;
        }
        
        return response;
    }
    
    global class FeedbackResponse {
        public Boolean success;
        public String message;
        public Id feedbackId;
    }
}
