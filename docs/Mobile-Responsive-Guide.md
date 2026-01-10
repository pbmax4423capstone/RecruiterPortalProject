# Mobile-Responsive Recruiting App Guide

## Overview

The Recruiting Portal has been optimized for mobile devices and tablets, providing a seamless experience across all screen sizes. This guide explains the responsive features and how to use the mobile app.

## What's New? 📱

### Responsive Design
- **Mobile First**: Optimized layouts for phones (< 768px)
- **Tablet Support**: Enhanced layouts for tablets (768px - 1024px)
- **Desktop Compatible**: Maintains full functionality on desktop
- **Touch Optimized**: Larger tap targets (minimum 44px) for easy interaction

### Mobile Applications

#### 1. Recruiter Portal (Updated)
- **Form Factors**: Large and Small
- **Access**: Available on desktop, tablet, and mobile
- **Features**: All existing features now mobile-responsive

#### 2. Recruiter Portal Mobile (New)
- **Form Factors**: Small and Medium (optimized for mobile)
- **Access**: Salesforce Mobile App
- **Features**: Mobile-first interface with simplified navigation

## Responsive Features by Component

### Recruiter Dashboard
**Mobile (< 768px)**
- Single column layout
- Stacked action buttons
- Full-width cards
- Vertical scrolling for lists
- Full-screen modals
- Touch-friendly buttons (44px minimum)

**Tablet (768px - 1024px)**
- Two-column grid layout
- Side-by-side call lists
- Inline action buttons
- Optimized modals (90% width)

**Desktop (> 1024px)**
- Full multi-column layout
- All original features preserved

### Sales Manager Dashboard
**Mobile Features**
- Single-column metrics cards
- Stacked pipeline view
- Full-width kanban board
- Touch-friendly drag & drop

**Tablet Features**
- Two-column metrics grid
- Optimized kanban columns
- Responsive card sizing

### Contract B Pipeline Dashboard
**Mobile Features**
- Vertical metrics stack
- Horizontal scroll for tables
- Single-column charts
- Collapsible sections

**Tablet Features**
- Two-column metrics
- Scrollable pipeline table
- Optimized chart sizes

## Mobile Utility Classes

### Display Utilities
```html
<!-- Show only on mobile -->
<div class="mobile-show">Mobile Only Content</div>

<!-- Hide on mobile -->
<div class="mobile-hide">Desktop Only Content</div>

<!-- Full width on mobile -->
<div class="mobile-full-width">Stretches on mobile</div>

<!-- Center on mobile -->
<div class="mobile-center">Centered on mobile</div>
```

### Responsive Grid
```html
<!-- Stacks on mobile, grid on tablet -->
<div class="responsive-grid-tablet-2">
    <div>Column 1</div>
    <div>Column 2</div>
</div>

<!-- 3 columns on tablet -->
<div class="responsive-grid-tablet-3">
    <div>Col 1</div>
    <div>Col 2</div>
    <div>Col 3</div>
</div>
```

## Accessing the Mobile App

### Salesforce Mobile App
1. Download Salesforce Mobile App from App Store or Google Play
2. Log in with your credentials
3. Navigate to App Launcher
4. Select **"Recruiter Portal Mobile"** or **"Recruiter Portal"**

### Mobile Browser
1. Open browser on mobile device
2. Navigate to your Salesforce org URL
3. Log in with credentials
4. Select Recruiter Portal from App Launcher

## Touch Interactions

### Gestures Supported
- **Tap**: Primary interaction (replaces click)
- **Long Press**: Context menu (where applicable)
- **Swipe**: Horizontal scrolling for tables and activity feeds
- **Pinch**: Zoom on charts (native browser behavior)

### Touch-Friendly Elements
- All buttons minimum 44px x 44px
- Increased padding around tap targets
- Larger form inputs (prevents iOS zoom)
- Prominent active states (visual feedback on tap)

## Mobile-Specific Optimizations

### Performance
- Reduced animation complexity on mobile
- Simplified shadows and gradients
- Optimized scrolling with `-webkit-overflow-scrolling: touch`
- Minimal layout shifts

### Forms
- 16px minimum font size (prevents iOS auto-zoom)
- Full-width inputs on mobile
- Touch-friendly date/time pickers
- Stacked form layouts

### Modals
- Full-screen on phones
- Sticky headers and footers
- Smooth scrolling content area
- Bottom-to-top button order (primary action on top)

### Tables
- Horizontal scroll with momentum
- Minimum width preservation
- Touch-friendly row heights
- Visible scroll indicators

## Breakpoints

```css
/* Mobile Phones */
@media screen and (max-width: 767px) {
  /* Single column layouts */
  /* Full-screen modals */
  /* Stacked buttons */
}

/* Tablets */
@media screen and (min-width: 768px) and (max-width: 1024px) {
  /* 2-3 column layouts */
  /* Optimized modals */
  /* Inline buttons */
}

/* Landscape Mode */
@media screen and (max-width: 1024px) and (orientation: landscape) {
  /* Compact vertical spacing */
  /* Reduced header height */
}

/* Touch Devices */
@media (hover: none) and (pointer: coarse) {
  /* Larger tap targets */
  /* No hover effects */
  /* Active state feedback */
}
```

## Responsive CSS Files

### Component-Specific Styles
- `recruiterDashboard-mobile.css` - Recruiter dashboard mobile styles
- `salesManagerDashboard-mobile.css` - Sales manager mobile styles
- `contractBPipelineDashboard-mobile.css` - Contract B pipeline mobile styles

### Utility Styles
- `mobileUtilities.css` - Universal mobile helper classes and utilities

## Best Practices

### For Users
1. **Orientation**: Use portrait mode on phones, landscape on tablets
2. **Zoom**: Don't zoom - layouts are optimized for each screen size
3. **Scrolling**: Use swipe gestures for horizontal scrolling
4. **Forms**: Tap directly on input fields to activate keyboard
5. **Modals**: Scroll within modal content, don't try to drag down to close

### For Developers
1. **Test on Real Devices**: Emulators don't always represent touch behavior accurately
2. **Use Touch Events**: Consider both click and touch events
3. **Prevent Zoom**: Use 16px minimum font size on inputs
4. **Avoid Fixed Positioning**: Can cause issues on mobile browsers
5. **Test Landscape**: Many users prefer landscape on tablets

## Accessibility

### Mobile Accessibility Features
- Minimum 44px touch targets (WCAG 2.1 Level AAA)
- Increased text contrast on mobile
- Focus indicators visible and clear
- Screen reader compatible
- Keyboard navigation support

### Testing Tools
- iOS VoiceOver
- Android TalkBack
- Chrome DevTools Mobile Emulation
- Lighthouse Mobile Audit

## Troubleshooting

### Issue: App not appearing in mobile app
**Solution**: Ensure "Recruiter Portal Mobile" is assigned to your profile

### Issue: Layout looks wrong on tablet
**Solution**: Force refresh (pull down) or clear cache

### Issue: Buttons too small to tap
**Solution**: Zoom out to see full layout - buttons should be 44px minimum

### Issue: Text is too small
**Solution**: Use device text size settings - app respects system font preferences

### Issue: Modal won't close
**Solution**: Use the X button or Cancel button - swipe to dismiss not supported

### Issue: Table cuts off content
**Solution**: Swipe left/right to scroll table horizontally

## Support

### Getting Help
- **Technical Issues**: Contact IT Support
- **Feature Requests**: Submit through Feedback form in app
- **Training**: See ATS-Training-Program.md for full training materials

### Feedback
We welcome feedback on the mobile experience! Use the feedback form in the app or contact your administrator.

## Version History

### Version 1.0 (Current)
- Initial mobile-responsive implementation
- Support for phones and tablets
- Touch-optimized interactions
- Three responsive breakpoints
- Mobile utility classes
- Separate mobile app configuration

## Future Enhancements

### Planned Features
- Offline mode support
- Progressive Web App (PWA) capabilities
- Native app-like animations
- Biometric authentication
- Push notifications for scheduled calls
- Voice input for notes

---

**Last Updated**: January 2026  
**Maintained By**: Development Team  
**Questions?**: Contact support@capstonepartners.com
