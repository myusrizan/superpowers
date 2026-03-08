---
name: ui-ux-design
description: Use when designing or implementing any user interface — websites, landing pages, dashboards, mobile apps, or SaaS products. Invoke even if the user doesn't say "UI" or "UX"; trigger on requests to build, create, style, implement, improve, or fix any visual interface, component, or layout. Also invoke when the user asks about color, typography, animations, accessibility, or responsiveness. NOT for general code quality review (use code-reviewer for that) — this skill covers visual design correctness: styling, layout, industry-appropriate aesthetics, accessibility compliance, and UX patterns.
---

# UI/UX Design

## Overview

Produce professional, distinctive UI/UX by following a 5-step process: establish design intent (concept + tonal direction + what makes it memorable), analyze project context, match to a design system, apply non-negotiable standards, then validate against anti-patterns.

**Source:** Adapted from `nextlevelbuilder/ui-ux-pro-max-skill` (MIT) — 38k stars, 100 industry rules, 99 UX guidelines, 68 style definitions.

---

## Step 0: Establish Design Intent

Before matching industry patterns or writing any code, define what makes this interface **memorable and distinctive**. Generic-correct is worse than bold-and-specific.

Ask and answer these three questions:

1. **What is the core concept?** One sentence. Not "a dashboard for analytics" — something like "a command center that makes the user feel like they have superhuman visibility."
2. **What is the tonal direction?** Pick one: minimal-precise / bold-playful / dark-technical / warm-human / editorial-magazine / brutalist-raw / luxurious-restrained. This choice drives every subsequent decision.
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

The implementation depth must match the aesthetic ambition:
- **Maximalist direction** (bold, rich, editorial) → elaborate animations, layered visual details, expressive spacing. Half-measures look broken.
- **Refined/minimal direction** → precision in spacing (4px grid strictly), tight typographic rhythm, subtle micro-interactions. Sloppiness is immediately visible.
- **Neutral/functional direction** → clean component patterns, zero decorative elements, accessibility-first. Any ornament becomes noise.

### Anti-generic-AI patterns

These patterns signal "AI built this" and undermine credibility — avoid by default:

- Purple/violet gradients as the primary accent (`#6366F1`, `#8B5CF6`) — overused, especially in SaaS
- Glassmorphism applied uniformly to everything regardless of context
- Hero sections with: large centered heading + subtitle + two CTA buttons + abstract blob graphic
- Cards with identical padding, identical border-radius, identical shadow — no hierarchy
- Icon + heading + 3-line description repeated 6 times in a grid ("features section")
- Color palettes of 5+ colors with no clear dominant/accent structure

**The test:** Would this look identical if a different AI generated it for a different product? If yes, it needs a distinct direction.

---

## Step 1: Analyze Requirements

Extract from the user's request:
- **Product type** — SaaS, e-commerce, dashboard, portfolio, healthcare app, etc.
- **Industry** — fintech, wellness, gaming, B2B enterprise, etc.
- **Style keywords** — any mentioned aesthetic preferences
- **Tech stack** — React, Next.js, Vue, HTML+Tailwind, mobile (SwiftUI/Flutter), etc.
- **Audience** — consumer, enterprise, developer, elderly, children, etc.

If stack is not specified, default to **HTML + Tailwind CSS**.

---

## Step 2: Match Industry & Style

### Industry Design Rules (Top 30 Categories)

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
| Luxury/Premium Brand | Storytelling + Feature-Rich | Liquid Glass + Glassmorphism | Black + Gold + White | Cheap visuals, fast animations (need 400-600ms) |

### Style Selection Guide

**By use case:**

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
- **Glassmorphism:** backdrop-blur 10-20px, translucent overlays, vibrant background required
- **Neumorphism:** soft box-shadows both inward/outward, rounded 12-16px, monochromatic pastels
- **Brutalism:** zero border-radius, instant transitions, bold primary colors, stark contrast
- **Liquid Glass:** morphing shapes, iridescent gradients, slow animations (400-600ms)
- **AI-Native UI:** minimal chrome, conversational layout, typing indicators, streaming text
- **Bento Grid:** modular cards, asymmetric grid, rounded 16-24px, Apple-style hierarchy
- **Claymorphism:** chunky borders 3-4px, double shadows, rounded 16-24px, pastel colors
- **Dark Mode OLED:** true black (#000000), vibrant neon accents, no pure white text

---

## Step 3: Apply Non-Negotiable Standards

These apply to **every** UI task regardless of style or industry:

### Interaction Standards
- Add `cursor-pointer` to **every** interactive element (buttons, links, cards, icons)
- Minimum touch target: **44×44px** — use `min-h-[44px] min-w-[44px]`
- Minimum gap between touch targets: **8px**
- Micro-interaction timing: **150–300ms** — never exceed 500ms for UI feedback
- Use `transform` and `opacity` for animations, **never** `width`/`height`/`top`/`left`
- Add `active:scale-95` for press feedback on buttons and cards

### Icon Standards
- **Never use emojis as UI icons** — use SVG icon libraries (Heroicons, Lucide, Phosphor)
- Icon-only buttons **must** have `aria-label`

### Color & Contrast
- Minimum contrast ratio: **4.5:1** for normal text, **3:1** for large text (18px+)
- Never use color as the only indicator (error/success) — always pair with icon or text
- `text-gray-900` on white = 7:1 (good). `text-gray-400` on gray-100 = 2.8:1 (fails)

### Typography
- Body text minimum: **16px** on mobile, **14px** absolute minimum anywhere
- Line height: **1.5–1.75** for body text (`leading-relaxed`)
- Line length: **65–75 characters** max — use `max-w-prose` or `max-w-3xl`
- Heading hierarchy: h1 → h2 → h3 only — never skip levels

### Layout
- Viewport units: use `dvh` or `min-h-screen`, **not** `100vh` on mobile
- Content width: `max-w-full overflow-x-hidden` to prevent horizontal scroll
- Images: always `max-w-full h-auto` or use `aspect-ratio` to prevent layout shift
- Z-index scale: use 10/20/30/50 — **never** arbitrary `z-[9999]`

### Glassmorphism (light mode)
- Glass cards require `bg-white/80` or higher — lower opacity becomes unreadable

### Floating Navbar
- Use `top-4 left-4 right-4` for proper edge spacing
- Compensate with `pt-20` (or matching nav height) on the body/first section

### Responsive Breakpoints
Test at minimum: **375px, 768px, 1024px, 1440px**

---

## Step 4: Critical UX Rules (HIGH Severity)

Apply these rules in all implementations:

### Navigation
- Smooth scroll: `html { scroll-behavior: smooth; }`
- Preserve browser back button: use `history.pushState()`, never `location.replace()`

### Animation
- Animate max **1–2 elements** per view — not everything that moves
- Always check `prefers-reduced-motion`: `@media (prefers-reduced-motion: reduce) { ... }`
- Show loading skeleton/spinner for operations > 300ms — never freeze the UI
- Use `ease-out` for entering elements, `ease-in` for exiting

### Layout
- Reserve space for async content (`aspect-ratio` or fixed height) to prevent content jump
- Test fixed-position elements don't overlap each other

### Accessibility
- All form inputs must have `<label for="...">` — placeholder alone is not a label
- Use `role="alert"` or `aria-live` for error messages — not just visual red borders
- Tab order must match visual order — test keyboard navigation
- Use semantic HTML: `<nav>`, `<main>`, `<article>`, `<section>` — never div soup

### Interaction
- Disable + show spinner on submit buttons while loading (prevent double-submit)
- Show error message near the problem field, not a single message at the top
- Confirm before destructive actions (delete, irreversible changes) — confirmation must use a modal with clearly labeled confirm/cancel buttons naming the specific action (e.g., "Delete 'Project Alpha'?" not "Are you sure?"). `window.confirm()` is not acceptable.
- Add visible focus rings: `focus:ring-2 focus:ring-blue-500` — never `outline-none` alone

### Responsive
- Minimum 16px body text on mobile
- `<meta name="viewport" content="width=device-width, initial-scale=1">` is required
- Tables need `overflow-x-auto` wrapper on mobile
- Touch-friendly hit areas: use `touch-action: manipulation` to remove tap delay

### Forms
- Use semantic input types: `type="email"`, `type="tel"`, `type="number"`, `type="url"`
- Use `inputmode="numeric"` for numeric inputs on mobile (shows number keyboard)
- Validate on blur (`onBlur`), not only on submit
- Password fields must have a show/hide toggle

### Performance
- Images: use WebP, `srcset`, and `loading="lazy"` for below-fold images
- No synchronous `<script>` in `<head>` — use `async` or `defer`
- `font-display: swap` to prevent invisible text during font load
- Video: use `playsInline muted preload="none"` — never `autoplay loop` for decorative video

### AI-Specific
- Always label AI-generated content clearly ("AI Assistant", not a human name)
- Stream responses token-by-token — never a spinner for 10+ seconds
- Provide thumbs up/down or "Regenerate" feedback mechanism

### Feedback
- Show loading indicator for anything taking > 300ms
- Empty states must have a helpful message and an action ("No items yet. Add one →")
- Onboarding tours must have a "Skip" button

---

## Design System Persistence (for multi-page projects)

For projects with multiple pages, establish a Master + Overrides hierarchy:

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
- Use `next/image` with `width`/`height` or `fill` — never raw `<img>` for content images
- Animate with Framer Motion for complex sequences; CSS transitions for simple hover
- shadcn/ui components already have accessible patterns — extend rather than replace
- `useReducedMotion()` hook from Framer Motion for motion accessibility

### HTML + Tailwind CSS
- Use `@layer components` for repeated patterns — don't copy-paste class strings
- `prose` class from `@tailwindcss/typography` for readable long-form content
- JIT mode: arbitrary values sparingly — prefer scale values (`p-4` not `p-[17px]`)
- Group hover: `group` on parent, `group-hover:` on child for card interactions

### Vue / Nuxt
- Use `<Transition>` and `<TransitionGroup>` for enter/leave animations
- `v-bind` CSS variables for dynamic theming
- Nuxt Image module for optimized `<NuxtImg>` equivalent to `next/image`

### Mobile (React Native / Flutter)
- Test thumb zones: bottom 60% of screen for primary actions
- Safe area insets: `SafeAreaView` (RN) or `SafeArea` (Flutter) — always
- Haptic feedback on confirmations: `Haptics.impactAsync()` (RN Expo)

---

## Common Anti-Pattern Checklist

Before delivering any UI code, verify. **If time constraints make a full pass impossible, do NOT deliver silently — explicitly flag each unchecked item as a known defect. Silent delivery without checklist completion is not permitted.**

- [ ] Design intent defined (concept, tonal direction, memorable detail) before coding
- [ ] Typography is a deliberate choice — not Arial/Inter/Roboto by default
- [ ] No anti-generic-AI patterns (purple gradient accent, uniform glassmorphism, clone hero section, features icon-grid)
- [ ] No emojis used as icons
- [ ] All buttons have `cursor-pointer`
- [ ] All interactive elements have hover + active states
- [ ] Touch targets are 44×44px minimum
- [ ] Icon-only buttons have `aria-label`
- [ ] Form inputs have `<label>` elements (not just placeholder)
- [ ] Contrast ratio passes 4.5:1 for normal text
- [ ] `prefers-reduced-motion` respected for animations
- [ ] No `100vh` on mobile layouts — use `dvh` or `min-h-screen`
- [ ] Images have `max-w-full h-auto` or fixed dimensions
- [ ] No `z-[9999]` — use z-index scale (10/20/30/50)
- [ ] Loading states shown for async operations > 300ms
- [ ] Empty states are non-blank (message + action)
- [ ] Viewport meta tag present
- [ ] No horizontal scroll on mobile
