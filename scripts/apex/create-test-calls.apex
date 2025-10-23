// Create test call tasks for testing the dashboard
List<Contact> contacts = [SELECT Id, Name FROM Contact LIMIT 5];

if (contacts.size() > 0) {
    List<Task> tasks = new List<Task>();
    
    // Create scheduled calls (future dates)
    for (Integer i = 0; i < Math.min(3, contacts.size()); i++) {
        Task scheduledTask = new Task();
        scheduledTask.Subject = 'Follow-up call with ' + contacts[i].Name;
        scheduledTask.ActivityDate = Date.today().addDays(i + 1);
        scheduledTask.Status = 'Not Started';
        scheduledTask.WhoId = contacts[i].Id;
        scheduledTask.OwnerId = UserInfo.getUserId();
        scheduledTask.Description = 'Scheduled follow-up call to discuss opportunities';
        tasks.add(scheduledTask);
    }
    
    // Create past due calls (past dates)
    for (Integer i = 0; i < Math.min(2, contacts.size()); i++) {
        Task pastDueTask = new Task();
        pastDueTask.Subject = 'Past due call with ' + contacts[i].Name;
        pastDueTask.ActivityDate = Date.today().addDays(-(i + 1));
        pastDueTask.Status = 'Not Started';
        pastDueTask.WhoId = contacts[i].Id;
        pastDueTask.OwnerId = UserInfo.getUserId();
        pastDueTask.Description = 'Past due call that needs attention';
        tasks.add(pastDueTask);
    }
    
    try {
        insert tasks;
        System.debug('Successfully created ' + tasks.size() + ' test call tasks');
    } catch (Exception e) {
        System.debug('Error creating test tasks: ' + e.getMessage());
    }
} else {
    System.debug('No contacts found to create test tasks');
}