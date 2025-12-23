// Check available fields on Candidate__c object for Contract B Pipeline
System.debug('=== CANDIDATE FIELDS FOR CONTRACT B PIPELINE ===');

// Check for specific fields we need
Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Candidate__c.fields.getMap();

List<String> neededFields = new List<String>{
    'Name',
    'Contract_Type__c',
    'Start_Date__c',
    'Status__c',
    'Highest_Level_Achieved__c',
    'Sales_Manager__c',
    'Contact__c',
    'Contract_End_Date__c',
    'Extended_End_Date__c',
    'Extension_Granted__c',
    'Total_FYC__c',
    'Opportunity_Count__c',
    'Days_Until_Contract_End__c',
    'Contract_Deadline_Date__c',
    'Requirements_Met__c',
    'FYC_Progress_Percent__c',
    'Submissions_Progress_Percent__c',
    'Contract_Status_Indicator__c'
};

for (String fieldName : neededFields) {
    Boolean exists = fieldMap.containsKey(fieldName.toLowerCase());
    System.debug(fieldName + ': ' + (exists ? 'EXISTS' : 'MISSING'));
}
