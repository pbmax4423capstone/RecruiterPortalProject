// Update terminated candidates with 2025 termination dates for YTD display
List<Candidate__c> terminatedCandidates = [
    SELECT Id, Name, First_Name__c, Last_Name__c, Termination_Date__c 
    FROM Candidate__c 
    WHERE Status__c = 'Terminated'
];

System.debug('Found ' + terminatedCandidates.size() + ' terminated candidates');

// Map of names to termination dates (2025 dates for YTD visibility)
Map<String, Date> terminationDates = new Map<String, Date>{
    'Herbert Franco' => Date.newInstance(2025, 12, 4),
    'Phong Nguyen' => Date.newInstance(2025, 9, 16),
    'Kinley Yann' => Date.newInstance(2025, 11, 27),
    'James Farden' => Date.newInstance(2025, 10, 14),
    'Christina Lee' => Date.newInstance(2025, 12, 5),
    'Timothy Johnson' => Date.newInstance(2025, 9, 16),
    'Lisa Paras' => Date.newInstance(2025, 10, 11),
    'Syncere Cumpian' => Date.newInstance(2025, 11, 26),
    'Constance Hammonds' => Date.newInstance(2025, 11, 21),
    'Scott Primm' => Date.newInstance(2025, 10, 15),
    'Richard Stribling' => Date.newInstance(2025, 10, 9),
    'Gregory Poulton' => Date.newInstance(2025, 10, 10),
    'Gregory Smith' => Date.newInstance(2025, 9, 27),
    'Kimberley Schkade-hill' => Date.newInstance(2025, 11, 7),
    'Thomas Thorkelson' => Date.newInstance(2025, 11, 4),
    'Tyler Parcell' => Date.newInstance(2025, 10, 24),
    'Ryan Atchley' => Date.newInstance(2025, 10, 16),
    'Cory Smith' => Date.newInstance(2025, 10, 16),
    'Thomas Spink' => Date.newInstance(2025, 10, 16),
    'Patricia Moulton' => Date.newInstance(2025, 10, 16),
    'Wilson Skinner' => Date.newInstance(2025, 10, 16),
    'Amy Corpron' => Date.newInstance(2025, 10, 16),
    'Craig Simmerman' => Date.newInstance(2025, 10, 16),
    'Erica Neal' => Date.newInstance(2025, 10, 15),
    'Diljeet Masuda' => Date.newInstance(2025, 10, 15)
};

// Update termination dates
for (Candidate__c c : terminatedCandidates) {
    String fullName = c.First_Name__c + ' ' + c.Last_Name__c;
    if (terminationDates.containsKey(fullName)) {
        c.Termination_Date__c = terminationDates.get(fullName);
        System.debug('Setting termination date for ' + fullName + ' to ' + c.Termination_Date__c);
    } else {
        System.debug('No termination date found for: ' + fullName);
    }
}

update terminatedCandidates;
System.debug('Updated ' + terminatedCandidates.size() + ' candidates with termination dates');

// Verify the update
List<Candidate__c> verified = [
    SELECT Id, Name, Termination_Date__c 
    FROM Candidate__c 
    WHERE Status__c = 'Terminated' AND Termination_Date__c != null
];
System.debug('Verified ' + verified.size() + ' candidates now have termination dates');
