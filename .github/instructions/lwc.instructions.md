---
description: 'Lightning Web Components (LWC) development guidelines for RecruiterPortal'
applyTo: 'force-app/main/default/lwc/**'
---

<!-- 
Attribution: Adapted from github.com/github/awesome-copilot/instructions/lwc.instructions.md
Customized for RecruiterPortal project requirements
-->

# LWC Development for RecruiterPortal

## Project-Specific Context

RecruiterPortal uses Lightning Web Components for:
- **Recruiter Dashboard** - Interview statistics and metrics
- **Contract B Pipeline Dashboard** - Contract lifecycle tracking with YTD metrics
- **Candidate Record View** - Auto-refresh with CDC subscription
- **Kanban Boards** - Candidate and career contracting pipelines
- **Dark Mode Support** - Lightning Message Service for theme switching

**Existing Components:**
- `recruiterDashboard`
- `contractBPipelineDashboard`
- `candidateRecordView`
- `candidateKanban`
- `portalHeaderNew` (dark mode publisher)
- `salesManagerActivity`
- `interviewLeaderboard`

## Component Structure

Each LWC resides in its own folder under `force-app/main/default/lwc/`:

```
lwc/
├── myComponent/
│   ├── myComponent.html       # Template
│   ├── myComponent.js          # Controller
│   ├── myComponent.css         # Styles
│   ├── myComponent.js-meta.xml # Metadata
│   └── __tests__/
│       └── myComponent.test.js # Jest tests
```

## Core Principles

### 1. Use Lightning Components Over HTML

Always prefer Lightning components for consistency and accessibility:

```html
<!-- ✅ GOOD: Use Lightning components -->
<lightning-button label="Save" variant="brand" onclick={handleSave}></lightning-button>
<lightning-input type="text" label="Name" value={name} onchange={handleNameChange}></lightning-input>
<lightning-combobox label="Stage" options={stageOptions} value={selectedStage}></lightning-combobox>

<!-- ❌ BAD: Plain HTML -->
<button onclick={handleSave}>Save</button>
<input type="text" onchange={handleNameChange} />
```

### 2. Lightning Design System (SLDS)

Use SLDS utility classes with `slds-var-` prefix:

```html
<!-- Spacing -->
<div class="slds-var-m-around_medium slds-var-p-top_large">
    <div class="slds-var-m-bottom_small">Content</div>
</div>

<!-- Layout -->
<div class="slds-grid slds-wrap slds-gutters_small">
    <div class="slds-col slds-size_1-of-2 slds-medium-size_1-of-3">
        <!-- Content -->
    </div>
</div>

<!-- Typography -->
<h2 class="slds-text-heading_medium slds-var-m-bottom_small">Section Title</h2>
<p class="slds-text-body_regular">Description text</p>
```

### 3. Avoid Custom CSS

Use SLDS classes instead of custom CSS:

```html
<!-- ✅ GOOD: SLDS theme classes -->
<div class="slds-theme_success slds-text-color_inverse slds-var-p-around_small">
    Success message
</div>

<!-- ❌ BAD: Custom CSS -->
<div class="custom-success-message">
    Success message
</div>
```

### 4. Reactive Properties

Use reactive properties correctly:

```javascript
import { LightningElement, track, api, wire } from 'lwc';

export default class MyComponent extends LightningElement {
    // @api for public properties
    @api recordId;
    @api title;
    
    // Primitive properties are automatically reactive
    simpleValue = 'initial';
    count = 0;
    
    // Computed properties
    get displayName() {
        return this.name ? `Hello, ${this.name}` : 'Hello, Guest';
    }
    
    // Use @track ONLY for deep object/array mutations
    @track complexData = {
        user: {
            preferences: {
                theme: 'dark'
            }
        }
    };
    
    handleDeepUpdate() {
        // Requires @track
        this.complexData.user.preferences.theme = 'light';
    }
    
    // BETTER: Use immutable patterns (no @track needed)
    regularData = {
        user: { name: 'John' }
    };
    
    handleImmutableUpdate() {
        this.regularData = {
            ...this.regularData,
            user: {
                ...this.regularData.user,
                name: 'Jane'
            }
        };
    }
}
```

### 5. Wire Service for Data Access

Use `@wire` for reactive data fetching:

```javascript
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

const FIELDS = ['Candidate__c.First_Name__c', 'Candidate__c.Last_Name__c', 'Candidate__c.Stage__c'];

export default class CandidateView extends LightningElement {
    @api recordId;
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    candidate;
    
    get candidateName() {
        return this.candidate.data 
            ? `${this.candidate.data.fields.First_Name__c.value} ${this.candidate.data.fields.Last_Name__c.value}`
            : '';
    }
    
    async handleRefresh() {
        await refreshApex(this.candidate);
    }
}
```

### 6. Error Handling

Implement proper error boundaries:

```javascript
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MyComponent extends LightningElement {
    isLoading = false;
    error = null;
    
    async handleAsyncOperation() {
        this.isLoading = true;
        this.error = null;
        
        try {
            const result = await this.performOperation();
            this.showSuccessToast();
        } catch (error) {
            this.error = error;
            this.showErrorToast(error.body?.message || 'An error occurred');
        } finally {
            this.isLoading = false;
        }
    }
    
    showSuccessToast() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Operation completed successfully',
            variant: 'success'
        }));
    }
    
    showErrorToast(message) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'sticky'
        }));
    }
}
```

### 7. Conditional Rendering

Use `lwc:if`, `lwc:elseif`, `lwc:else` (API v58.0+):

```html
<template lwc:if={isLoading}>
    <lightning-spinner alternative-text="Loading..."></lightning-spinner>
</template>
<template lwc:elseif={error}>
    <div class="slds-theme_error slds-text-color_inverse slds-var-p-around_small">
        {error.message}
    </div>
</template>
<template lwc:else>
    <template for:each={items} for:item="item">
        <div key={item.id} class="slds-var-m-bottom_small">
            {item.name}
        </div>
    </template>
</template>
```

## RecruiterPortal-Specific Patterns

### Dark Mode Integration

Components should subscribe to the `DarkModeChannel__c` Lightning Message Service:

```javascript
import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';

export default class MyComponent extends LightningElement {
    @wire(MessageContext)
    messageContext;
    
    isDarkMode = false;
    
    connectedCallback() {
        this.subscribeToMessageChannel();
    }
    
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            DARK_MODE_CHANNEL,
            (message) => this.handleDarkModeChange(message)
        );
    }
    
    handleDarkModeChange(message) {
        this.isDarkMode = message.isDarkMode;
    }
}
```

### Auto-Refresh with CDC

For components that need real-time updates (like `candidateRecordView`):

```javascript
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class MyComponent extends LightningElement {
    subscription = {};
    channelName = '/data/Candidate__ChangeEvent';
    
    connectedCallback() {
        this.registerErrorListener();
        this.handleSubscribe();
    }
    
    handleSubscribe() {
        const messageCallback = (response) => {
            console.log('Received CDC event', response);
            this.refreshData();
        };
        
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            this.subscription = response;
        });
    }
    
    registerErrorListener() {
        onError((error) => {
            console.error('CDC Error:', error);
        });
    }
    
    disconnectedCallback() {
        unsubscribe(this.subscription);
    }
}
```

### Dashboard Controller Pattern

```javascript
import { LightningElement, wire } from 'lwc';
import getDashboardData from '@salesforce/apex/RecruiterDashboardController.getDashboardData';

export default class RecruiterDashboard extends LightningElement {
    timeFrame = 'Current Month';
    
    @wire(getDashboardData, { timeFrame: '$timeFrame' })
    wiredData({ error, data }) {
        if (data) {
            this.processData(data);
        } else if (error) {
            this.handleError(error);
        }
    }
    
    handleTimeFrameChange(event) {
        this.timeFrame = event.target.value;
    }
}
```

## Testing with Jest

Write comprehensive Jest tests for all components:

```javascript
import { createElement } from 'lwc';
import MyComponent from 'c/myComponent';
import getDashboardData from '@salesforce/apex/RecruiterDashboardController.getDashboardData';

// Mock Apex
jest.mock(
    '@salesforce/apex/RecruiterDashboardController.getDashboardData',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

describe('c-my-component', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });
    
    it('renders correctly with data', async () => {
        const mockData = { totalInterviews: 10 };
        getDashboardData.mockResolvedValue(mockData);
        
        const element = createElement('c-my-component', {
            is: MyComponent
        });
        document.body.appendChild(element);
        
        await Promise.resolve();
        
        const dataElement = element.shadowRoot.querySelector('.data-display');
        expect(dataElement.textContent).toBe('10');
    });
    
    it('handles error gracefully', async () => {
        getDashboardData.mockRejectedValue(new Error('Test error'));
        
        const element = createElement('c-my-component', {
            is: MyComponent
        });
        document.body.appendChild(element);
        
        await Promise.resolve();
        
        const errorElement = element.shadowRoot.querySelector('.error-message');
        expect(errorElement).toBeTruthy();
    });
});
```

## Performance Optimization

- **Lazy Loading:** Use dynamic imports for heavy components
- **Debounce Events:** Use debounce/throttle for scroll, resize, input events
- **Efficient Queries:** Fetch only required fields
- **Pagination:** Implement for large data sets
- **Caching:** Use `cacheable=true` for read-only data

## Common Pitfalls

- ❌ Direct DOM manipulation (use `this.template.querySelector()` sparingly)
- ❌ Not cleaning up event listeners in `disconnectedCallback()`
- ❌ Using inline styles instead of SLDS classes
- ❌ Not handling loading and error states
- ❌ Forgetting to use keys in `for:each` loops
- ❌ Over-using `@track` (use immutable patterns instead)

## Deployment Checklist

- [ ] Run Jest tests: `npm run test`
- [ ] Verify test coverage >= 80%
- [ ] Check SLDS compliance
- [ ] Test dark mode support (if applicable)
- [ ] Verify accessibility (ARIA labels, keyboard navigation)
- [ ] Test in ProdTest sandbox
- [ ] Review for performance issues
- [ ] Update component documentation

## Resources

- [LWC Developer Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [Lightning Design System](https://www.lightningdesignsystem.com/)
- [Jest Testing](https://jestjs.io/docs/getting-started)
- [LWC Recipes](https://github.com/trailheadapps/lwc-recipes)
