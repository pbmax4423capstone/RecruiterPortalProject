public with sharing class CandidateRecordViewController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCandidateData(Id recordId) {
        try {
            // Get only accessible fields dynamically
            List<String> accessibleFields = getAccessibleCandidateFields();
            
            String query = 'SELECT ' + String.join(accessibleFields, ', ') + 
                          ' FROM Candidate__c WHERE Id = :recordId LIMIT 1';
            
            List<Candidate__c> candidates = Database.query(query);
            
            if (candidates.isEmpty()) {
                throw new AuraHandledException('Candidate record not found');
            }
            
            // Convert to map to handle null fields gracefully
            Candidate__c candidate = candidates[0];
            Map<String, Object> result = new Map<String, Object>();
            
            // Get all populated fields
            Map<String, Object> populatedFields = candidate.getPopulatedFieldsAsMap();
            result.putAll(populatedFields);
            result.put('Id', candidate.Id);
            
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error loading candidate: ' + e.getMessage());
        }
    }
    
    private static List<String> getAccessibleCandidateFields() {
        // Get field describe info to check accessibility
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Candidate__c.fields.getMap();
        
        // List of fields we want to query
        List<String> desiredFields = new List<String>{
            'Id', 'Name', 'Type__c', 'First_Name__c', 'Nickname__c', 'Middle_Name_or_Initial__c',
            'Last_Name__c', 'Suffix__c', 'Status__c', 'Email__c', 'Phone__c', 'Contact__c',
            'Position__c', 'Sales_Manager__c', 'RecruiterPicklist__c', 'Office_Location_Picklist__c',
            'Highest_Level_Achieved__c', 'Agency__c', 'Target_Market__c', 'Recruiting_Source__c',
            'Recruiting_Sub_Source__c', 'Gender__c', 'Website__c', 'MDE200__c', 'MS_10__c',
            'Career_Presentation_ppt__c', 'Next_Step__c', 'Next_Meeting_Date__c',
            'Studying_for_Life_Health__c', 'Registered__c', 'Insurance_Licensed__c',
            'Date_of_Birth__c', 'RELATIONSHIPS__c', 'Offer_Accepted__c',
            'Device_Inspection__c', 'Device_Inspection_Status__c', 'Candidate_Summary__c'
        };
        
        List<String> accessibleFields = new List<String>();
        
        for (String fieldName : desiredFields) {
            String lowerFieldName = fieldName.toLowerCase();
            if (fieldMap.containsKey(lowerFieldName)) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(lowerFieldName).getDescribe();
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
}