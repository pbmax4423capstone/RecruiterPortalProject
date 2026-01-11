---
description: 'Code review guidelines for RecruiterPortal pull requests'
applyTo: '**'
excludeAgent: ['coding-agent']
---

<!--
Attribution: Adapted from github.com/github/awesome-copilot/instructions/code-review-generic.instructions.md
Customized for RecruiterPortal code review requirements
-->

# Code Review Guidelines for RecruiterPortal

## Review Language

Respond in **English** for all code reviews.

## Review Priorities

### 🔴 CRITICAL (Block merge)

- **Security:** SOQL injection, XSS vulnerabilities, missing CRUD/FLS checks, exposed secrets
- **Correctness:** Logic errors, data corruption risks, incorrect FYC calculations
- **Breaking Changes:** API changes without versioning, removed public methods
- **Governor Limits:** SOQL/DML in loops, unbulkified code, missing pagination

### 🟡 IMPORTANT (Requires discussion)

- **Code Quality:** Missing error handling, no test coverage, duplicated code
- **Test Coverage:** Critical paths without tests, <75% Apex coverage, <80% Jest coverage
- **Performance:** N+1 queries, missing indexes, inefficient algorithms
- **Architecture:** Violations of trigger handler pattern, missing service layer

### 🟢 SUGGESTION (Non-blocking)

- **Readability:** Poor naming, complex logic that could be simplified
- **Optimization:** Performance improvements without functional impact
- **Best Practices:** Minor deviations from conventions
- **Documentation:** Missing JSDoc, unclear comments

## Salesforce-Specific Checks

### Apex Code Review

**Security:**
- [ ] All classes use `with sharing` or document why not
- [ ] CRUD/FLS checked before SOQL/DML (`isAccessible()`, `WITH SECURITY_ENFORCED`)
- [ ] User input escaped (`String.escapeSingleQuotes()`)
- [ ] Bind variables used instead of dynamic SOQL
- [ ] No hardcoded IDs or credentials

**Bulkification:**
- [ ] Code handles collections, not single records
- [ ] No SOQL queries in loops
- [ ] No DML statements in loops
- [ ] Uses Maps for O(1) lookups instead of nested loops

**Testing:**
- [ ] Test class exists for new code
- [ ] @TestSetup creates bulk data (200 records)
- [ ] Tests cover positive, negative, and bulk scenarios
- [ ] Coverage >= 75% (aim for 100%)
- [ ] Uses Assert class methods, not deprecated System.assert

**Governor Limits:**
- [ ] SOQL queries minimized (<100 per transaction)
- [ ] DML statements batched (<150 per transaction)
- [ ] Batch Apex used for >50,000 records
- [ ] SOQL for loops used for large datasets

**Code Quality:**
- [ ] Descriptive naming (PascalCase classes, camelCase methods)
- [ ] Methods <50 lines
- [ ] Proper exception handling
- [ ] Constants for magic numbers
- [ ] JavaDoc comments on public methods

### LWC Code Review

**Component Structure:**
- [ ] Files: .html, .js, .js-meta.xml, .css (if needed), .test.js
- [ ] Uses Lightning components over plain HTML
- [ ] SLDS classes with `slds-var-` prefix
- [ ] Avoids custom CSS unless necessary

**JavaScript:**
- [ ] Uses `const`/`let`, never `var`
- [ ] Async/await with error handling
- [ ] Immutable data patterns (no direct mutations)
- [ ] Optional chaining for null-safe access
- [ ] Event listeners cleaned up in `disconnectedCallback()`

**Data Handling:**
- [ ] @wire used for data fetching
- [ ] `@api` for public properties
- [ ] `@track` only for deep object mutations (prefer immutable patterns)
- [ ] Computed properties for derived data

**Testing:**
- [ ] Jest test file exists
- [ ] Mocks Apex methods
- [ ] Tests rendering, user interactions, error states
- [ ] Coverage >= 80%

**Dark Mode Support (if applicable):**
- [ ] Subscribes to `DarkModeChannel__c`
- [ ] Implements `handleDarkModeChange()`
- [ ] Dark mode styles in CSS

### Integration Points

**Email Workflows:**
- [ ] Uses `{!Contact.FirstName}` syntax (not Lightning syntax)
- [ ] Email templates in `Candidate_Outreach` folder
- [ ] Connected to `Candidate_Stage_Email_Automation` flow

**Browser Extensions:**
- [ ] Content scripts use IIFE guard pattern
- [ ] No `eval()` or `Function()` with user input
- [ ] OAuth tokens from secure storage
- [ ] Validates all user input

## Comment Format

```markdown
**[PRIORITY] Category: Brief title**

Detailed description of the issue or suggestion.

**Why this matters:**
Explanation of the impact.

**Suggested fix:**
[code example if applicable]

**Reference:** [link to docs or standards]
```

### Example Critical Issue

```markdown
**🔴 CRITICAL - Security: SOQL Injection**

Line 45: Concatenating user input directly into SOQL query creates injection vulnerability.

**Why this matters:**
Attacker could manipulate `searchTerm` to access unauthorized records or extract data.

**Suggested fix:**
```apex
// Instead of:
String query = 'SELECT Id FROM Candidate__c WHERE Name = \'' + searchTerm + '\'';

// Use:
String safeTerm = String.escapeSingleQuotes(searchTerm);
String query = 'SELECT Id FROM Candidate__c WHERE Name = \'' + safeTerm + '\'';

// Or better - bind variable:
List<Candidate__c> results = [
    SELECT Id FROM Candidate__c WHERE Name = :searchTerm
];
```

**Reference:** [Apex Security Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_security_best_practices.htm)
```

### Example Important Issue

```markdown
**🟡 IMPORTANT - Testing: Missing Bulk Test**

`CandidateService.updateCandidates()` has no test with 200 records.

**Why this matters:**
Bulk operations can hit governor limits. Need to verify the method handles collections properly.

**Suggested fix:**
```apex
@IsTest
static void testUpdateCandidates_Bulk() {
    List<Candidate__c> candidates = new List<Candidate__c>();
    for (Integer i = 0; i < 200; i++) {
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Candidate' + i,
            Stage__c = 'CI-First'
        ));
    }
    insert candidates;
    
    Test.startTest();
    CandidateService.updateCandidates(candidates);
    Test.stopTest();
    
    Assert.areEqual(200, [SELECT COUNT() FROM Candidate__c]);
}
```
```

### Example Suggestion

```markdown
**🟢 SUGGESTION - Readability: Simplify Stage Validation**

Lines 30-45: Nested if statements make stage validation hard to follow.

**Why this matters:**
Simpler code is easier to maintain and debug.

**Suggested fix:**
```apex
// Instead of nested ifs:
if (stage != null) {
    if (validStages.contains(stage)) {
        if (!stage.equals(oldStage)) {
            // Process
        }
    }
}

// Use guard clauses:
if (stage == null || !validStages.contains(stage)) {
    return;
}

if (stage.equals(oldStage)) {
    return;
}

// Process
```
```

## Review Checklist

### Code Quality
- [ ] Consistent style (run `npm run lint`)
- [ ] Descriptive names (no single letters except loop counters)
- [ ] Functions/methods are small (<50 lines)
- [ ] No code duplication
- [ ] Error handling is appropriate
- [ ] No commented-out code

### Security
- [ ] No sensitive data in code or logs
- [ ] Input validation on all user inputs
- [ ] No SOQL/XSS injection vulnerabilities
- [ ] CRUD/FLS permissions checked
- [ ] Named Credentials used for APIs

### Testing
- [ ] New code has test coverage
- [ ] Tests are well-named and focused
- [ ] Tests cover edge cases
- [ ] Apex >= 75%, Jest >= 80%

### Performance
- [ ] No SOQL/DML in loops
- [ ] Efficient algorithms (no O(n²))
- [ ] Appropriate use of pagination
- [ ] Resource cleanup (event listeners, etc.)

### Architecture
- [ ] Follows RecruiterPortal patterns
- [ ] Proper separation of concerns (Service, Controller, Selector)
- [ ] Trigger handler pattern for triggers
- [ ] Dependencies flow correctly

### Documentation
- [ ] Public APIs documented
- [ ] Complex logic has comments
- [ ] README updated if needed
- [ ] Breaking changes documented

## Project-Specific Patterns

### Expected Patterns
- **FYC Calculations:** Use `CandidateFYCRollupService`
- **Dashboard Controllers:** Use `@AuraEnabled(cacheable=true)` for read operations
- **Email Workflows:** Use classic merge field syntax `{!Contact.FirstName}`
- **Dark Mode:** Subscribe to `DarkModeChannel__c` LMS
- **Auto-Refresh:** Use CDC subscription for real-time updates

### Deployment Flow
1. Test in ProdTest sandbox
2. Run all tests: `sf apex run test --test-level RunLocalTests`
3. Verify coverage >= 75% Apex, >= 80% Jest
4. Run Code Analyzer: `sf code-analyzer run --severity-threshold 2`
5. Deploy to ProductionCapstone

## Resources

- [RecruiterPortal Copilot Instructions](../copilot-instructions.md)
- [Work Coordination Guide](../../WORK_COORDINATION.md)
- [Shared Planning](../../SHARED_PLANNING.md)
- [Apex Best Practices](https://developer.salesforce.com/wiki/apex_code_best_practices)
- [LWC Best Practices](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.create_best_practices)
