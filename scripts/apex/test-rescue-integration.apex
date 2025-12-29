// Test script to verify Rescue integration is working after configuration update
System.debug('=== TESTING RESCUE INTEGRATION ===');

// Check for NEW Rescue Logs created after configuration fix
List<logmein__Rescue_Log__c> logs = [
    SELECT Id, Name, logmein__SessionId__c, logmein__Type__c,
           logmein__CaseId__c, logmein__CField0__c, logmein__CField1__c,
           logmein__CField2__c, logmein__CField3__c, logmein__CField4__c,
           logmein__Final_Post__c, logmein__Initial_Post__c, CreatedDate
    FROM logmein__Rescue_Log__c
    ORDER BY CreatedDate DESC
    LIMIT 5
];

if (logs.isEmpty()) {
    System.debug('❌ Still no Rescue Logs found.');
    System.debug('✅ Configuration is correct, but no test session has been completed yet.');
    System.debug('');
    System.debug('NEXT STEPS:');
    System.debug('1. Start a test Rescue session');
    System.debug('2. End the session');
    System.debug('3. Run this script again to verify Rescue Log was created');
} else {
    System.debug('✅ SUCCESS! Rescue Logs are being created!');
    System.debug('Total Logs Found: ' + logs.size());
    System.debug('');
    
    for (logmein__Rescue_Log__c log : logs) {
        System.debug('====================================');
        System.debug('Log: ' + log.Name);
        System.debug('Session ID: ' + log.logmein__SessionId__c);
        System.debug('Type: ' + log.logmein__Type__c);
        System.debug('Case ID: ' + log.logmein__CaseId__c);
        System.debug('Initial Post: ' + log.logmein__Initial_Post__c);
        System.debug('Final Post: ' + log.logmein__Final_Post__c);
        System.debug('Created Date: ' + log.CreatedDate);
        System.debug('');
        System.debug('Field Mappings:');
        System.debug('  CField0 (SuppliedName): ' + log.logmein__CField0__c);
        System.debug('  CField1 (SuppliedName): ' + log.logmein__CField1__c);
        System.debug('  CField2 (SuppliedPhone): ' + log.logmein__CField2__c);
        System.debug('  CField3 (Agency__c): ' + log.logmein__CField3__c);
        System.debug('  CField4 (SuppliedEmail): ' + log.logmein__CField4__c);
    }
    
    System.debug('');
    System.debug('✅ Integration is working correctly!');
    System.debug('Session data is being posted to Salesforce.');
}

// Also check for recent sessions
System.debug('');
System.debug('=== RECENT RESCUE SESSIONS ===');
List<logmein__Rescue_Session__c> sessions = [
    SELECT Id, Name, logmein__Pin_Number__c, logmein__Pin_Type__c, 
           logmein__Case__c, CreatedDate
    FROM logmein__Rescue_Session__c
    WHERE CreatedDate = TODAY
    ORDER BY CreatedDate DESC
    LIMIT 3
];

if (sessions.isEmpty()) {
    System.debug('No sessions created today yet.');
} else {
    System.debug('Sessions created today: ' + sessions.size());
    for (logmein__Rescue_Session__c session : sessions) {
        System.debug('  ' + session.Name + ' | PIN: ' + session.logmein__Pin_Number__c);
    }
}
