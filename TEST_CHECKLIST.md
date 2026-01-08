# Testing Checklist - Capstone Color Scheme

**Tester:** _________________  
**Date:** _________________  
**Environment:** ProdTest Sandbox  
**Branch:** copilot/align-colors-with-capstone-scheme

## Pre-Testing Setup

- [ ] Deployed to ProdTest: `sf project deploy start --source-dir force-app/main/default/lwc --target-org ProdTest`
- [ ] Deployment completed successfully
- [ ] Browser: Chrome (latest version)
- [ ] Clear browser cache before testing

## Component Testing

### 1. Recruiter Dashboard
**URL:** `/lightning/n/Recruiter_Dashboard`

**Visual Checks:**
- [ ] Metric tile borders use Capstone colors (blue, orange, green, gold)
- [ ] Interview type indicators display correctly:
  - [ ] SI1 (Align - 2nd): Blue `#0070d2`
  - [ ] SI2 (Plan - 3rd): Green `#2e844a`
  - [ ] SI3 (Optional - 5th): Gold `#f39c12`
  - [ ] Career (Present - 4th): Dark Blue `#003366`
- [ ] Activity metric numbers are Capstone blue `#0066cc`
- [ ] No console errors

**Functional Checks:**
- [ ] All metrics display correct numbers
- [ ] Click on metrics navigates correctly
- [ ] Hover states work properly
- [ ] Data refreshes correctly

**Screenshot:** ☐ Attached

---

### 2. Contract B Pipeline Dashboard
**URL:** `/lightning/n/Contract_B_Pipeline`

**Visual Checks:**
- [ ] Interview stat badges use Capstone colors
- [ ] Recruiting metric cards display correctly:
  - [ ] Contract A: Blue `#0066cc`
  - [ ] Contract B: Green `#2e844a`
  - [ ] Transitions: Orange `#fe9339`
  - [ ] Terminations: Red `#c23934`
- [ ] Progress bars show correct gradient colors
- [ ] No console errors

**Functional Checks:**
- [ ] Pipeline data displays correctly
- [ ] Filters work as expected
- [ ] YTD toggle functions properly
- [ ] Click actions work correctly

**Screenshot:** ☐ Attached

---

### 3. Interview Leaderboard
**URL:** `/lightning/n/Interview_Leaderboard`

**Visual Checks:**
- [ ] Category cards use Capstone gradients:
  - [ ] CI First (Attraction): Blue gradient
  - [ ] Align (SI1): Blue alt gradient
  - [ ] Plan (SI2): Green gradient
  - [ ] Present (Career): Dark blue gradient
  - [ ] Optional (SI3): Gold gradient
- [ ] Summary cards (week/month) display correctly
- [ ] Badge colors match category colors
- [ ] No console errors

**Dark Mode Check:**
- [ ] Toggle dark mode on
- [ ] Colors adjust appropriately
- [ ] Text remains readable
- [ ] Toggle back to light mode

**Functional Checks:**
- [ ] Interview counts accurate
- [ ] Click on categories works
- [ ] Period toggle functions
- [ ] Modal popups work

**Screenshot (Light Mode):** ☐ Attached  
**Screenshot (Dark Mode):** ☐ Attached

---

### 4. Candidate Kanban
**URL:** `/lightning/n/Candidate_Kanban`

**Visual Checks:**
- [ ] Column count badges are Capstone blue `#0066cc`
- [ ] Card hover states show blue border
- [ ] Avatar circles use blue gradient `#003366` to `#0066cc`
- [ ] Contracting badges are blue
- [ ] Action button icons turn blue on hover
- [ ] No console errors

**Functional Checks:**
- [ ] Drag and drop works correctly
- [ ] Cards load properly
- [ ] Click on cards opens details
- [ ] Stage transitions work
- [ ] Filters function correctly

**Screenshot:** ☐ Attached

---

### 5. Candidate Funnel Dashboard
**URL:** `/lightning/n/Candidate_Funnel`

**Visual Checks:**
- [ ] Funnel bars use Capstone blue gradient
- [ ] Summary card borders (green/red) are Capstone colors
- [ ] Conversion metrics display correctly
- [ ] No console errors

**Functional Checks:**
- [ ] Funnel stages expand/collapse
- [ ] Click on stages shows details
- [ ] Filter toggles work
- [ ] Data accuracy verified

**Screenshot:** ☐ Attached

---

### 6. Recruiting Director Dashboard
**URL:** `/lightning/n/Recruiting_Director_Dashboard`

**Visual Checks:**
- [ ] All 7 metric cards use Capstone gradient colors:
  - [ ] Card 1: Blue gradient
  - [ ] Card 2: Red gradient
  - [ ] Card 3: Blue alt gradient
  - [ ] Card 4: Green gradient
  - [ ] Card 5: Orange/gold gradient
  - [ ] Card 6: Blue gradient (reversed)
  - [ ] Card 7: Light blue gradient
- [ ] Chart bars use Capstone blue gradient
- [ ] No console errors

**Functional Checks:**
- [ ] Metrics calculate correctly
- [ ] Click on cards shows details
- [ ] Filter dropdowns work
- [ ] Charts render properly

**Screenshot:** ☐ Attached

---

### 7. Service Dashboard
**URL:** `/lightning/n/Service_Dashboard`

**Visual Checks:**
- [ ] Metric values use Capstone colors:
  - [ ] Default: Blue `#0066cc`
  - [ ] Warning: Orange `#fe9339`
  - [ ] Error: Red `#c23934`
- [ ] Chart placeholder borders are blue
- [ ] Case age bars use correct colors:
  - [ ] Critical: Red `#c23934`
  - [ ] Warning: Gold `#f39c12`
  - [ ] OK: Green `#2e844a`
- [ ] No console errors

**Functional Checks:**
- [ ] Case metrics accurate
- [ ] Links navigate correctly
- [ ] Refresh works properly
- [ ] Dark mode toggle (if present)

**Screenshot:** ☐ Attached

---

### 8. Sales Manager Key Metrics
**URL:** `/lightning/n/Sales_Manager_Metrics`

**Visual Checks:**
- [ ] Summary cards use Capstone gradients:
  - [ ] Total: Blue gradient
  - [ ] Warning: Gold gradient
  - [ ] Info: Blue alt gradient
  - [ ] Success: Green gradient
  - [ ] Rate: Blue-to-gold gradient
- [ ] Info note borders are Capstone blue
- [ ] No console errors

**Functional Checks:**
- [ ] Metrics display correctly
- [ ] Click actions work
- [ ] Hover states function
- [ ] Data refreshes properly

**Screenshot:** ☐ Attached

---

## Cross-Browser Testing

### Chrome
- [ ] All components tested
- [ ] All functionality works
- [ ] No visual issues

### Edge
- [ ] All components tested
- [ ] All functionality works
- [ ] No visual issues

### Safari (if applicable)
- [ ] All components tested
- [ ] All functionality works
- [ ] No visual issues

---

## Accessibility Testing

### Color Contrast
- [ ] Ran WAVE or aXe accessibility checker
- [ ] All color combinations meet WCAG 2.1 AA (4.5:1 minimum)
- [ ] No contrast warnings or errors

### Keyboard Navigation
- [ ] Tab through all interactive elements
- [ ] Focus indicators visible
- [ ] Enter/Space activate buttons
- [ ] Escape closes modals

### Screen Reader
- [ ] Tested with screen reader (NVDA/JAWS/VoiceOver)
- [ ] All labels read correctly
- [ ] Color information supplemented with text
- [ ] Navigation makes sense

---

## Performance Testing

- [ ] Components load within 2 seconds
- [ ] No lag when interacting
- [ ] Smooth animations and transitions
- [ ] Browser memory usage normal

---

## Issues Found

| Component | Issue | Severity | Screenshot |
|-----------|-------|----------|------------|
|           |       |          |            |
|           |       |          |            |
|           |       |          |            |

**Issue Details:**
_Describe any issues found during testing_

---

## Final Approval

**Testing Complete:** ☐ Yes ☐ No  
**Issues Found:** ☐ None ☐ Minor ☐ Major  
**Ready for Production:** ☐ Yes ☐ No ☐ With Fixes  

**Tester Signature:** _________________  
**Date:** _________________  

**Notes:**
_Add any additional observations or comments_

---

## Post-Testing Actions

If testing passed:
- [ ] Update this checklist with results
- [ ] Attach all screenshots
- [ ] Get stakeholder approval
- [ ] Proceed with production deployment

If issues found:
- [ ] Document all issues above
- [ ] Create GitHub issues for tracking
- [ ] Notify development team
- [ ] Retest after fixes

---

**Next Step:** Production Deployment using DEPLOYMENT_GUIDE.md
