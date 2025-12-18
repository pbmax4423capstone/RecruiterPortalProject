// Check what ALC records exist and their stages
List<AggregateResult> stageCounts = [
    SELECT Stage__c, COUNT(Id) cnt
    FROM ALC__c
    WHERE Candidate__c != null
    GROUP BY Stage__c
    ORDER BY Stage__c
];

System.debug('=== ALC Stage Counts ===');
for (AggregateResult ar : stageCounts) {
    System.debug(ar.get('Stage__c') + ': ' + ar.get('cnt'));
}

// Check Contract_Type values
List<AggregateResult> contractTypes = [
    SELECT Contract_Type__c, COUNT(Id) cnt
    FROM ALC__c
    WHERE Candidate__c != null
    GROUP BY Contract_Type__c
];

System.debug('=== Contract Type Counts ===');
for (AggregateResult ar : contractTypes) {
    System.debug(ar.get('Contract_Type__c') + ': ' + ar.get('cnt'));
}
