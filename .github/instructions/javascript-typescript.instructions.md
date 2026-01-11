---
description: 'JavaScript/TypeScript best practices for RecruiterPortal (LWC, Browser Extensions, MCP Server)'
applyTo: '**/*.js, **/*.ts, lwc/**, chrome-extension-linkedin/**, edge-extension-linkedin/**, mcp-server/**'
---

<!--
Attribution: Adapted from github.com/github/awesome-copilot/instructions/typescript-5-es2022.instructions.md
Customized for RecruiterPortal JavaScript/TypeScript requirements
-->

# JavaScript/TypeScript Best Practices for RecruiterPortal

## Project Context

RecruiterPortal uses JavaScript/TypeScript in:
- **LWC Components:** Lightning Web Components (ES6+ JavaScript)
- **Browser Extensions:** Chrome and Edge extensions for LinkedIn import
- **MCP Server:** Model Context Protocol server (TypeScript)
- **Jest Tests:** Unit tests for LWC components

## General Principles

### Code Style

```javascript
// ✅ GOOD: Use const/let, never var
const MAX_RETRIES = 3;
let retryCount = 0;

// ✅ GOOD: Arrow functions for callbacks
const candidateNames = candidates.map(c => `${c.firstName} ${c.lastName}`);

// ✅ GOOD: Template literals
const greeting = `Hello, ${candidate.firstName}!`;

// ✅ GOOD: Destructuring
const { firstName, lastName, stage } = candidate;
const [first, second, ...rest] = candidates;

// ✅ GOOD: Spread operator
const updatedCandidate = { ...candidate, stage: 'Contracted' };
const allCandidates = [...existingCandidates, ...newCandidates];

// ❌ BAD: var and string concatenation
var name = candidate.firstName + ' ' + candidate.lastName;
```

### Async/Await

```javascript
// ✅ GOOD: Use async/await with error handling
async function getCandidates() {
    try {
        const result = await getCandidatesApex();
        return result;
    } catch (error) {
        console.error('Error fetching candidates:', error);
        throw new Error('Failed to load candidates');
    }
}

// ✅ GOOD: Promise.all for parallel operations
async function loadDashboardData() {
    try {
        const [candidates, interviews, alcs] = await Promise.all([
            getCandidatesApex(),
            getInterviewsApex(),
            getALCsApex()
        ]);
        
        return { candidates, interviews, alcs };
    } catch (error) {
        this.handleError(error);
    }
}

// ❌ BAD: Nested promises
getCandidatesApex().then(result => {
    getInterviewsApex().then(interviews => {
        // Callback hell
    });
});
```

### Error Handling

```javascript
// ✅ GOOD: Specific error handling
async function updateCandidate(candidateId, data) {
    try {
        await updateCandidateApex({ candidateId, data });
        this.showSuccessToast();
    } catch (error) {
        if (error.body?.message?.includes('permission')) {
            this.showPermissionError();
        } else if (error.status === 404) {
            this.showNotFoundError();
        } else {
            this.showGenericError(error.body?.message || 'Unknown error');
        }
    }
}

// ✅ GOOD: Guard clauses
function processCandidate(candidate) {
    if (!candidate) {
        throw new Error('Candidate is required');
    }
    
    if (!candidate.id) {
        throw new Error('Candidate ID is required');
    }
    
    // Main logic here
}

// ❌ BAD: Silent failures
try {
    await someOperation();
} catch (error) {
    // Do nothing
}
```

## LWC JavaScript Patterns

### Component Lifecycle

```javascript
import { LightningElement, api, track, wire } from 'lwc';

export default class MyComponent extends LightningElement {
    // Public properties
    @api recordId;
    @api title;
    
    // Private reactive properties
    candidates = [];
    isLoading = false;
    error = null;
    
    // Computed properties
    get hasCandidates() {
        return this.candidates && this.candidates.length > 0;
    }
    
    get candidateCount() {
        return this.candidates.length;
    }
    
    // Lifecycle hooks
    connectedCallback() {
        // Component inserted into DOM
        this.loadData();
        this.registerListeners();
    }
    
    renderedCallback() {
        // After render (use sparingly)
        if (this.hasRendered) return;
        this.hasRendered = true;
        
        // One-time DOM setup
    }
    
    disconnectedCallback() {
        // Component removed from DOM
        this.unregisterListeners();
    }
    
    errorCallback(error, stack) {
        // Error boundary
        console.error('Component error:', error, stack);
        this.error = error.message;
    }
}
```

### Event Handling

```javascript
// ✅ GOOD: Custom events with detail
handleSave() {
    const saveEvent = new CustomEvent('save', {
        detail: {
            candidateId: this.recordId,
            timestamp: new Date().toISOString()
        },
        bubbles: true,
        composed: true
    });
    
    this.dispatchEvent(saveEvent);
}

// ✅ GOOD: Debounce user input
handleSearchInput(event) {
    clearTimeout(this.searchTimeout);
    
    const searchTerm = event.target.value;
    this.searchTimeout = setTimeout(() => {
        this.performSearch(searchTerm);
    }, 300);
}

// ✅ GOOD: Prevent default and stop propagation when needed
handleLinkClick(event) {
    event.preventDefault();
    event.stopPropagation();
    
    // Custom navigation logic
}
```

### Data Management

```javascript
// ✅ GOOD: Immutable updates
handleCandidateUpdate(updatedCandidate) {
    this.candidates = this.candidates.map(candidate =>
        candidate.Id === updatedCandidate.Id
            ? { ...candidate, ...updatedCandidate }
            : candidate
    );
}

// ✅ GOOD: Filter and transform data
get filteredCandidates() {
    return this.candidates
        .filter(c => c.Stage__c === this.selectedStage)
        .sort((a, b) => a.Last_Name__c.localeCompare(b.Last_Name__c));
}

// ✅ GOOD: Null-safe access
get candidateName() {
    return this.candidate?.First_Name__c 
        ? `${this.candidate.First_Name__c} ${this.candidate.Last_Name__c}`
        : 'Unknown';
}

// ❌ BAD: Direct mutation
this.candidates[0].Stage__c = 'Contracted'; // Doesn't trigger reactivity
```

## Browser Extension Patterns

### Content Script Protection

```javascript
// ✅ GOOD: IIFE guard pattern (REQUIRED for RecruiterPortal extensions)
(function() {
    if (window.__linkedinToSalesforceLoaded) return;
    window.__linkedinToSalesforceLoaded = true;
    
    // Extension code here
    
    // ✅ GOOD: Safe DOM queries
    function getProfileData() {
        const nameElement = document.querySelector('.pv-text-details__left-panel h1');
        const name = nameElement?.textContent?.trim() || '';
        
        if (!name) {
            throw new Error('Unable to find profile name');
        }
        
        return { name };
    }
    
    // ✅ GOOD: Message passing
    chrome.runtime.sendMessage({
        action: 'importCandidate',
        data: getProfileData()
    }, (response) => {
        if (response.success) {
            showSuccessNotification();
        } else {
            showErrorNotification(response.error);
        }
    });
})();
```

### Background Script

```javascript
// ✅ GOOD: Handle messages
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'importCandidate') {
        importToSalesforce(request.data)
            .then(result => sendResponse({ success: true, result }))
            .catch(error => sendResponse({ success: false, error: error.message }));
        
        return true; // Keep message channel open for async response
    }
});

// ✅ GOOD: OAuth flow
async function authenticateWithSalesforce() {
    try {
        const redirectUrl = chrome.identity.getRedirectURL();
        const authUrl = `https://login.salesforce.com/services/oauth2/authorize?response_type=code&client_id=${CLIENT_ID}&redirect_uri=${redirectUrl}`;
        
        const responseUrl = await chrome.identity.launchWebAuthFlow({
            url: authUrl,
            interactive: true
        });
        
        const code = new URL(responseUrl).searchParams.get('code');
        
        if (!code) {
            throw new Error('Authorization failed');
        }
        
        return await exchangeCodeForToken(code);
    } catch (error) {
        console.error('OAuth error:', error);
        throw error;
    }
}
```

## TypeScript for MCP Server

```typescript
// ✅ GOOD: Type definitions
interface Candidate {
    id: string;
    firstName: string;
    lastName: string;
    stage: CandidateStage;
    totalFYC?: number;
}

type CandidateStage = 
    | 'CI-First'
    | 'Align-Second'
    | 'Plan-Third'
    | 'Present-Fourth'
    | 'Contracted';

// ✅ GOOD: Generic functions
function groupBy<T, K extends keyof any>(
    array: T[],
    keyFn: (item: T) => K
): Record<K, T[]> {
    return array.reduce((result, item) => {
        const key = keyFn(item);
        (result[key] = result[key] || []).push(item);
        return result;
    }, {} as Record<K, T[]>);
}

// Usage
const candidatesByStage = groupBy(candidates, c => c.stage);

// ✅ GOOD: Type guards
function isCandidate(obj: any): obj is Candidate {
    return obj 
        && typeof obj.id === 'string'
        && typeof obj.firstName === 'string'
        && typeof obj.lastName === 'string'
        && typeof obj.stage === 'string';
}

// ✅ GOOD: Async type safety
async function fetchCandidates(): Promise<Candidate[]> {
    const response = await fetch('/api/candidates');
    
    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data: unknown = await response.json();
    
    if (!Array.isArray(data) || !data.every(isCandidate)) {
        throw new Error('Invalid candidate data');
    }
    
    return data;
}
```

## Common Patterns

### Utility Functions

```javascript
// ✅ GOOD: Debounce
function debounce(func, delay) {
    let timeoutId;
    return function(...args) {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => func.apply(this, args), delay);
    };
}

// ✅ GOOD: Throttle
function throttle(func, limit) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// ✅ GOOD: Safe JSON parse
function safeJsonParse(json, fallback = null) {
    try {
        return JSON.parse(json);
    } catch (error) {
        console.error('JSON parse error:', error);
        return fallback;
    }
}

// ✅ GOOD: Format currency
function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 2
    }).format(amount);
}
```

## Anti-Patterns to Avoid

```javascript
// ❌ BAD: Using var
var name = 'John';

// ❌ BAD: Modifying parameters
function updateCandidate(candidate) {
    candidate.stage = 'Contracted'; // Mutates original
}

// ❌ BAD: Nested ternaries
const message = isActive ? isNew ? 'New Active' : 'Active' : 'Inactive';

// ❌ BAD: Long function bodies
function processEverything() {
    // 200 lines of code
}

// ❌ BAD: Magic numbers
if (candidates.length > 50) { }

// ✅ GOOD: Use constants
const MAX_CANDIDATE_DISPLAY = 50;
if (candidates.length > MAX_CANDIDATE_DISPLAY) { }

// ❌ BAD: console.log in production
console.log('Debug:', data);

// ✅ GOOD: Use proper logging levels
if (DEBUG_MODE) {
    console.debug('Debug:', data);
}
```

## Code Quality Checklist

- [ ] No `var` declarations (use `const`/`let`)
- [ ] Async/await used instead of raw promises
- [ ] Error handling in all async operations
- [ ] No magic numbers (use named constants)
- [ ] Functions are small and focused (<50 lines)
- [ ] Immutable data patterns used
- [ ] Null-safe access with optional chaining
- [ ] No console.log in production code
- [ ] Event listeners cleaned up in disconnectedCallback
- [ ] IIFE guard pattern in content scripts

## Resources

- [MDN JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [LWC JavaScript](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_javascript)
- [Chrome Extension APIs](https://developer.chrome.com/docs/extensions/reference/)
