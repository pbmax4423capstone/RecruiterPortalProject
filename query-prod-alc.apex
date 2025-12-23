// Query Production for ALC records by candidate name
// Get key fields: Candidate name, LADL_Sales_Experience__c, Contract_Effective_Date__c

List<String> agentNames = new List<String>{
    'Jacob Pesicka', 'Robert Wilson', 'Alec Bucklen', 'Washington Ibarra', 'Pierre Perez',
    'Calix Boldt', 'Yvonne Garcia', 'Michael Donatucci', 'Paras Bengco', 'Sabrina Moya',
    'Marcus Filardi', 'Gwyneth Landaburu', 'Katerina Minevich', 'David Robbins', 'Michael Krupin',
    'Jason Weiss', 'Justin Ricks', 'Douglas Gold', 'Shane Butler', 'Rodney Sager',
    'Eric Wilson', 'Erwin Espina Prieto', 'Robert Silberman', 'Brent Emch', 'John Bradley',
    'Jonathon Olivas', 'Steven Dark', 'Tom Maguire', 'Lauren Skrabonja', 'Slava Palamarchuk',
    'Vladimir Donets', 'Carmina Rodriguez', 'Nacole Light', 'Jeremiah Goldenetz', 'Kerry Hendrix',
    'Robert Perez', 'ANDREW Moore Sr', 'Scott Balboni', 'Ethan Barnes', 'David Tsymbal',
    'Linda Chen', 'Michael McKnight', 'Linh Ma', 'Irina Tarasova', 'Matthew Collins',
    'Erica Pu', 'Todd Frank', 'Woong Eddie Lee', 'Jonny Campbell', 'Brian Barney',
    'Edward Ricker', 'Beau Wendling', 'Jonathan Weir', 'Kyle Annas', 'Matthew Rauen',
    'Susan Kim Chow', 'Josh Wakefield', 'Philip Bodine', 'Nick Morgan', 'Allen Cannon',
    'Andre Coulombe', 'Brad Morgan', 'Brett Longenecker', 'Carl Anthony Fletcher', 'Charles Showalter',
    'Christopher Bissonnette', 'David Guterman', 'Greg Clemensen', 'Greg Karis', 'Harry Hank W Frazee Iii',
    'Jacklin Bahramy', 'Joel Tremmel', 'John Grady Griffin', 'Jon Schaeffer', 'Joseph Joe Brezden',
    'Kenneth Tooke II', 'Lee Kitzenberg', 'Leopold PJ Pfeifenberger Jr', 'Mark Quinlan', 'Matthew Sathe',
    'Raymond Bell', 'Richard Bryan Sedway', 'Robert Goggins', 'Rodney D Sager', 'Ryan A Lax',
    'Sandra Colon-Williams'
};

// Query ALC records where the related Candidate name matches
List<ALC__c> alcRecords = [
    SELECT Id, Name, Candidate__c, Candidate__r.Name, LADL_Sales_Experience__c, Sales_Manager__c
    FROM ALC__c
    WHERE Candidate__r.Name IN :agentNames
];

System.debug('Found ' + alcRecords.size() + ' ALC records in Production');

for (ALC__c alc : alcRecords) {
    System.debug(alc.Candidate__r.Name + ' | LADL Exp: ' + alc.LADL_Sales_Experience__c);
}
