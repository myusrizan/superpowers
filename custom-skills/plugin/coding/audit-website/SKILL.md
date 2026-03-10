---
name: audit-website
description: Use when asked to audit, review, or assess a website's health — covering performance, accessibility, SEO, and code quality. Invoke when someone says "audit the site", "review the website", "check the performance", or "what's wrong with the site".
---

# Audit Website

## Overview

Full website health audit across four dimensions: performance, accessibility, SEO, and code quality.

**Core principle:** Audit everything before recommending anything. A finding without measurement is an opinion.

---

## Audit Dimensions

### 1. Performance

**Target metrics (Core Web Vitals):**

| Metric | Good | Needs Work | Poor |
|--------|------|-----------|------|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5–4s | > 4s |
| INP (Interaction to Next Paint) | < 200ms | 200–500ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1–0.25 | > 0.25 |
| TTFB (Time to First Byte) | < 800ms | 800ms–1.8s | > 1.8s |

**What to check:**
- [ ] Image sizes and formats (use WebP/AVIF; lazy load below fold)
- [ ] JavaScript bundle size (> 200KB parsed JS = problem)
- [ ] Render-blocking resources (CSS and JS in `<head>`)
- [ ] Third-party scripts (each adds ~300ms latency)
- [ ] Font loading strategy (font-display: swap; preload critical fonts)
- [ ] Cache headers (static assets: 1 year; HTML: short or no-cache)
- [ ] Compression (Brotli > Gzip; all text assets ≥ 1KB should be compressed)

**Tools:**
```bash
# Lighthouse CLI
npx lighthouse https://example.com --output json --chrome-flags="--headless"

# Check bundle size
npx bundlesize

# Check Core Web Vitals via PageSpeed Insights API
curl "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https://example.com"
```

### 2. Accessibility (a11y)

**WCAG 2.1 AA compliance checklist:**

| Category | What to Check |
|----------|--------------|
| **Perceivable** | Alt text on all images; captions on video; color not sole differentiator |
| **Operable** | All interactions keyboard-accessible; focus visible; no keyboard traps |
| **Understandable** | Form labels associated; errors identified in text; language declared |
| **Robust** | Valid HTML; ARIA used correctly; works with screen readers |

**Automated check:**
```bash
npx axe-cli https://example.com
# or
npx pa11y https://example.com
```

**Manual checks (automation misses these):**
- [ ] Tab order makes logical sense
- [ ] Focus is never lost (especially in modals/dialogs)
- [ ] Screen reader announces meaningful content (test with VoiceOver/NVDA)
- [ ] Error messages link to the field in error

### 3. SEO

**Technical SEO checklist:**
- [ ] `<title>` tag present and descriptive (50–60 chars)
- [ ] Meta description present (150–160 chars)
- [ ] Canonical URLs set
- [ ] robots.txt accessible and correct
- [ ] sitemap.xml present and submitted
- [ ] Structured data (Schema.org) where applicable
- [ ] Open Graph tags for social sharing
- [ ] Internal link structure logical
- [ ] No broken links (internal or external)
- [ ] HTTPS enforced (HTTP → HTTPS redirect)

```bash
# Check robots.txt and sitemap
curl https://example.com/robots.txt
curl https://example.com/sitemap.xml

# Check redirects
curl -I http://example.com
```

### 4. Code Quality

- [ ] No console errors in browser
- [ ] No 4xx/5xx errors in network tab
- [ ] Valid HTML (run through W3C validator)
- [ ] No inline styles (prefer CSS classes)
- [ ] No render-blocking `<script>` without `async`/`defer`
- [ ] Security headers present (CSP, HSTS, X-Frame-Options)

```bash
# Check security headers
curl -I https://example.com | grep -i "content-security\|strict-transport\|x-frame"
```

---

## Audit Report Format

```markdown
# Website Audit — [URL]
**Date:** YYYY-MM-DD

## Executive Summary
[2-3 sentence overall assessment. Grade each dimension: A/B/C/D/F]

## Performance — Grade: [X]
### Scores
- LCP: Xs (Good/Needs Work/Poor)
- INP: Xms
- CLS: X.X
- TTFB: Xms

### Top Issues
1. [Specific issue] — Impact: High/Medium/Low — Fix: [concrete action]

## Accessibility — Grade: [X]
### Issues Found
| Severity | Issue | Element | Fix |
|----------|-------|---------|-----|
| Critical | [issue] | [selector] | [fix] |

## SEO — Grade: [X]
### Missing / Broken
- [ ] [issue] — [fix]

## Code Quality — Grade: [X]
### Issues
- [issue at file:line or URL]

## Recommended Fix Order
1. [highest impact fix] — estimated effort: [S/M/L]
2. ...
```

---

## Hard Rules

- **Measure before reporting.** Run tools — don't guess scores.
- **Specific findings only.** "Performance could be better" is not a finding. "LCP is 4.2s — hero image (2.4MB PNG) loads without lazy loading or compression" is a finding.
- **Grade all four dimensions.** An audit that only checks SEO is incomplete.
- **Include actionable fixes.** Every issue must have a concrete, implementable fix.
