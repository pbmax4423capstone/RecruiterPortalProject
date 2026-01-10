# Mobile-Responsive Quick Test Guide

## Quick Browser Test (5 Minutes)

### Step 1: Open Chrome DevTools

1. Navigate to your Salesforce org
2. Open Recruiter Dashboard
3. Press **F12** (or Cmd+Option+I on Mac)
4. Press **Ctrl+Shift+M** (or Cmd+Shift+M on Mac) to toggle device toolbar

### Step 2: Test Mobile View (iPhone)

1. Select "iPhone 12 Pro" or "iPhone SE" from device dropdown
2. Check:
   - ✅ Action buttons stack vertically
   - ✅ Metrics cards are full width
   - ✅ Charts are readable
   - ✅ Tables scroll horizontally
   - ✅ Buttons are easy to tap (not too small)

### Step 3: Test Tablet View (iPad)

1. Select "iPad" or "iPad Pro" from device dropdown
2. Check:
   - ✅ Metrics show in 3 columns
   - ✅ Charts are medium-sized
   - ✅ Layout looks balanced
   - ✅ Touch targets are adequate

### Step 4: Test Desktop View

1. Click "Responsive" and resize to 1440px width
2. Check:
   - ✅ No regression in desktop layout
   - ✅ All original features still work
   - ✅ Charts at full size

## Test on Real Mobile Device (10 Minutes)

### Option A: Salesforce Mobile App

1. Install Salesforce Mobile app on iOS/Android
2. Login to your org
3. Open "Recruiter Portal" app
4. Navigate through dashboards
5. Test touch interactions

### Option B: Mobile Browser

1. Open Safari (iOS) or Chrome (Android)
2. Navigate to your Salesforce org URL
3. Login and access Recruiter Portal
4. Test functionality

## What to Look For

### ✅ Good Mobile Experience

- All content visible without horizontal scrolling (except tables)
- Text is readable without zooming
- Buttons are easy to tap with finger
- Navigation works smoothly
- Forms are easy to fill out
- Modals fit on screen

### ❌ Issues to Report

- Horizontal scrolling on main page
- Text too small to read
- Buttons too small to tap accurately
- Layout looks broken or overlapping
- Content cut off
- Slow performance

## Common Viewport Sizes to Test

| Device Type   | Width  | Height | Purpose      |
| ------------- | ------ | ------ | ------------ |
| iPhone SE     | 375px  | 667px  | Small phone  |
| iPhone 12 Pro | 390px  | 844px  | Modern phone |
| iPad          | 768px  | 1024px | Tablet       |
| Desktop       | 1440px | 900px  | Large screen |

## Quick Deployment Test

### After Deploying to Sandbox

```bash
# Deploy to ProdTest
sf project deploy start \
  --source-dir force-app/main/default/lwc/recruiterDashboard \
  --source-dir force-app/main/default/lwc/salesManagerDashboard \
  --source-dir force-app/main/default/lwc/contractBPipelineDashboard \
  --source-dir force-app/main/default/applications \
  --target-org ProdTest
```

1. Login to ProdTest sandbox
2. Open Recruiter Dashboard
3. Test on mobile view (use Chrome DevTools)
4. Report any issues before production deployment

## Reporting Issues

If you find any issues:

1. Take a screenshot
2. Note the device/viewport size
3. Describe what's broken
4. Create a GitHub issue with "Mobile" label

## Success Criteria ✅

Mobile implementation is successful when:

- [ ] All dashboards render correctly on mobile (320px-767px)
- [ ] All dashboards render correctly on tablets (768px-1024px)
- [ ] Desktop functionality unchanged (>1024px)
- [ ] Touch interactions work smoothly
- [ ] App accessible via Salesforce Mobile app
- [ ] No critical layout issues
- [ ] Performance is acceptable

## Next Steps

After successful testing:

1. ✅ Mark testing complete in PR
2. Deploy to production
3. Notify users of mobile availability
4. Monitor for feedback
5. Plan future enhancements

## Need Help?

- Check `MOBILE_RESPONSIVE_IMPLEMENTATION.md` for detailed info
- Review CSS changes in component files
- Test in browser first before mobile device
- Report specific issues with screenshots
