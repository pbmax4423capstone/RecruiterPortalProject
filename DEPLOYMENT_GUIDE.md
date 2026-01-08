# Deployment Guide - Capstone Color Scheme Alignment

**Status:** ✅ Ready for Deployment  
**Date:** January 8, 2026  
**Branch:** `copilot/align-colors-with-capstone-scheme`

## Pre-Deployment Checklist

### ✅ Completed
- [x] All color scheme changes committed and pushed
- [x] Code review passed with no issues
- [x] Documentation created (CAPSTONE_COLOR_SCHEME.md)
- [x] Implementation summary prepared
- [x] 8 CSS files updated with Capstone colors
- [x] 2 documentation files added

### Changes Summary
```
10 files changed, 556 insertions(+), 79 deletions(-)
- 8 CSS files updated
- 2 documentation files added
```

## Deployment Steps

### Step 1: Deploy to ProdTest Sandbox (Testing)

Deploy the LWC components to the ProdTest sandbox for testing:

```bash
sf project deploy start \
  --source-dir force-app/main/default/lwc \
  --target-org ProdTest
```

**Alternative - Deploy specific components:**
```bash
sf project deploy start \
  --source-dir force-app/main/default/lwc/recruiterDashboard \
  --source-dir force-app/main/default/lwc/contractBPipelineDashboard \
  --source-dir force-app/main/default/lwc/interviewLeaderboard \
  --source-dir force-app/main/default/lwc/candidateKanban \
  --source-dir force-app/main/default/lwc/candidateFunnelDashboard \
  --source-dir force-app/main/default/lwc/recruitingDirectorDashboard \
  --source-dir force-app/main/default/lwc/serviceDashboard \
  --source-dir force-app/main/default/lwc/salesManagerKeyMetrics \
  --target-org ProdTest
```

### Step 2: Visual Testing in ProdTest

Test each updated component:

#### Dashboard Components
1. **Recruiter Dashboard** (`/lightning/n/Recruiter_Dashboard`)
   - ✓ Verify metric tile border colors
   - ✓ Check interview type indicators (SI1, SI2, SI3, Career)
   - ✓ Confirm activity metric numbers are blue

2. **Contract B Pipeline Dashboard** (`/lightning/n/Contract_B_Pipeline`)
   - ✓ Verify interview stat badges
   - ✓ Check recruiting metric cards
   - ✓ Confirm progress bar colors

3. **Recruiting Director Dashboard** (`/lightning/n/Recruiting_Director_Dashboard`)
   - ✓ Verify all 7 metric card gradients
   - ✓ Check chart bar colors

4. **Service Dashboard** (`/lightning/n/Service_Dashboard`)
   - ✓ Verify metric value colors
   - ✓ Check chart placeholder borders
   - ✓ Confirm case age indicator bars

#### Specialized Components
5. **Interview Leaderboard** (`/lightning/n/Interview_Leaderboard`)
   - ✓ Verify category cards (5 interview types)
   - ✓ Check summary cards (week/month)
   - ✓ Test dark mode toggle
   - ✓ Confirm badge colors

6. **Candidate Kanban** (`/lightning/n/Candidate_Kanban`)
   - ✓ Verify column count badges
   - ✓ Check card hover states
   - ✓ Confirm avatar gradients
   - ✓ Test contracting badges

7. **Candidate Funnel Dashboard** (`/lightning/n/Candidate_Funnel`)
   - ✓ Verify funnel bar gradients
   - ✓ Check summary card borders

8. **Sales Manager Key Metrics** (`/lightning/n/Sales_Manager_Metrics`)
   - ✓ Verify summary card gradients
   - ✓ Check info note borders

### Step 3: Functional Testing

Verify no functionality has been broken:
- [ ] All components load successfully
- [ ] No console errors in browser developer tools
- [ ] All buttons and links work correctly
- [ ] Data displays properly
- [ ] Hover states respond correctly
- [ ] Click/tap interactions work as expected
- [ ] Mobile responsive design maintained

### Step 4: Browser Compatibility

Test in multiple browsers:
- [ ] Chrome (primary browser)
- [ ] Edge
- [ ] Safari (if applicable)
- [ ] Mobile browsers (iOS Safari, Chrome Mobile)

### Step 5: Accessibility Check

Verify accessibility standards:
- [ ] Color contrast ratios meet WCAG 2.1 AA (minimum 4.5:1)
- [ ] Color is not the only means of conveying information
- [ ] Screen reader compatibility (test with component labels)
- [ ] Keyboard navigation works properly

### Step 6: Production Deployment

Once testing is complete and approved, deploy to production:

```bash
sf project deploy start \
  --source-dir force-app/main/default/lwc \
  --target-org ProductionCapstone
```

**Or deploy all source:**
```bash
sf project deploy start \
  --source-dir force-app \
  --target-org ProductionCapstone
```

### Step 7: Post-Deployment Verification

After production deployment:
1. **Smoke Test** - Quickly verify each component loads
2. **Monitor** - Watch for user feedback in first 24 hours
3. **Document** - Update release notes with color scheme changes

## Quick Deployment Commands

### Option A: Deploy Only CSS Files (Fastest)
```bash
# ProdTest
sf project deploy start \
  --metadata LightningComponentBundle:recruiterDashboard,contractBPipelineDashboard,interviewLeaderboard,candidateKanban,candidateFunnelDashboard,recruitingDirectorDashboard,serviceDashboard,salesManagerKeyMetrics \
  --target-org ProdTest

# Production
sf project deploy start \
  --metadata LightningComponentBundle:recruiterDashboard,contractBPipelineDashboard,interviewLeaderboard,candidateKanban,candidateFunnelDashboard,recruitingDirectorDashboard,serviceDashboard,salesManagerKeyMetrics \
  --target-org ProductionCapstone
```

### Option B: Deploy All LWC (Recommended)
```bash
# ProdTest
sf project deploy start --source-dir force-app/main/default/lwc --target-org ProdTest

# Production
sf project deploy start --source-dir force-app/main/default/lwc --target-org ProductionCapstone
```

## Rollback Procedure

If issues are found after deployment:

### Quick Rollback (Revert CSS Only)
```bash
# Checkout previous state
git checkout 54519c8 -- force-app/main/default/lwc/

# Deploy reverted version
sf project deploy start --source-dir force-app/main/default/lwc --target-org ProductionCapstone
```

### Full Rollback (Revert All Changes)
```bash
# Revert commits
git revert d242e1b 4017d4b 038b061 23bce45 222a2b9

# Deploy
sf project deploy start --source-dir force-app --target-org ProductionCapstone
```

## Deployment Timeline

**Estimated Time:**
- Deploy to ProdTest: 5-10 minutes
- Visual Testing: 30-45 minutes
- Functional Testing: 15-30 minutes
- Production Deployment: 5-10 minutes
- **Total: ~1-2 hours**

## Success Criteria

✅ Deployment is successful when:
1. All 8 components display new Capstone colors
2. No console errors or warnings
3. All functionality works unchanged
4. Visual testing checklist completed
5. Stakeholder approval received

## Support & Documentation

**Technical Documentation:**
- Color Guide: `docs/CAPSTONE_COLOR_SCHEME.md`
- Implementation Summary: `docs/COLOR_SCHEME_IMPLEMENTATION_SUMMARY.md`

**Questions?**
- Contact: Patrick Baker (@pbmax4423capstone)
- Contact: Cole Arnold
- GitHub Issue: Use "color-scheme" label

## Notes

- **No Data Impact:** Changes are CSS-only, no metadata or records affected
- **No Downtime:** Deployment can be done during business hours
- **Reversible:** Changes can be rolled back quickly if needed
- **Low Risk:** Visual changes only, no logic or functionality modified

---

**Ready to Deploy!** 🚀

Execute Step 1 to begin deployment to ProdTest sandbox.
