# Shared Planning & Task Board

## 🎯 Current Sprint/Focus

**Sprint:** January 2026
**Focus:** Agent collaboration framework and system stability

---

## 📋 Task Board

### 🔵 In Progress

| ID | Task | Owner | Agent | Priority | Started | ETA | Notes |
|----|------|-------|-------|----------|---------|-----|-------|
| - | - | - | - | - | - | - | No tasks in progress |

### 🟡 Ready to Start

| ID | Task | Owner | Agent | Priority | Dependencies | Notes |
|----|------|-------|-------|----------|--------------|-------|
| 003 | Sales Manager Qualification Dashboard - Apex Controller | Patrick/Agent | Patrick's Agent | High | Task #002 ✅ | **HANDOFF READY:** See HANDOFF-RESEARCH-TO-APEX-2026-01-08.md |
| 004 | Sales Manager Qualification Dashboard - LWC Component | Cole/Agent | Cole's Agent | High | Task #003 | Awaiting Apex controller handoff |
| 005 | Sales Manager Qualification Dashboard - Testing & Deployment | Cole/Agent | Cole's Agent | High | Task #004 | Final integration testing |

### 🔴 Blocked

| ID | Task | Owner | Agent | Blocker | Notes |
|----|------|-------|-------|---------|-------|
| - | - | - | - | - | No blocked tasks |

### 🟢 Completed (Last 10)

| ID | Task | Owner | Agent | Completed | Notes |
|----|------|-------|-------|-----------|-------|
| 002 | Sales Manager Qualification Dashboard - Research & Audit | Patrick/Agent | Research Agent | 2026-01-08 | Handoff document: HANDOFF-RESEARCH-TO-APEX-2026-01-08.md |
| 001 | Created collaborative planning system | Patrick's Agent | Copilot | 2026-01-08 | WORK_COORDINATION.md and SHARED_PLANNING.md |

---

## 📝 Task Details

### How to Use This Board

1. **Add new tasks** to "Ready to Start" section
2. **Move to "In Progress"** when work begins (include your name and agent)
3. **Update "Notes"** column with progress or blockers
4. **Move to "Blocked"** if stuck (explain blocker)
5. **Move to "Completed"** when done (keep last 10 for reference)

### Task ID Format
- Use incremental numbers: 001, 002, 003, etc.
- IDs are never reused

---

## 🚀 Example Tasks (Templates)

### Template: New Feature

```markdown
### Task 042: Add dark mode to Candidate Record View
**Type:** Feature
**Priority:** Medium
**Owner:** Cole Arnold
**Agent:** Cole's Copilot Agent
**Estimated Effort:** 2 hours

#### Description
Implement dark mode support for the candidateRecordView LWC component following the established dark mode pattern.

#### Acceptance Criteria
- [ ] Component subscribes to DarkModeChannel__c
- [ ] Dark mode styles match other components
- [ ] Toggle works without page refresh
- [ ] Tested in ProdTest sandbox

#### Subtasks
- [ ] Add MessageContext wire adapter
- [ ] Implement subscribeToMessageChannel()
- [ ] Add handleDarkModeChange() method
- [ ] Update CSS with dark mode classes
- [ ] Write Jest tests for dark mode toggle
- [ ] Run local tests: `npm run test:unit`
- [ ] Test in ProdTest org
- [ ] Verify test coverage >= 80%

#### Technical Notes
- Reference: `portalHeaderNew` (publisher), `candidateKanban` (subscriber)
- Colors: Use standard palette from copilot-instructions-cole.md
- Target org: `choujifan90@gmail.com.prodtest` for testing

#### Handoff Points
None - self-contained task

#### Files to Modify
- `force-app/main/default/lwc/candidateRecordView/candidateRecordView.js`
- `force-app/main/default/lwc/candidateRecordView/candidateRecordView.html`
- `force-app/main/default/lwc/candidateRecordView/candidateRecordView.css`
```

### Template: Bug Fix

```markdown
### Task 043: Fix email merge field syntax
**Type:** Bug Fix
**Priority:** High
**Owner:** Patrick Baker
**Agent:** Patrick's Copilot Agent
**Estimated Effort:** 30 minutes

#### Description
Email template showing raw merge field code instead of candidate name.

#### Root Cause
Using Lightning syntax in classic text template.

#### Solution
Change `{{{Recipient.FirstName}}}` to `{!Contact.FirstName}`

#### Files to Modify
- `force-app/main/default/email/Candidate_Outreach/[template-name].email`

#### Testing
- Send test email from Salesforce
- Verify name appears correctly

#### Notes
No Jest tests needed (email template only)
```

### Template: Research Task

```markdown
### Task 044: Research CDC implementation for Interview object
**Type:** Research
**Owner:** Cole Arnold
**Agent:** Cole's Copilot Agent
**Estimated Effort:** 1 hour

#### Objective
Investigate how to implement Change Data Capture for Interview__c object to enable real-time dashboard updates.

#### Deliverable
- Document in `docs/CDC-IMPLEMENTATION-PLAN.md`
- Include code examples
- List any limitations or gotchas

#### Research Questions
- [ ] How to enable CDC on custom object?
- [ ] What's the event channel name format?
- [ ] How does subscription work in LWC?
- [ ] Performance implications?

#### Handoff To
Patrick's Agent - for implementation phase
```

### Template: LWC Component with Tests

```markdown
### Task 045: Create new Interview Summary LWC component
**Type:** New Feature
**Priority:** Medium
**Owner:** Cole Arnold
**Agent:** Cole's Copilot Agent
**Estimated Effort:** 4 hours

#### Description
Create a new Lightning Web Component to display interview summary data with filtering and sorting capabilities.

#### Acceptance Criteria
- [ ] Component displays interview data from Apex controller
- [ ] Includes filter by date range
- [ ] Supports sorting by multiple columns
- [ ] Shows loading spinner during data fetch
- [ ] Handles errors gracefully
- [ ] Jest tests pass with >= 80% coverage
- [ ] Works in ProdTest sandbox

#### Development Steps
**Phase 1: Local Development (No Deployment)**
- [ ] Create component structure (HTML, JS, CSS, XML)
- [ ] Write Jest test file (`__tests__/interviewSummary.test.js`)
- [ ] Implement basic rendering logic
- [ ] Run: `npm run test:unit:watch` (keep running)
- [ ] Add @wire mock for controller method
- [ ] Test data rendering with mock data
- [ ] Test filter functionality
- [ ] Test sort functionality
- [ ] Test loading states
- [ ] Test error handling
- [ ] Verify coverage: `npm run test:unit:coverage`
- [ ] Commit with tests: `git commit -m "Add interviewSummary component + tests"`

**Phase 2: Sandbox Integration**
- [ ] Deploy to ProdTest: `sf project deploy start --source-dir "force-app/main/default/lwc/interviewSummary" --target-org ProdTest`
- [ ] Test with real Apex controller
- [ ] Verify @wire integration
- [ ] Test with real user permissions
- [ ] Fix any integration issues
- [ ] Re-run Jest tests: `npm run test:unit`
- [ ] Deploy to Production when ready

#### Files to Create/Modify
- `force-app/main/default/lwc/interviewSummary/interviewSummary.html` (new)
- `force-app/main/default/lwc/interviewSummary/interviewSummary.js` (new)
- `force-app/main/default/lwc/interviewSummary/interviewSummary.css` (new)
- `force-app/main/default/lwc/interviewSummary/interviewSummary.js-meta.xml` (new)
- `force-app/main/default/lwc/interviewSummary/__tests__/interviewSummary.test.js` (new)

#### Testing Strategy
**Jest Unit Tests (Local - Fast):**
- Component renders correctly with mock data
- Filter logic works as expected
- Sort logic works as expected
- Loading spinner shows/hides correctly
- Error messages display properly
- User interactions trigger correct behaviors

**Sandbox Tests (Integration - Slower):**
- Real Apex data displays correctly
- @wire adapters work with actual org data
- Permissions enforced correctly
- Performance acceptable with large datasets

#### Technical Notes
- Use `@wire(getInterviews)` for data fetching
- Mock wire adapter in tests using `@salesforce/sfdx-lwc-jest`
- Reference existing test patterns in `recruiterDashboard/__tests__/`

#### Success Metrics
- Jest tests: >= 80% code coverage
- All tests passing locally before deployment
- Zero console errors in ProdTest
- Response time < 2 seconds for typical data load
```

---

## 🧪 Testing Best Practices

### Jest Testing Workflow

**1. Test-Driven Development (TDD)**
```bash
# Start watch mode
npm run test:unit:watch

# Write test first (it will fail - RED)
# Implement feature (test passes - GREEN)
# Refactor code (test still passes - REFACTOR)
```

**2. What to Test Locally with Jest**
✅ Component rendering
✅ User interactions (clicks, input changes)
✅ Conditional logic (if/else, ternary operators)
✅ Event handlers
✅ @api property behavior
✅ Error handling
✅ Loading states
✅ Data transformation logic

**3. What Requires Sandbox Testing**
⚠️ @wire with real Salesforce data
⚠️ Apex controller integration
⚠️ User permissions and sharing rules
⚠️ Lightning Message Service (real-time)
⚠️ Navigation between pages
⚠️ Platform Events
⚠️ Record edits/creates

**4. Quick Test Commands**
```bash
# Run all tests once
npm run test

# Watch mode (auto-run on file changes)
npm run test:unit:watch

# Check coverage
npm run test:unit:coverage

# Run tests for specific component
npm test -- interviewSummary

# Debug mode
npm run test:unit:debug
```

**5. Coverage Standards**
- **Target:** >= 80% code coverage for all LWC components
- **Minimum:** >= 60% for complex components with extensive Apex integration
- **Goal:** >= 90% for components with heavy business logic

**6. Typical Test Structure**
```javascript
import { createElement } from 'lwc';
import MyComponent from 'c/myComponent';

describe('c-my-component', () => {
    afterEach(() => {
        // Clean up DOM after each test
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders correctly', () => {
        const element = createElement('c-my-component', {
            is: MyComponent
        });
        document.body.appendChild(element);
        
        expect(element).toBeTruthy();
    });

    it('handles user click', () => {
        const element = createElement('c-my-component', {
            is: MyComponent
        });
        document.body.appendChild(element);
        
        const button = element.shadowRoot.querySelector('button');
        button.click();
        
        // Assert expected behavior
    });
});
```

---

## 🔄 Coordination Examples

### Example 1: Sequential Work

```
Task: Implement FYC calculator enhancement

Phase 1 - Research (Cole's Agent)
├─ Research FYC calculation logic
├─ Document current implementation
└─ Propose enhancement plan
    └─ HANDOFF → Patrick's Agent

Phase 2 - Backend (Patrick's Agent)  
├─ Modify CandidateFYCRollupService
├─ Update scheduled job
├─ Write Apex tests
├─ Deploy to ProdTest
└─ HANDOFF → Cole's Agent

Phase 3 - Frontend (Cole's Agent)
├─ Update contractBPipelineDashboard
├─ Write Jest tests for FYC display
├─ Run: npm run test:unit
├─ Modify display logic
└─ Test in ProdTest

Phase 4 - Review (Both)
├─ Code review
├─ Integration testing
└─ Deploy to Production
```

### Example 2: Parallel Work

```
Task: Update all dashboards for Q1 metrics

Team A (Patrick's Agent)
├─ Update RecruiterDashboardController
├─ Update ContractBDashboardController
├─ Write/update Apex tests
└─ Deploy Apex controllers

Team B (Cole's Agent) [Independent]
├─ Update recruiterDashboard LWC
├─ Update contractBPipelineDashboard LWC
├─ Write/update Jest tests
├─ Run: npm run test:unit:coverage
└─ Deploy LWC components

Integration Point: After both complete
├─ Verify all tests pass
└─ Joint testing in ProdTest
```

---

## 📊 Sprint Planning

### Week of January 6-12, 2026

**Goals:**
- Establish collaboration framework ✅
- Document agent capabilities
- Clean up deployment artifacts

**Tasks:**
1. ✅ Create WORK_COORDINATION.md
2. ✅ Create SHARED_PLANNING.md
3. 🔵 Update .gitignore for CSV files
4. 🔵 Document agent handoff protocols
5. 🟡 Create example coordinated workflow

### Week of January 13-19, 2026

**Goals:**
- TBD based on priorities

**Tasks:**
- TBD

---

## 📈 Metrics & Insights

### Collaboration Stats
- **Total tasks completed together:** 1
- **Average handoff time:** TBD
- **Conflict rate:** 0%

### Agent Utilization
- **Patrick's Agent:** 1 task
- **Cole's Agent:** 0 tasks
- **Training Agent:** 0 tasks

---

## 💬 Collaboration Log

### 2026-01-08
**Event:** Created collaborative planning framework
**Participants:** Patrick's Copilot Agent
**Outcome:** WORK_COORDINATION.md and SHARED_PLANNING.md created
**Next Steps:** Begin using for actual work coordination

---

## 🔗 Quick Links

- [Work Coordination Guide](WORK_COORDINATION.md) - Protocols and patterns
- [Cole's Development Guide](COLE_ARNOLD_DEVELOPMENT_GUIDE.md) - Cole-specific info
- [Patrick's Copilot Instructions](.github/copilot-instructions.md) - Patrick's agent config
- [Cole's Copilot Instructions](.github/copilot-instructions-cole.md) - Cole's agent config
- [Project README](README.md) - Project overview

---

## ⚙️ Settings & Preferences

### Notification Preferences
- **Slack channel:** #recruiter-portal-dev (if exists)
- **Update frequency:** Daily or per-task completion
- **Tag format:** @patrick or @cole in messages

### Work Hours
- **Patrick:** [TBD]
- **Cole:** [TBD]
- **Overlap hours:** Use for synchronous coordination

---

## 📚 Learning & Retrospectives

### What's Working Well
- TBD - update after using the system

### What Could Improve
- TBD - update after using the system

### Action Items
- TBD - update after using the system

---

## ❓ FAQ

**Q: How do I know if someone is already working on something?**
A: Check the "In Progress" section at the top of this file.

**Q: What if I need to work on a "protected file"?**
A: Check WORK_COORDINATION.md for the list, coordinate with the other person first.

**Q: Can I modify someone else's task?**
A: Yes, but update the Owner field and add a note explaining the change.

**Q: How often should I update this file?**
A: Update when starting work, when blocked, when completing, or when significant progress is made.

**Q: What if there's a merge conflict?**
A: See "Conflict Resolution" section in WORK_COORDINATION.md.

---

**Last Updated:** 2026-01-08
**Maintained By:** Patrick Baker & Cole Arnold
