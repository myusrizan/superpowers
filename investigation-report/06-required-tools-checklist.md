# Required Tools Checklist

**Last audited:** 2026-03-07 (status updated 2026-03-07)
**Skills audited:** 48

At the start of each session, check this list. If a Tier 1 tool is missing, inform the user before proceeding with any task that depends on it.

---

## Tier 1 — Install now (skills broken without these)

| Status | Tool | Skills that need it | Install command |
|--------|------|---------------------|-----------------|
| [x] | **`gh`** (GitHub CLI) | `finishing-a-development-branch`, `autonomous-loops`, `receiving-code-review`, `github-cli` | v2.87.3 — installed 2026-03-07 |
| [x] | **`rg`** (ripgrep) | `search-first` (search checklist step 1) | v15.1.0 — installed 2026-03-07 |
| [x] | **Context7 MCP** | `search-first` (step 4a — fetch current library docs) | available as deferred tool — confirmed 2026-03-07 |

---

## Tier 2 — Install per project type (when that skill fires)

| Status | Tool | Skill | Install | When |
|--------|------|-------|---------|------|
| [ ] | `@playwright/test` | `e2e-testing` | `npm install -D @playwright/test` | Any project with browser E2E tests |
| [ ] | `pip-audit` | `dependency-management`, `security-review` | `pip install pip-audit` | Python projects |
| [ ] | `cargo-audit` | `dependency-management`, `security-review` | `cargo install cargo-audit` | Rust projects |
| [ ] | `bundler-audit` | `dependency-management` | `gem install bundler-audit` | Ruby projects |

---

## Tier 3 — No local install needed (reference / cloud only)

These appear in skills as options but are cloud services or CI-provisioned:

| Tool | Skill | Notes |
|------|-------|-------|
| Datadog, Prometheus, Grafana | `observability` | Cloud/infra platforms — no local install |
| Jaeger, Zipkin, AWS X-Ray | `observability` | Distributed tracing — cloud/infra |
| Docker | `ci-cd-pipeline` | Provisioned by CI runners; install locally only if building images |
| PostgreSQL, MySQL, Redis, MongoDB | `dependency-management`, `sensitive-data-guard`, `performance-profiling` | Database servers — project-specific, not skill-level requirement |

---

## How to verify Tier 1 is installed

```bash
gh --version          # GitHub CLI
rg --version          # ripgrep
claude mcp list       # should show context7
```

---

## Notes

- `npm`, `pip`, `cargo`, `git`, `poetry` — standard package managers, assumed present
- Update this file when new skills are added that require new tools
- Mark checkboxes as `[x]` once confirmed installed
