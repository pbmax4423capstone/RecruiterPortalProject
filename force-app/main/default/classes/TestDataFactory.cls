/**
 * @description Test Data Factory for creating comprehensive test data in sandbox environments
 * Generates: 500 Candidates with Contacts, 300 ALC records, 800 Interviews (distributed), 1000 Opportunities
 * Supports incremental data generation and cleanup between test runs
 * 
 * IMPORTANT NOTES:
 * ----------------
 * 1. This factory creates data that may trigger Flow automations (e.g., "Candidate Stage Email Automation")
 * 2. If flows fail due to missing email templates or org configuration in sandbox:
 *    - Option A: Deactivate problematic flows temporarily in sandbox
 *    - Option B: Ensure email templates and org-wide email addresses are configured
 *    - Option C: Use Database.insert(records, false) with allOrNone=false (not implemented here)
 * 3. The factory checks for existing "Capstone Partners" account and creates it if missing
 * 4. Can be run multiple times - uses timestamps for unique email addresses
 * 
 * @author RecruiterPortal Team
 * @date 2026-01-07
 */
public class TestDataFactory {
    
    // Constants for test data generation
    private static final String ACCOUNT_NAME = 'Capstone Partners';
    private static final Integer CANDIDATE_COUNT = 500;
    private static final Integer ALC_COUNT = 300;
    private static final Integer OPPORTUNITY_COUNT = 1000;
    
    // Interview distribution constants
    private static final Integer INTERVIEW_CI_FIRST = 500;
    private static final Integer INTERVIEW_PLAN_3RD = 150;
    private static final Integer INTERVIEW_PRESENT_4TH = 100;
    private static final Integer INTERVIEW_OPTIONAL_5TH = 50;
    
    // DML batch size to avoid governor limits
    private static final Integer DML_BATCH_SIZE = 200;
    
    /**
     * @description Main method to generate all test data
     * Creates the complete data hierarchy: Account → Contacts → Candidates → Interviews → ALCs → Opportunities
     * Can be run multiple times - adds incremental data with unique identifiers
     */
    public static void generateCompleteTestData() {
        System.debug('=== Starting Test Data Generation ===');
        Savepoint sp = Database.setSavepoint();
        
        try {
            // Step 1: Get or create Capstone Partners account
            Account capstoneAccount = getOrCreateCapstoneAccount();
            System.debug('Using Account: ' + capstoneAccount.Name + ' (Id: ' + capstoneAccount.Id + ')');
            
            // Step 2: Create 500 Contacts linked to account
            List<Contact> contacts = createContacts(CANDIDATE_COUNT, capstoneAccount.Id);
            insert contacts;
            System.debug('Created ' + contacts.size() + ' Contacts');
            
            // Step 3: Create 500 Candidates linked to Contacts
            List<Candidate__c> candidates = createCandidates(contacts);
            insert candidates;
            System.debug('Created ' + candidates.size() + ' Candidates');
            
            // Step 4: Create 800 Interviews with distributed types
            List<Interview__c> interviews = createDistributedInterviews(candidates);
            insert interviews;
            System.debug('Created ' + interviews.size() + ' Interviews');
            
            // Step 5: Create 300 ALC records for first 300 candidates
            List<ALC__c> alcRecords = createALCRecords(candidates, contacts, ALC_COUNT);
            insert alcRecords;
            System.debug('Created ' + alcRecords.size() + ' ALC Records');
            
            // Step 6: Create 1000 Opportunities linked to agent Contacts (batch inserts)
            createOpportunitiesInBatches(contacts, capstoneAccount.Id, OPPORTUNITY_COUNT);
            System.debug('Created ' + OPPORTUNITY_COUNT + ' Opportunities');
            
            System.debug('=== Test Data Generation Complete ===');
            System.debug('Summary: ' + CANDIDATE_COUNT + ' Candidates, ' + interviews.size() + ' Interviews, ' 
                        + ALC_COUNT + ' ALCs, ' + OPPORTUNITY_COUNT + ' Opportunities');
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(LoggingLevel.ERROR, 'Error generating test data: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw e;
        }
    }
    
    /**
     * @description Deletes all test data created by this factory
     * Removes Opportunities, ALCs, Interviews, Candidates, and Contacts in proper order
     * Preserves the Capstone Partners account for reuse
     */
    public static void deleteAllTestData() {
        System.debug('=== Starting Test Data Cleanup ===');
        Savepoint sp = Database.setSavepoint();
        
        try {
            // Delete in reverse order of dependencies
            
            // Step 1: Delete Opportunities (no formula fields prevent deletion)
            List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountId IN 
                                     (SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME) LIMIT 50000];
            if (!opps.isEmpty()) {
                delete opps;
                System.debug('Deleted ' + opps.size() + ' Opportunities');
            }
            
            // Step 2: Delete ALC records
            List<ALC__c> alcs = [SELECT Id FROM ALC__c LIMIT 50000];
            if (!alcs.isEmpty()) {
                delete alcs;
                System.debug('Deleted ' + alcs.size() + ' ALC Records');
            }
            
            // Step 3: Delete Interviews
            List<Interview__c> interviews = [SELECT Id FROM Interview__c LIMIT 50000];
            if (!interviews.isEmpty()) {
                delete interviews;
                System.debug('Deleted ' + interviews.size() + ' Interviews');
            }
            
            // Step 4: Delete Candidates
            List<Candidate__c> candidates = [SELECT Id FROM Candidate__c LIMIT 50000];
            if (!candidates.isEmpty()) {
                delete candidates;
                System.debug('Deleted ' + candidates.size() + ' Candidates');
            }
            
            // Step 5: Delete Contacts (except those not created by us)
            List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId IN 
                                     (SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME) 
                                     AND Email LIKE '%testfactory%' LIMIT 50000];
            if (!contacts.isEmpty()) {
                delete contacts;
                System.debug('Deleted ' + contacts.size() + ' Contacts');
            }
            
            System.debug('=== Test Data Cleanup Complete ===');
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(LoggingLevel.ERROR, 'Error during cleanup: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw e;
        }
    }
    
    /**
     * @description Gets existing Capstone Partners account or creates it
     * @return Account record (existing or newly created)
     */
    private static Account getOrCreateCapstoneAccount() {
        List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1];
        
        if (!existingAccounts.isEmpty()) {
            return existingAccounts[0];
        }
        
        Account newAccount = new Account(Name = ACCOUNT_NAME);
        insert newAccount;
        return newAccount;
    }
    
    /**
     * @description Creates Contact records with unique identifiers
     * @param count Number of contacts to create
     * @param accountId Account to link contacts to
     * @return List of Contact records (not yet inserted)
     */
    private static List<Contact> createContacts(Integer count, Id accountId) {
        List<Contact> contacts = new List<Contact>();
        Long timestamp = System.currentTimeMillis();
        
        // Common first names for variety
        List<String> firstNames = new List<String>{
            'James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda',
            'William', 'Elizabeth', 'David', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica',
            'Thomas', 'Sarah', 'Charles', 'Karen', 'Christopher', 'Nancy', 'Daniel', 'Lisa',
            'Matthew', 'Betty', 'Anthony', 'Margaret', 'Mark', 'Sandra', 'Donald', 'Ashley'
        };
        
        // Common last names for variety
        List<String> lastNames = new List<String>{
            'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
            'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas',
            'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson', 'White',
            'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker', 'Young'
        };
        
        for (Integer i = 0; i < count; i++) {
            String firstName = firstNames[Math.mod(i, firstNames.size())];
            String lastName = lastNames[Math.mod(i, lastNames.size())];
            
            contacts.add(new Contact(
                FirstName = firstName,
                LastName = lastName + ' ' + i,
                Email = 'testfactory.' + timestamp + '.' + i + '@example.com',
                Phone = '555-01' + String.valueOf(1000 + i).substring(1),
                MobilePhone = '555-02' + String.valueOf(1000 + i).substring(1),
                AccountId = accountId
            ));
        }
        
        return contacts;
    }
    
    /**
     * @description Creates Candidate records linked to Contacts
     * @param contacts List of Contact records to link to
     * @return List of Candidate__c records (not yet inserted)
     */
    private static List<Candidate__c> createCandidates(List<Contact> contacts) {
        List<Candidate__c> candidates = new List<Candidate__c>();
        
        // Sales managers for distribution
        List<String> salesManagers = new List<String>{
            'Tim Denton', 'Elizabeth Kagele', 'Van Hess', 'Michael Yang', 'Bradley Sofonia', 'Rachyll Tenny'
        };
        
        // Status values for variety
        List<String> statuses = new List<String>{
            'Active/In Process', 'Active/In Process', 'Active/In Process', // Weight toward active
            'Contracting Started', 'Contracted- Contract B', 'Keep In Touch'
        };
        
        // Contract types
        List<String> contractTypes = new List<String>{
            'Contract B', 'Contract B', 'Contract A', 'Broker', 'College Intern'
        };
        
        for (Integer i = 0; i < contacts.size(); i++) {
            Contact c = contacts[i];
            
            candidates.add(new Candidate__c(
                Contact__c = c.Id,
                First_Name__c = c.FirstName,
                Last_Name__c = c.LastName,
                Email__c = c.Email,
                Phone__c = c.Phone,
                Status__c = statuses[Math.mod(i, statuses.size())],
                Sales_Manager__c = salesManagers[Math.mod(i, salesManagers.size())],
                Contract_Type__c = contractTypes[Math.mod(i, contractTypes.size())],
                Highest_Level_Achieved__c = i < 100 ? '7-Contracted' : (i < 300 ? 'Plan_3rd' : '0-Prequal')
            ));
        }
        
        return candidates;
    }
    
    /**
     * @description Creates distributed Interview records across 5 types
     * Distribution: 500 Ci-First, 150 Plan-3rd, 100 Present-4th, 50 Optional-5th (800 total)
     * @param candidates List of Candidate records to create interviews for
     * @return List of Interview__c records (not yet inserted)
     */
    private static List<Interview__c> createDistributedInterviews(List<Candidate__c> candidates) {
        List<Interview__c> interviews = new List<Interview__c>();
        Id defaultUserId = UserInfo.getUserId();
        
        // Interview type distribution
        Map<String, Integer> interviewDistribution = new Map<String, Integer>{
            'Ci-First' => INTERVIEW_CI_FIRST,
            'Plan-3rd' => INTERVIEW_PLAN_3RD,
            'Present-4th' => INTERVIEW_PRESENT_4TH,
            'Optional-5th' => INTERVIEW_OPTIONAL_5TH
        };
        
        // Interview statuses for variety
        List<String> statuses = new List<String>{
            'Completed', 'Completed', 'Completed', 'Scheduled', 'No Show', 'Canceled'
        };
        
        // Interview outcomes
        List<String> outcomes = new List<String>{
            'Proceed', 'Proceed', 'Proceed to SI3', 'Hold', 'Decline'
        };
        
        Integer interviewCounter = 0;
        Integer candidateIndex = 0;
        
        // Create interviews distributed across types
        for (String interviewType : new List<String>{'Ci-First', 'Plan-3rd', 'Present-4th', 'Optional-5th'}) {
            Integer countForType = interviewDistribution.get(interviewType);
            
            for (Integer i = 0; i < countForType; i++) {
                // Cycle through candidates (multiple interviews per candidate is realistic)
                Candidate__c candidate = candidates[Math.mod(candidateIndex, candidates.size())];
                candidateIndex++;
                
                Boolean isCompleted = Math.mod(interviewCounter, 6) < 3; // 50% completed
                
                interviews.add(new Interview__c(
                    Candidate__c = candidate.Id,
                    Interview_Type__c = interviewType,
                    Interview_Status__c = isCompleted ? 'Completed' : statuses[Math.mod(interviewCounter, statuses.size())],
                    Conducted_By__c = defaultUserId,
                    Date_Time_Scheduled__c = System.now().addDays(-30 + Math.mod(interviewCounter, 60)),
                    Date_Completed__c = isCompleted ? Date.today().addDays(-15 + Math.mod(interviewCounter, 30)) : null,
                    Outcome__c = isCompleted ? outcomes[Math.mod(interviewCounter, outcomes.size())] : null,
                    Notes__c = 'Test interview notes for ' + interviewType
                ));
                
                interviewCounter++;
            }
        }
        
        return interviews;
    }
    
    /**
     * @description Creates ALC records for contracting candidates
     * @param candidates List of all Candidate records
     * @param contacts List of Contact records (same order as candidates)
     * @param count Number of ALC records to create
     * @return List of ALC__c records (not yet inserted)
     */
    private static List<ALC__c> createALCRecords(List<Candidate__c> candidates, List<Contact> contacts, Integer count) {
        List<ALC__c> alcs = new List<ALC__c>();
        
        // ALC stages for variety
        List<String> stages = new List<String>{
            'Initial Form Sent', 'MM ONX sent', 'In Background', 'Receive NRF Info',
            'Request AE', 'Step 1 Email', 'NRF BIG Review', 'Fingerprinting', 'Sent To Compliance'
        };
        
        // Contract types
        List<String> contractTypes = new List<String>{
            'Contract B', 'Contract B', 'Contract B', 'Contract A', 'Broker'
        };
        
        List<String> salesManagers = new List<String>{
            'Tim Denton', 'Elizabeth Kagele', 'Van Hess', 'Michael Yang', 'Bradley Sofonia'
        };
        
        for (Integer i = 0; i < count && i < candidates.size(); i++) {
            Candidate__c candidate = candidates[i];
            Contact contact = contacts[i];
            
            alcs.add(new ALC__c(
                Candidate__c = candidate.Id,
                Contact__c = contact.Id,
                First_Name__c = contact.FirstName,
                Last_Name__c = contact.LastName,
                Stage__c = stages[Math.mod(i, stages.size())],
                Contract_Type__c = contractTypes[Math.mod(i, contractTypes.size())],
                Sales_Manager__c = salesManagers[Math.mod(i, salesManagers.size())],
                Personal_Email_Address__c = contact.Email,
                Mobile__c = contact.MobilePhone,
                Start_date__c = Date.today().addDays(-60 + Math.mod(i, 120)),
                Contract_Effective__c = Math.mod(i, 3) == 0 ? Date.today().addDays(-30 + Math.mod(i, 60)) : null,
                Life_Insurance_Licensed__c = Math.mod(i, 2) == 0 ? 'Yes' : 'No',
                Registered__c = Math.mod(i, 3) == 0,
                Notes__c = 'Test ALC record for contracting process'
            ));
        }
        
        return alcs;
    }
    
    /**
     * @description Creates Opportunities in batches to avoid governor limits
     * Links opportunities to agent Contacts (for FYC rollup to Candidates)
     * @param contacts List of Contact records to use as agents
     * @param accountId Account to link opportunities to
     * @param totalCount Total number of opportunities to create
     */
    private static void createOpportunitiesInBatches(List<Contact> contacts, Id accountId, Integer totalCount) {
        // Get New Business Coordinator users or fall back to current user
        List<User> nbcUsers = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'New Business Coordinator' LIMIT 10];
        if (nbcUsers.isEmpty()) {
            nbcUsers = new List<User>{ new User(Id = UserInfo.getUserId()) };
        }
        
        // Opportunity stages
        List<String> stages = new List<String>{
            'Submitted', 'Submitted', 'Submitted', 'Complete – Won Sale', 'In Progress', 'Pending'
        };
        
        Integer created = 0;
        Integer batchNumber = 1;
        
        while (created < totalCount) {
            List<Opportunity> oppBatch = new List<Opportunity>();
            Integer batchSize = Math.min(DML_BATCH_SIZE, totalCount - created);
            
            for (Integer i = 0; i < batchSize; i++) {
                Integer oppIndex = created + i;
                Contact agentContact = contacts[Math.mod(oppIndex, contacts.size())];
                User owner = nbcUsers[Math.mod(oppIndex, nbcUsers.size())];
                
                // FYC amounts - realistic distribution
                Decimal fycAmount = 500 + (Math.mod(oppIndex, 20) * 100); // Range: $500-$2400
                
                oppBatch.add(new Opportunity(
                    Name = 'Test Opportunity ' + (oppIndex + 1),
                    ContactId = agentContact.Id, // Links to agent for FYC rollup
                    Soliciting_Agent__c = agentContact.Id,
                    AccountId = accountId,
                    StageName = stages[Math.mod(oppIndex, stages.size())],
                    CloseDate = Date.today().addDays(-90 + Math.mod(oppIndex, 180)),
                    FYC__c = fycAmount,
                    Amount = fycAmount,
                    OwnerId = owner.Id,
                    Reported_Date__c = Date.today().addDays(-30 + Math.mod(oppIndex, 60))
                ));
            }
            
            insert oppBatch;
            created += oppBatch.size();
            System.debug('Inserted batch ' + batchNumber + ': ' + oppBatch.size() + ' Opportunities (Total: ' + created + ')');
            batchNumber++;
        }
    }
}
