// Import Prequal Candidates from Report - Status = Active/In Process, Highest_Level_Achieved__c = 0-Prequal

List<Candidate__c> candidatesToInsert = new List<Candidate__c>();

// Prequal candidates from report (55 candidates)
List<Map<String, String>> prequelData = new List<Map<String, String>>();
prequelData.add(new Map<String, String>{'name'=>'Devin Murphy', 'phone'=>'(801)200-5333', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Adam Dahle', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Sofia Falcone', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Marcus Hensel', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Tyler Moore', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Millicent Dadson', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Zackary Roberts', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Gleb Belyy', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Jered Bocanegra', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Samantha Rasmussen', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Mannie Esplin', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Ethan Smith', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'T.R Ward', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Brason Denton', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Dallin Reichert', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Luwana Smiley', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Steven LaFrance', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Steve Davis', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Josh Cann', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'David Glauser', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Calvin Howell', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Draek Greco', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Jacob Richins', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Hunter Bartley', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Joe Callahan', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Luke Sampson', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Dan White', 'phone'=>'', 'email'=>'', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Easton Kimura', 'phone'=>'801-808-3330', 'email'=>'eastkim1@hotmail.com', 'salesManager'=>'Brad Sofonia'});
prequelData.add(new Map<String, String>{'name'=>'Evan Vasquez', 'phone'=>'', 'email'=>'evanvasquez@yahoo.com', 'salesManager'=>'Tim Denton'});
prequelData.add(new Map<String, String>{'name'=>'Matt', 'phone'=>'', 'email'=>'', 'salesManager'=>'Elizabeth Kagele'});
prequelData.add(new Map<String, String>{'name'=>'Kyle', 'phone'=>'', 'email'=>'', 'salesManager'=>'Elizabeth Kagele'});
prequelData.add(new Map<String, String>{'name'=>'Testing Candidate', 'phone'=>'', 'email'=>'', 'salesManager'=>'Diljeet Masuda'});
prequelData.add(new Map<String, String>{'name'=>'Darius Shepard', 'phone'=>'', 'email'=>'dshep003@yahoo.com', 'salesManager'=>'Son Le'});
prequelData.add(new Map<String, String>{'name'=>'Lawrence Gabriel Cadena Jr.', 'phone'=>'', 'email'=>'', 'salesManager'=>'Son Le'});
prequelData.add(new Map<String, String>{'name'=>'Kristopher Galvan', 'phone'=>'818-624-8512', 'email'=>'krisgalvan67@gmail.com', 'salesManager'=>'Tim Denton'});
prequelData.add(new Map<String, String>{'name'=>'John McKee', 'phone'=>'410-443-3677', 'email'=>'john@iandeplanning.com', 'salesManager'=>'Tim Denton'});
prequelData.add(new Map<String, String>{'name'=>'Mitchell Kallick', 'phone'=>'', 'email'=>'', 'salesManager'=>'Tim Denton'});
prequelData.add(new Map<String, String>{'name'=>'Brandon Calderon Mata', 'phone'=>'', 'email'=>'', 'salesManager'=>'Tim Denton'});
prequelData.add(new Map<String, String>{'name'=>'Alan Dash', 'phone'=>'2138049727', 'email'=>'dash@alandashjr.com', 'salesManager'=>'Tim Denton'});
prequelData.add(new Map<String, String>{'name'=>'Ryan Carpenter', 'phone'=>'772-521-1113', 'email'=>'ryan.kdjames@gmail.com', 'salesManager'=>'Tim Denton'});
prequelData.add(new Map<String, String>{'name'=>'Curtis Defeo', 'phone'=>'', 'email'=>'', 'salesManager'=>'Tim Denton'});
prequelData.add(new Map<String, String>{'name'=>'Chrissie Brooks', 'phone'=>'', 'email'=>'', 'salesManager'=>'Tim Denton'});
prequelData.add(new Map<String, String>{'name'=>'Anais Tadlaoui', 'phone'=>'', 'email'=>'', 'salesManager'=>'Tim Denton'});
prequelData.add(new Map<String, String>{'name'=>'Louis A Berlin', 'phone'=>'949-439-3838', 'email'=>'louisberlin@mac.com', 'salesManager'=>'Van Hess'});
prequelData.add(new Map<String, String>{'name'=>'Jared Shumway', 'phone'=>'801-726-2902', 'email'=>'jared.shumway@nm.com', 'salesManager'=>'Van Hess'});
prequelData.add(new Map<String, String>{'name'=>'Samuel Frombgen', 'phone'=>'', 'email'=>'', 'salesManager'=>'Michael Yang'});
prequelData.add(new Map<String, String>{'name'=>'Gagandeep Singh', 'phone'=>'', 'email'=>'', 'salesManager'=>'Son Le'});
prequelData.add(new Map<String, String>{'name'=>'Michael Smith', 'phone'=>'', 'email'=>'', 'salesManager'=>'Scott Primm'});
prequelData.add(new Map<String, String>{'name'=>'Sunia Kinikini', 'phone'=>'', 'email'=>'', 'salesManager'=>'Scott Primm'});
prequelData.add(new Map<String, String>{'name'=>'John Beck', 'phone'=>'', 'email'=>'', 'salesManager'=>'Scott Primm'});
prequelData.add(new Map<String, String>{'name'=>'Jason Smith', 'phone'=>'', 'email'=>'', 'salesManager'=>'Scott Primm'});
prequelData.add(new Map<String, String>{'name'=>'Robert Wagner', 'phone'=>'', 'email'=>'', 'salesManager'=>'Scott Primm'});
prequelData.add(new Map<String, String>{'name'=>'Steve Davis 2', 'phone'=>'', 'email'=>'', 'salesManager'=>'Scott Primm'}); // Renamed to avoid duplicate
prequelData.add(new Map<String, String>{'name'=>'Alicia Johnson', 'phone'=>'661-428-9378', 'email'=>'missacharles@gmail.com', 'salesManager'=>'Son Le'});
prequelData.add(new Map<String, String>{'name'=>'Mark Hales', 'phone'=>'(949) 453-5100', 'email'=>'markhales1@gmail.com', 'salesManager'=>'Van Hess'});

// Get existing candidate names to avoid duplicates
Set<String> existingNames = new Set<String>();
for (Candidate__c c : [SELECT Name FROM Candidate__c]) {
    existingNames.add(c.Name.toLowerCase().trim());
}

for (Map<String, String> data : prequelData) {
    String candidateName = data.get('name');
    
    // Skip if candidate already exists
    if (existingNames.contains(candidateName.toLowerCase().trim())) {
        System.debug('Skipping duplicate: ' + candidateName);
        continue;
    }
    
    // Parse name into first/last
    String firstName = '';
    String lastName = '';
    if (candidateName.contains(' ')) {
        Integer spaceIndex = candidateName.indexOf(' ');
        firstName = candidateName.substring(0, spaceIndex);
        lastName = candidateName.substring(spaceIndex + 1);
    } else {
        firstName = candidateName;
        lastName = 'Candidate';
    }
    
    Candidate__c c = new Candidate__c();
    c.First_Name__c = firstName;
    c.Last_Name__c = lastName;
    c.Status__c = 'Active/In Process';
    c.Highest_Level_Achieved__c = '0-Prequal';
    
    // Set phone if provided
    String phone = data.get('phone');
    if (String.isNotBlank(phone)) {
        c.Phone__c = phone;
    }
    
    // Set email if provided
    String email = data.get('email');
    if (String.isNotBlank(email)) {
        c.Email__c = email;
    }
    
    // Set Sales Manager if valid
    String salesManager = data.get('salesManager');
    Set<String> validSalesManagers = new Set<String>{'Tim Denton', 'Van Hess', 'Michael Yang', 'Son Le', 'Brad Sofonia', 'Elizabeth Kagele'};
    if (String.isNotBlank(salesManager)) {
        if (validSalesManagers.contains(salesManager)) {
            c.Sales_Manager__c = salesManager;
        }
    }
    
    candidatesToInsert.add(c);
}

if (!candidatesToInsert.isEmpty()) {
    insert candidatesToInsert;
    System.debug('Inserted ' + candidatesToInsert.size() + ' Prequal candidates');
}

// Verification
System.debug('');
System.debug('=== VERIFICATION ===');
for (AggregateResult ar : [SELECT Highest_Level_Achieved__c hla, COUNT(Id) cnt 
                            FROM Candidate__c 
                            WHERE Status__c = 'Active/In Process'
                            GROUP BY Highest_Level_Achieved__c 
                            ORDER BY Highest_Level_Achieved__c]) {
    System.debug(ar.get('hla') + ': ' + ar.get('cnt'));
}
System.debug('Total Active/In Process: ' + [SELECT COUNT() FROM Candidate__c WHERE Status__c = 'Active/In Process']);
