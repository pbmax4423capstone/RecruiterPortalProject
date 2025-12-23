// Update Contract Types based on ALC LADL Sales Experience
// Rule: None or Less_than_2_years = Contract B
//       2+ years = Contract A
//       null = leave as null

List<ALC__c> alcRecords = [
    SELECT Id, Name, Candidate__c, Candidate__r.Name, LADL_Sales_Experience__c 
    FROM ALC__c 
    WHERE Candidate__c != null
];

System.debug('Found ' + alcRecords.size() + ' ALC records with candidates');

List<Candidate__c> candidatesToUpdate = new List<Candidate__c>();
for (ALC__c alc : alcRecords) {
    String experience = alc.LADL_Sales_Experience__c;
    String contractType = null;
    
    if (experience == 'None' || experience == 'Less_than_2_years') {
        contractType = 'Contract B';
    } else if (experience == '2_years_or_more' || experience == '2_years_plus') {
        contractType = 'Contract A';
    }
    // If experience is null, leave contract type as null
    
    if (contractType != null) {
        Candidate__c cand = new Candidate__c();
        cand.Id = alc.Candidate__c;
        cand.Contract_Type__c = contractType;
        candidatesToUpdate.add(cand);
        System.debug(alc.Candidate__r.Name + ' -> ' + contractType + ' (Experience: ' + experience + ')');
    } else {
        System.debug(alc.Candidate__r.Name + ' -> No contract type set (Experience: ' + experience + ')');
    }
}

if (candidatesToUpdate.size() > 0) {
    update candidatesToUpdate;
    System.debug('Updated ' + candidatesToUpdate.size() + ' candidates with Contract Type');
}
