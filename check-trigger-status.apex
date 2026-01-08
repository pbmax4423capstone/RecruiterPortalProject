List<ApexTrigger> triggers = [SELECT Name, Status, ApiVersion FROM ApexTrigger WHERE Name = 'InterviewDefaultsTrigger'];
if (triggers.isEmpty()) {
    System.debug('ERROR: InterviewDefaultsTrigger not found in org');
} else {
    System.debug('Trigger Name: ' + triggers[0].Name);
    System.debug('Status: ' + triggers[0].Status);
    System.debug('API Version: ' + triggers[0].ApiVersion);
}
