# Modal Design Guidelines - Recruiter Portal

## **PERMANENT INSTRUCTIONS FOR MODAL DESIGN**

### **Critical Modal Sizing Standards**
- **Size Class**: Use `slds-modal_small` for display-only modals
- **Width**: Fixed width 420px maximum for simple display modals
- **Height**: Max-height 400px for simple display modals
- **Container**: `max-height: 400px; width: 420px;` for simple modals
- **Content Area**: `max-height: 300px; overflow-y: auto;` for scrolling

### **Exception: Editable Form Modals**
- **Size Class**: `slds-modal_medium` when forms require editing
- **Width**: 600px maximum for editable forms
- **Height**: Max-height 80vh with scrollable content area
- **Container**: `max-height: 80vh; width: 600px;`
- **Content Area**: `max-height: 60vh; overflow-y: auto;` for form scrolling

### **Ultra-Compact Spacing Requirements**
- **Header Padding**: `padding: 6px 12px;` (NO SLDS classes)
- **Content Padding**: `padding: 8px;` (minimal)
- **Footer Padding**: `padding: 4px 8px;` (minimal)
- **Section Margins**: `margin-bottom: 4px;` between sections
- **Box Padding**: `padding: 6px 8px;` for content boxes

### **Typography Standards - SMALLER FONTS**
- **Modal Title**: `font-size: 14px;` (not SLDS classes)
- **Section Headers**: `font-size: 12px; font-weight: 500;`
- **Labels**: `font-size: 10px; color: #666;`
- **Content Text**: `font-size: 11px;`
- **Primary Names**: `font-size: 14px;` maximum

### **Layout Principles - EXTREMELY COMPACT**
1. **Minimal Whitespace**: Eliminate ALL unnecessary spacing
2. **Scrollable When Needed**: Content scrolls, modal size stays fixed
3. **No SLDS Spacing Classes**: Use inline styles for precise control
4. **Grid Layout**: `display: grid; grid-template-columns: 1fr 1fr; gap: 4px;`
5. **Button Sizing**: `size="small"` with `font-size: 11px;`

### **Content Organization - NO WASTED SPACE**
- **Custom Styling**: NO SLDS box/margin classes - use inline styles
- **Tight Sections**: `margin-bottom: 4px;` between sections
- **Compact Headers**: Section titles `font-size: 12px;`
- **Minimal Padding**: `6px 8px` for all content boxes
- **CSS Grid**: Replace SLDS grid with CSS grid for tighter layout

### **Correct Ultra-Compact Implementation**
```html
<!-- CORRECT: Ultra-Compact Modal -->
<section class="slds-modal slds-fade-in-open slds-modal_small">
  <div class="slds-modal__container" style="max-height: 400px; width: 420px;">
    <header style="padding: 6px 12px; border-bottom: 1px solid #e8e8e8;">
      <h2 style="font-size: 14px; margin: 0;">Title</h2>
    </header>
    <div class="slds-modal__content" style="padding: 8px; overflow-y: auto; max-height: 300px;">
      <!-- Ultra-compact sections with 6px-8px padding -->
      <div style="background: #ffffff; border: 1px solid #e8e8e8; padding: 6px 8px; margin-bottom: 4px;">
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 4px;">
          <!-- Content with 10-11px fonts -->
        </div>
      </div>
    </div>
    <footer style="padding: 4px 8px; border-top: 1px solid #e8e8e8;">
      <!-- Compact buttons -->
    </footer>
  </div>
</section>
```

### **Anti-Patterns to Avoid - CRITICAL**
- ❌ ANY SLDS spacing classes (`slds-p-*`, `slds-m-*`)
- ❌ Heights over 400px or widths over 420px
- ❌ Font sizes over 14px in modals
- ❌ `padding: 0.75rem` or other large padding values
- ❌ SLDS box/grid classes (use CSS grid instead)
- ❌ Modals taller than viewport
- ❌ Any margin/padding over 8px

### **Validation Checklist - STRICT REQUIREMENTS**
- [ ] Modal container: `max-height: 400px; width: 420px;`
- [ ] Content area: `max-height: 300px; overflow-y: auto;`
- [ ] Header padding: `6px 12px`
- [ ] Content padding: `8px`
- [ ] Footer padding: `4px 8px`
- [ ] Section padding: `6px 8px`
- [ ] Section margins: `4px` only
- [ ] Font sizes: Title 14px, Headers 12px, Content 11px, Labels 10px
- [ ] NO SLDS spacing classes used anywhere
- [ ] Uses CSS grid instead of SLDS grid

**Last Updated**: October 22, 2025 - CORRECTED VERSION
**Status**: ACTIVE - ZERO TOLERANCE for oversized modals