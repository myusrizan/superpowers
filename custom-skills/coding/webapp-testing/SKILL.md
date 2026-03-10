---
name: webapp-testing
description: Use when testing web applications interactively — navigating pages, filling forms, checking rendered output, or testing user flows in a browser. Invoke when asked to "test the app", "check if the form works", "verify the login flow", or any task requiring live browser interaction with a running web app.
---

# Web App Testing

## Overview

Test web applications through live browser interaction — going beyond static code analysis to verify actual runtime behavior.

**Core principle:** The app works when a user can complete the task, not when the code looks correct.

---

## When to Use

- Verifying a user flow end-to-end (signup, login, purchase, form submission)
- Checking that UI renders correctly in different states
- Confirming that API calls fire and return expected data
- Validating that error states display correctly
- Regression testing after UI changes

**Do NOT use when:** You need headless test automation → `advanced-testing` (Playwright/Cypress) · Pure unit/logic testing → `test-driven-development`

---

## Tools

### Playwright MCP (preferred)

If the Playwright MCP is available, use it for reliable browser automation:

```
Navigate to: http://localhost:3000
Take a screenshot
Click the "Sign Up" button
Fill in email: test@example.com
Fill in password: TestPassword123!
Click "Create Account"
Take a screenshot
Assert: URL contains "/dashboard"
```

### Claude's Browser Tool

If available as a tool in the current session, use it directly to:
- Navigate to URLs
- Click elements
- Fill form fields
- Take screenshots
- Read page content

### Manual Script Approach (Playwright)

When MCP/browser tools unavailable:

```typescript
// playwright-test.ts
import { chromium } from 'playwright'

const browser = await chromium.launch({ headless: true })
const page = await browser.newPage()

await page.goto('http://localhost:3000')
await page.fill('[name="email"]', 'test@example.com')
await page.fill('[name="password"]', 'TestPassword123!')
await page.click('[type="submit"]')

await page.waitForURL('**/dashboard')
console.log('Login flow: PASS')

await browser.close()
```

---

## Test Flow Structure

### For each user flow:

**1. Define the flow**
```
Actor: [who is doing this]
Start state: [where they begin]
Steps: [numbered actions]
End state: [what success looks like]
```

**2. Test the happy path first**
Complete the primary success scenario. Screenshot at key steps.

**3. Test edge cases**
- Empty inputs
- Invalid inputs (wrong format, too long, special chars)
- Boundary values (max length fields, date ranges)

**4. Test error states**
- Network error (disable network mid-flow)
- Invalid credentials
- Duplicate data (try to register twice with same email)

**5. Report findings**

```markdown
## Flow: [Name]
**Status:** PASS / FAIL / PARTIAL

### Happy Path
- [x] Step 1: Navigate to /signup → loads correctly
- [x] Step 2: Fill form → fields accept input
- [x] Step 3: Submit → redirects to /dashboard
- [ ] Step 4: Dashboard loads user data → FAIL (shows "undefined" for username)

### Failures Found
1. **Username displays as "undefined"** — after successful login, dashboard greets "Hello, undefined"
   - Expected: "Hello, [actual username]"
   - Screenshot: [attach or describe]
   - Likely cause: profile fetch fails silently

### Screenshots
[Key step screenshots attached or described]
```

---

## State Verification

After each significant step, verify:

| What to check | How |
|--------------|-----|
| URL changed as expected | Check page URL |
| Success message displayed | Read page content |
| Data persisted | Refresh and check |
| No console errors | Check browser console |
| Network requests succeeded | Check network tab |

---

## Hard Rules

- **Run the app first.** Confirm the development server is running before starting tests.
- **Screenshot on failure.** Every failed step needs a screenshot or detailed description.
- **Test error states, not just happy paths.** An app that fails gracefully is still acceptable; one that fails silently is not.
- **Report what worked too.** "Steps 1–4 pass; step 5 fails" is more useful than "step 5 fails".
- **Don't fix bugs during testing.** Log findings, then fix separately.
