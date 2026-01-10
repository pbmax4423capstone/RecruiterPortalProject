# Requirements Specification: Summary Card Metrics Component

**Document Version:** 1.0  
**Date:** December 23, 2025  
**Phase:** 1 - Requirements Extraction  
**Project:** Salesforce Recruiter Portal  
**Component:** summaryCardMetrics (LWC)

---

## 1. OVERVIEW

### 1.1 Purpose

Create a Lightning Web Component that displays 6 key recruiting metrics in a visually appealing summary card format, matching the design and functionality specified in the training card materials.

### 1.2 Source Documents

- Training Card Screenshot: Summary Cards Row (6 metrics)
- Training Card Screenshot: Definitions Table
- Training Card Screenshot: Informational Note
- Existing Pattern: `contractBPipelineDashboard` component

### 1.3 Development Strategy

- **Phase 1:** Mock data implementation for UI/UX validation
- **Phase 2:** Integration with real Salesforce data (out of scope for Phase 1)

---

## 2. FUNCTIONAL REQUIREMENTS

### 2.1 Summary Card Display (FR-001)

**FR-001.1: Six Metric Cards**
The component MUST display exactly 6 summary cards in a horizontal row layout, each containing:

- A large numeric value (primary metric)
- A descriptive label (metric name)
- A color-coded background gradient

**FR-001.2: Card Order**
Cards MUST appear in this exact order (left to right):

1. Total Candidates
2. Upcoming Interviews
3. Active Pipeline
4. On Contract B
5. Hired This Month
6. Interview Rate

**FR-001.3: Card Visual Design**
Each card MUST include:

- Large numeric display (2rem font size, bold weight)
- Small label text (0.75rem font size, 90% opacity)
- Rounded corners (8px border-radius)
- Center-aligned content
- White text color
- Gradient background matching assigned color variant
- Padding: 1rem on all sides

**FR-001.4: Color Assignments**
Each card MUST use the following gradient variant:

- **Total Candidates:** Blue gradient (`.summary-total`) - #0176d3 to #032d60
- **Upcoming Interviews:** Orange gradient (`.summary-warning`) - #f4a024 to #c87400
- **Active Pipeline:** Teal gradient (`.summary-info`) - #06a59a to #024642
- **On Contract B:** Purple gradient (`.summary-purple`) - #8a4dbf to #4a1f6b
- **Hired This Month:** Green gradient (`.summary-success`) - #2e844a to #194e2e
- **Interview Rate:** Custom gradient (`.summary-rate`) - Multi-color blend

### 2.2 Metric Definitions (FR-002)

**FR-002.1: Total Candidates**

- **Description:** All candidates assigned to you
- **Calculation:** Count of all candidate records
- **Mock Value:** 24
- **Data Type:** Integer
- **Format:** Whole number (no decimals)

**FR-002.2: Upcoming Interviews**

- **Description:** Scheduled interviews not yet completed
- **Calculation:** Interviews with status = Scheduled
- **Mock Value:** 8
- **Data Type:** Integer
- **Format:** Whole number (no decimals)

**FR-002.3: Active Pipeline**

- **Description:** Candidates actively in process
- **Calculation:** Excludes Hired and Inactive
- **Mock Value:** 12
- **Data Type:** Integer
- **Format:** Whole number (no decimals)

**FR-002.4: On Contract B**

- **Description:** Agents in probationary period
- **Calculation:** Contract Type = B
- **Mock Value:** 3
- **Data Type:** Integer
- **Format:** Whole number (no decimals)

**FR-002.5: Hired This Month**

- **Description:** Candidates hired in current month
- **Calculation:** Hire Date in current month
- **Mock Value:** 5
- **Data Type:** Integer
- **Format:** Whole number (no decimals)

**FR-002.6: Interview Rate**

- **Description:** Percentage of candidates interviewed
- **Calculation:** Interviewed / Total Candidates
- **Mock Value:** 85%
- **Data Type:** Percentage
- **Format:** Whole number with % symbol (no decimals)

### 2.3 Definitions Table (FR-003)

**FR-003.1: Table Structure**
The component MUST display a static HTML table below the summary cards with:

- 3 columns: Card, Description, Calculation
- 6 data rows (one per metric)
- Column headers with bold text
- Borders around cells
- Alternating row background colors for readability

**FR-003.2: Table Content**
The table MUST contain these exact entries:

| Card                | Description                            | Calculation                        |
| ------------------- | -------------------------------------- | ---------------------------------- |
| Total Candidates    | All candidates assigned to you         | Count of all candidate records     |
| Upcoming Interviews | Scheduled interviews not yet completed | Interviews with status = Scheduled |
| Active Pipeline     | Candidates actively in process         | Excludes Hired and Inactive        |
| On Contract B       | Agents in probationary period          | Contract Type = B                  |
| Hired This Month    | Candidates hired in current month      | Hire Date in current month         |
| Interview Rate      | Percentage of candidates interviewed   | Interviewed / Total Candidates     |

**FR-003.3: Table Styling**

- Full-width table within container
- SLDS-compatible styling
- Responsive design (stacks on mobile if needed)
- Minimum readable font size (0.875rem)

### 2.4 Informational Note (FR-004)

**FR-004.1: Note Display**
The component MUST display an informational note below the definitions table containing:

- An information icon (SLDS utility icon or emoji)
- The exact text: "Click on any summary card to filter the Pipeline Details table to show only those records."

**FR-004.2: Note Styling**

- Light blue background (info theme)
- Padding: 0.75rem
- Border-radius: 4px
- Icon positioned to the left of text
- Horizontal layout (icon + text inline)

### 2.5 Interactive Behavior (FR-005)

**FR-005.1: Click Handler**
Each summary card MUST be clickable and trigger a custom event when clicked.

**FR-005.2: Event Specification**
When a card is clicked, the component MUST dispatch a `CustomEvent` with:

- **Event Name:** `cardclick`
- **Event Payload:**
  ```javascript
  {
    label: String,  // e.g., "Total Candidates"
    value: Number   // e.g., 24 or 85 (for 85%)
  }
  ```

**FR-005.3: Visual Feedback**
Cards SHOULD provide hover feedback:

- Cursor changes to pointer
- Slight scale transform (1.02x) on hover
- Smooth transition (0.2s)

**FR-005.4: Phase 1 Behavior**
In Phase 1, clicking a card MUST:

- Fire the `cardclick` event
- Log the event payload to browser console
- NOT implement actual filtering (deferred to Phase 2)

### 2.6 Responsive Layout (FR-006)

**FR-006.1: Desktop Layout**
On screens ≥1024px wide:

- 6 cards displayed in a single horizontal row
- Each card occupies 1/6 of available width (using `slds-size_1-of-6`)
- Cards have equal height

**FR-006.2: Tablet Layout**
On screens 768px - 1023px wide:

- Cards wrap to 2 rows of 3 cards each
- Each card occupies 1/3 of available width (using `slds-size_1-of-3`)

**FR-006.3: Mobile Layout**
On screens <768px wide:

- Cards stack vertically
- Each card occupies full width (using `slds-size_1-of-1`)
- Maintain spacing between cards

---

## 3. NON-FUNCTIONAL REQUIREMENTS

### 3.1 Performance (NFR-001)

**NFR-001.1: Initial Load Time**
Component MUST render within 500ms of page load (with mock data).

**NFR-001.2: Click Response**
Click handlers MUST respond within 50ms (event dispatch only, no heavy processing).

### 3.2 Code Quality (NFR-002)

**NFR-002.1: Salesforce Standards**

- Follow Salesforce Lightning Web Component best practices
- Use SLDS (Salesforce Lightning Design System) utility classes
- API Version: 65.0
- No deprecated APIs or patterns

**NFR-002.2: Code Structure**

- Clean separation: HTML (template), JavaScript (logic), CSS (styling)
- No inline styles in HTML
- No hard-coded values in CSS (use CSS custom properties where applicable)
- Meaningful variable and method names
- Inline comments for complex logic

**NFR-002.3: Maintainability**

- Mock data easily replaceable with real data queries
- Event handlers extensible for Phase 2 filtering
- CSS classes reusable across similar components
- No magic numbers or undocumented constants

### 3.3 Browser Compatibility (NFR-003)

**NFR-003.1: Supported Browsers**
Component MUST work in:

- Chrome (latest 2 versions)
- Edge (latest 2 versions)
- Safari (latest 2 versions)
- Firefox (latest 2 versions)

**NFR-003.2: Salesforce Compatibility**

- Lightning Experience (not Classic)
- Salesforce Mobile App (responsive design)
- Lightning App Builder (component exposed and configurable)

### 3.4 Visual Consistency (NFR-004)

**NFR-004.1: Design System Compliance**

- Match existing `contractBPipelineDashboard` styling patterns
- Use established gradient color classes
- Consistent spacing, typography, and borders with portal theme
- White text on colored backgrounds maintains WCAG contrast (deferred for Phase 1)

**NFR-004.2: Brand Alignment**

- No custom colors outside approved gradient palette
- Consistent with MassMutual brand guidelines (if applicable)
- Professional, clean, modern aesthetic

### 3.5 Deployment (NFR-005)

**NFR-005.1: Environments**
Component MUST deploy successfully to:

1. Recruiting Sandbox (development)
2. ProdTest Sandbox (validation)
3. Production (final deployment - Phase 2)

**NFR-005.2: Deployment Safety**

- Validation-only deployment MUST pass before actual deployment
- No breaking changes to existing components
- Rollback procedure documented

---

## 4. ACCEPTANCE CRITERIA

### 4.1 Visual Acceptance (AC-001)

**AC-001.1: Summary Cards**

- [ ] All 6 cards render in correct order
- [ ] Each card displays mock value and label
- [ ] Colors match specified gradients exactly
- [ ] Card dimensions and spacing match training card screenshot
- [ ] Text is centered and readable
- [ ] Font sizes match specification (2rem value, 0.75rem label)

**AC-001.2: Definitions Table**

- [ ] Table displays below summary cards
- [ ] 3 columns (Card, Description, Calculation) present
- [ ] 6 data rows with correct text (matches training card exactly)
- [ ] Table borders and spacing match screenshot
- [ ] Column headers are bold and styled correctly

**AC-001.3: Informational Note**

- [ ] Note displays below definitions table
- [ ] Icon and text are present
- [ ] Text reads: "Click on any summary card to filter the Pipeline Details table to show only those records."
- [ ] Background color is light blue (info theme)
- [ ] Padding and border-radius applied correctly

### 4.2 Functional Acceptance (AC-002)

**AC-002.1: Mock Data Display**

- [ ] Total Candidates shows 24
- [ ] Upcoming Interviews shows 8
- [ ] Active Pipeline shows 12
- [ ] On Contract B shows 3
- [ ] Hired This Month shows 5
- [ ] Interview Rate shows 85%

**AC-002.2: Click Behavior**

- [ ] Clicking any card fires `cardclick` event
- [ ] Event payload contains correct `label` and `value`
- [ ] Event payload logs to browser console
- [ ] No JavaScript errors in console
- [ ] Hover effect works (cursor pointer, scale transform)

**AC-002.3: Responsive Behavior**

- [ ] Desktop (≥1024px): 6 cards in 1 row
- [ ] Tablet (768-1023px): 6 cards in 2 rows
- [ ] Mobile (<768px): 6 cards stacked vertically
- [ ] No horizontal scrolling at any breakpoint
- [ ] Cards maintain readability at all sizes

### 4.3 Technical Acceptance (AC-003)

**AC-003.1: Code Structure**

- [ ] Component located at `force-app/main/default/lwc/summaryCardMetrics/`
- [ ] 4 files present: `.html`, `.js`, `.css`, `.js-meta.xml`
- [ ] No syntax errors or linting warnings
- [ ] API version set to 65.0 in meta.xml
- [ ] Component exposed for Lightning App Builder

**AC-003.2: Stub Controller**

- [ ] Apex class created: `SummaryCardMetricsController.cls`
- [ ] Test class created: `SummaryCardMetricsControllerTest.cls`
- [ ] `@AuraEnabled` method signature defined
- [ ] Inline comments document Phase 2 implementation
- [ ] Test class provides 75%+ coverage (placeholder)

**AC-003.3: Deployment Validation**

- [ ] `sfdx force:source:deploy --checkonly` passes
- [ ] No deployment warnings or errors
- [ ] Component appears in Lightning App Builder
- [ ] Component renders correctly when added to app page
- [ ] No conflicts with existing components

### 4.4 Documentation Acceptance (AC-004)

**AC-004.1: Phase 2 Handoff Document**

- [ ] Document lists TBD items (real queries, filtering, wire service)
- [ ] References existing controller patterns to follow
- [ ] Documents event integration approach
- [ ] Includes test plan for real data validation

**AC-004.2: Deployment Guide**

- [ ] Sandbox deployment steps documented
- [ ] Validation commands provided
- [ ] Manual QA checklist included
- [ ] Rollback procedure documented

---

## 5. OUT OF SCOPE (PHASE 2 ITEMS)

### 5.1 Real Data Integration

- ❌ Apex queries against `Candidate__c`, `Interview__c`, `Opportunity` objects
- ❌ Wire service (`@wire`) integration
- ❌ Dynamic metric calculation from Salesforce records
- ❌ User-specific filtering (assigned to current user)
- ❌ Date range filtering (current month calculations)

### 5.2 Pipeline Filtering

- ❌ Actual filtering of Pipeline Details table
- ❌ Event subscriber implementation in parent dashboard
- ❌ Lightning Message Service (LMS) integration
- ❌ Filter state management
- ❌ Clear filter functionality

### 5.3 Advanced Features

- ❌ Configurable metrics via `@api` properties
- ❌ Drill-down navigation to filtered views
- ❌ Export metrics to CSV/Excel
- ❌ Historical trend comparisons
- ❌ Tooltips with additional metric details
- ❌ WCAG 2.1 AA accessibility compliance (ARIA labels, keyboard navigation)

### 5.4 Production Features

- ❌ Error handling for failed Apex queries
- ❌ Loading spinners during data fetch
- ❌ Empty state messaging (0 candidates scenario)
- ❌ Permission-based visibility
- ❌ Audit logging of metric views

---

## 6. ASSUMPTIONS AND CONSTRAINTS

### 6.1 Technical Assumptions

**TA-001: Salesforce Environment**

- SFDX project structure is already established
- Target org: `patrickbakeradmin2@financialguide.com.prodtest` (ProdTest Sandbox)
- Salesforce API version 65.0 is supported
- Lightning Web Components runtime is available

**TA-002: Existing Infrastructure**

- `contractBPipelineDashboard` component CSS is available for reference
- SLDS framework is loaded and available
- Custom objects exist: `Candidate__c`, `Interview__c`, `Opportunity`
- Standard Salesforce navigation APIs are available

**TA-003: Development Tools**

- Salesforce CLI (sfdx) installed and configured
- VS Code with Salesforce Extensions
- Git repository for version control
- Access to Lightning App Builder for manual testing

### 6.2 Business Assumptions

**BA-001: Metric Definitions**

- "Total Candidates" includes ALL candidate records (no status filter)
- "Active Pipeline" definition excludes exactly 2 statuses: Hired and Inactive
- "Interview Rate" calculation uses simple division (no rounding rules specified)
- "Hired This Month" uses current calendar month (not rolling 30 days)
- "Contract Type = B" is a valid field value on relevant object

**BA-002: User Context**

- Component displays metrics for the currently logged-in user
- Users have read access to required objects
- No cross-org or multi-user aggregation required in Phase 1

**BA-003: Data Quality**

- Mock data values (24, 8, 12, 3, 5, 85%) are realistic and representative
- Real data in Phase 2 will have similar value ranges
- Percentage calculations will always result in 0-100% range

### 6.3 Design Assumptions

**DA-001: Visual Design**

- Training card screenshots are the single source of truth
- Pixel-perfect matching is required for card layout
- Gradient colors from existing components are approved for reuse
- No custom branding beyond existing portal styles

**DA-002: User Experience**

- Click behavior is primary interaction (no keyboard shortcuts Phase 1)
- Hover effects are optional but recommended
- No mobile-specific gestures (swipe, pinch) required
- Loading states not required for Phase 1 (mock data is instant)

### 6.4 Constraints

**C-001: Timeline**

- Phase 1 must be complete before Phase 2 can begin
- No parallel development of filtering logic
- Handoff dependencies must be met before proceeding

**C-002: Scope**

- Cannot modify existing components as part of this work
- Cannot change custom object schemas
- Cannot introduce new Salesforce platform features (e.g., Platform Events)

**C-003: Resources**

- Single developer implementation
- No dedicated QA team (manual testing by developer)
- Limited sandbox availability (Recruiting + ProdTest only)

**C-004: Technology**

- Must use Lightning Web Components (not Aura)
- Must use static HTML table (not `lightning-datatable`)
- Must hardcode 6 metrics (not configurable)
- Cannot use third-party JavaScript libraries

---

## 7. DATA DICTIONARY

### 7.1 Mock Data Structure

```javascript
mockMetrics = [
  {
    label: "Total Candidates",
    value: 24,
    variant: "summary-total",
    description: "All candidates assigned to you",
    calculation: "Count of all candidate records"
  },
  {
    label: "Upcoming Interviews",
    value: 8,
    variant: "summary-warning",
    description: "Scheduled interviews not yet completed",
    calculation: "Interviews with status = Scheduled"
  },
  {
    label: "Active Pipeline",
    value: 12,
    variant: "summary-info",
    description: "Candidates actively in process",
    calculation: "Excludes Hired and Inactive"
  },
  {
    label: "On Contract B",
    value: 3,
    variant: "summary-purple",
    description: "Agents in probationary period",
    calculation: "Contract Type = B"
  },
  {
    label: "Hired This Month",
    value: 5,
    variant: "summary-success",
    description: "Candidates hired in current month",
    calculation: "Hire Date in current month"
  },
  {
    label: "Interview Rate",
    value: 85,
    variant: "summary-rate",
    description: "Percentage of candidates interviewed",
    calculation: "Interviewed / Total Candidates",
    isPercentage: true
  }
];
```

### 7.2 Event Payload Structure

```javascript
// cardclick event detail
{
    label: String,        // Metric name (e.g., "Total Candidates")
    value: Number,        // Metric value (e.g., 24)
    variant: String,      // CSS class name (e.g., "summary-total") [optional]
    timestamp: Number     // Event timestamp (Date.now()) [optional]
}
```

### 7.3 Future Data Sources (Phase 2)

**Object: Candidate\_\_c**

- Total Candidates: `COUNT(Id)`
- Active Pipeline: `COUNT(Id WHERE Status__c NOT IN ('Hired', 'Inactive'))`
- Hired This Month: `COUNT(Id WHERE Hire_Date__c = THIS_MONTH)`

**Object: Interview\_\_c**

- Upcoming Interviews: `COUNT(Id WHERE Status__c = 'Scheduled')`
- Interview Rate numerator: `COUNT(DISTINCT Candidate__c WHERE Status__c = 'Completed')`

**Object: Opportunity or Candidate\_\_c**

- On Contract B: `COUNT(Id WHERE Contract_Type__c = 'B')`

---

## 8. RISKS AND MITIGATION

### 8.1 Technical Risks

**RISK-001: CSS Conflicts**

- **Risk:** Gradient class names may conflict with existing components
- **Likelihood:** Low
- **Impact:** Medium
- **Mitigation:** Namespace CSS classes with component prefix if conflicts occur

**RISK-002: Event Bubbling**

- **Risk:** `cardclick` event may not propagate correctly to parent components
- **Likelihood:** Low
- **Impact:** High (breaks Phase 2 filtering)
- **Mitigation:** Test event dispatch in Lightning App Builder, use `bubbles: true, composed: true`

**RISK-003: Responsive Breakpoints**

- **Risk:** SLDS breakpoints may not match all device sizes
- **Likelihood:** Low
- **Impact:** Low
- **Mitigation:** Test on multiple screen sizes, add custom media queries if needed

### 8.2 Requirements Risks

**RISK-004: Ambiguous Calculations**

- **Risk:** Metric calculations not fully defined (e.g., "Interviewed" field unclear)
- **Likelihood:** Medium
- **Impact:** High (incorrect metrics in Phase 2)
- **Mitigation:** Document assumptions, validate with stakeholder before Phase 2

**RISK-005: Training Card Mismatch**

- **Risk:** Screenshots may not reflect latest approved design
- **Likelihood:** Low
- **Impact:** Medium (rework required)
- **Mitigation:** Confirm training card is current, review with stakeholder

### 8.3 Deployment Risks

**RISK-006: Sandbox Data Differences**

- **Risk:** ProdTest may have different data than Recruiting Sandbox
- **Likelihood:** Medium
- **Impact:** Low (Phase 1 uses mock data)
- **Mitigation:** Mock data insulates from environment differences

**RISK-007: Permissions Issues**

- **Risk:** Component may not be visible due to profile/permission restrictions
- **Likelihood:** Low
- **Impact:** Medium
- **Mitigation:** Test with recruiter profile, document required permissions

---

## 9. SUCCESS METRICS

### 9.1 Phase 1 Completion Criteria

- ✅ All acceptance criteria (AC-001 through AC-004) passed
- ✅ Component renders in Lightning App Builder without errors
- ✅ Visual design matches training card pixel-perfect
- ✅ Click events fire correctly with proper payload
- ✅ Deployment validation passes
- ✅ Phase 2 handoff document complete

### 9.2 Quality Gates

- **Code Quality:** No lint errors, follows Salesforce best practices
- **Visual Quality:** Pixel-perfect match with training card screenshots
- **Functional Quality:** All click handlers work, no console errors
- **Documentation Quality:** Phase 2 handoff is clear and actionable

---

## 10. HANDOFF REQUIREMENTS

### 10.1 Deliverables for Phase 2

1. **Component Files:**
   - `force-app/main/default/lwc/summaryCardMetrics/summaryCardMetrics.html`
   - `force-app/main/default/lwc/summaryCardMetrics/summaryCardMetrics.js`
   - `force-app/main/default/lwc/summaryCardMetrics/summaryCardMetrics.css`
   - `force-app/main/default/lwc/summaryCardMetrics/summaryCardMetrics.js-meta.xml`

2. **Apex Stub Files:**
   - `force-app/main/default/classes/SummaryCardMetricsController.cls`
   - `force-app/main/default/classes/SummaryCardMetricsController.cls-meta.xml`
   - `force-app/main/default/classes/SummaryCardMetricsControllerTest.cls`
   - `force-app/main/default/classes/SummaryCardMetricsControllerTest.cls-meta.xml`

3. **Documentation:**
   - Phase 2 Implementation Guide (real data integration steps)
   - Deployment Runbook (Sandbox → ProdTest → Prod)
   - QA Validation Checklist

4. **Test Evidence:**
   - Screenshots of component in Lightning App Builder
   - Browser console logs showing event payloads
   - Responsive layout screenshots (desktop, tablet, mobile)

### 10.2 Prerequisites for Phase 2

- ✅ Phase 1 requirements document approved
- ✅ Component deployed to Recruiting Sandbox
- ✅ Visual design validated by stakeholder
- ✅ Event structure confirmed for filtering integration
- ✅ No blocking defects or technical issues

---

## 11. APPENDIX

### 11.1 Glossary

- **LWC:** Lightning Web Component
- **SLDS:** Salesforce Lightning Design System
- **SFDX:** Salesforce Developer Experience
- **API:** Application Programming Interface
- **TBD:** To Be Determined (Phase 2 items)
- **Mock Data:** Hardcoded sample data for development/testing
- **Wire Service:** Salesforce reactive data binding mechanism

### 11.2 References

- Salesforce LWC Developer Guide: https://developer.salesforce.com/docs/component-library/documentation/en/lwc
- SLDS Design Tokens: https://www.lightningdesignsystem.com/design-tokens/
- Existing Component: `force-app/main/default/lwc/contractBPipelineDashboard`
- Existing Controller: `force-app/main/default/classes/RecruiterDashboardController.cls`

### 11.3 Revision History

| Version | Date       | Author                   | Changes                                            |
| ------- | ---------- | ------------------------ | -------------------------------------------------- |
| 1.0     | 2025-12-23 | Planning Agent (Phase 1) | Initial requirements extraction from training card |

---

**END OF REQUIREMENTS DOCUMENT**

**HANDOFF STATUS:** ✅ READY FOR PHASE 2 (TECHNICAL ARCHITECTURE)

**Next Agent:** Architecture / System Design Agent  
**Recommended Model:** Claude Opus 4.5  
**Next Objective:** Design how the component will be built in Salesforce
