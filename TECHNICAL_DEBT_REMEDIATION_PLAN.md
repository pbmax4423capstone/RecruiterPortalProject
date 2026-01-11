# Technical Debt Remediation Plan
**RecruiterPortal Project**  
**Generated:** January 10, 2026  
**Status:** Week 2 - Jest Infrastructure Complete ✅

---

## Executive Summary

### Week 1 Accomplishments ✅
- Removed 79 CSV deployment artifacts from Git tracking
- Removed 24+ debug statements from 7 files (1 Apex, 6 LWC)
- Added ESLint no-console enforcement
- Fixed ALCRelationshipBackfillService_Test
- Deployed all changes to Production (100% success rate)

### Week 2 Progress ✅
- Enhanced jest.config.js with comprehensive LWC support
- Created force-app/test-utils/ with jest-setup.js and lwc-test-helpers.js
- Rewrote candidateKanban test with proper mocking patterns
- **candidateKanban: 10/10 tests passing** ✅

### Remaining Work: 52-75.5 Hours

| Category | Hours | Priority | Status |
|----------|-------|----------|--------|
| Jest Phase 1 (3 critical) | 8-10h | 🔴 High | 🔵 Next |
| Jest Phase 2 (4 service) | 8-10h | 🔴 High | 🟡 Ready |
| Jest Phase 3 (4 supporting) | 8-10h | 🟡 Medium | 🟡 Ready |
| Jest Phase 4 (18 remaining) | 16-20h | 🟡 Medium | 🟡 Ready |
| Debug Statements (5 files) | 1h | 🟢 Low | 🟡 Ready |
| TODO Features (3 items) | 4-6h | 🟡 Medium | 🟡 Ready |
| Documentation (5 components) | 3-4h | 🟡 Medium | 🟡 Ready |
| CSS Compatibility (3 files) | 2-3h | 🟢 Low | 🟡 Ready |
| Deprecated Config | 0.5h | 🟢 Low | 🟡 Ready |
| HTML Inline Styles (2 docs) | 1h | 🟢 Low | 🟡 Ready |
| Apex Test Naming (15 classes) | 1h | 🟢 Low | 🟡 Ready |
| **TOTAL** | **52-75.5h** | - | **8.5% Complete** |

---

## 🎯 Current Jest Test Status

### ✅ Passing (1 suite, 10 tests)
- **candidateKanban** - 10/10 tests passing
  - Component initialization (4 tests)
  - Public API (3 tests)
  - Dark mode (2 tests)
  - Toast events (2 tests)
  - Embedded mode (2 tests)
  - localStorage integration (3 tests)
  - Refresh functionality (3 tests)
  - Navigation (2 tests)
  - Component structure (2 tests)

### ❌ Failing (5 suites, 47 failed tests)
All failures due to **wire adapter connector.connect/disconnect not a function**:

1. **salesManagerContractingKanban** - 5 failures
2. **alcRelationshipMonitor** - 16 failures
3. **candidateInformationEdit** - NavigationMixin undefined
4. **recruiterDashboard** - Jest worker crashed (out of memory, 3,424 lines)
5. **alcRelationshipBackfillWizard** - Worker terminated

**Root Cause:** Old test files use deprecated `registerApexTestWireAdapter` pattern.

**Solution:** Rewrite each test using the new candidateKanban pattern (jest.mock for all Apex + LMS).

---

## 📋 Detailed Technical Debt Categories

### 1. Jest Test Coverage Phase 1 - Critical Components ⭐
**Priority:** 🔴 High  
**Effort:** 8-10 hours  
**Status:** 🔵 Next  
**Ease:** 🟢🟢⚪⚪⚪ (2/5)  
**Impact:** 🎯🎯🎯🎯🎯 (5/5)  
**Risk:** 🔴 High

**Components (3):**
- **recruiterDashboard** (3,424 lines) - Main dashboard, needs refactoring
- **contractBPipelineDashboard** - Contract B lifecycle tracking
- **salesManagerKeyMetrics** - Key metrics display

**Approach:**
1. **recruiterDashboard refactoring required before testing:**
   - Split into smaller sub-components
   - Extract utility functions
   - Separate data fetching from presentation
   - Target: <500 lines per component

2. **Test pattern** (apply candidateKanban pattern):
```javascript
// Mock all Apex with jest.mock (not registerApexTestWireAdapter)
jest.mock('@salesforce/apex/Controller.method', () => {
    return { default: jest.fn() };
}, { virtual: true });

// Mock LMS
jest.mock('lightning/messageService', () => ({
    subscribe: jest.fn(),
    unsubscribe: jest.fn(),
    publish: jest.fn(),
    MessageContext: {}
}), { virtual: true });
```

3. **Focus tests on:**
   - Component renders without errors
   - Public API methods (@api decorated)
   - Event dispatching (ShowToastEvent, CustomEvent)
   - Dark mode toggle
   - localStorage persistence
   - DOM structure validation

**Deliverables:**
- [ ] recruiterDashboard refactored into 3-5 sub-components
- [ ] 15+ tests for recruiterDashboard (post-refactor)
- [ ] 15+ tests for contractBPipelineDashboard
- [ ] 10+ tests for salesManagerKeyMetrics
- [ ] All tests passing locally
- [ ] Code coverage >= 80%

---

### 2. Jest Test Coverage Phase 2 - Service Components
**Priority:** 🔴 High  
**Effort:** 8-10 hours  
**Status:** 🟡 Ready  
**Ease:** 🟢🟢🟢⚪⚪ (3/5)  
**Impact:** 🎯🎯🎯🎯⚪ (4/5)  
**Risk:** 🟡 Medium

**Components (4):**
- **serviceDashboard** - Service team dashboard
- **serviceHomeVibe** - Service home interface
- **scheduledCalls** - Call scheduling
- **scheduledCallsModal** - Call modal

**Test Coverage:**
- Component initialization
- Data loading with mocked Apex
- User interactions (button clicks, form inputs)
- Modal open/close
- Filter logic
- Dark mode support

**Deliverables:**
- [ ] 10+ tests per component (40+ total)
- [ ] All tests passing
- [ ] Coverage >= 80%

---

### 3. Jest Test Coverage Phase 3 - Supporting Components
**Priority:** 🟡 Medium  
**Effort:** 8-10 hours  
**Status:** 🟡 Ready  
**Ease:** 🟢🟢🟢⚪⚪ (3/5)  
**Impact:** 🎯🎯🎯⚪⚪ (3/5)  
**Risk:** 🟡 Medium

**Components (4):**
- **salesManagerContractingKanban** - SM contracting kanban
- **alcRelationshipMonitor** - ALC monitoring
- **candidateInformationEdit** - Candidate editor
- **alcRelationshipBackfillWizard** - ALC backfill wizard

**Note:** These already have failing tests - need rewrite with new pattern.

**Deliverables:**
- [ ] Fix salesManagerContractingKanban (5 current failures)
- [ ] Fix alcRelationshipMonitor (16 current failures)
- [ ] Fix candidateInformationEdit (NavigationMixin issue)
- [ ] Fix alcRelationshipBackfillWizard (worker termination)
- [ ] All 57+ tests passing
- [ ] Coverage >= 80%

---

### 4. Jest Test Coverage Phase 4 - Remaining Components
**Priority:** 🟡 Medium  
**Effort:** 16-20 hours  
**Status:** 🟡 Ready  
**Ease:** 🟢🟢🟢🟢⚪ (4/5)  
**Impact:** 🎯🎯🎯⚪⚪ (3/5)  
**Risk:** 🟢 Low

**Components (18):**
- candidateList
- candidateRecordView
- careerContractingKanban
- contactRecordView
- interviewLeaderboard
- portalHeaderNew
- recentActivity
- salesManagerDashboard
- taskRecordModal
- alcDashboard
- allCandidatesList
- candidateFilters
- candidateNotes
- candidateOverview
- candidateStageHistory
- candidateTimeline
- interviewRecordView
- recruitingDirectorDashboard

**Approach:**
- 8-12 tests per component
- Focus on public API and core functionality
- Use candidateKanban test as template

**Deliverables:**
- [ ] 144-216 tests (8-12 per component × 18)
- [ ] All tests passing
- [ ] Project-wide coverage >= 75%

---

### 5. Remaining Debug Statements
**Priority:** 🟢 Low  
**Effort:** 1 hour  
**Status:** 🟡 Ready  
**Ease:** 🟢🟢🟢🟢🟢 (5/5)  
**Impact:** 🎯🎯⚪⚪⚪ (2/5)  
**Risk:** 🟢 Low

**Files (5):**
1. **serviceHomeVibe.js** - 9 console statements
   - Lines 325, 329, 338 (refresh logging)
   - Lines 369, 391, 396 (modal/task logging)

2. **recruitingDirectorDashboard.js** - 2 console.log
   - Line 116: Sales manager list result
   - Line 141: Metrics loaded for manager

3. **recruiterPortalHeader.js** - 4 console statements
   - Lines 60-61: User info logging
   - Line 116: Create ticket clicked
   - Line 126: Case created successfully

**Implementation:**
```bash
# Remove all console statements
sf project deploy start --source-dir force-app/main/default/lwc/serviceHomeVibe
sf project deploy start --source-dir force-app/main/default/lwc/recruitingDirectorDashboard
sf project deploy start --source-dir force-app/main/default/lwc/recruiterPortalHeader
```

**Deliverables:**
- [ ] Remove 15 console statements from 3 files
- [ ] Deploy to Production
- [ ] Verify ESLint passes

---

### 6. TODO/Incomplete Features
**Priority:** 🟡 Medium  
**Effort:** 4-6 hours (implementation) OR 1 hour (removal)  
**Status:** 🟡 Ready  
**Ease:** 🟢🟢⚪⚪⚪ (2/5) for implementation, 🟢🟢🟢🟢🟢 (5/5) for removal  
**Impact:** 🎯🎯🎯⚪⚪ (3/5)  
**Risk:** 🟡 Medium

**Location:** recruiterDashboard.js (3 TODO comments)

1. **Line 1749:** "TODO: Implement interview detail modal"
2. **Line 2407:** "TODO: Implement actual interview creation logic"
3. **Line 2993:** "TODO: Implement actual ticket creation"

**Options:**

**Option A: Implement features** (4-6 hours)
- Build interview detail modal
- Implement interview creation with Apex
- Implement ticket creation with Apex
- Write Jest tests for new features

**Option B: Remove and document** (1 hour) ⭐ **Recommended**
- Remove incomplete code
- Create GitHub issues for each feature
- Document requirements
- Prioritize for future sprints

**Deliverables:**
- [ ] Choose Option A or B
- [ ] If Option B: Create 3 GitHub issues
- [ ] Remove TODO comments
- [ ] Deploy to Production

---

### 7. Component Documentation
**Priority:** 🟡 Medium  
**Effort:** 3-4 hours  
**Status:** 🟡 Ready  
**Ease:** 🟢🟢🟢🟢⚪ (4/5)  
**Impact:** 🎯🎯🎯🎯⚪ (4/5)  
**Risk:** 🟢 Low

**Components (5):**
1. candidateKanban
2. portalHeaderNew
3. salesManagerDashboard
4. contractBPipelineDashboard
5. recruiterDashboard

**Documentation Template:**
```markdown
# Component Name

## Purpose
Brief description of what the component does.

## Usage
```html
<c-component-name
    property1="value"
    property2="value"
    onEvent={handleEvent}>
</c-component-name>
```

## Features
- Feature 1
- Feature 2

## Public API
### Properties (@api)
- `property1` (String) - Description
- `property2` (Boolean) - Description

### Methods (@api)
- `method1()` - Description
- `method2(param)` - Description

## Wire Adapters
- `@wire(getMethod)` - Description

## Events
- `customevent` - Fired when...

## Dependencies
- Apex: ControllerName
- LMS: ChannelName
- Other components: component-name

## Testing
- 10+ Jest tests in __tests__/
- Run: `npm test -- componentName`
```

**Deliverables:**
- [ ] Create README.md in each component folder
- [ ] Document all 5 critical components
- [ ] Update main README with component index

---

### 8. CSS Browser Compatibility
**Priority:** 🟢 Low  
**Effort:** 2-3 hours  
**Status:** 🟡 Ready  
**Ease:** 🟢🟢🟢🟢⚪ (4/5)  
**Impact:** 🎯🎯⚪⚪⚪ (2/5)  
**Risk:** 🟢 Low

**Files (3):**
- salesManagerDashboard.css
- contractBPipelineDashboard.css
- recruiterDashboard.css

**Issue:** `-webkit-` specific properties (overflow-scrolling, box-sizing)

**Solution:**
```css
/* Before */
-webkit-overflow-scrolling: touch;

/* After - Use standard properties + autoprefixer */
overflow-y: auto;
scroll-behavior: smooth;
```

**Deliverables:**
- [ ] Replace webkit properties with standard equivalents
- [ ] Add autoprefixer to build process if not present
- [ ] Test in Chrome, Firefox, Edge, Safari
- [ ] Deploy to Production

---

### 9. Deprecated TypeScript Config
**Priority:** 🟢 Low  
**Effort:** 0.5 hours  
**Status:** 🟡 Ready  
**Ease:** 🟢🟢🟢🟢🟢 (5/5)  
**Impact:** 🎯⚪⚪⚪⚪ (1/5)  
**Risk:** 🟢 Low

**File:** jsconfig.json

**Issue:** Deprecated `baseUrl` property

**Solution:**
```json
{
    "compilerOptions": {
        "paths": {
            "c/*": ["force-app/main/default/lwc/*"]
        }
    },
    "include": [
        "force-app/**/*",
        "force-app/main/default/lwc/**/*"
    ],
    "exclude": [
        "node_modules",
        "force-app/**/__tests__/**"
    ]
}
```

**Deliverables:**
- [ ] Update jsconfig.json
- [ ] Verify VS Code IntelliSense still works
- [ ] Commit change

---

### 10. HTML Inline Styles
**Priority:** 🟢 Low  
**Effort:** 1 hour  
**Status:** 🟡 Ready  
**Ease:** 🟢🟢🟢🟢🟢 (5/5)  
**Impact:** 🎯🎯⚪⚪⚪ (2/5)  
**Risk:** 🟢 Low

**Files (2):**
- docs/ATS-Training-Program.md
- docs/ATS-Quick-Start-Guide.md

**Issue:** Inline styles in markdown (e.g., `<span style="color: red;">`)

**Solution:**
- Move to external CSS file
- Use markdown native formatting
- Create docs/styles.css for shared styles

**Deliverables:**
- [ ] Extract inline styles to docs/styles.css
- [ ] Update markdown files to reference styles
- [ ] Verify rendering in markdown viewers

---

### 11. Apex Test Naming Convention
**Priority:** 🟢 Low  
**Effort:** 1 hour  
**Status:** 🟡 Ready  
**Ease:** 🟢🟢🟢🟢🟢 (5/5)  
**Impact:** 🎯🎯⚪⚪⚪ (2/5)  
**Risk:** 🟢 Low

**Classes (15):**
All end with `_Test` instead of `Test` (Salesforce convention)

**Solution:**
```bash
# Rename using Salesforce CLI
sf project rename --type ApexClass --from CandidateKanbanController_Test --to CandidateKanbanControllerTest
```

**Deliverables:**
- [ ] Rename 15 test classes (remove underscore)
- [ ] Update @isTest annotations if needed
- [ ] Verify all tests still pass
- [ ] Deploy to Production

---

## 🗓️ 8-Week Roadmap (Sequential)

### ✅ Week 1 (Completed)
- Clean up CSV files
- Remove debug statements
- Deploy to Production

### 🔵 Week 2 (Current - In Progress)
- **Completed:** Jest infrastructure setup ✅
- **Next:** Jest Phase 1 - Critical components testing
- **Hours:** 8-10 hours remaining

### Week 3
- Jest Phase 2 - Service components
- **Hours:** 8-10 hours

### Week 4
- Jest Phase 3 - Fix existing test failures
- **Hours:** 8-10 hours

### Week 5-6
- Jest Phase 4 - Remaining 18 components
- **Hours:** 16-20 hours

### Week 7
- Cleanup: Debug statements, TODOs, CSS, configs
- **Hours:** 4-8 hours

### Week 8
- Documentation & standards
- Final validation & report
- **Hours:** 4-5 hours

---

## 📊 Alternative Prioritization (Impact-First)

If timeline is constrained, prioritize by impact:

1. **🔴 Critical (Week 2-3)**
   - Jest Phase 1 (recruiterDashboard, contractBPipelineDashboard, salesManagerKeyMetrics)
   - Component documentation (5 critical components)
   - **Total:** 11-14 hours

2. **🟡 Important (Week 4-5)**
   - Jest Phase 2 + 3 (Fix existing failures)
   - TODO feature removal (Option B)
   - **Total:** 17-21 hours

3. **🟢 Nice-to-Have (Week 6-8)**
   - Jest Phase 4 (remaining 18 components)
   - Debug statements cleanup
   - CSS compatibility
   - Apex naming conventions
   - **Total:** 20-24 hours

---

## ✅ Success Metrics

### Code Quality
- [ ] Zero console.log/debug statements in production code
- [ ] ESLint passes with no warnings
- [ ] No TODO comments in deployed code
- [ ] All Apex test classes follow naming conventions

### Testing
- [ ] Jest tests: >= 80% code coverage per component
- [ ] All Jest tests passing (0 failures)
- [ ] Apex tests: >= 75% code coverage (maintained)
- [ ] CI/CD: Tests run on every commit

### Documentation
- [ ] README.md for 5 critical components
- [ ] Test utilities documented (lwc-test-helpers.js)
- [ ] Technical debt log updated
- [ ] Deployment guide refreshed

### Browser Compatibility
- [ ] Zero webkit-only CSS properties
- [ ] Tests pass in Chrome, Firefox, Edge, Safari
- [ ] Dark mode works consistently across browsers

---

## 🛠️ Tools & Resources

### Testing
- **Jest:** `npm test -- --coverage`
- **Watch mode:** `npm run test:unit:watch`
- **Specific component:** `npm test -- componentName`
- **Test utilities:** `force-app/test-utils/lwc-test-helpers.js`

### Code Quality
- **ESLint:** `npm run lint`
- **Prettier:** `npm run prettier`
- **Salesforce Code Analyzer:** `sf scanner run --target "force-app/**"`

### Deployment
- **Deploy to Production:** `sf project deploy start --source-dir force-app/main/default/lwc/COMPONENT`
- **Deploy to ProdTest:** Add `--target-org ProdTest` flag
- **Run all Apex tests:** `sf apex run test --test-level RunLocalTests`

### Documentation
- **Component README template:** See Category #7
- **Markdown preview:** VS Code built-in or GitHub
- **JSDoc generation:** Consider adding jsdoc npm package

---

## 📝 Quick Start Guide for Week 2

**Goal:** Fix Jest tests for 3 critical components

**Steps:**

1. **Refactor recruiterDashboard (4-5 hours)**
```bash
# Create sub-components
mkdir -p force-app/main/default/lwc/recruiterDashboardHeader
mkdir -p force-app/main/default/lwc/recruiterDashboardMetrics
mkdir -p force-app/main/default/lwc/recruiterDashboardInterviews

# Extract code into smaller components
# Target: <500 lines per component
```

2. **Write tests for recruiterDashboard (2-3 hours)**
```bash
# Use candidateKanban test as template
cp force-app/main/default/lwc/candidateKanban/__tests__/candidateKanban.test.js \
   force-app/main/default/lwc/recruiterDashboard/__tests__/recruiterDashboard.test.js

# Update mocks and test cases
npm run test:unit:watch -- recruiterDashboard
```

3. **Test contractBPipelineDashboard (1-2 hours)**
```bash
# Create test file
npm test -- --coverage contractBPipelineDashboard
```

4. **Test salesManagerKeyMetrics (1 hour)**
```bash
# Create test file
npm test -- --coverage salesManagerKeyMetrics
```

5. **Verify all tests pass**
```bash
npm test -- --coverage
# Target: >= 80% coverage for new tests
```

---

## 📞 Questions & Support

**Need Help?**
- Refer to: `COLE_ARNOLD_DEVELOPMENT_GUIDE.md`
- Check: `WORK_COORDINATION.md` for active work
- Review: `.github/copilot-instructions.md`

**Resources:**
- [LWC Testing Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.unit_testing_using_jest)
- [Jest Best Practices](https://jestjs.io/docs/getting-started)
- [ESLint Rules](https://eslint.org/docs/rules/)

---

**Last Updated:** January 10, 2026  
**Next Review:** End of Week 2 (After Jest Phase 1 complete)  
**Maintained By:** Patrick Baker & Cole Arnold
