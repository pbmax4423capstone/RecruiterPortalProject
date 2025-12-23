// Get Candidate IDs for creating ALC records
List<String> names = new List<String>{
    'Jacob Pesicka', 'Robert Wilson', 'Alec Bucklen', 'Washington Ibarra', 
    'Pierre Perez', 'Calix Boldt', 'Yvonne Garcia', 'Michael Donatucci', 
    'Paras Bengco', 'Sabrina Moya', 'Marcus Filardi', 'Gwyneth Landaburu', 
    'Katerina Minevich', 'David Robbins', 'Brian Barney', 'David Tsymbal', 
    'Michael McKnight'
};

List<Candidate__c> candidates = [
    SELECT Id, Name 
    FROM Candidate__c 
    WHERE Name IN :names
    ORDER BY Name
];

System.debug('Found ' + candidates.size() + ' candidates');
for (Candidate__c c : candidates) {
    System.debug(c.Name + ': ' + c.Id);
}
