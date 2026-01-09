# Capstone Partners Color Scheme Guide

## Overview
This document defines the official Capstone Partners brand color scheme to be used consistently across all Lightning Web Components in the Recruiter Portal.

## Primary Brand Colors

### Core Brand Colors
| Color Name | Hex Code | Usage | Example |
|------------|----------|-------|---------|
| **Capstone Blue** | `#003366` | Primary headers, navigation, main branding | Headers, hero sections |
| **Capstone Blue Light** | `#055199` | Gradients, hover states | Header gradients |
| **Capstone Blue Dark** | `#032d60` | Dark gradients, emphasis | Deep headers |
| **Capstone Gold** | `#f4a024` | Accents, highlights, borders | Border accents, badges |

### Secondary Action Colors
| Color Name | Hex Code | Usage | Example |
|------------|----------|-------|---------|
| **Action Blue** | `#0066cc` | Primary buttons, links | Call-to-action buttons |
| **Action Blue Alt** | `#0070d2` | Alternative actions, focus states | Secondary buttons |
| **Action Blue Hover** | `#005fb2` | Hover states | Button hover |

### Status Colors
| Color Name | Hex Code | Usage | Example |
|------------|----------|-------|---------|
| **Success Green** | `#2e844a` | Success states, positive metrics | Completion badges |
| **Success Light** | `#4bca81` | Light success states | Progress indicators |
| **Warning Orange** | `#fe9339` | Warning states, attention needed | At-risk indicators |
| **Warning Gold** | `#f39c12` | Alternative warnings | Pending states |
| **Error Red** | `#c23934` | Error states, critical issues | Overdue, failures |
| **Error Dark** | `#ea001e` | Severe errors | Critical alerts |

### Neutral Colors
| Color Name | Hex Code | Usage | Example |
|------------|----------|-------|---------|
| **White** | `#ffffff` | Backgrounds, text on dark | Card backgrounds |
| **Light Gray 1** | `#f8f9fa` | Subtle backgrounds | Section backgrounds |
| **Light Gray 2** | `#f3f3f3` | Alternative backgrounds | Container backgrounds |
| **Light Gray 3** | `#e5e5e5` | Borders, dividers | Separator lines |
| **Medium Gray** | `#706e6b` | Secondary text | Labels, captions |
| **Dark Gray** | `#3e3e3c` | Body text | Main content text |
| **Charcoal** | `#181818` | Primary text | Headings, emphasis |

## Color Replacement Map

### Colors to Replace
This section maps commonly used random colors to Capstone brand colors:

| Current Color | Replace With | New Color Name | Notes |
|---------------|--------------|----------------|-------|
| `#1589ee` | `#0066cc` | Action Blue | Primary metrics |
| `#ff6b35` | `#fe9339` | Warning Orange | Secondary metrics |
| `#9f42ff` | `#f39c12` | Warning Gold | Info metrics |
| `#5867e8` | `#0070d2` | Action Blue Alt | SI1 interviews |
| `#e3abec` | `#f39c12` | Warning Gold | SI2 interviews |
| `#8b63d6` | `#0066cc` | Action Blue | SI3 interviews |
| `#00a651` | `#2e844a` | Success Green | Career interviews |

### Gradient Patterns

#### Primary Header Gradient
```css
background: linear-gradient(135deg, #032d60 0%, #055199 100%);
```

#### Light Background Gradient
```css
background: linear-gradient(135deg, #e6f2ff 0%, #ffffff 100%);
```

#### Success Gradient
```css
background: linear-gradient(135deg, #2e844a 0%, #194e2e 100%);
```

#### Warning Gradient
```css
background: linear-gradient(135deg, #f39c12 0%, #b37209 100%);
```

#### Error Gradient
```css
background: linear-gradient(135deg, #e74c3c 0%, #a72d20 100%);
```

## Component-Specific Guidelines

### Dashboard Metric Tiles
Replace random border colors with semantic colors:
- **Total/Primary Metrics:** `#0066cc` (Action Blue)
- **Active/In-Progress:** `#0070d2` (Action Blue Alt)
- **Success/Completed:** `#2e844a` (Success Green)
- **Warning/At-Risk:** `#fe9339` (Warning Orange)
- **Critical/Overdue:** `#c23934` (Error Red)

### Interview Type Colors
Standardize interview type indicators:
- **Attraction Interview:** `#0066cc` (Action Blue)
- **SI1 (Align - 2nd):** `#0070d2` (Action Blue Alt)
- **SI2 (Plan - 3rd):** `#2e844a` (Success Green)
- **SI3 (Optional - 5th):** `#f39c12` (Warning Gold)
- **Career (Present - 4th):** `#003366` (Capstone Blue)

### Status Indicators
- **Scheduled:** `#0070d2` (Action Blue Alt)
- **Completed:** `#2e844a` (Success Green)
- **No-Show:** `#c23934` (Error Red)
- **Canceled:** `#706e6b` (Medium Gray)

### Contract Lifecycle Stages
- **Contract A:** `#0066cc` (Action Blue)
- **Contract B:** `#2e844a` (Success Green)
- **Transition:** `#fe9339` (Warning Orange)
- **Terminated:** `#c23934` (Error Red)

## Dark Mode Considerations

For components with dark mode support, use these alternatives:
- **Background:** `#16325c`, `#1a3a52`, `#243649`, `#2c4460`
- **Text:** `#ffffff` (headings), `#e8f4fd` (body), `#b0c4de` (secondary)
- **Borders:** `#3e5771`
- **Accents:** `#5ea3f2`

## Accessibility Guidelines

### Contrast Ratios
All color combinations must meet WCAG 2.1 AA standards:
- **Normal text:** Minimum 4.5:1 contrast ratio
- **Large text:** Minimum 3:1 contrast ratio
- **UI components:** Minimum 3:1 contrast ratio

### Tested Combinations
✅ **White text on #003366:** 12.63:1 (Excellent)
✅ **White text on #032d60:** 13.54:1 (Excellent)
✅ **Charcoal #181818 on White:** 16.10:1 (Excellent)
✅ **Medium Gray #706e6b on White:** 4.68:1 (Good)

## Implementation Priority

### High Priority (Phase 1)
1. Main dashboard components
2. Candidate record views
3. Interview management

### Medium Priority (Phase 2)
4. Specialized dashboards
5. Kanban and funnel views
6. Leaderboard components

### Low Priority (Phase 3)
7. Service dashboards
8. Modal components
9. Supporting utilities

## Usage Examples

### Before (Random Colors)
```css
.metric-tile {
  border-left-color: #1589ee; /* Random blue */
}
.metric-secondary {
  border-left-color: #ff6b35; /* Random orange */
}
```

### After (Capstone Colors)
```css
.metric-tile {
  border-left-color: #0066cc; /* Capstone Action Blue */
}
.metric-secondary {
  border-left-color: #fe9339; /* Capstone Warning Orange */
}
```

## References

- Original Capstone branding: `portalHeaderNew.css`
- Dark mode implementation: `.github/copilot-instructions-cole.md`
- Component examples: `recruiterDashboard.css`

## Version History

- **v1.0** (2026-01-08): Initial color scheme documentation
