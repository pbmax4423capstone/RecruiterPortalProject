// Check SI1 records with and without conductors
System.debug('=== SI1 CONDUCTOR ANALYSIS ===');

Integer withConductor = [SELECT COUNT() FROM Candidate__c WHERE SI_1_Date_Completed__c != null AND SI_1_Conducted_By__c != null];
Integer withoutConductor = [SELECT COUNT() FROM Candidate__c WHERE SI_1_Date_Completed__c != null AND SI_1_Conducted_By__c = null];
Integer total = [SELECT COUNT() FROM Candidate__c WHERE SI_1_Date_Completed__c != null];

System.debug('Total SI1 completed: ' + total);
System.debug('With conductor: ' + withConductor);
System.debug('Without conductor (NULL): ' + withoutConductor);
