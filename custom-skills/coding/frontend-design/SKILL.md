---
name: frontend-design
description: Use when designing UI components, building frontend interfaces, or applying design patterns to web UIs. Invoke when implementing visual components, designing layouts, choosing UI patterns, or applying design systems to frontend code.
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
