// Verify Contract Qualification record count
Integer count = [SELECT COUNT() FROM Contract_Qualification__c];
System.debug('Total Contract Qualification records: ' + count);

// Show summary by qualification status
List<AggregateResult> byStatus = [
    SELECT WLADL_GDC_Qual_Status__c status, COUNT(Id) cnt 
    FROM Contract_Qualification__c 
    GROUP BY WLADL_GDC_Qual_Status__c
];
System.debug('By Qualification Status:');
for (AggregateResult ar : byStatus) {
    System.debug('  ' + ar.get('status') + ': ' + ar.get('cnt'));
}
