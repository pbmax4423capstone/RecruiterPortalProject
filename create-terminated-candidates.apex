// Create terminated candidates from the terminated_users.csv list
// All 25 users need to be created fresh in Recruiting sandbox

// Capstone Account Id
Id capstoneAccountId = '001dh00000MKQ8YAAX';

// Define terminated users with their termination dates
List<Map<String, String>> terminatedUsers = new List<Map<String, String>>();
terminatedUsers.add(new Map<String, String>{'firstName' => 'Herbert', 'lastName' => 'Franco', 'termDate' => '2024-12-04'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Phong', 'lastName' => 'Nguyen', 'termDate' => '2024-09-16'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Kinley', 'lastName' => 'Yann', 'termDate' => '2024-11-27'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'James', 'lastName' => 'Farden', 'termDate' => '2024-10-14'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Christina', 'lastName' => 'Lee', 'termDate' => '2024-12-05'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Timothy', 'lastName' => 'Johnson', 'termDate' => '2024-09-16'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Lisa', 'lastName' => 'Paras', 'termDate' => '2024-10-11'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Syncere', 'lastName' => 'Cumpian', 'termDate' => '2024-11-26'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Constance', 'lastName' => 'Hammonds', 'termDate' => '2024-11-21'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Scott', 'lastName' => 'Primm', 'termDate' => '2024-10-15'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Richard', 'lastName' => 'Stribling', 'termDate' => '2024-10-09'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Gregory', 'lastName' => 'Poulton', 'termDate' => '2024-10-10'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Gregory', 'lastName' => 'Smith', 'termDate' => '2024-09-27'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Kimberley', 'lastName' => 'Schkade-hill', 'termDate' => '2024-11-07'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Thomas', 'lastName' => 'Thorkelson', 'termDate' => '2024-11-04'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Tyler', 'lastName' => 'Parcell', 'termDate' => '2024-10-24'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Ryan', 'lastName' => 'Atchley', 'termDate' => '2024-10-16'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Cory', 'lastName' => 'Smith', 'termDate' => '2024-10-16'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Thomas', 'lastName' => 'Spink', 'termDate' => '2024-10-16'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Patricia', 'lastName' => 'Moulton', 'termDate' => '2024-10-16'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Wilson', 'lastName' => 'Skinner', 'termDate' => '2024-10-16'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Amy', 'lastName' => 'Corpron', 'termDate' => '2024-10-16'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Craig', 'lastName' => 'Simmerman', 'termDate' => '2024-10-16'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Erica', 'lastName' => 'Neal', 'termDate' => '2024-10-15'});
terminatedUsers.add(new Map<String, String>{'firstName' => 'Diljeet', 'lastName' => 'Masuda', 'termDate' => '2024-10-15'});

// Step 1: Create Contacts first
List<Contact> contactsToInsert = new List<Contact>();
for (Map<String, String> user : terminatedUsers) {
    Contact c = new Contact();
    c.FirstName = user.get('firstName');
    c.LastName = user.get('lastName');
    c.AccountId = capstoneAccountId;
    contactsToInsert.add(c);
}

insert contactsToInsert;
System.debug('Created ' + contactsToInsert.size() + ' contacts');

// Step 2: Create Candidates
List<Candidate__c> candidatesToInsert = new List<Candidate__c>();
for (Integer i = 0; i < terminatedUsers.size(); i++) {
    Map<String, String> user = terminatedUsers[i];
    Contact c = contactsToInsert[i];
    
    Candidate__c cand = new Candidate__c();
    cand.Name = user.get('firstName') + ' ' + user.get('lastName');
    cand.First_Name__c = user.get('firstName');
    cand.Last_Name__c = user.get('lastName');
    cand.Status__c = 'Terminated';
    cand.Contract_Type__c = 'Contract A'; // Candidate uses "Contract A"
    cand.Contact__c = c.Id;
    candidatesToInsert.add(cand);
}

insert candidatesToInsert;
System.debug('Created ' + candidatesToInsert.size() + ' candidates');

// Step 3: Create ALC records
List<ALC__c> alcsToInsert = new List<ALC__c>();
for (Integer i = 0; i < terminatedUsers.size(); i++) {
    Map<String, String> user = terminatedUsers[i];
    Candidate__c cand = candidatesToInsert[i];
    Contact cont = contactsToInsert[i];
    
    ALC__c alc = new ALC__c();
    alc.Candidate__c = cand.Id;
    alc.Contact__c = cont.Id;
    alc.Candidate_Name__c = user.get('firstName') + ' ' + user.get('lastName');
    alc.First_Name__c = user.get('firstName');
    alc.Last_Name__c = user.get('lastName');
    alc.Contract_Type__c = 'A'; // ALC uses "A" not "Contract A"
    alc.Stage__c = 'TERMINATED'; // ALC uses uppercase "TERMINATED"
    alcsToInsert.add(alc);
}

insert alcsToInsert;
System.debug('Created ' + alcsToInsert.size() + ' ALC records');

System.debug('=== SUMMARY ===');
System.debug('Created ' + contactsToInsert.size() + ' Contacts');
System.debug('Created ' + candidatesToInsert.size() + ' Candidates (Status: Terminated)');
System.debug('Created ' + alcsToInsert.size() + ' ALC records (Stage: TERMINATED)');
