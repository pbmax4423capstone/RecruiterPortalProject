// List ALC records and whether Contact__c is populated
List<ALC__c> alcs = [SELECT Id, Name, Contact__c FROM ALC__c ORDER BY CreatedDate DESC LIMIT 20];
System.debug('Recent ALCs: ' + alcs.size());
for (ALC__c a : alcs) {
    System.debug('ALC ' + a.Name + ' (' + a.Id + ') Contact__c=' + a.Contact__c);
}
