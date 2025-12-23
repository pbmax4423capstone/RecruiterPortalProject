// First find the field API names for Contract B dates
System.debug('=== FINDING FIELD NAMES ===');
for (Schema.SObjectField f : Candidate__c.SObjectType.getDescribe().fields.getMap().values()) {
    Schema.DescribeFieldResult dfr = f.getDescribe();
    String label = dfr.getLabel().toLowerCase();
    String name = dfr.getName().toLowerCase();
    if (label.contains('contract') || label.contains('expir') || name.contains('contract') || name.contains('expir')) {
        System.debug(dfr.getName() + ' - ' + dfr.getLabel() + ' (' + dfr.getType() + ')');
    }
}

System.debug('');
System.debug('=== CURRENT STATUS VALUES ===');
for (AggregateResult ar : [SELECT Status__c, COUNT(Id) cnt FROM Candidate__c GROUP BY Status__c]) {
    System.debug(ar.get('Status__c') + ': ' + ar.get('cnt'));
}

System.debug('');
System.debug('=== HIGHEST LEVEL VALUES ===');
for (AggregateResult ar : [SELECT Highest_Level_Achieved__c, COUNT(Id) cnt FROM Candidate__c GROUP BY Highest_Level_Achieved__c]) {
    System.debug(ar.get('Highest_Level_Achieved__c') + ': ' + ar.get('cnt'));
}
