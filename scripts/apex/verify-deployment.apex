// Check if our components actually exist in this org
System.debug('=== CHECKING COMPONENT DEPLOYMENT ===');

// Check if our LWC exists
try {
    List<LightningComponentBundle> lwcs = [SELECT Id, DeveloperName, MasterLabel FROM LightningComponentBundle WHERE DeveloperName = 'recruiterDashboard'];
    System.debug('Found LWC components: ' + lwcs.size());
    for (LightningComponentBundle lwc : lwcs) {
        System.debug('LWC: ' + lwc.DeveloperName + ' - ' + lwc.MasterLabel);
    }
} catch (Exception e) {
    System.debug('Error querying LWC: ' + e.getMessage());
}

// Check if our FlexiPage exists
try {
    List<FlexiPage> pages = [SELECT Id, DeveloperName, MasterLabel FROM FlexiPage WHERE DeveloperName LIKE '%Recruiter%'];
    System.debug('Found FlexiPages: ' + pages.size());
    for (FlexiPage page : pages) {
        System.debug('FlexiPage: ' + page.DeveloperName + ' - ' + page.MasterLabel);
    }
} catch (Exception e) {
    System.debug('Error querying FlexiPage: ' + e.getMessage());
}

// Check if our Custom Tabs exist
try {
    System.debug('Checking CustomTab metadata...');
    // This might not work as CustomTab isn't always queryable
} catch (Exception e) {
    System.debug('CustomTab query failed: ' + e.getMessage());
}

// Most importantly - check if our controller and data work
try {
    Map<String, Object> result = RecruiterDashboardController.getInterviewStatsByType();
    System.debug('Controller works - Interview stats: ' + result);
    
    // Check data
    Integer count = [SELECT COUNT() FROM Interview__c];
    System.debug('Interview records in org: ' + count);
} catch (Exception e) {
    System.debug('Controller/Data error: ' + e.getMessage());
}