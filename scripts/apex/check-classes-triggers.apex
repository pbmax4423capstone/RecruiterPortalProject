// Check if InterviewEventHandler class exists
List<ApexClass> classes = [SELECT Id, Name, Status FROM ApexClass WHERE Name = 'InterviewEventHandler'];
System.debug('InterviewEventHandler classes found: ' + classes.size());
for (ApexClass cls : classes) {
    System.debug('  Class: ' + cls.Name + ', Status: ' + cls.Status);
}

// Check triggers
List<ApexTrigger> triggers = [SELECT Id, Name, Status, TableEnumOrId FROM ApexTrigger WHERE Name = 'InterviewEventTrigger'];
System.debug('InterviewEventTrigger triggers found: ' + triggers.size());
for (ApexTrigger t : triggers) {
    System.debug('  Trigger: ' + t.Name + ', Status: ' + t.Status + ', Object: ' + t.TableEnumOrId);
}
