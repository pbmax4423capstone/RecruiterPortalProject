// Check flow status
List<FlowVersionView> flows = [SELECT FlowDefinitionViewId, DurableId, Label, Status, VersionNumber FROM FlowVersionView WHERE Label IN ('Set Interview Name', 'Set Interview Name Auto') AND Status = 'Active' ORDER BY Label];
for (FlowVersionView flow : flows) {
    System.debug('Flow: ' + flow.Label + ' | Status: ' + flow.Status + ' | Version: ' + flow.VersionNumber + ' | ID: ' + flow.DurableId);
}
if (flows.isEmpty()) {
    System.debug('No active Interview Name flows found');
}
