---
name: web-design-guidelines
description: Use when building web interfaces and needing design standards, principles, and guidelines to follow. Invoke when designing web pages, reviewing UI consistency, or establishing visual standards for a web project.
---

# Web Design Guidelines

## Overview

Practical web design principles for building consistent, accessible, and user-friendly interfaces.

**Core principle:** Good web design is invisible. Users should complete tasks, not notice the design.

---

## Visual Hierarchy

Users scan, not read. Structure information so the most important content is seen first.

**Hierarchy tools:**
- **Size** — larger = more important
- **Weight** — bold = emphasis
- **Color** — high contrast = primary action; muted = secondary
- **Position** — top-left to bottom-right (F-pattern reading)
- **Whitespace** — separation signals grouping

**Rule:** Every page has exactly one primary action. If everything is important, nothing is.

---

## Typography Standards

```css
/* Scale: use a modular type scale (1.25 ratio) */
--text-xs: 0.64rem;   /* 10px — captions, labels */
--text-sm: 0.8rem;    /* 13px — secondary text */
--text-base: 1rem;    /* 16px — body (NEVER below 16px for body) */
--text-lg: 1.25rem;   /* 20px — subheadings */
--text-xl: 1.563rem;  /* 25px — headings */
--text-2xl: 1.953rem; /* 31px — page titles */

/* Line height */
body text: 1.5–1.6
headings: 1.2–1.3

/* Measure (line length) */
optimal: 60–75 characters
max: 80 characters (never wider)
```

---

## Color System

```css
/* Structure every color system as: */
--color-primary: [brand color]       /* primary actions, links */
--color-primary-hover: [darker]      /* interaction state */
--color-secondary: [supporting]      /* secondary actions */
--color-surface: [backgrounds]       /* cards, panels */
--color-surface-raised: [elevated]   /* modals, dropdowns */
--color-border: [dividers]           /* subtle separators */
--color-text: [main text]            /* body copy */
--color-text-muted: [secondary]      /* labels, captions */
--color-error: [red]                 /* errors, destructive */
--color-success: [green]             /* confirmations */
--color-warning: [amber]             /* cautions */
```

**Contrast minimums (WCAG AA):**
- Normal text (<18px): 4.5:1
- Large text (≥18px or ≥14px bold): 3:1
- UI components (buttons, inputs): 3:1 against background

---

## Layout Principles

### Grid System

Use a consistent grid. Don't invent pixel values:

```css
/* 12-column grid, responsive */
.container {
  max-width: 1280px;
  padding: 0 var(--space-4);
  margin: 0 auto;
}
```

### Z-Axis (Layering)

Define a z-index scale:
```css
--z-base: 0;
--z-raised: 10;      /* cards, panels */
--z-dropdown: 100;   /* dropdowns, tooltips */
--z-sticky: 200;     /* sticky headers */
--z-modal: 300;      /* modals, dialogs */
--z-toast: 400;      /* notifications */
```

### Whitespace — the most underused tool

- Use generous whitespace between sections
- Inner padding > outer margin for content containers
- Group related items closer; separate unrelated items more

---

## Interaction Standards

| Interaction | Standard |
|-------------|----------|
| **Hover** | Visible within 100ms; color shift or underline |
| **Focus** | 2px solid outline, offset 2px, visible on all backgrounds |
| **Active/press** | Scale or color feedback within 50ms |
| **Loading** | Skeleton or spinner within 300ms of action |
| **Transition** | 150–300ms; ease-in-out for most; ease-out for entrances |
| **Error** | Inline, next to the field; never only at top of form |

---

## Responsive Breakpoints

```css
/* Mobile first */
/* xs: 0–479px  — base styles */
/* sm: 480px    — larger phones */
@media (min-width: 480px) { }
/* md: 768px    — tablets */
@media (min-width: 768px) { }
/* lg: 1024px   — laptops */
@media (min-width: 1024px) { }
/* xl: 1280px   — desktops */
@media (min-width: 1280px) { }
```

**Rule:** Never use breakpoints at arbitrary widths. Adjust at content breakpoints, not device breakpoints.

---

## Design Checklist

Before considering any web UI complete:

**Hierarchy:**
- [ ] One clear primary action per page/screen
- [ ] Visual hierarchy scannable in under 3 seconds

**Typography:**
- [ ] Body text ≥ 16px
- [ ] Line length 60–75 chars for body copy
- [ ] Line height 1.5 for body, 1.2 for headings

**Color:**
- [ ] All text passes WCAG AA contrast
- [ ] Color not used as the only differentiator (also shape/text)
- [ ] Dark mode considered (or explicitly deferred)

**Spacing:**
- [ ] Consistent spacing scale used (no arbitrary pixel values)
- [ ] Related elements grouped; unrelated elements separated

**Responsiveness:**
- [ ] Tested at 375px (small mobile), 768px (tablet), 1280px (desktop)
- [ ] No horizontal scroll at any breakpoint

**Interaction:**
- [ ] Focus states visible on all interactive elements
- [ ] Loading states present for async operations
- [ ] Error states present near the failing element

---

## Common Failures

| Failure | Fix |
|---------|-----|
| Everything is primary | One primary CTA per screen; demote the rest |
| Body text < 16px | 16px minimum — no exceptions for "compact" layouts |
| Color is the only signal | Add icon, text, or pattern alongside color |
| No focus state | Visible focus is required — never `outline: none` alone |
| Inconsistent spacing | Use spacing tokens — eliminate all `margin: 13px` |
| Design only tested at 1440px | Check mobile first — then scale up |
