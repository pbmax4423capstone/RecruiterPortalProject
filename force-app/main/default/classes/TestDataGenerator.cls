public class TestDataGenerator {
  @AuraEnabled
  public static String generateTestDataForUsers() {
    try {
      // Get the users we need to assign interviews to
      List<User> users = [
        SELECT Id, Name
        FROM User
        WHERE
          Name IN (
            'Rachyll Tenny',
            'Timothy Denton',
            'Elizabeth Kagele',
            'Bradley Sofonia'
          )
          AND IsActive = TRUE
      ];

      Map<String, Id> userMap = new Map<String, Id>();
      for (User u : users) {
        userMap.put(u.Name, u.Id);
      }

      // If we don't find all users, we'll use the current user for testing
      Id defaultUserId = UserInfo.getUserId();

      // Create Contacts for candidates
      List<Contact> contacts = new List<Contact>();
      List<String> candidateNames = new List<String>{
        'John Smith',
        'Jane Doe',
        'Robert Johnson',
        'Emily Williams',
        'Michael Brown',
        'Sarah Davis',
        'David Miller',
        'Lisa Wilson',
        'James Taylor',
        'Jennifer Anderson',
        'Christopher Thomas',
        'Amanda Jackson',
        'Daniel White',
        'Jessica Harris',
        'Matthew Martin',
        'Ashley Thompson',
        'Andrew Garcia',
        'Michelle Martinez',
        'Joshua Robinson',
        'Sarah Clark',
        'Ryan Rodriguez',
        'Nicole Lewis',
        'Kevin Walker',
        'Stephanie Hall',
        'Timothy Allen',
        'Lauren Young',
        'Jason King',
        'Samantha Wright',
        'Jonathan Lopez',
        'Melissa Hill',
        'Brandon Scott',
        'Kimberly Green',
        'Eric Adams',
        'Amy Baker',
        'Jacob Nelson',
        'Heather Carter',
        'Justin Mitchell',
        'Rebecca Perez',
        'Scott Roberts',
        'Rachel Turner',
        'Brian Moore',
        'Laura Taylor',
        'Mark Anderson',
        'Nancy Thomas',
        'Kevin Jackson',
        'Angela White',
        'Jeffrey Harris',
        'Sandra Martin',
        'Adam Thompson',
        'Diana Garcia'
      };

      // Create 50 contacts for candidates
      for (Integer i = 0; i < 50; i++) {
        Contact c = new Contact(
          FirstName = candidateNames[i].split(' ')[0],
          LastName = candidateNames[i].split(' ')[1],
          Email = 'candidate' + i + '@example.com',
          Phone = '(555) ' + (100 + i) + '-' + (1000 + i)
        );
        contacts.add(c);
      }

      if (contacts.isEmpty()) {
        return 'ERROR: No contacts created';
      }

      insert contacts;

      // Create Candidate__c records
      List<Candidate__c> candidates = new List<Candidate__c>();

      // Create 50 candidates
      for (Integer i = 0; i < 50; i++) {
        // Find the corresponding contact
        Contact contact = contacts[i];

        Candidate__c candidate = new Candidate__c(
          Contact__c = contact.Id,
          Status__c = 'Active/In Process'
          // Source__c field not available in this org
        );

        // Interview scheduling handled through Interview__c custom object
        // Commented out fields that don't exist in this org:
        // candidate.Attraction_Interview_Date_Scheduled__c
        // candidate.SI_1_Date_Scheduled__c
        // candidate.SI_2_Date_Scheduled__c
        // candidate.Career_Presentation_Date_Scheduled__c

        candidates.add(candidate);
      }

      insert candidates;

      // Create Interview__c records
      List<Interview__c> interviews = new List<Interview__c>();

      // Create 25 scheduled interviews
      for (Integer i = 0; i < 25; i++) {
        Interview__c interview = new Interview__c(
          Candidate__c = candidates[i].Id,
          Interview_Type__c = 'Attraction',
          Interview_Status__c = 'Scheduled',
          Conducted_By__c = userMap.get('Rachyll Tenny') != null
            ? userMap.get('Rachyll Tenny')
            : defaultUserId,
          Notes__c = 'Test scheduled interview ' + (i + 1),
          Date_Time_Scheduled__c = System.now().addDays(i + 1)
        );
        interviews.add(interview);
      }

      // Create 50 past due interviews
      for (Integer i = 0; i < 50; i++) {
        Interview__c interview = new Interview__c(
          Candidate__c = candidates[i].Id,
          Interview_Type__c = 'SI1',
          Interview_Status__c = 'Completed',
          Conducted_By__c = userMap.get('Timothy Denton') != null
            ? userMap.get('Timothy Denton')
            : defaultUserId,
          Outcome__c = 'Proceed',
          Notes__c = 'Test past due interview ' + (i + 1),
          Date_Time_Scheduled__c = System.now().addDays(-30 - i)
        );
        interviews.add(interview);
      }

      // Create 5 AI Interviews scheduled
      for (Integer i = 0; i < 5; i++) {
        Interview__c interview = new Interview__c(
          Candidate__c = candidates[25 + i].Id,
          Interview_Type__c = 'SI3',
          Interview_Status__c = 'Scheduled',
          Conducted_By__c = userMap.get('Elizabeth Kagele') != null
            ? userMap.get('Elizabeth Kagele')
            : defaultUserId,
          Notes__c = 'Test AI interview ' + (i + 1),
          Date_Time_Scheduled__c = System.now().addDays(10 + i)
        );
        interviews.add(interview);
      }

      // Create 3 SI1 interviews scheduled
      for (Integer i = 0; i < 3; i++) {
        Interview__c interview = new Interview__c(
          Candidate__c = candidates[30 + i].Id,
          Interview_Type__c = 'SI1',
          Interview_Status__c = 'Scheduled',
          Conducted_By__c = userMap.get('Bradley Sofonia') != null
            ? userMap.get('Bradley Sofonia')
            : defaultUserId,
          Notes__c = 'Test SI1 interview ' + (i + 1),
          Date_Time_Scheduled__c = System.now().addDays(15 + i)
        );
        interviews.add(interview);
      }

      // Create 2 SI2 interviews scheduled
      for (Integer i = 0; i < 2; i++) {
        Interview__c interview = new Interview__c(
          Candidate__c = candidates[33 + i].Id,
          Interview_Type__c = 'SI2',
          Interview_Status__c = 'Scheduled',
          Conducted_By__c = userMap.get('Rachyll Tenny') != null
            ? userMap.get('Rachyll Tenny')
            : defaultUserId,
          Notes__c = 'Test SI2 interview ' + (i + 1),
          Date_Time_Scheduled__c = System.now().addDays(20 + i)
        );
        interviews.add(interview);
      }

      // Create 1 Career interview scheduled
      Interview__c careerInterview = new Interview__c(
        Candidate__c = candidates[35].Id,
        Interview_Type__c = 'Career',
        Interview_Status__c = 'Scheduled',
        Conducted_By__c = userMap.get('Timothy Denton') != null
          ? userMap.get('Timothy Denton')
          : defaultUserId,
        Notes__c = 'Test Career interview 1',
        Date_Time_Scheduled__c = System.now().addDays(25)
      );
      interviews.add(careerInterview);

      insert interviews;

      // Create Task records for calls
      List<Task> tasks = new List<Task>();

      // Create 25 scheduled calls
      for (Integer i = 0; i < 25; i++) {
        Task task = new Task(
          Subject = 'Follow-up Call - ' + candidates[i].Name,
          Type = 'Call',
          Status = 'Not Started',
          Priority = 'Normal',
          OwnerId = userMap.get('Rachyll Tenny') != null
            ? userMap.get('Rachyll Tenny')
            : defaultUserId,
          WhatId = candidates[i].Id,
          ActivityDate = Date.today().addDays(3),
          Description = 'Scheduled follow-up call for candidate ' +
            candidates[i].Name
        );
        tasks.add(task);
      }

      // Create 50 past due calls
      for (Integer i = 0; i < 50; i++) {
        Task task = new Task(
          Subject = 'Overdue Call - ' + candidates[i].Name,
          Type = 'Call',
          Status = 'Not Started',
          Priority = 'High',
          OwnerId = userMap.get('Timothy Denton') != null
            ? userMap.get('Timothy Denton')
            : defaultUserId,
          WhatId = candidates[i].Id,
          ActivityDate = Date.today().addDays(-2),
          Description = 'Past due follow-up call for candidate ' +
            candidates[i].Name
        );
        tasks.add(task);
      }

      insert tasks;

      return 'SUCCESS: Generated test data with ' +
        contacts.size() +
        ' contacts, ' +
        candidates.size() +
        ' candidates, ' +
        interviews.size() +
        ' interviews, and ' +
        tasks.size() +
        ' tasks for users Rachyll Tenny, Timothy Denton, Elizabeth Kagele, and Bradley Sofonia.';
    } catch (Exception e) {
      System.debug('Error generating test data: ' + e.getMessage());
      return 'ERROR: ' + e.getMessage();
    }
  }
}
