# Prerequisites — What to Install Before Superpowers

> Source: `investigation-report/06-required-tools-checklist.md`

---

## Tier 1 — Required (Install Before Installing Superpowers)

These tools are needed for core skills to function. Without them, several skills will silently break or produce incorrect outputs.

| Tool | Purpose in Superpowers | Install Command |
|------|------------------------|-----------------|
| **Claude Code** (CLI) | The runtime — Superpowers is a Claude Code plugin | [See Claude Code install guide](https://docs.anthropic.com/claude-code) |
| **`gh`** (GitHub CLI) | Used by `finishing-a-development-branch`, `autonomous-loops`, `receiving-code-review`, `github-cli` | `brew install gh` / `winget install gh` |
| **`rg`** (ripgrep) | Used by `search-first` (Step 1: codebase search) and `proactive-memory` (tag retrieval) | `brew install ripgrep` / `choco install ripgrep` |
| **Context7 MCP** | Used by `search-first` (Step 4a: live library docs) | `claude mcp add context7` |

Verify Tier 1 is ready:

```bash
gh --version
rg --version
claude mcp list   # look for context7
```

---

## Tier 2 — Per-Project (Install When Your Project Needs It)

Install these when starting a project that uses the corresponding skill.

| Tool | Skill | Install | When Needed |
|------|-------|---------|-------------|
| `@playwright/test` | `e2e-testing` | `npm install -D @playwright/test` | Browser end-to-end tests |
| `pip-audit` | `dependency-management`, `security-review` | `pip install pip-audit` | Python projects |
| `cargo-audit` | `dependency-management`, `security-review` | `cargo install cargo-audit` | Rust projects |
| `bundler-audit` | `dependency-management` | `gem install bundler-audit` | Ruby projects |
| `npm audit` | `dependency-management` | Built into npm (≥6) | Node.js projects |

---

## Tier 3 — Cloud/Infra (No Local Install)

These are referenced in skills but are cloud services or CI-only tools. No local installation needed.

- Datadog, Prometheus, Grafana (observability)
- Jaeger, Zipkin, AWS X-Ray (distributed tracing)
- Docker, PostgreSQL, MySQL, Redis, MongoDB (infra)
- GitHub Actions (CI/CD)

---

## Standard Tools (Assumed Present)

Superpowers assumes these are already on your machine:

- `git`
- `bash`
- `node` / `npm`
- `python` / `pip`
- `cargo` (for Rust projects)

---

## Platform Notes

| Platform | Notes |
|----------|-------|
| macOS/Linux | Full support; no special setup beyond Tier 1 |
| Windows | Hook runner uses a polyglot wrapper (`hooks/run-hook.cmd`). Requires bash (Git Bash or WSL). Fixed in v4.3.1. |

**Source:** `docs/windows/` for Windows-specific install details.
