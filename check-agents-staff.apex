// Check what Agents_Staff record is being assigned
Agents_Staff__c agentStaff = [SELECT Id, Name, Contact__c, Contact__r.Name FROM Agents_Staff__c WHERE Id = 'a0a5f00000BEMNcAAP' LIMIT 1];
System.debug('Agents_Staff__c: ' + agentStaff.Name);
System.debug('Contact__c: ' + agentStaff.Contact__c);
System.debug('Contact Name: ' + agentStaff.Contact__r.Name);
