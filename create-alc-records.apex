// Create ALC records in Recruiting sandbox with LADL Sales Experience data from Production

// Mapping from Production: Candidate Name -> LADL_Sales_Experience__c
// None: Alec Bucklen, David Robbins, Gwyneth Landaburu, Katerina Minevich, Michael Donatucci, Pierre Perez, Robert Wilson, Sabrina Moya, Washington Ibarra
// Less_than_2_years: Marcus Filardi
// null: Brian Barney, Calix Boldt, David Tsymbal, Jacob Pesicka, Michael McKnight, Paras Bengco, Yvonne Garcia

// Candidate IDs in Recruiting sandbox
Map<Id, String> candidateExperience = new Map<Id, String>{
    // None
    'a02dh00000AnyDsAAJ' => 'None',      // Alec Bucklen
    'a02dh00000AnyEeAAJ' => 'None',      // David Robbins
    'a02dh00000AnyENAAZ' => 'None',      // Gwyneth Landaburu
    'a02dh00000AnyEPAAZ' => 'None',      // Katerina Minevich
    'a02dh00000AnyEAAAZ' => 'None',      // Michael Donatucci
    'a02dh00000AnyE4AAJ' => 'None',      // Pierre Perez
    'a02dh00000AnyDrAAJ' => 'None',      // Robert Wilson
    'a02dh00000AnyELAAZ' => 'None',      // Sabrina Moya
    'a02dh00000AnyDuAAJ' => 'None',      // Washington Ibarra
    // Less_than_2_years
    'a02dh00000AnyEMAAZ' => 'Less_than_2_years', // Marcus Filardi
    // null
    'a02dh00000AoN2eAAF' => null,        // Brian Barney
    'a02dh00000AnyE8AAJ' => null,        // Calix Boldt
    'a02dh00000AoN2UAAV' => null,        // David Tsymbal
    'a02dh00000AnyDmAAJ' => null,        // Jacob Pesicka
    'a02dh00000AoN2WAAV' => null,        // Michael McKnight
    'a02dh00000AnyEKAAZ' => null,        // Paras Bengco
    'a02dh00000AnyE9AAJ' => null         // Yvonne Garcia
};

// Get candidate names for ALC record names
Map<Id, String> candidateNames = new Map<Id, String>();
List<Candidate__c> candidates = [SELECT Id, Name FROM Candidate__c WHERE Id IN :candidateExperience.keySet()];
for (Candidate__c c : candidates) {
    candidateNames.put(c.Id, c.Name);
}

// Create ALC records
List<ALC__c> alcRecords = new List<ALC__c>();
for (Id candId : candidateExperience.keySet()) {
    ALC__c alc = new ALC__c();
    alc.Candidate__c = candId;
    alc.Name = candidateNames.get(candId);
    alc.LADL_Sales_Experience__c = candidateExperience.get(candId);
    alcRecords.add(alc);
}

insert alcRecords;
System.debug('Created ' + alcRecords.size() + ' ALC records');

for (ALC__c alc : alcRecords) {
    System.debug(alc.Name + ' - Experience: ' + alc.LADL_Sales_Experience__c + ' - Id: ' + alc.Id);
}
