---
name: frontend-design
description: Use when designing or implementing web UI — components, layouts, design systems, or visual standards. Invoke when building visual components, establishing design tokens (colors, typography, spacing), choosing UI patterns, or asked about accessibility, responsiveness, or web design guidelines.
---

# Frontend Design

## Overview

Apply structured UI/UX design patterns to frontend implementation. Bridges design thinking and code output.

**Core principle:** Design intent must survive implementation. Don't lose the design in the code.

---

## Design Analysis — Before Writing Code

Before any UI implementation, answer:

1. **What is this component's single job?** (one sentence)
2. **Who uses it and in what context?** (user type, device, frequency)
3. **What state does it need to handle?** (empty, loading, error, populated, disabled)
4. **What are the accessibility requirements?** (keyboard nav, screen reader, contrast)

---

## Component Design Patterns

### Atomic Design Hierarchy

```
atoms       → Button, Input, Label, Icon (single responsibility)
molecules   → SearchBar (Input + Button), FormField (Label + Input + Error)
organisms   → NavBar (multiple molecules), DataTable (rows of molecules)
templates   → PageLayout (organism arrangements)
pages       → Specific instances of templates with real data
```

**Rule:** Components should only compose elements from the same level or below. Pages assemble organisms. Organisms assemble molecules.

### State Handling

Every UI component must handle all states or explicitly delegate:

```typescript
type ComponentState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; message: string }
  | { status: 'empty' }
```

**Never:** Render data without handling loading and error states.

### Composition over Props

```typescript
// ❌ Prop explosion — adding features requires new props forever
<Card title="..." subtitle="..." badge="..." action="..." icon="..." />

// ✅ Composition — consumers control their own layout
<Card>
  <Card.Header>
    <Card.Title>...</Card.Title>
    <Badge>New</Badge>
  </Card.Header>
  <Card.Body>...</Card.Body>
  <Card.Footer>
    <Button>Action</Button>
  </Card.Footer>
</Card>
```

---

## Layout Systems

### Spacing Scale

Use a consistent spacing scale. Never use arbitrary pixel values.

```css
/* Token-based spacing (4px base unit) */
--space-1: 4px;
--space-2: 8px;
--space-3: 12px;
--space-4: 16px;
--space-6: 24px;
--space-8: 32px;
--space-12: 48px;
--space-16: 64px;
```

### Responsive Design

Mobile-first. Add breakpoints only when content requires it — not at standard widths by habit.

```css
/* Mobile first — base styles are mobile */
.card { padding: var(--space-4); }

/* Expand at breakpoint */
@media (min-width: 768px) {
  .card { padding: var(--space-6); }
}
```

---

## Design System Standards

### Visual Hierarchy

Users scan, not read. Every page or screen needs exactly one primary action.

**Hierarchy tools:** Size (larger = more important) · Weight (bold = emphasis) · Color (high contrast = primary, muted = secondary) · Position (top-left to bottom-right scan path) · Whitespace (separation signals grouping)

**Rule:** If everything is important, nothing is. One primary CTA per screen — demote the rest.

### Typography Scale

```css
/* Modular scale (1.25 ratio), 4px base */
--text-xs:   0.64rem;   /* ~10px — captions, labels */
--text-sm:   0.8rem;    /* ~13px — secondary text */
--text-base: 1rem;      /* 16px — body (NEVER below 16px for body) */
--text-lg:   1.25rem;   /* 20px — subheadings */
--text-xl:   1.563rem;  /* 25px — headings */
--text-2xl:  1.953rem;  /* 31px — page titles */

/* Line height */
/* body text: 1.5–1.6  |  headings: 1.2–1.3 */

/* Measure (line length): 60–75 chars optimal, 80 max */
```

**Rule:** Body text minimum 16px. Never three font families — one display face + one workhorse face.

### Color System Tokens

```css
--color-primary:        [brand color — primary actions, links]
--color-primary-hover:  [darker — interaction state]
--color-secondary:      [supporting — secondary actions]
--color-surface:        [backgrounds — cards, panels]
--color-surface-raised: [elevated — modals, dropdowns]
--color-border:         [dividers — subtle separators]
--color-text:           [main text — body copy]
--color-text-muted:     [secondary — labels, captions]
--color-error:          [red — errors, destructive]
--color-success:        [green — confirmations]
--color-warning:        [amber — cautions]
```

**Contrast minimums (WCAG AA):** Normal text (<18px): 4.5:1 · Large text (≥18px or ≥14px bold): 3:1 · UI components: 3:1

### Z-Axis (Layering)

```css
--z-base:     0;
--z-raised:   10;   /* cards, panels */
--z-dropdown: 100;  /* dropdowns, tooltips */
--z-sticky:   200;  /* sticky headers */
--z-modal:    300;  /* modals, dialogs */
--z-toast:    400;  /* notifications */
```

Never use arbitrary `z-index: 9999`.

### Interaction Timing

| Interaction | Standard |
|-------------|----------|
| **Hover** | Color shift within 100ms |
| **Focus** | 2px solid outline, 2px offset, visible on all backgrounds |
| **Active/press** | Scale or color feedback within 50ms |
| **Loading** | Skeleton or spinner within 300ms of triggering action |
| **Transition** | 150–300ms; ease-in-out for most; ease-out for entrances |
| **Error** | Inline, next to the field — never only at top of form |

### Responsive Breakpoints

```css
/* Mobile first — base styles target mobile */
/* xs: 0–479px  — base */
@media (min-width: 480px) { }  /* sm — larger phones */
@media (min-width: 768px) { }  /* md — tablets */
@media (min-width: 1024px) { } /* lg — laptops */
@media (min-width: 1280px) { } /* xl — desktops */
```

**Rule:** Adjust at content breakpoints, not device breakpoints. Always test at 375px (small mobile), 768px (tablet), 1280px (desktop).

---

## Accessibility Standards

Every interactive component must satisfy:

| Requirement | Implementation |
|-------------|---------------|
| **Keyboard navigation** | All actions reachable via Tab + Enter/Space |
| **Focus visible** | Never `outline: none` without a visible alternative |
| **ARIA labels** | Icon-only buttons need `aria-label` |
| **Color contrast** | Text: 4.5:1 minimum (WCAG AA); large text: 3:1 |
| **Motion sensitivity** | Animations respect `prefers-reduced-motion` |
| **Semantic HTML** | `<button>` for actions, `<a>` for navigation — never reversed |

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Design Review Checklist

Before calling a UI component complete:

- [ ] All states handled (empty, loading, error, success)
- [ ] Keyboard navigable
- [ ] Screen reader compatible (aria attributes present)
- [ ] Color contrast passes WCAG AA
- [ ] Responsive at all breakpoints (check mobile, tablet, desktop)
- [ ] Motion respects `prefers-reduced-motion`
- [ ] No hardcoded pixel values — uses spacing/color tokens
- [ ] Component has a single, clear responsibility

---

## Common Failures

| Failure | Fix |
|---------|-----|
| Missing loading state | Every async data fetch needs a loading UI |
| Missing error state | Every async operation can fail — show it |
| Aria missing on icon buttons | Add `aria-label` to all icon-only interactive elements |
| Hardcoded colors | Use design tokens — `var(--color-primary)` not `#1a73e8` |
| Arbitrary spacing | Stick to spacing scale — no `margin: 13px` |
| Mobile not tested | Check at 375px before any desktop work |
