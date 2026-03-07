---
name: e2e-testing
description: Use when writing, organizing, or debugging end-to-end tests — including Playwright, Cypress, or Selenium work. Invoke when E2E tests are flaky, slow, or missing, or when browser automation is needed.
---

# End-to-End Testing

## Overview

E2E tests verify the system works from a user's perspective: real browser, real DOM, real API calls. They are slow and flaky by nature. The goal is a small, reliable suite that catches real integration failures — not to cover every edge case (unit tests do that).

**Core principle:** Wait for conditions, not time. Structure tests around user intent, not implementation details.

---

## Directory Structure

```
tests/
  e2e/
    auth/
      login.spec.ts
      logout.spec.ts
    features/
      search.spec.ts
      checkout.spec.ts
    api/
      users.api.spec.ts
    fixtures/
      auth.fixture.ts
      db.fixture.ts
    pages/               ← Page Object Model
      LoginPage.ts
      SearchPage.ts
    playwright.config.ts
```

---

## Page Object Model (POM)

The POM pattern encapsulates page interactions. Tests describe what to do; page objects describe how to do it.

```typescript
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}

  // Locators as properties — not methods
  emailInput = this.page.locator('[data-testid="email-input"]');
  passwordInput = this.page.locator('[data-testid="password-input"]');
  submitButton = this.page.locator('[data-testid="submit-btn"]');
  errorMessage = this.page.locator('[data-testid="error-message"]');

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}
```

```typescript
// auth/login.spec.ts
test('successful login redirects to dashboard', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password123');
  await expect(page).toHaveURL('/dashboard');
});
```

**POM rules:**
- Page objects contain selectors and actions, not assertions
- Assertions stay in the test
- One page object per meaningful page or component
- Use `data-testid` attributes — they survive CSS/class refactors

---

## Wait Strategy

**Never use arbitrary timeouts.** They make tests slow and still flaky.

```typescript
// Wrong — arbitrary wait
await page.waitForTimeout(5000);

// Right — wait for a condition
await page.waitForResponse(resp => resp.url().includes('/api/users') && resp.status() === 200);
await page.waitForSelector('[data-testid="user-list"]');
await expect(page.locator('.loading-spinner')).toBeHidden();
```

**Condition-based wait patterns:**

| Scenario | Wait for |
|----------|---------|
| After form submit | Network response OR success indicator |
| After navigation | `page.waitForURL()` |
| After async render | Element to be visible |
| After data load | Loading indicator to disappear |

---

## Playwright Configuration

```typescript
// playwright.config.ts
export default defineConfig({
  testDir: './tests/e2e',
  timeout: 30_000,
  retries: process.env.CI ? 2 : 0,  // Retry only in CI
  use: {
    baseURL: process.env.BASE_URL ?? 'http://localhost:3000',
    headless: true,
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
  ],
});
```

**Key settings:**
- `retries: 2` in CI catches transient failures without masking real bugs
- `screenshot`, `video`, `trace` on failure only — not on every passing test
- `baseURL` from env — same test code, different environments

---

## Flaky Test Management

### Identify flaky tests

```bash
# Run the test 10 times in a row to reveal flakiness
npx playwright test my-test.spec.ts --repeat-each=10
```

### Quarantine pattern

When a test goes flaky in CI, quarantine immediately — don't let it block the pipeline:

```typescript
// Mark flaky tests explicitly while investigating
test.fixme('checkout with coupon code', async ({ page }) => {
  // Tracked in: https://github.com/org/repo/issues/456
  // Flaky since: 2024-03-15
  // Root cause: race condition in payment widget
  ...
});
```

**Never use `test.skip()` to silence flakiness without a tracking comment.** It becomes permanently skipped.

### Common flakiness causes and fixes

| Cause | Fix |
|-------|-----|
| Timing-dependent selectors | Wait for specific network responses |
| Shared test state | Isolate test data per test (fixtures) |
| External service calls | Mock external services |
| Element not in viewport | Scroll to element before interacting |
| Animations | Disable animations in test config |

### Environment-specific skips

If a test must be skipped in specific environments, use an explicit env variable:

```typescript
// Wrong — dangerous if CI_ENV is unset or misconfigured
test.skip(process.env.NODE_ENV === 'production', 'Skip on production');

// Right — explicit, intentional flag
test.skip(!!process.env.SKIP_PAYMENT_TESTS, 'Payment tests disabled via SKIP_PAYMENT_TESTS');
```

The `NODE_ENV` approach is unsafe: a deployment with an unset `NODE_ENV` would run tests against production. Use purpose-specific flags.

---

## Test Fixtures

Fixtures handle setup and teardown. Use them for auth state and database seeding.

```typescript
// fixtures/auth.fixture.ts
export const authFixture = base.extend<{ authenticatedPage: Page }>({
  authenticatedPage: async ({ page }, use) => {
    // Setup: log in once
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('test@example.com', 'testpassword');
    await page.waitForURL('/dashboard');

    // Provide authenticated page to the test
    await use(page);

    // Teardown: nothing needed — browser context is isolated
  },
});
```

---

## Artifact Collection

```typescript
// playwright.config.ts
reporter: [
  ['html', { outputFolder: 'playwright-report' }],
  ['junit', { outputFile: 'test-results/junit.xml' }],
]
```

Artifacts tell you exactly what happened when a test failed. Screenshots + trace = full replay capability.

---

## CI/CD Integration (GitHub Actions)

```yaml
- name: Run E2E tests
  run: npx playwright test
  env:
    BASE_URL: http://localhost:3000
    CI: true

- name: Upload artifacts on failure
  uses: actions/upload-artifact@v3
  if: failure()
  with:
    name: playwright-artifacts
    path: |
      playwright-report/
      test-results/
    retention-days: 30
```

**Upload artifacts only on failure** — not on every run. Artifact storage is expensive at scale.

---

## What E2E Tests Should NOT Cover

- Every edge case and validation rule (unit tests)
- Every error message (unit/integration tests)
- Performance benchmarks (load testing tools)
- Visual regression (dedicated visual testing tools)

E2E tests are expensive. Keep the suite small and focused on critical user journeys.

---

## Hard Rules

- **One Page Object per page/component.** Tests should read as user stories, not as DOM selectors.
- **No `waitForTimeout()`.** Every wait must be condition-based.
- **Quarantine flaky tests immediately.** A flaky test is worse than no test — it trains people to ignore failures.
- **Isolate test data.** Tests that share database state will fail non-deterministically.
- **Never use `NODE_ENV` as a test skip condition.** Use explicit purpose-specific environment flags.
- **Collect artifacts on failure only.** Screenshots/video/traces for every test wastes storage.
