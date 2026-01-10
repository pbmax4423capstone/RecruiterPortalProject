# Technical Design: Summary Card Metrics Component

**Component:** `summaryCardMetrics`  
**API Version:** 65.0  
**Pattern Reference:** `contractBPipelineDashboard`

---

## 1. COMPONENT STRUCTURE

### Files

```
force-app/main/default/
├── lwc/summaryCardMetrics/
│   ├── summaryCardMetrics.html      (Template)
│   ├── summaryCardMetrics.js        (Controller)
│   ├── summaryCardMetrics.css       (Styles)
│   └── summaryCardMetrics.js-meta.xml (Metadata)
└── classes/
    ├── SummaryCardMetricsController.cls
    ├── SummaryCardMetricsController.cls-meta.xml
    ├── SummaryCardMetricsControllerTest.cls
    └── SummaryCardMetricsControllerTest.cls-meta.xml
```

---

## 2. HTML TEMPLATE DESIGN

**Structure:**

- 6-column grid using `slds-grid slds-wrap slds-gutters`
- Each card: `slds-col slds-size_1-of-6` (desktop), responsive on mobile
- Static HTML `<table>` with 3 columns × 6 rows
- Informational note with light blue background

**Responsive Breakpoints:**

- Desktop (≥1024px): 6 cards in 1 row
- Tablet (768-1023px): CSS wraps to 3 per row
- Mobile (<768px): Stacks vertically

---

## 3. JAVASCRIPT MODULE DESIGN

**Mock Data:**

```javascript
mockMetrics = [
  { label: "Total Candidates", value: 24, variant: "summary-total" },
  { label: "Upcoming Interviews", value: 8, variant: "summary-warning" },
  { label: "Active Pipeline", value: 12, variant: "summary-info" },
  { label: "On Contract B", value: 3, variant: "summary-purple" },
  { label: "Hired This Month", value: 5, variant: "summary-success" },
  {
    label: "Interview Rate",
    value: 85,
    variant: "summary-rate",
    isPercentage: true
  }
];
```

**Event Handler:**

```javascript
handleCardClick(event) {
    const label = event.currentTarget.dataset.label;
    const value = event.currentTarget.dataset.value;

    // Phase 1: Log only
    console.log('Card clicked:', { label, value });

    // Fire custom event for Phase 2 filtering
    this.dispatchEvent(new CustomEvent('cardclick', {
        detail: { label, value },
        bubbles: true,
        composed: true
    }));
}
```

---

## 4. CSS ARCHITECTURE

**Extend Existing Gradients:**

```css
.summary-total {
  background: linear-gradient(135deg, #0176d3, #032d60);
}
.summary-warning {
  background: linear-gradient(135deg, #f39c12, #b37209);
}
.summary-info {
  background: linear-gradient(135deg, #06a59a, #014d48);
}
.summary-purple {
  background: linear-gradient(135deg, #9b59b6, #6c3483);
}
.summary-success {
  background: linear-gradient(135deg, #2e844a, #194e2e);
}
.summary-rate {
  background: linear-gradient(135deg, #0176d3, #9b59b6);
}
```

**Hover Effects:**

```css
.summary-card:hover {
  cursor: pointer;
  transform: scale(1.02);
  transition: transform 0.2s ease;
}
```

---

## 5. APEX CONTROLLER STUB

```apex
public with sharing class SummaryCardMetricsController {
  // Phase 2: Implement real data queries
  // Pattern: Follow RecruiterDashboardController.getCandidateStats()
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> getMetrics() {
    // TODO Phase 2: Query Candidate__c, Interview__c
    // Return: { totalCandidates: 24, upcomingInterviews: 8, ... }
    return new Map<String, Object>();
  }
}
```

---

## 6. METADATA CONFIGURATION

```xml
<apiVersion>65.0</apiVersion>
<isExposed>true</isExposed>
<targets>
    <target>lightning__AppPage</target>
    <target>lightning__RecordPage</target>
    <target>lightning__HomePage</target>
</targets>
```

---

## 7. DEPLOYMENT

**Validation Command:**

```bash
sfdx force:source:deploy --checkonly --targetusername patrickbakeradmin2@financialguide.com.prodtest --sourcepath force-app/main/default/lwc/summaryCardMetrics,force-app/main/default/classes/SummaryCardMetricsController*
```

**Deployment Order:**

1. Recruiting Sandbox (development)
2. ProdTest Sandbox (validation)
3. Production (Phase 2)

---

## 8. PHASE 2 INTEGRATION POINTS

**Wire Service (commented out in Phase 1):**

```javascript
// Phase 2: Uncomment and connect to Apex
// import getMetrics from '@salesforce/apex/SummaryCardMetricsController.getMetrics';
// @wire(getMetrics) wiredMetrics({ data, error }) { ... }
```

**Filter Event Subscriber:**

- Parent dashboard component subscribes to `cardclick` event
- Filters Pipeline Details table based on event payload

---

**HANDOFF STATUS:** ✅ READY FOR PHASE 3 (IMPLEMENTATION)
