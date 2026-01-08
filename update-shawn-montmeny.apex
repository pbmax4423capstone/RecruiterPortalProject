// Update Shawn Montmeny's Highest_Level_Achieved__c to use new value
Candidate__c candidate = [SELECT Id, Highest_Level_Achieved__c 
                          FROM Candidate__c 
                          WHERE First_Name__c = 'Shawn' AND Last_Name__c = 'Montmeny' 
                          LIMIT 1];

System.debug('Current value: ' + candidate.Highest_Level_Achieved__c);

// Update to new matching value
candidate.Highest_Level_Achieved__c = 'Ci-First';
update candidate;

System.debug('Updated to: Ci-First');

// Verify
candidate = [SELECT Id, Highest_Level_Achieved__c FROM Candidate__c WHERE Id = :candidate.Id];
System.debug('Verified value: ' + candidate.Highest_Level_Achieved__c);
