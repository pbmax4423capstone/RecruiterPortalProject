// Check candidates without contract type and their LADL Sales Experience
List<Candidate__c> candidatesNoContractType = [
    SELECT Id, Name, Contract_Type__c, Status__c, LADL_Sales_Experience__c
    FROM Candidate__c
    WHERE Contract_Type__c = null
    AND Status__c = 'Completed'
    LIMIT 100
];

System.debug('Candidates without Contract Type: ' + candidatesNoContractType.size());

Integer contractA = 0;
Integer contractB = 0;
Integer noExperience = 0;

for (Candidate__c c : candidatesNoContractType) {
    String exp = c.LADL_Sales_Experience__c;
    System.debug(c.Name + ' | LADL Sales Experience: ' + exp);
    
    if (exp == null || exp == '') {
        noExperience++;
    } else if (exp == 'Less than 2 years' || exp == '< 2 years' || exp.containsIgnoreCase('less than 2')) {
        contractB++;
    } else {
        contractA++;
    }
}

System.debug('');
System.debug('Summary:');
System.debug('  Would be Contract A (2+ years): ' + contractA);
System.debug('  Would be Contract B (< 2 years): ' + contractB);
System.debug('  No experience data: ' + noExperience);
