// Query for all active Flows that update Case records
List<FlowDefinitionView> flows = [
    SELECT ApiName, Label, Description, ProcessType, TriggerType, IsActive
    FROM FlowDefinitionView 
    WHERE ProcessType IN ('AutolaunchedFlow', 'Workflow', 'InvocableProcess', 'RecordAfterSave')
    AND IsActive = true
    ORDER BY Label
];

System.debug('=== ACTIVE FLOWS ===');
for (FlowDefinitionView f : flows) {
    if (f.Label.containsIgnoreCase('Case') || f.Label.containsIgnoreCase('Contact') || 
        f.Label.containsIgnoreCase('Assign') || f.ApiName.containsIgnoreCase('Case')) {
        System.debug('Flow: ' + f.Label + ' (API: ' + f.ApiName + ')');
        System.debug('  Type: ' + f.ProcessType + ' | Trigger: ' + f.TriggerType);
        System.debug('  Description: ' + f.Description);
        System.debug('---');
    }
}

// Also check for Apex Triggers on Case
System.debug('\n=== CHECKING FOR CASE TRIGGERS ===');
List<ApexTrigger> triggers = [
    SELECT Name, TableEnumOrId, Status, UsageAfterInsert, UsageAfterUpdate
    FROM ApexTrigger 
    WHERE TableEnumOrId = 'Case' AND Status = 'Active'
];

for (ApexTrigger t : triggers) {
    System.debug('Trigger: ' + t.Name);
    System.debug('  After Insert: ' + t.UsageAfterInsert);
    System.debug('  After Update: ' + t.UsageAfterUpdate);
    System.debug('---');
}
