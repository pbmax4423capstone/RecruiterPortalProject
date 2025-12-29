// Interview Counts by Conductor - Shows who conducted interviews by type
System.debug('CIT (1st) THIS MONTH');
Map<String, Integer> citM = new Map<String, Integer>();
for (Candidate__c c : [SELECT AI_Conducted_By__c FROM Candidate__c WHERE (AI_Completed_Date_Time__c = THIS_MONTH OR Attraction_Interview_Date_Completed__c = THIS_MONTH) AND AI_Conducted_By__c != null]) {
    for (String name : c.AI_Conducted_By__c.split(';')) {
        citM.put(name.trim(), citM.containsKey(name.trim()) ? citM.get(name.trim()) + 1 : 1);
    }
}
for (String k : citM.keySet()) System.debug(k + ': ' + citM.get(k));

System.debug('\nCIT (1st) THIS YEAR');
Map<String, Integer> citY = new Map<String, Integer>();
for (Candidate__c c : [SELECT AI_Conducted_By__c FROM Candidate__c WHERE (AI_Completed_Date_Time__c = THIS_YEAR OR Attraction_Interview_Date_Completed__c = THIS_YEAR) AND AI_Conducted_By__c != null]) {
    for (String name : c.AI_Conducted_By__c.split(';')) {
        citY.put(name.trim(), citY.containsKey(name.trim()) ? citY.get(name.trim()) + 1 : 1);
    }
}
for (String k : citY.keySet()) System.debug(k + ': ' + citY.get(k));

System.debug('\nALIGN (2nd) THIS MONTH');
for (AggregateResult ar : [SELECT SI_1_Conducted_By__c, COUNT(Id) cnt FROM Candidate__c WHERE SI_1_Date_Completed__c = THIS_MONTH AND SI_1_Conducted_By__c != null GROUP BY SI_1_Conducted_By__c ORDER BY COUNT(Id) DESC]) {
    System.debug(ar.get('SI_1_Conducted_By__c') + ': ' + ar.get('cnt'));
}

System.debug('\nALIGN (2nd) THIS YEAR');
for (AggregateResult ar : [SELECT SI_1_Conducted_By__c, COUNT(Id) cnt FROM Candidate__c WHERE SI_1_Date_Completed__c = THIS_YEAR AND SI_1_Conducted_By__c != null GROUP BY SI_1_Conducted_By__c ORDER BY COUNT(Id) DESC]) {
    System.debug(ar.get('SI_1_Conducted_By__c') + ': ' + ar.get('cnt'));
}
