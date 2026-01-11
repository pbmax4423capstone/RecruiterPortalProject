---
description: 'Testing best practices for RecruiterPortal - Apex and Jest'
applyTo: '**/*Test.cls, **/*.test.js'
---

<!--
Attribution: Based on github.com/github/awesome-copilot best practices
Customized for RecruiterPortal Salesforce testing
-->

# Testing Best Practices for RecruiterPortal

## Overview

RecruiterPortal requires comprehensive testing:
- **Apex Tests:** 100% code coverage goal (75% minimum)
- **Jest Tests:** 80%+ coverage for LWC components
- **Integration Tests:** Test full user workflows

## Apex Testing

### Test Class Structure

```apex
@IsTest
private class RecruiterDashboardControllerTest {
    @TestSetup
    static void setupTestData() {
        // Create shared test data
        List<Candidate__c> candidates = new List<Candidate__c>();
        for (Integer i = 0; i < 200; i++) {
            candidates.add(new Candidate__c(
                First_Name__c = 'Test',
                Last_Name__c = 'Candidate' + i,
                Stage__c = 'CI-First',
                Total_FYC__c = i * 1000
            ));
        }
        insert candidates;
        
        // Create related records
        List<Interview__c> interviews = new List<Interview__c>();
        for (Candidate__c cand : candidates) {
            interviews.add(new Interview__c(
                Candidate__c = cand.Id,
                Interview_Date__c = Date.today(),
                Stage__c = 'CI-First'
            ));
        }
        insert interviews;
    }
    
    @IsTest
    static void testGetDashboardData_CurrentMonth() {
        // Arrange
        String timeFrame = 'Current Month';
        
        // Act
        Test.startTest();
        Map<String, Object> result = RecruiterDashboardController.getDashboardData(timeFrame);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Result should not be null');
        Assert.areEqual(200, (Integer)result.get('totalCandidates'), 'Should return 200 candidates');
    }
    
    @IsTest
    static void testGetDashboardData_YTD() {
        // Arrange
        String timeFrame = 'YTD';
        
        // Act
        Test.startTest();
        Map<String, Object> result = RecruiterDashboardController.getDashboardData(timeFrame);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Result should not be null');
        Assert.isTrue(result.containsKey('totalCandidates'), 'Should contain totalCandidates');
    }
    
    @IsTest
    static void testBulkOperation_200Records() {
        // Test governor limits with bulk data
        List<Candidate__c> candidates = [SELECT Id FROM Candidate__c];
        Set<Id> candidateIds = new Map<Id, Candidate__c>(candidates).keySet();
        
        Test.startTest();
        RecruiterDashboardController.updateCandidateStage(candidateIds, 'Align-Second');
        Test.stopTest();
        
        List<Candidate__c> updated = [
            SELECT Id, Stage__c 
            FROM Candidate__c 
            WHERE Id IN :candidateIds
        ];
        
        Assert.areEqual(200, updated.size(), 'All 200 records should be updated');
        for (Candidate__c cand : updated) {
            Assert.areEqual('Align-Second', cand.Stage__c, 'Stage should be updated');
        }
    }
    
    @IsTest
    static void testErrorHandling_InvalidInput() {
        Test.startTest();
        try {
            RecruiterDashboardController.getDashboardData(null);
            Assert.fail('Should throw exception for null input');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('Invalid'), 'Should contain error message');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testUserPermissions_NoAccess() {
        // Create user with limited permissions
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@recruiterportal.test',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + DateTime.now().getTime() + '@recruiterportal.test'
        );
        insert testUser;
        
        Test.startTest();
        System.runAs(testUser) {
            try {
                RecruiterDashboardController.getDashboardData('Current Month');
                Assert.fail('Should throw SecurityException');
            } catch (SecurityException e) {
                Assert.isTrue(true, 'SecurityException thrown as expected');
            }
        }
        Test.stopTest();
    }
}
```

### Testing Patterns

**1. Test All Scenarios:**
- ✅ Positive cases (happy path)
- ✅ Negative cases (error conditions)
- ✅ Bulk operations (200+ records)
- ✅ Edge cases (null, empty, boundaries)
- ✅ Permission checks

**2. Use @TestSetup:**
```apex
@TestSetup
static void setupTestData() {
    // Shared data created once per test class
    // Reduces SOQL queries and improves performance
}
```

**3. Test.startTest() and Test.stopTest():**
```apex
Test.startTest();
// Code here gets fresh governor limits
// Resets: SOQL (100), DML (150), CPU time
Test.stopTest();
// Async operations complete here
```

**4. Use Assert Class:**
```apex
// ✅ GOOD: Use Assert class with descriptive messages
Assert.areEqual(expected, actual, 'Candidates should be in CI-First stage');
Assert.isTrue(condition, 'Should have access to records');
Assert.isNotNull(result, 'Result should not be null');

// ❌ BAD: Old deprecated System.assert
System.assertEquals(expected, actual);
```

## Jest Testing for LWC

### Test Structure

```javascript
import { createElement } from 'lwc';
import RecruiterDashboard from 'c/recruiterDashboard';
import getDashboardData from '@salesforce/apex/RecruiterDashboardController.getDashboardData';

// Mock Apex method
jest.mock(
    '@salesforce/apex/RecruiterDashboardController.getDashboardData',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

describe('c-recruiter-dashboard', () => {
    afterEach(() => {
        // Clean up DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear all mocks
        jest.clearAllMocks();
    });
    
    it('renders dashboard with data', async () => {
        // Arrange
        const mockData = {
            totalCandidates: 50,
            ciFirstCount: 10,
            alignSecondCount: 15
        };
        getDashboardData.mockResolvedValue(mockData);
        
        // Act
        const element = createElement('c-recruiter-dashboard', {
            is: RecruiterDashboard
        });
        document.body.appendChild(element);
        
        // Wait for async operations
        await Promise.resolve();
        
        // Assert
        const totalElement = element.shadowRoot.querySelector('.total-candidates');
        expect(totalElement.textContent).toBe('50');
    });
    
    it('handles error from Apex', async () => {
        // Arrange
        const mockError = {
            body: { message: 'Test error' },
            ok: false,
            status: 400
        };
        getDashboardData.mockRejectedValue(mockError);
        
        // Act
        const element = createElement('c-recruiter-dashboard', {
            is: RecruiterDashboard
        });
        document.body.appendChild(element);
        
        await Promise.resolve();
        
        // Assert
        const errorElement = element.shadowRoot.querySelector('.error-message');
        expect(errorElement).toBeTruthy();
        expect(errorElement.textContent).toContain('Test error');
    });
    
    it('updates time frame on selection', () => {
        // Arrange
        const element = createElement('c-recruiter-dashboard', {
            is: RecruiterDashboard
        });
        document.body.appendChild(element);
        
        // Act
        const combobox = element.shadowRoot.querySelector('lightning-combobox');
        combobox.dispatchEvent(new CustomEvent('change', {
            detail: { value: 'YTD' }
        }));
        
        // Assert
        return Promise.resolve().then(() => {
            expect(element.timeFrame).toBe('YTD');
        });
    });
    
    it('shows loading spinner', () => {
        const element = createElement('c-recruiter-dashboard', {
            is: RecruiterDashboard
        });
        element.isLoading = true;
        document.body.appendChild(element);
        
        const spinner = element.shadowRoot.querySelector('lightning-spinner');
        expect(spinner).toBeTruthy();
    });
});
```

### Jest Best Practices

**1. Mock External Dependencies:**
```javascript
// Mock Apex
jest.mock('@salesforce/apex/ControllerName.methodName', ...);

// Mock Lightning Message Service
jest.mock('lightning/messageService', () => ({
    subscribe: jest.fn(),
    unsubscribe: jest.fn(),
    MessageContext: jest.fn()
}));

// Mock Platform Events
jest.mock('lightning/empApi', () => ({
    subscribe: jest.fn(),
    unsubscribe: jest.fn(),
    onError: jest.fn()
}));
```

**2. Test User Interactions:**
```javascript
it('handles button click', () => {
    const element = createElement('c-my-component', { is: MyComponent });
    document.body.appendChild(element);
    
    const button = element.shadowRoot.querySelector('lightning-button');
    button.click();
    
    return Promise.resolve().then(() => {
        // Assert side effects
    });
});
```

**3. Test Conditional Rendering:**
```javascript
it('shows error when data load fails', async () => {
    const mockError = { message: 'Load failed' };
    getDataMethod.mockRejectedValue(mockError);
    
    const element = createElement('c-my-component', { is: MyComponent });
    document.body.appendChild(element);
    
    await Promise.resolve();
    
    const errorDiv = element.shadowRoot.querySelector('.error');
    expect(errorDiv).toBeTruthy();
});
```

## Testing Checklist

### Apex Tests
- [ ] All public/global methods tested
- [ ] Bulk operations tested (200+ records)
- [ ] Error handling tested
- [ ] Permission checks tested
- [ ] Edge cases tested (null, empty, boundaries)
- [ ] Test coverage >= 75% (aim for 100%)
- [ ] All assertions have descriptive messages

### Jest Tests
- [ ] Component renders correctly
- [ ] User interactions tested
- [ ] Apex mocks configured
- [ ] Loading states tested
- [ ] Error states tested
- [ ] Conditional rendering tested
- [ ] Event handling tested
- [ ] Test coverage >= 80%

## Running Tests

### Apex Tests
```bash
# Run all tests
sf apex run test --test-level RunLocalTests --wait 10

# Run specific test class
sf apex run test --class-names RecruiterDashboardControllerTest --wait 10

# Get test results
sf apex get test --test-run-id <id>

# Check coverage
sf apex get test --test-run-id <id> --code-coverage
```

### Jest Tests
```bash
# Run all tests
npm run test

# Run in watch mode
npm run test:unit:watch

# Check coverage
npm run test:unit:coverage

# Run specific test
npm test -- recruiterDashboard
```

## Common Testing Anti-Patterns

### ❌ Bad Practices

```apex
// ❌ Using @SeeAllData=true
@IsTest(SeeAllData=true)
private class MyTest {
    // Depends on org data - fragile
}

// ❌ Not testing bulk
@IsTest
static void testSingleRecord() {
    Candidate__c cand = new Candidate__c();
    insert cand; // Only tests 1 record
}

// ❌ Generic assertions
System.assert(result != null); // What should it be?

// ❌ No error testing
@IsTest
static void testMethod() {
    // Only tests happy path
}
```

### ✅ Good Practices

```apex
// ✅ Create test data
@TestSetup
static void setup() {
    // Create specific test data
}

// ✅ Test bulk operations
@IsTest
static void testBulk() {
    List<Candidate__c> candidates = new List<Candidate__c>();
    for (Integer i = 0; i < 200; i++) {
        candidates.add(new Candidate__c(/* ... */));
    }
    insert candidates;
    // Test with 200 records
}

// ✅ Specific assertions
Assert.areEqual(50, result.size(), 'Should return 50 candidates');

// ✅ Test error handling
@IsTest
static void testError() {
    try {
        myMethod(null);
        Assert.fail('Should throw exception');
    } catch (Exception e) {
        Assert.isTrue(e.getMessage().contains('Invalid'));
    }
}
```

## Resources

- [Apex Testing Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_best_practices.htm)
- [LWC Jest Testing](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.testing)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Salesforce Test Coverage](https://help.salesforce.com/s/articleView?id=sf.code_coverage_best_practices.htm)
