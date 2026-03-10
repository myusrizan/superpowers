---
name: ui-ux-design
description: Use when designing or implementing any user interface — websites, landing pages, dashboards, mobile apps, SaaS products, or UI components. Invoke when building visual components, establishing design tokens, choosing UI patterns, styling layouts, or asked about color, typography, accessibility, responsiveness, or web design guidelines. NOT for general code quality review.
---

# UI/UX Design

## Overview

Produce professional, distinctive UI/UX by following a structured process: establish design intent → analyze context → match to industry pattern → build components correctly → apply non-negotiable standards → validate.

**Source:** Adapted from `nextlevelbuilder/ui-ux-pro-max-skill` (MIT) + component architecture patterns.

---

## Step 0: Establish Design Intent

Before matching industry patterns or writing any code, define what makes this interface **memorable and distinctive**. Generic-correct is worse than bold-and-specific.

Answer these three questions:

1. **What is the core concept?** One sentence — not "a dashboard for analytics" but "a command center that makes the user feel like they have superhuman visibility."
2. **What is the tonal direction?** Pick one: minimal-precise / bold-playful / dark-technical / warm-human / editorial-magazine / brutalist-raw / luxurious-restrained. This drives every subsequent decision.
3. **What makes this memorable?** One specific detail that elevates it above competent: an unusual typeface pairing, a signature animation, an unexpected color choice, a layout that breaks the grid deliberately.

### Typography — choose intentionally

Generic fonts (Arial, Inter, Roboto as defaults) produce generic results. If you reach for Inter as a first instinct, stop and justify it or choose differently.

| Intent | Alternatives worth considering |
|--------|-------------------------------|
| Modern technical | Geist, JetBrains Mono (for accents), IBM Plex |
| Editorial / magazine | Playfair Display + DM Sans, Fraunces + Figtree |
| Luxury / premium | Cormorant Garamond + Montserrat |
| Playful / bold | Cabinet Grotesk, Clash Display, Space Grotesk |
| Minimal / Swiss | Neue Haas Grotesk, GT Walsheim, Aktiv Grotesk |

Pairing rule: one display face (headings, hero) + one workhorse face (body, UI). Never three font families.

### Complexity matches vision

- **Maximalist direction** → elaborate animations, layered visual details, expressive spacing. Half-measures look broken.
- **Refined/minimal direction** → precision in spacing (4px grid strictly), tight typographic rhythm, subtle micro-interactions. Sloppiness is immediately visible.
- **Neutral/functional direction** → clean component patterns, zero decorative elements, accessibility-first. Any ornament becomes noise.

### Anti-generic-AI patterns

Avoid by default — these signal "AI built this":

- Purple/violet gradients as primary accent (`#6366F1`, `#8B5CF6`) — overused in SaaS
- Glassmorphism applied uniformly to everything
- Hero: large centered heading + subtitle + two CTA buttons + abstract blob graphic
- Cards with identical padding, radius, shadow — no hierarchy
- Icon + heading + 3-line description repeated 6 times in a grid
- Color palettes of 5+ colors with no clear dominant/accent structure

**The test:** Would this look identical if a different AI generated it for a different product? If yes, it needs a distinct direction.

---

## Step 1: Analyze Requirements

Extract from the request:
- **Product type** — SaaS, e-commerce, dashboard, portfolio, healthcare, etc.
- **Industry** — fintech, wellness, gaming, B2B enterprise, etc.
- **Style keywords** — any mentioned aesthetic preferences
- **Tech stack** — React, Next.js, Vue, HTML+Tailwind, mobile, etc.
- **Audience** — consumer, enterprise, developer, elderly, children, etc.

If stack is not specified, default to **HTML + Tailwind CSS**.

---

## Step 2: Match Industry & Style

### Industry Design Rules

| Industry | Pattern | Style | Colors | Anti-Patterns |
|----------|---------|-------|--------|---------------|
| SaaS (General) | Hero + Features + CTA | Glassmorphism + Flat | Trust blue + Accent | Excessive animation, dark mode default |
| Micro SaaS | Minimal + Demo | Flat + Vibrant Block | Vibrant + White space | Complex onboarding, clutter |
| B2B Enterprise | Feature-Rich + Trust | Trust & Authority + Minimal | Professional blue + Grey | Playful design, hidden features |
| AI/Chatbot Platform | Interactive Demo + Minimal | AI-Native UI + Minimalism | Neutral + AI Purple (#6366F1) | Heavy chrome, slow feedback, spinner > 3s |
| Developer Tool/IDE | Minimal + Documentation | Dark OLED + Minimalism | Dark syntax + Blue focus | Light mode default, slow performance |
| E-commerce | Feature-Rich Showcase | Vibrant Block-based | Brand primary + Success green | Flat without depth, text-heavy |
| E-commerce Luxury | Feature-Rich Showcase | Liquid Glass + Glassmorphism | Black + Gold + White | Cheap visuals, fast animations |
| SaaS Dashboard | Data-Dense Dashboard | Data-Dense + Heat Map | Cool→Hot gradients + Grey | Ornate design, slow rendering |
| Analytics Dashboard | Data-Dense + Drill-Down | Data-Dense + Heat Map | Cool→Hot + Neutral grey | Ornate, no filtering capability |
| Financial Dashboard | Data-Dense Dashboard | Dark OLED + Data-Dense | Dark + Red/Green alerts + Blue | Light mode default, slow rendering |
| Fintech/Crypto | Conversion-Optimized | Glassmorphism + Dark OLED | Dark tech + Vibrant accents | Light backgrounds, no security signals |
| Banking/Finance | Trust & Authority | Minimalism + Accessible | Navy + Trust Blue + Gold | Playful, unclear fees, poor security UX |
| Healthcare App | Social Proof-Focused | Neumorphism + Accessible | Calm blue + Health green | Bright neon, motion-heavy, small text |
| Medical Clinic | Trust & Authority + Conversion | Accessible + Minimalism | Medical Blue + Trust White | Outdated, confusing booking |
| Wellness/Mental Health | Social Proof-Focused | Neumorphism + Accessible | Calm pastels + Trust | Bright neon, motion overload |
| Government/Public | Minimal & Direct | Accessible + Minimalism | Professional blue + High contrast | Ornate, low contrast, motion |
| Education/E-learning | Feature-Rich + Social Proof | Claymorphism + Vibrant Block | Vibrant learning + Progress green | Boring, no gamification |
| Portfolio/Personal | Storytelling-Driven | Motion-Driven + Minimalism | Brand primary + Artistic | Generic templates, corporate feel |
| Creative Agency | Storytelling-Driven | Brutalism + Motion-Driven | Bold primaries + Artistic | Corporate minimalism, hidden portfolio |
| Gaming | Feature-Rich Showcase | 3D Hyperrealism + Retro-Futurism | Vibrant + Neon + Immersive | Minimalist, static assets |
| Startup Landing | Hero-Centric + Trust | Motion-Driven + Vibrant Block | Bold primaries + Accent | Static, no video, poor mobile |
| Restaurant/Food | Hero-Centric + Conversion | Vibrant Block + Motion-Driven | Warm (Orange/Red/Brown) | Low-quality imagery, outdated |
| Travel/Tourism | Storytelling + Hero | Aurora UI + Motion-Driven | Vibrant destination + Sky Blue | Generic photos, complex booking |
| Music/Entertainment | Feature-Rich Showcase | Dark OLED + Vibrant Block | Dark (#121212) + Vibrant | Cluttered, poor audio player |
| Legal Services | Trust & Authority + Minimal | Trust & Authority + Minimalism | Navy (#1E3A5F) + Gold + White | Outdated, hidden credentials |
| Real Estate | Hero-Centric + Feature-Rich | Glassmorphism + Minimalism | Trust Blue + Gold + White | Poor photos, no virtual tours |
| Cybersecurity | Trust & Authority + Real-Time | Cyberpunk UI + Dark OLED | Matrix Green + Deep Black | Light mode, poor data viz |
| NFT/Web3 | Feature-Rich Showcase | Cyberpunk UI + Glassmorphism | Dark + Neon + Gold (#FFD700) | Light mode, no wallet status |
| News/Media | Hero-Centric + Feature-Rich | Minimalism + Flat | Brand + High contrast | Cluttered, slow loading |
| Luxury/Premium Brand | Storytelling + Feature-Rich | Liquid Glass + Glassmorphism | Black + Gold + White | Cheap visuals, fast animations (need 400–600ms) |

### Style Selection Guide

| Use Case | Recommended Style | Avoid |
|----------|------------------|-------|
| Modern SaaS, fintech dashboards | Glassmorphism | In light mode without `bg-white/80+` opacity |
| Health/wellness, meditation | Neumorphism | For high-information density products |
| Dark mode apps, coding tools | Dark Mode OLED | As only option — always provide toggle |
| Enterprise, documentation | Minimalism / Swiss Style | When the product needs personality |
| Startups, youth brands | Vibrant Block-based | For professional/corporate audiences |
| Educational apps, children's tools | Claymorphism | For B2B or finance |
| Portfolios, artistic projects | Brutalism | For anything requiring trust signals |
| Premium brands, luxury e-commerce | Liquid Glass | For utility apps (adds performance cost) |
| AI products, voice assistants | AI-Native UI (minimal chrome) | When the context needs visual richness |
| Dashboards/feature showcases | Bento Grid | For narrative-driven pages |
| Conversions, pricing pages | Conversion-Optimized | When social proof is the main persuader |
| B2B, enterprise software | Trust & Authority | For creative/portfolio work |
| Gaming, crypto, dev tools | Cyberpunk UI | For healthcare, government, financial |

**Quick style characteristics:**
- **Glassmorphism:** backdrop-blur 10–20px, translucent overlays, vibrant background required
- **Neumorphism:** soft box-shadows both inward/outward, rounded 12–16px, monochromatic pastels
- **Brutalism:** zero border-radius, instant transitions, bold primary colors, stark contrast
- **Liquid Glass:** morphing shapes, iridescent gradients, slow animations (400–600ms)
- **AI-Native UI:** minimal chrome, conversational layout, typing indicators, streaming text
- **Bento Grid:** modular cards, asymmetric grid, rounded 16–24px, Apple-style hierarchy
- **Claymorphism:** chunky borders 3–4px, double shadows, rounded 16–24px, pastel colors
- **Dark Mode OLED:** true black (#000000), vibrant neon accents, no pure white text

---

## Step 3: Component Architecture

### Atomic Design Hierarchy

```
atoms       → Button, Input, Label, Icon (single responsibility)
molecules   → SearchBar (Input + Button), FormField (Label + Input + Error)
organisms   → NavBar (multiple molecules), DataTable (rows of molecules)
templates   → PageLayout (organism arrangements)
pages       → Specific instances of templates with real data
```

**Rule:** Components only compose elements from the same level or below.

### State Handling

Every UI component must handle all states or explicitly delegate:

```typescript
type ComponentState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; message: string }
  | { status: 'empty' }
```

**Never:** Render data without handling loading and error states.

### Composition over Props

```typescript
// ❌ Prop explosion
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

## Step 4: Design System Tokens

### Spacing Scale (4px base unit)

```css
--space-1: 4px;   --space-2: 8px;   --space-3: 12px;
--space-4: 16px;  --space-6: 24px;  --space-8: 32px;
--space-12: 48px; --space-16: 64px;
```

Never use arbitrary pixel values for spacing.

### Typography Scale

```css
--text-xs:   0.64rem;   /* ~10px — captions, labels */
--text-sm:   0.8rem;    /* ~13px — secondary text */
--text-base: 1rem;      /* 16px — body (NEVER below 16px) */
--text-lg:   1.25rem;   /* 20px — subheadings */
--text-xl:   1.563rem;  /* 25px — headings */
--text-2xl:  1.953rem;  /* 31px — page titles */

/* Line height: body 1.5–1.6 | headings 1.2–1.3 */
/* Measure: 60–75 chars optimal, 80 max */
```

### Color System Tokens

```css
--color-primary:        /* brand color — primary actions, links */
--color-primary-hover:  /* darker — interaction state */
--color-secondary:      /* supporting — secondary actions */
--color-surface:        /* backgrounds — cards, panels */
--color-surface-raised: /* elevated — modals, dropdowns */
--color-border:         /* dividers — subtle separators */
--color-text:           /* main text — body copy */
--color-text-muted:     /* secondary — labels, captions */
--color-error:          /* red — errors, destructive */
--color-success:        /* green — confirmations */
--color-warning:        /* amber — cautions */
```

### Z-Axis Layering

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
| Hover | Color shift within 100ms |
| Focus | 2px solid outline, 2px offset, visible on all backgrounds |
| Active/press | Scale or color feedback within 50ms |
| Loading | Skeleton or spinner within 300ms of triggering action |
| Transition | 150–300ms; ease-in-out for most; ease-out for entrances |
| Error | Inline, next to the field — never only at top of form |

### Responsive Breakpoints

```css
/* Mobile first — base styles target mobile */
/* xs: 0–479px — base */
@media (min-width: 480px) { }  /* sm — larger phones */
@media (min-width: 768px) { }  /* md — tablets */
@media (min-width: 1024px) { } /* lg — laptops */
@media (min-width: 1280px) { } /* xl — desktops */
```

Test at minimum: **375px, 768px, 1024px, 1440px**. Adjust at content breakpoints, not device breakpoints.

---

## Step 5: Non-Negotiable Standards

These apply to **every** UI task regardless of style or industry.

### Interaction
- `cursor-pointer` on **every** interactive element (buttons, links, cards, icons)
- Minimum touch target: **44×44px** — use `min-h-[44px] min-w-[44px]`
- Minimum gap between touch targets: **8px**
- `active:scale-95` for press feedback on buttons and cards
- Use `transform` and `opacity` for animations — **never** `width`/`height`/`top`/`left`

### Icons
- **Never use emojis as UI icons** — use SVG libraries (Heroicons, Lucide, Phosphor)
- Icon-only buttons **must** have `aria-label`

### Color & Contrast
- Normal text: **4.5:1** minimum; large text (18px+): **3:1**; UI components: **3:1**
- Never use color as the only indicator — always pair with icon or text

### Layout
- Viewport: use `dvh` or `min-h-screen`, **not** `100vh` on mobile
- Content: `max-w-full overflow-x-hidden` to prevent horizontal scroll
- Images: always `max-w-full h-auto` or use `aspect-ratio`
- Floating navbar: `top-4 left-4 right-4` + compensate with `pt-20` on body

### Glassmorphism (light mode)
- Glass cards require `bg-white/80` or higher — lower opacity becomes unreadable

---

## Step 6: Critical UX Rules

### Navigation
- Smooth scroll: `html { scroll-behavior: smooth; }`
- Preserve browser back button: use `history.pushState()`, never `location.replace()`

### Animation
- Animate max **1–2 elements** per view
- Always respect `prefers-reduced-motion`:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

- Show loading skeleton/spinner for operations > 300ms
- `ease-out` for entering elements, `ease-in` for exiting

### Accessibility
- All form inputs must have `<label for="...">` — placeholder alone is not a label
- Use `role="alert"` or `aria-live` for error messages
- Tab order must match visual order — test keyboard navigation
- Use semantic HTML: `<nav>`, `<main>`, `<article>`, `<section>` — never div soup
- All interactions reachable via Tab + Enter/Space
- Never `outline: none` without a visible alternative

### Forms
- Semantic input types: `type="email"`, `type="tel"`, `type="number"`
- `inputmode="numeric"` for numeric inputs on mobile
- Validate on blur (`onBlur`), not only on submit
- Password fields must have a show/hide toggle
- Disable + show spinner on submit while loading (prevent double-submit)
- Error message near the problem field, not at the top of the form

### Destructive Actions
- Confirm before delete/irreversible changes — use a modal with clearly labeled confirm/cancel naming the specific action (e.g., "Delete 'Project Alpha'?"). `window.confirm()` is not acceptable.

### Responsive
- `<meta name="viewport" content="width=device-width, initial-scale=1">` is required
- Tables need `overflow-x-auto` wrapper on mobile
- `touch-action: manipulation` to remove tap delay

### Performance
- Images: WebP, `srcset`, `loading="lazy"` for below-fold
- No synchronous `<script>` in `<head>` — use `async` or `defer`
- `font-display: swap` to prevent invisible text during font load
- Video: `playsInline muted preload="none"` — never `autoplay loop` for decorative video

### AI-Specific
- Label AI-generated content clearly ("AI Assistant", not a human name)
- Stream responses token-by-token — never a spinner for 10+ seconds
- Provide thumbs up/down or "Regenerate" feedback mechanism

### Feedback
- Empty states must have a helpful message and an action ("No items yet. Add one →")
- Onboarding tours must have a "Skip" button

---

## Design System Persistence (multi-page projects)

```
design-system/
├── MASTER.md         Global tokens: colors, typography, spacing, effects, style
└── pages/
    ├── dashboard.md  Dashboard-specific overrides (take precedence over MASTER)
    └── landing.md    Landing page overrides
```

**MASTER.md structure:**
```markdown
# Design System — [Project Name]
## Style: [chosen style name]
## Colors: primary / secondary / accent / error / success / neutral
## Typography: [font pairing] — headings: [font] / body: [font]
## Spacing scale: 4 8 16 24 32 48 64
## Border radius: [e.g., 8px standard, 16px cards, 24px chips]
## Shadows: [levels]
## Animation timing: [micro: 150ms / standard: 250ms / emphasis: 400ms]
```

Page files only contain rules that **differ** from MASTER.

---

## Stack Quick Reference

### React / Next.js
- `next/image` with `width`/`height` or `fill` — never raw `<img>` for content images
- Framer Motion for complex sequences; CSS transitions for simple hover
- shadcn/ui components already have accessible patterns — extend rather than replace
- `useReducedMotion()` hook for motion accessibility

### HTML + Tailwind CSS
- `@layer components` for repeated patterns — don't copy-paste class strings
- `prose` class from `@tailwindcss/typography` for long-form content
- JIT mode: arbitrary values sparingly — prefer scale values (`p-4` not `p-[17px]`)
- Group hover: `group` on parent, `group-hover:` on child for card interactions

### Vue / Nuxt
- `<Transition>` and `<TransitionGroup>` for enter/leave animations
- `v-bind` CSS variables for dynamic theming

### Mobile (React Native / Flutter)
- Test thumb zones: bottom 60% of screen for primary actions
- `SafeAreaView` (RN) or `SafeArea` (Flutter) — always
- Haptic feedback on confirmations: `Haptics.impactAsync()` (RN Expo)

---

## Delivery Checklist

Before delivering any UI code — **if time prevents a full pass, explicitly flag each unchecked item as a known defect. Silent delivery without checklist completion is not permitted.**

**Design intent:**
- [ ] Concept, tonal direction, memorable detail defined before coding
- [ ] Typography is a deliberate choice — not Arial/Inter/Roboto by default
- [ ] No anti-generic-AI patterns (purple gradient, uniform glassmorphism, clone hero, icon-grid features)

**Component correctness:**
- [ ] All states handled: idle, loading, success, error, empty
- [ ] Composition pattern used (no prop explosion)
- [ ] Spacing/color/z-index use design tokens — no hardcoded values

**Interactions:**
- [ ] All buttons have `cursor-pointer`
- [ ] All interactive elements have hover + active states
- [ ] Touch targets 44×44px minimum
- [ ] Icon-only buttons have `aria-label`

**Accessibility:**
- [ ] Form inputs have `<label>` elements (not just placeholder)
- [ ] Contrast ratio 4.5:1 for normal text
- [ ] `prefers-reduced-motion` respected
- [ ] No `outline: none` without visible alternative
- [ ] Semantic HTML used throughout

**Layout & responsive:**
- [ ] No `100vh` on mobile — use `dvh` or `min-h-screen`
- [ ] Images have `max-w-full h-auto` or fixed dimensions
- [ ] No `z-[9999]` — use z-index token scale
- [ ] No horizontal scroll on mobile
- [ ] Viewport meta tag present
- [ ] Tested at 375px, 768px, 1024px, 1440px

**UX:**
- [ ] Loading states shown for async operations > 300ms
- [ ] Empty states are non-blank (message + action)
- [ ] Destructive actions require confirmation modal

---

## Common Failures

| Failure | Fix |
|---------|-----|
| Missing loading state | Every async fetch needs a loading UI |
| Missing error state | Every async operation can fail — show it |
| ARIA missing on icon buttons | Add `aria-label` to all icon-only interactive elements |
| Hardcoded colors | Use design tokens — `var(--color-primary)` not `#1a73e8` |
| Arbitrary spacing | Stick to spacing scale — no `margin: 13px` |
| Mobile not tested | Check at 375px before desktop work |
| Generic-AI look | Define design intent before touching code |
