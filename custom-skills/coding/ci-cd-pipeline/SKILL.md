---
name: ci-cd-pipeline
description: Use when designing, debugging, or reviewing CI/CD pipelines — pipeline structure, caching strategy, secrets management, deployment strategies, or troubleshooting failed pipeline runs
---

# CI/CD Pipeline

## Overview

A CI/CD pipeline is the automated path from a commit to production. It enforces quality gates (lint, test, build) before anything ships, and automates deployment so shipping is repeatable and low-stress.

**Core principle:** The pipeline is the single source of truth for build correctness. If it passes, the code is releasable. If it's slow or flaky, it becomes ignored — which defeats the purpose.

---

## Pipeline Stage Order

```
commit → [lint] → [test] → [build] → [deploy]
```

**Why this order:**

| Stage | Runs before | Reason |
|-------|-------------|--------|
| Lint | Tests | Catch obvious issues cheaply (seconds, not minutes) |
| Tests | Build | No point building code that doesn't pass tests |
| Build | Deploy | Only build artifacts that are tested |
| Deploy | — | Only deploy tested, built artifacts |

**Fail fast:** Each stage fails the pipeline immediately if it doesn't pass. Never run tests on code that doesn't lint. Never deploy code that doesn't build.

### Example (GitHub Actions)

```yaml
name: CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - run: npm run lint

  test:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - run: npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: build-artifact
          path: dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/download-artifact@v4
        with: { name: build-artifact, path: dist/ }
      - run: ./deploy.sh
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
```

---

## Caching Strategy

Caching package installs is the single biggest speed improvement for most pipelines.

### Node.js

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: npm          # Caches ~/.npm based on package-lock.json hash
```

After cache hit: `npm ci` restores from `~/.npm`, skips network download.
Cache key: automatically derived from `package-lock.json` hash — invalidates on dependency changes.

### Python

```yaml
- uses: actions/setup-python@v5
  with:
    python-version: "3.12"
    cache: pip           # Caches pip download cache
- run: pip install -r requirements.txt
```

### Docker layers

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3

- name: Build and push
  uses: docker/build-push-action@v5
  with:
    cache-from: type=gha       # GitHub Actions cache
    cache-to: type=gha,mode=max
```

Layer caching: unchanged layers from previous builds are reused. Order `Dockerfile` instructions from least-frequently-changed (base image, OS deps) to most-frequently-changed (app code).

```dockerfile
# Good order — cache-friendly
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./      # Changes rarely
RUN npm ci                 # Cached when package.json unchanged
COPY . .                   # Changes every commit
RUN npm run build
```

---

## Secrets Management

**Never put secrets in:**
- Source code (even encrypted)
- CI configuration YAML files
- Build artifacts
- Pipeline logs (mask secrets in output)

**Always use:**
- CI platform secret storage (GitHub Actions Secrets, GitLab CI Variables)
- At runtime: environment variables injected by the CI system
- For production: secret managers (AWS Secrets Manager, HashiCorp Vault, GCP Secret Manager)

```yaml
# GitHub Actions — reference secrets by name only
- run: ./deploy.sh
  env:
    API_KEY: ${{ secrets.API_KEY }}
    DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
```

**Verify secrets are masked in logs:**
```bash
# In GitHub Actions, registered secrets are automatically masked in logs
# Test by echoing — it should appear as ***
echo "$SECRET"  # → ***
```

**Rotation:** Rotate secrets on a schedule (quarterly minimum) and immediately after personnel changes or suspected exposure.

---

## Deployment Strategies

### Rolling deployment

Replace instances one at a time (or in batches):

```
v1  v1  v1  v1     →    v2  v1  v1  v1    →    v2  v2  v1  v1    →    v2  v2  v2  v2
```

- **Pros:** Simple, low infrastructure cost, gradual rollout
- **Cons:** Both versions run simultaneously during deploy, rollback requires re-deploy
- **Use when:** Stateless services, can tolerate mixed versions briefly

### Blue-green deployment

Maintain two identical environments, switch traffic:

```
[Traffic] → Blue (v1)         [Traffic] → Green (v2)
             Green (v2) ready →            Blue (v1) idle (instant rollback)
```

- **Pros:** Zero downtime, instant rollback (switch traffic back)
- **Cons:** 2x infrastructure cost, database migrations must be backward-compatible
- **Use when:** Zero-downtime is required, can afford duplicate environment

### Canary deployment

Route a small percentage of traffic to the new version:

```
[Traffic] → 95% → v1
             5%  → v2 (canary)
```

Gradually increase: 5% → 20% → 50% → 100% once metrics confirm stability.

- **Pros:** Risk-controlled, real traffic validation, easy automated rollback
- **Cons:** Requires sophisticated traffic routing, both versions must be compatible
- **Use when:** High-risk changes, large user bases where even 1% is meaningful signal

### Decision table

| Need | Strategy |
|------|----------|
| Simplest option | Rolling |
| Zero downtime, instant rollback | Blue-green |
| Risk-controlled gradual rollout | Canary |
| Database schema changes | Blue-green with expand-contract migrations |

---

## Debugging Failed Pipelines

### Process

1. **Read from the top of the failure.** Error messages are often buried under stack traces. The first failure in the log is usually the root cause.
2. **Check the exit code.** `exit 1` = explicit failure; non-zero codes have meanings.
3. **Reproduce locally.** Run the exact command that failed in your local environment.
4. **Check environment drift.** CI often has a different OS, Node/Python/Go version, or missing env vars. Match the CI environment locally.

### Common failure categories

| Failure | Likely cause | Investigation |
|---------|-------------|---------------|
| Works locally, fails in CI | Environment difference | Check OS, language version, env vars, file permissions |
| Intermittent failures | Flaky test or network dependency | See flaky CI section below |
| Cache-related failures | Stale cache after dependency change | Clear cache and re-run |
| Secret not found | Missing secret registration | Check CI secret storage |
| Out of memory | Test or build running out of RAM | Increase runner memory, reduce parallelism |
| Slow pipeline | No caching, large artifacts | Profile stage durations, add caching |

### Flaky CI

A flaky pipeline step fails sometimes without code changes. Types:

| Flake type | Signal | Fix |
|------------|--------|-----|
| Infrastructure flake | Fails at different test each time | Retry once automatically; report to CI provider |
| Test flake | Same test fails 20-30% of runs | Mark as flaky, quarantine, fix root cause |
| Code flake | Fails consistently on affected code | It's a real bug, not flakiness |

```yaml
# GitHub Actions — retry a step automatically on failure
- name: Run tests
  run: npm test
  continue-on-error: false
  id: tests
- name: Retry tests once on failure
  if: steps.tests.outcome == 'failure'
  run: npm test
```

**Rule:** Don't let flaky tests hide in CI with `continue-on-error: true`. Quarantine them explicitly with tracking issues.

---

## Hard Rules

- **Fail fast.** Lint before test. Test before build. Build before deploy. Never skip stages.
- **Secrets in CI secret storage only.** Never in YAML, source code, or logs.
- **Lock file in CI.** Use `npm ci`, not `npm install`. The lockfile is the source of truth for reproducibility.
- **Cache package installs.** Every pipeline run downloading dependencies from the internet is slow and fragile.
- **Read from the top when debugging.** The first failure in a log is the cause; everything after is the cascade.
- **Quarantine, don't ignore, flaky tests.** A `continue-on-error` on a test stage is not a fix.
