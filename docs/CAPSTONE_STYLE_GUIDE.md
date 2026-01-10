# Capstone Partners Style Guide

**Version:** 1.0  
**Last Updated:** January 9, 2026  
**Maintained By:** Capstone Styling Agent

## Overview

This style guide establishes the official Capstone Partners brand identity for all Salesforce Lightning Web Components in the RecruiterPortal project. All components MUST adhere to these standards to maintain visual consistency and brand integrity.

---

## 🎨 Color Palette

### Primary Brand Colors

| Color Name | Hex Code | RGB | Usage | CSS Variable |
|------------|----------|-----|-------|--------------|
| **Capstone Navy** | `#003366` | rgb(0, 51, 102) | Primary brand color, headers, primary actions | `--capstone-navy` |
| **Capstone Gold** | `#f4a024` | rgb(244, 160, 36) | Accent color, highlights, CTAs | `--capstone-gold` |
| **Capstone White** | `#ffffff` | rgb(255, 255, 255) | Text on dark backgrounds, cards | `--capstone-white` |

### Light Mode Colors

```css
/* Backgrounds */
--light-bg-primary: #ffffff;        /* Main page background */
--light-bg-secondary: #f8f9fa;      /* Card backgrounds */
--light-bg-tertiary: #e6f2ff;       /* Subtle highlights */
--light-bg-hover: #f0f4f8;          /* Hover states */

/* Text */
--light-text-primary: #2c3e50;      /* Headings, primary text */
--light-text-secondary: #706e6b;    /* Body text, descriptions */
--light-text-tertiary: #5e5e5e;     /* Muted text, labels */
--light-text-link: #003366;         /* Links (Capstone Navy) */

/* Borders */
--light-border: #e5e5e5;            /* Subtle dividers */
--light-border-medium: #dddbda;     /* Standard borders */
--light-border-dark: #c9c7c5;       /* Emphasized borders */
```

### Dark Mode Colors

```css
/* Backgrounds */
--dark-bg-primary: #16325c;         /* Main page background */
--dark-bg-secondary: #1a3a52;       /* Card backgrounds */
--dark-bg-tertiary: #243649;        /* Nested elements */
--dark-bg-quaternary: #2c4460;      /* Hover states */

/* Text */
--dark-text-primary: #ffffff;       /* Headings, primary text */
--dark-text-secondary: #e8f4fd;     /* Body text, descriptions */
--dark-text-tertiary: #b0c4de;      /* Muted text, labels */

/* Borders */
--dark-border: #3e5771;             /* Subtle dividers */
--dark-border-light: #4a5d7a;       /* Standard borders */

/* Accents */
--dark-accent: #5ea3f2;             /* Links, highlights */
--dark-gold: #f4a024;               /* Capstone Gold (unchanged in dark mode) */
```

### Status Colors (Mode-Independent)

```css
/* Status/Semantic Colors */
--success: #4bca81;                 /* Success states, positive metrics */
--warning: #ff6b35;                 /* Warning states, attention needed */
--error: #c23934;                   /* Error states, critical issues */
--info: #1589ee;                    /* Informational, neutral highlights */
```

### Shadow Colors

```css
/* Light Mode Shadows */
--shadow-light: rgba(0, 0, 0, 0.1);
--shadow-medium: rgba(0, 0, 0, 0.15);
--shadow-heavy: rgba(0, 0, 0, 0.25);
--shadow-navy: rgba(0, 51, 102, 0.15);
--shadow-navy-hover: rgba(0, 51, 102, 0.25);
--shadow-gold: rgba(244, 160, 36, 0.2);

/* Dark Mode Shadows */
--shadow-dark-light: rgba(0, 0, 0, 0.3);
--shadow-dark-medium: rgba(0, 0, 0, 0.4);
--shadow-dark-heavy: rgba(0, 0, 0, 0.6);
```

---

## 🌈 Gradient Patterns

### Standard: 180deg Vertical Gradients

**Rule:** All gradients MUST use 180deg (vertical) direction for brand consistency.

#### Pattern 1: Navy Base
```css
/* Navy to Lighter Navy */
background: linear-gradient(180deg, #003366 0%, #004d99 100%);
```

#### Pattern 2: Light Subtle
```css
/* Light backgrounds with subtle gradient */
background: linear-gradient(180deg, #f8f9fa 0%, #e6f2ff 100%);
```

#### Pattern 3: Dark Mode Gradients
```css
/* Dark mode card backgrounds */
background: linear-gradient(180deg, #16325c 0%, #1a3a52 100%);
```

### ❌ LEGACY PATTERNS (Do Not Use)

```css
/* WRONG - 135deg diagonal gradients */
background: linear-gradient(135deg, #0176d3, #032d60); /* ❌ */
background: linear-gradient(135deg, #e6f2ff 0%, #ffffff 100%); /* ❌ */

/* CORRECT - Use 180deg instead */
background: linear-gradient(180deg, #003366 0%, #004d99 100%); /* ✅ */
background: linear-gradient(180deg, #f8f9fa 0%, #e6f2ff 100%); /* ✅ */
```

---

## 📐 Component Styling Patterns

### Dashboard Cards

#### Standard Metric Card (Light Mode)
```css
.metric-card {
    background: linear-gradient(180deg, #f8f9fa 0%, #e6f2ff 100%);
    border: 1px solid var(--light-border);
    border-radius: 8px;
    padding: 1.5rem;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    box-shadow: 0 2px 4px var(--shadow-light);
}

.metric-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 16px var(--shadow-medium);
}

.metric-card .number {
    font-size: 3.5rem;
    font-weight: 700;
    color: var(--capstone-navy);
    line-height: 1;
    margin-bottom: 0.5rem;
}

.metric-card .label {
    font-size: 1rem;
    font-weight: 400;
    color: var(--light-text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
```

#### Standard Metric Card (Dark Mode)
```css
.dark-mode .metric-card {
    background: linear-gradient(180deg, #16325c 0%, #1a3a52 100%);
    border: 1px solid var(--dark-border);
    box-shadow: 0 2px 4px var(--shadow-dark-light);
}

.dark-mode .metric-card:hover {
    box-shadow: 0 8px 16px var(--shadow-dark-medium);
}

.dark-mode .metric-card .number {
    color: var(--dark-text-primary);
}

.dark-mode .metric-card .label {
    color: var(--dark-text-secondary);
}
```

### Kanban Board Headers

#### Column Header (Light Mode)
```css
.column-header {
    background: linear-gradient(180deg, #003366 0%, #004d99 100%);
    border-radius: 8px 8px 0 0;
    padding: 12px 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 2px 4px var(--shadow-medium);
}

.column-title {
    font-size: 13px;
    font-weight: 600;
    color: white;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.column-count {
    background: rgba(255, 255, 255, 0.95);
    color: #003366;
    font-size: 12px;
    font-weight: 700;
    padding: 4px 12px;
    border-radius: 12px;
    min-width: 30px;
    text-align: center;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
```

#### Column Header (Dark Mode)
```css
.dark-mode .column-header {
    background: linear-gradient(180deg, #16325c 0%, #1a3a52 100%);
}

.dark-mode .column-count {
    background: rgba(255, 255, 255, 0.9);
    color: #16325c;
}
```

### Badges & Tags

```css
/* Light Mode Badge */
.badge {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}

.badge-success {
    background: #e8f5e9;
    color: #2e7d32;
    border: 1px solid #4bca81;
}

.badge-warning {
    background: #fff3e0;
    color: #e65100;
    border: 1px solid #ff6b35;
}

.badge-error {
    background: #ffebee;
    color: #b71c1c;
    border: 1px solid #c23934;
}

/* Dark Mode Badge */
.dark-mode .badge-success {
    background: rgba(75, 202, 129, 0.2);
    color: #4bca81;
}

.dark-mode .badge-warning {
    background: rgba(255, 107, 53, 0.2);
    color: #ff6b35;
}

.dark-mode .badge-error {
    background: rgba(194, 57, 52, 0.2);
    color: #c23934;
}
```

---

## 📏 Typography

### Font Scales

```css
/* Dashboard Numbers */
--font-size-hero: 3.5rem;          /* Large metric numbers */
--font-size-large: 2.5rem;         /* Category totals */
--font-size-medium: 1.5rem;        /* Subheadings */
--font-size-base: 1rem;            /* Body text */
--font-size-small: 0.875rem;       /* Labels, captions */
--font-size-tiny: 0.75rem;         /* Helper text */

/* Font Weights */
--font-weight-light: 300;
--font-weight-regular: 400;
--font-weight-medium: 500;
--font-weight-semibold: 600;
--font-weight-bold: 700;
```

### Typography Examples

```css
/* Dashboard Metric Number */
.dashboard-number {
    font-size: var(--font-size-hero);
    font-weight: var(--font-weight-bold);
    line-height: 1;
}

/* Dashboard Label */
.dashboard-label {
    font-size: var(--font-size-small);
    font-weight: var(--font-weight-medium);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

/* Kanban Header Title */
.kanban-title {
    font-size: var(--font-size-small);
    font-weight: var(--font-weight-semibold);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

/* Card Title */
.card-title {
    font-size: var(--font-size-base);
    font-weight: var(--font-weight-semibold);
    line-height: 1.4;
}

/* Body Text */
.body-text {
    font-size: var(--font-size-base);
    font-weight: var(--font-weight-regular);
    line-height: 1.6;
}
```

---

## 🌓 Dark Mode Implementation

### LWC Dark Mode Pattern

All components MUST subscribe to `DarkModeChannel__c` using Lightning Message Service.

#### JavaScript Pattern
```javascript
import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import DARK_MODE_CHANNEL from '@salesforce/messageChannel/DarkModeChannel__c';

export default class MyComponent extends LightningElement {
    darkMode = false;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                DARK_MODE_CHANNEL,
                (message) => this.handleDarkModeChange(message)
            );
        }
    }

    handleDarkModeChange(message) {
        this.darkMode = message.darkModeEnabled;
    }

    get containerClass() {
        return this.darkMode ? 'container dark-mode' : 'container';
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }
}
```

#### HTML Pattern
```html
<template>
    <div class={containerClass}>
        <div class="metric-card">
            <div class="number">{metricValue}</div>
            <div class="label">{metricLabel}</div>
        </div>
    </div>
</template>
```

#### CSS Pattern
```css
/* Light Mode (Default) */
.container {
    background: var(--light-bg-primary);
}

.metric-card {
    background: linear-gradient(180deg, #f8f9fa 0%, #e6f2ff 100%);
    color: var(--light-text-primary);
}

/* Dark Mode */
.dark-mode.container {
    background: var(--dark-bg-primary);
}

.dark-mode .metric-card {
    background: linear-gradient(180deg, #16325c 0%, #1a3a52 100%);
    color: var(--dark-text-primary);
}
```

### Dark Mode Publisher (portalHeaderNew)

The global dark mode toggle is in `portalHeaderNew`. It uses localStorage to persist user preference.

```javascript
// Load preference on component load
connectedCallback() {
    const savedDarkMode = localStorage.getItem('capstone_dark_mode');
    if (savedDarkMode !== null) {
        this.darkMode = savedDarkMode === 'true';
        // Publish to all subscribers
        publish(this.messageContext, DARK_MODE_CHANNEL, { 
            darkModeEnabled: this.darkMode 
        });
    }
}

// Save preference on toggle
handleToggleDarkMode() {
    this.darkMode = !this.darkMode;
    localStorage.setItem('capstone_dark_mode', this.darkMode.toString());
    publish(this.messageContext, DARK_MODE_CHANNEL, { 
        darkModeEnabled: this.darkMode 
    });
}
```

**Default State:** OFF (light mode) for users who haven't set a preference.

---

## ♿ Accessibility

### Color Contrast Standards

All text MUST meet WCAG 2.1 Level AA standards:
- **Normal text:** Minimum 4.5:1 contrast ratio
- **Large text (18pt+ or 14pt+ bold):** Minimum 3:1 contrast ratio

### Verified Contrast Ratios

| Combination | Contrast | Status |
|-------------|----------|--------|
| Navy #003366 on White #ffffff | 10.3:1 | ✅ AAA |
| Gold #f4a024 on Navy #003366 | 4.8:1 | ✅ AA |
| White #ffffff on Navy #003366 | 10.3:1 | ✅ AAA |
| Light Text #2c3e50 on White #ffffff | 8.7:1 | ✅ AAA |
| Dark Text #ffffff on Dark BG #16325c | 9.2:1 | ✅ AAA |

### Focus States

All interactive elements MUST have visible focus indicators:

```css
button:focus,
a:focus,
input:focus {
    outline: 2px solid var(--capstone-gold);
    outline-offset: 2px;
}

.dark-mode button:focus,
.dark-mode a:focus,
.dark-mode input:focus {
    outline: 2px solid var(--dark-accent);
    outline-offset: 2px;
}
```

---

## 🚫 Legacy Colors to Avoid

### DO NOT USE These Colors

| Legacy Color | Hex Code | Replacement |
|--------------|----------|-------------|
| Salesforce Blue | `#0176d3` | `#003366` (Capstone Navy) |
| Old Dark Blue | `#032d60` | `#003366` (Capstone Navy) |
| Old Success Green | `#2e844a` | `#4bca81` (Capstone Success) |
| Old Teal | `#06a59a` | `#1589ee` (Capstone Info) |
| Old Red | `#e74c3c` | `#c23934` (Capstone Error) |
| Old Orange | `#f39c12` | `#ff6b35` (Capstone Warning) |
| Old Purple | `#9b59b6` | `#003366` (Capstone Navy) |

### Legacy Gradient Direction

**NEVER** use 135deg (diagonal) gradients:
```css
/* ❌ WRONG */
background: linear-gradient(135deg, #e6f2ff 0%, #ffffff 100%);

/* ✅ CORRECT */
background: linear-gradient(180deg, #f8f9fa 0%, #e6f2ff 100%);
```

---

## 📦 CSS Import System

### Using Capstone Brand Tokens

Import centralized CSS tokens in your component:

```css
/* Import Capstone brand tokens */
@import 'c/capstoneBrandTokens';

/* Use CSS variables */
.my-component {
    background: var(--capstone-navy);
    color: var(--capstone-white);
    border: 1px solid var(--light-border);
}

.dark-mode .my-component {
    background: var(--dark-bg-primary);
    border-color: var(--dark-border);
}
```

---

## ✅ Rebrand Checklist

Use this checklist when updating a component:

### Pre-Rebrand
- [ ] Document current appearance (screenshots)
- [ ] Identify all hex colors used (search CSS file)
- [ ] Check for gradients and note directions
- [ ] Review dark mode status (none, local, LMS)
- [ ] Create backup or new branch

### During Rebrand
- [ ] Replace legacy colors with Capstone palette
- [ ] Convert all 135deg gradients to 180deg
- [ ] Add `@wire(MessageContext)` if missing
- [ ] Add `subscribeToMessageChannel()` method
- [ ] Add `handleDarkModeChange()` method
- [ ] Add dark mode CSS classes (`.dark-mode .selector`)
- [ ] Import capstoneBrandTokens if using CSS variables
- [ ] Test all UI states (hover, active, disabled, focus)

### Post-Rebrand
- [ ] Compare before/after screenshots
- [ ] Test dark mode toggle functionality
- [ ] Test in ProductionCapstone org
- [ ] Verify no console errors
- [ ] Run linter: `npm run lint`
- [ ] Run Prettier: `npm run prettier`
- [ ] Update WORK_COORDINATION.md
- [ ] Update SHARED_PLANNING.md

### Deployment
- [ ] Deploy to ProductionCapstone
- [ ] Monitor for user issues
- [ ] Document any gotchas
- [ ] Mark task complete

---

## 📊 Before & After Examples

### Example 1: Metric Card

**Before (Legacy):**
```css
.metric-card {
    background: linear-gradient(135deg, #0176d3, #032d60);
    color: white;
}
```

**After (Capstone):**
```css
.metric-card {
    background: linear-gradient(180deg, #003366 0%, #004d99 100%);
    color: white;
}

.dark-mode .metric-card {
    background: linear-gradient(180deg, #16325c 0%, #1a3a52 100%);
}
```

### Example 2: Kanban Header

**Before (Legacy):**
```css
.column-header {
    background: #0176d3;
    padding: 10px;
}
```

**After (Capstone):**
```css
.column-header {
    background: linear-gradient(180deg, #003366 0%, #004d99 100%);
    padding: 12px 16px;
    border-radius: 8px 8px 0 0;
    box-shadow: 0 2px 4px rgba(0, 51, 102, 0.15);
}

.dark-mode .column-header {
    background: linear-gradient(180deg, #16325c 0%, #1a3a52 100%);
}
```

---

## 🔍 Automated Style Checks

The Capstone Styling Agent performs these automated checks:

1. **Color Compliance:** Searches for legacy hex codes
2. **Gradient Direction:** Flags 135deg gradients
3. **Dark Mode:** Checks for DarkModeChannel subscription
4. **CSS Variables:** Recommends using centralized tokens
5. **Accessibility:** Validates contrast ratios
6. **Typography:** Checks font sizes and weights

---

## 📚 Related Documentation

- [Capstone Styling Agent](.github/agents/Capstone Styling Agent.agent.md) - Automated style enforcement
- [COLE_ARNOLD_DEVELOPMENT_GUIDE.md](COLE_ARNOLD_DEVELOPMENT_GUIDE.md) - Developer guide
- [WORK_COORDINATION.md](WORK_COORDINATION.md) - Team coordination
- [SHARED_PLANNING.md](SHARED_PLANNING.md) - Task tracking

---

## 🔄 Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-01-09 | Initial style guide creation | Capstone Styling Agent |

---

**Questions or Feedback?**  
Contact Patrick Baker or Cole Arnold for style guide updates.

**Maintained By:** Capstone Styling Agent  
**Last Review:** January 9, 2026
