---
description: 'Apex development guidelines and best practices for RecruiterPortal Salesforce project'
applyTo: '**/*.cls, **/*.trigger'
---

<!-- 
Attribution: Adapted from github.com/github/awesome-copilot/instructions/apex.instructions.md
Customized for RecruiterPortal project requirements
-->

# Apex Development for RecruiterPortal

## Project-Specific Context

This Salesforce application manages:
- **Candidates** (Candidate__c) - Recruitment and contract lifecycle tracking
- **Interviews** (Interview__c) - Interview scheduling and tracking
- **ALCs** (ALC__c) - Agent Licensing & Contracting records
- **Contract B Dashboard** - YTD metrics and FYC rollup calculations
- **Email Automation** - Stage-based email workflows

**Target Org:** ProductionCapstone (production)
**Sandbox:** ProdTest (testing before production)

## General Instructions

- Always use the latest Apex features and best practices for the Salesforce Platform.
- Write clear and concise comments for each class and method, explaining the business logic and any complex operations.
- Handle edge cases and implement proper exception handling with meaningful error messages.
- Focus on bulkification - write code that handles collections of records, not single records.
- Be mindful of governor limits and design solutions that scale efficiently.
- Implement proper separation of concerns using service layers, domain classes, and selector classes.
- Document external dependencies, integration points, and their purposes in comments.

## Naming Conventions

- **Classes:**
  - Controllers: suffix with `Controller` (e.g., `RecruiterDashboardController`, `CandidateRecordViewController`)
  - Trigger Handlers: suffix with `TriggerHandler` (e.g., `CandidateTriggerHandler`)
  - Service Classes: suffix with `Service` (e.g., `CandidateFYCRollupService`)
  - Selector Classes: suffix with `Selector` (e.g., `CandidateSelector`)
  - Test Classes: suffix with `Test` (e.g., `RecruiterDashboardControllerTest`)
  - Batch Classes: suffix with `Batch` (e.g., `FYCRollupBatch`)
  - Schedulable Classes: suffix with `Scheduler` (e.g., `ContractBDailyRollupScheduler`)

- **Methods:** Use `camelCase` for method names. Use verbs to indicate actions.
  - Good: `getCandidatesByStage()`, `updateContractBStatus()`, `calculateFYC()`
  - Avoid abbreviations: `getCands()` → `getCandidates()`

- **Variables:** Use `camelCase` for variable names. Use descriptive names.
  - Good: `candidateList`, `interviewCount`, `totalFYC`
  - Avoid single letters except for loop counters

- **Constants:** Use `UPPER_SNAKE_CASE` for constants.
  - Good: `MAX_BATCH_SIZE`, `DEFAULT_STAGE`, `FYC_FIELD_NAME`

## Best Practices

### Bulkification

Always write bulkified code that handles collections:

```apex
// Good - Bulkified
public static void updateCandidateRatings(List<Candidate__c> candidates) {
    for (Candidate__c cand : candidates) {
        if (cand.Total_FYC__c > 100000) {
            cand.Rating__c = 'Hot';
        }
    }
    update candidates;
}

// Bad - Not bulkified
public static void updateCandidateRating(Candidate__c candidate) {
    if (candidate.Total_FYC__c > 100000) {
        candidate.Rating__c = 'Hot';
        update candidate; // DML in a method designed for single records
    }
}
```

### Security and Data Access

Always check CRUD/FLS permissions before performing operations:

```apex
public with sharing class CandidateService {
    public static List<Candidate__c> getCandidates() {
        if (!Schema.sObjectType.Candidate__c.isAccessible()) {
            throw new SecurityException('User does not have access to Candidate object');
        }
        
        List<Candidate__c> candidates = [
            SELECT Id, First_Name__c, Last_Name__c, Stage__c 
            FROM Candidate__c 
            WITH SECURITY_ENFORCED
        ];
        
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE, 
            candidates
        );
        
        return decision.getRecords();
    }
}
```

### SOQL Best Practices

- Always use `String.escapeSingleQuotes()` for user input
- Use selective queries with indexed fields
- Avoid `SELECT *` - always specify required fields
- Use relationship queries to minimize SOQL count

```apex
// Good - Selective query with relationships
List<Candidate__c> candidates = [
    SELECT Id, First_Name__c, Last_Name__c, 
           (SELECT Id, Interview_Date__c FROM Interviews__r ORDER BY Interview_Date__c DESC)
    FROM Candidate__c
    WHERE Stage__c = :stage
    AND OwnerId = :UserInfo.getUserId()
    LIMIT 100
];

// Good - Prevent SOQL injection
String searchTerm = String.escapeSingleQuotes(userInput);
List<Candidate__c> candidates = Database.query(
    'SELECT Id, First_Name__c FROM Candidate__c WHERE Last_Name__c LIKE \'%' + searchTerm + '%\''
);
```

### Governor Limits

Be aware of Salesforce governor limits:
- SOQL queries: 100 per transaction
- DML statements: 150 per transaction
- Heap size: 6MB
- CPU time: 10 seconds

```apex
// Good - SOQL for loop for large data sets
public static void processCandidates() {
    for (List<Candidate__c> candidates : [
        SELECT Id, First_Name__c, Total_FYC__c 
        FROM Candidate__c 
        WHERE Stage__c = 'Contracted'
    ]) {
        // Process batch of 200 records
        updateFYCCalculations(candidates);
    }
}
```

### Trigger Best Practices

Use one trigger per object with a handler pattern:

```apex
// Trigger
trigger CandidateTrigger on Candidate__c (before insert, before update, after insert, after update) {
    new CandidateTriggerHandler().run();
}

// Handler Class
public class CandidateTriggerHandler extends TriggerHandler {
    private List<Candidate__c> newCandidates;
    private List<Candidate__c> oldCandidates;
    private Map<Id, Candidate__c> newCandidateMap;
    private Map<Id, Candidate__c> oldCandidateMap;
    
    public CandidateTriggerHandler() {
        this.newCandidates = (List<Candidate__c>) Trigger.new;
        this.oldCandidates = (List<Candidate__c>) Trigger.old;
        this.newCandidateMap = (Map<Id, Candidate__c>) Trigger.newMap;
        this.oldCandidateMap = (Map<Id, Candidate__c>) Trigger.oldMap;
    }
    
    public override void beforeInsert() {
        CandidateService.setDefaultStage(newCandidates);
    }
    
    public override void afterUpdate() {
        CandidateService.handleStageChange(newCandidateMap, oldCandidateMap);
    }
}
```

### Asynchronous Apex

Use appropriate asynchronous processing:

```apex
// Good - Queueable for complex operations
public class FYCCalculationQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> candidateIds;
    
    public FYCCalculationQueueable(List<Id> candidateIds) {
        this.candidateIds = candidateIds;
    }
    
    public void execute(QueueableContext context) {
        List<Candidate__c> candidates = [
            SELECT Id, Total_FYC__c 
            FROM Candidate__c 
            WHERE Id IN :candidateIds
        ];
        
        for (Candidate__c cand : candidates) {
            cand.Total_FYC__c = CandidateFYCRollupService.calculateFYC(cand.Id);
        }
        
        update candidates;
    }
}

// Good - Batch for large data volumes
public class ContractBRollupBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, First_Name__c, Last_Name__c, Total_FYC__c
            FROM Candidate__c
            WHERE Stage__c = 'Contracted'
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Candidate__c> scope) {
        for (Candidate__c cand : scope) {
            cand.Total_FYC__c = CandidateFYCRollupService.calculateFYC(cand.Id);
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch completed');
    }
}
```

## Testing

**Always achieve 100% code coverage** (minimum 75% required):

```apex
@IsTest
private class CandidateServiceTest {
    @TestSetup
    static void setupTestData() {
        List<Candidate__c> candidates = new List<Candidate__c>();
        for (Integer i = 0; i < 200; i++) {
            candidates.add(new Candidate__c(
                First_Name__c = 'Test',
                Last_Name__c = 'Candidate ' + i,
                Stage__c = 'CI-First',
                Total_FYC__c = i * 1000
            ));
        }
        insert candidates;
    }
    
    @IsTest
    static void testUpdateCandidateStage_Positive() {
        // Arrange
        List<Candidate__c> candidates = [SELECT Id FROM Candidate__c];
        Set<Id> candidateIds = new Map<Id, Candidate__c>(candidates).keySet();
        
        // Act
        Test.startTest();
        CandidateService.updateCandidateStage(candidateIds, 'Align-Second');
        Test.stopTest();
        
        // Assert
        List<Candidate__c> updatedCandidates = [
            SELECT Id, Stage__c 
            FROM Candidate__c 
            WHERE Id IN :candidateIds
        ];
        
        for (Candidate__c cand : updatedCandidates) {
            Assert.areEqual('Align-Second', cand.Stage__c, 'Stage should be updated');
        }
    }
    
    @IsTest
    static void testBulkOperation() {
        // Test with 200 records
        List<Candidate__c> candidates = [SELECT Id FROM Candidate__c];
        Set<Id> candidateIds = new Map<Id, Candidate__c>(candidates).keySet();
        
        Test.startTest();
        CandidateService.updateCandidateStage(candidateIds, 'Plan-Third');
        Test.stopTest();
        
        List<Candidate__c> updatedCandidates = [SELECT Id FROM Candidate__c];
        Assert.areEqual(200, updatedCandidates.size(), 'All records should be processed');
    }
}
```

## RecruiterPortal-Specific Patterns

### FYC Rollup Calculations

```apex
public class CandidateFYCRollupService {
    public static Decimal calculateFYC(Id candidateId) {
        List<ALC__c> alcs = [
            SELECT Id, FYC__c
            FROM ALC__c
            WHERE Candidate__c = :candidateId
            AND Status__c = 'Active'
        ];
        
        Decimal totalFYC = 0;
        for (ALC__c alc : alcs) {
            totalFYC += (alc.FYC__c != null ? alc.FYC__c : 0);
        }
        
        return totalFYC;
    }
}
```

### Dashboard Controller Pattern

```apex
@AuraEnabled(cacheable=true)
public static Map<String, Object> getDashboardData(String timeFrame) {
    Map<String, Object> result = new Map<String, Object>();
    
    // Query with date filters
    Date startDate = timeFrame == 'YTD' ? Date.newInstance(Date.today().year(), 1, 1) : Date.today().toStartOfMonth();
    
    List<Interview__c> interviews = [
        SELECT Id, Stage__c, Interview_Date__c
        FROM Interview__c
        WHERE Interview_Date__c >= :startDate
        WITH SECURITY_ENFORCED
    ];
    
    // Aggregate statistics
    result.put('totalInterviews', interviews.size());
    result.put('ciFirstCount', countByStage(interviews, 'CI-First'));
    result.put('alignSecondCount', countByStage(interviews, 'Align-Second'));
    
    return result;
}
```

## Deployment Checklist

Before deploying:
- [ ] Run all Apex tests: `sf apex run test --test-level RunLocalTests`
- [ ] Verify code coverage >= 75%
- [ ] Run Salesforce Code Analyzer: `sf code-analyzer run --severity-threshold 2`
- [ ] Review deployment diff
- [ ] Test in ProdTest sandbox first
- [ ] Update documentation

## Common Pitfalls to Avoid

- ❌ DML/SOQL in loops
- ❌ Hardcoded IDs
- ❌ Missing null checks
- ❌ Not checking CRUD/FLS permissions
- ❌ Using `SELECT *` in queries
- ❌ Not handling bulk operations
- ❌ Ignoring governor limits
- ❌ Not writing test classes

## Resources

- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)
- [Apex Best Practices](https://developer.salesforce.com/wiki/apex_code_best_practices)
- [Governor Limits](https://developer.salesforce.com/docs/atlas.en-us.salesforce_app_limits_cheatsheet.meta/salesforce_app_limits_cheatsheet/)
