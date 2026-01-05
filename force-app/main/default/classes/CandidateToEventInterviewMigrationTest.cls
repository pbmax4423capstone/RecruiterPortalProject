@IsTest
private class CandidateToEventInterviewMigrationTest {
    
    @IsTest
    static void testMigrationWithCompletedInterviews() {
        // Create test data
        Candidate__c testCandidate = new Candidate__c(
            Name = 'Test Candidate',
            AI_Completed_Date_Time__c = DateTime.now().addDays(-5),
            SI_1_Date_Completed__c = Date.today().addDays(-3),
            SI_2_Date_Completed__c = Date.today().addDays(-2)
        );
        insert testCandidate;
        
        Test.startTest();
        // Test migration with List<Id> parameter
        List<Id> candidateIds = new List<Id>{testCandidate.Id};
        CandidateToEventInterviewMigration.Result result = 
            CandidateToEventInterviewMigration.migrate(candidateIds, false, null, null);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.candidatesProcessed, 'Should process 1 candidate');
        System.assert(result.eventsUpserted > 0, 'Should upsert at least 1 event');
        
        // Verify events were created
        List<Event> createdEvents = [SELECT Id, Subject, ActivityDate, IsAllDayEvent, Description 
                                      FROM Event 
                                      WHERE OwnerId = :UserInfo.getUserId()];
        System.assert(!createdEvents.isEmpty(), 'Events should be created');
    }
    
    @IsTest
    static void testMigrationDryRun() {
        // Create test data
        Candidate__c testCandidate = new Candidate__c(
            Name = 'Test Candidate Dry Run',
            Attraction_Interview_Date_Completed__c = Date.today().addDays(-10)
        );
        insert testCandidate;
        
        Test.startTest();
        List<Id> candidateIds = new List<Id>{testCandidate.Id};
        CandidateToEventInterviewMigration.Result result = 
            CandidateToEventInterviewMigration.migrate(candidateIds, true, null, null);
        Test.stopTest();
        
        // Verify dry run didn't create events
        System.assertEquals(1, result.candidatesProcessed, 'Should process 1 candidate');
        System.assertEquals(0, result.eventsUpserted, 'Dry run should not upsert events');
        System.assert(!result.warnings.isEmpty(), 'Dry run should have warnings');
        
        // Verify no events created
        List<Event> createdEvents = [SELECT Id FROM Event WHERE OwnerId = :UserInfo.getUserId()];
        System.assertEquals(0, createdEvents.size(), 'Dry run should not create events');
    }
    
    @IsTest
    static void testMigrationWithScheduledInterviews() {
        // Create test data
        Candidate__c testCandidate = new Candidate__c(
            Name = 'Test Scheduled',
            Attraction_Interview_Date_Scheduled__c = Date.today().addDays(5),
            SI_1_Date_Scheduled__c = Date.today().addDays(7)
        );
        insert testCandidate;
        
        Test.startTest();
        List<Id> candidateIds = new List<Id>{testCandidate.Id};
        CandidateToEventInterviewMigration.Result result = 
            CandidateToEventInterviewMigration.migrate(candidateIds, false, null, null);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, result.candidatesProcessed, 'Should process 1 candidate');
        System.assert(result.eventsUpserted > 0, 'Should upsert scheduled events');
    }
    
    @IsTest
    static void testMigrationWithMultipleCandidates() {
        // Create multiple test candidates
        List<Candidate__c> testCandidates = new List<Candidate__c>{
            new Candidate__c(
                Name = 'Candidate 1',
                AI_Completed_Date_Time__c = DateTime.now().addDays(-5),
                SI_1_Date_Completed__c = Date.today().addDays(-3)
            ),
            new Candidate__c(
                Name = 'Candidate 2',
                SI_2_Date_Completed__c = Date.today().addDays(-2),
                SI_3_Completed__c = Date.today().addDays(-1)
            )
        };
        insert testCandidates;
        
        Test.startTest();
        List<Id> candidateIds = new List<Id>();
        for (Candidate__c c : testCandidates) {
            candidateIds.add(c.Id);
        }
        CandidateToEventInterviewMigration.Result result = 
            CandidateToEventInterviewMigration.migrate(candidateIds, false, null, null);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(2, result.candidatesProcessed, 'Should process 2 candidates');
        System.assert(result.eventsUpserted > 0, 'Should upsert multiple events');
    }
    
    @IsTest
    static void testMigrationWithNullCandidateIds() {
        // Create test data
        Candidate__c testCandidate = new Candidate__c(
            Name = 'Test Null IDs',
            AI_Completed_Date_Time__c = DateTime.now().addDays(-5)
        );
        insert testCandidate;
        
        Test.startTest();
        // Pass null candidate IDs to process all candidates
        CandidateToEventInterviewMigration.Result result = 
            CandidateToEventInterviewMigration.migrate(null, false, null, null);
        Test.stopTest();
        
        // Verify results - should process at least the test candidate
        System.assert(result.candidatesProcessed >= 1, 'Should process at least 1 candidate');
    }
    
    @IsTest
    static void testMigrationWithNoCandidates() {
        Test.startTest();
        List<Id> emptyCandidateIds = new List<Id>();
        CandidateToEventInterviewMigration.Result result = 
            CandidateToEventInterviewMigration.migrate(emptyCandidateIds, false, null, null);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(0, result.candidatesProcessed, 'Should process 0 candidates');
        System.assertEquals(0, result.eventsUpserted, 'Should upsert 0 events');
    }
    
    @IsTest
    static void testResolveContactByEmail() {
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.com'
        );
        insert testContact;
        
        Test.startTest();
        Id resolvedId = CandidateToEventInterviewMigration.resolveContact('john.doe@test.com');
        Test.stopTest();
        
        System.assertEquals(testContact.Id, resolvedId, 'Should resolve contact by email');
    }
    
    @IsTest
    static void testResolveContactByName() {
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith'
        );
        insert testContact;
        
        Test.startTest();
        Id resolvedId = CandidateToEventInterviewMigration.resolveContact('Jane Smith');
        Test.stopTest();
        
        System.assertEquals(testContact.Id, resolvedId, 'Should resolve contact by name');
    }
}