// Script to configure LogMeIn Rescue integration for automatic record creation
// This will help diagnose and fix the session data mapping issue

// Step 1: Check current Lightning Custom Fields configuration
System.debug('=== STEP 1: Current Lightning Custom Fields Configuration ===');
List<logmein__Lightning_Custom_Fields__c> customFields = [
    SELECT Id, Name, 
           logmein__Custom_Field_0__c, 
           logmein__Custom_Field_1__c, 
           logmein__Custom_Field_2__c,
           logmein__Custom_Field_3__c,
           logmein__Custom_Field_4__c,
           logmein__Custom_Field_5__c,
           SetupOwnerId
    FROM logmein__Lightning_Custom_Fields__c
];

if (customFields.isEmpty()) {
    System.debug('❌ NO Lightning Custom Fields configuration found!');
    System.debug('You need to create a configuration record.');
} else {
    for (logmein__Lightning_Custom_Fields__c cf : customFields) {
        System.debug('Configuration Record: ' + cf.Name);
        System.debug('  Setup Owner: ' + cf.SetupOwnerId);
        System.debug('  Custom Field 0: ' + cf.logmein__Custom_Field_0__c);
        System.debug('  Custom Field 1: ' + cf.logmein__Custom_Field_1__c);
        System.debug('  Custom Field 2: ' + cf.logmein__Custom_Field_2__c);
        System.debug('  Custom Field 3: ' + cf.logmein__Custom_Field_3__c);
        System.debug('  Custom Field 4: ' + cf.logmein__Custom_Field_4__c);
        System.debug('  Custom Field 5: ' + cf.logmein__Custom_Field_5__c);
    }
}

// Step 2: Check Rescue Sessions
System.debug('\n=== STEP 2: Recent Rescue Sessions ===');
List<logmein__Rescue_Session__c> sessions = [
    SELECT Id, Name, logmein__Pin_Number__c, logmein__Pin_Type__c, 
           logmein__Case__c, logmein__Case__r.CaseNumber, CreatedDate
    FROM logmein__Rescue_Session__c
    ORDER BY CreatedDate DESC
    LIMIT 5
];

System.debug('Total Sessions Found: ' + sessions.size());
for (logmein__Rescue_Session__c session : sessions) {
    System.debug('Session: ' + session.Name + ' | PIN: ' + session.logmein__Pin_Number__c + 
                 ' | Type: ' + session.logmein__Pin_Type__c + ' | Case: ' + 
                 (session.logmein__Case__c != null ? session.logmein__Case__r.CaseNumber : 'None'));
}

// Step 3: Check Rescue Logs (these should be created when sessions post data)
System.debug('\n=== STEP 3: Rescue Logs (Session Data Posts) ===');
List<logmein__Rescue_Log__c> logs = [
    SELECT Id, Name, logmein__SessionId__c, logmein__Type__c, 
           logmein__CaseId__c, logmein__Final_Post__c, CreatedDate
    FROM logmein__Rescue_Log__c
    ORDER BY CreatedDate DESC
    LIMIT 5
];

if (logs.isEmpty()) {
    System.debug('❌ NO Rescue Logs found!');
    System.debug('This means sessions are NOT posting data back to Salesforce.');
    System.debug('\nPOSSIBLE CAUSES:');
    System.debug('1. Web Integration URL not configured in LogMeIn Rescue Admin Center');
    System.debug('2. POST URL endpoint not accessible');
    System.debug('3. Authentication issues between Rescue and Salesforce');
} else {
    System.debug('Total Logs Found: ' + logs.size());
    for (logmein__Rescue_Log__c log : logs) {
        System.debug('Log: ' + log.Name + ' | Session ID: ' + log.logmein__SessionId__c + 
                     ' | Type: ' + log.logmein__Type__c + ' | Final Post: ' + log.logmein__Final_Post__c);
    }
}

// Step 4: Check RescueIntegration custom settings
System.debug('\n=== STEP 4: RescueIntegration Settings ===');
List<logmein__RescueIntegration__c> integration = [
    SELECT Id, Name, SetupOwnerId
    FROM logmein__RescueIntegration__c
];

if (integration.isEmpty()) {
    System.debug('⚠️  No RescueIntegration custom settings found.');
} else {
    for (logmein__RescueIntegration__c ri : integration) {
        System.debug('Integration Setting: ' + ri.Name);
        System.debug('  Setup Owner: ' + ri.SetupOwnerId);
    }
}

System.debug('\n=== DIAGNOSIS COMPLETE ===');
System.debug('\n📋 NEXT STEPS:');
System.debug('1. If NO Rescue Logs exist, configure the Web Integration URL in Rescue Admin Center');
System.debug('2. Get your Salesforce POST URL for the integration');
System.debug('3. Configure it in LogMeIn Rescue Admin Center → Administration → Settings');
System.debug('4. Ensure the field mappings in Lightning Custom Fields are correct');
System.debug('5. Test with a new Rescue session and verify a Rescue Log is created');
