# Custom Skills System — Part 7: Post-Expansion Audit (2026-03-07)

> Scope: All 51 skills across 7 categories
> Trigger: Session expansion added 3 new skills (git/history-archaeology, git/github-cli, agents/mcp-server) + GSD investigation prompted review
> Updated: Session 4 (2026-03-07) — FLAW-17 resolved, autonomous-loops GREEN, eval-harness GREEN, database-migrations GREEN

---

## Executive Summary

**System Health: Good**

51 skills audited. 3 new flaws identified (FLAW-21 through FLAW-23), all resolved in this session. The system is structurally sound. No skills recommended for retirement or merger.

One notable improvement beyond flaw fixes: `coding/writing-plans` received a new **Plan Verification** section based on the GSD gsd-plan-checker pattern — a subagent is dispatched after plan drafting to validate atomicity, dependency ordering, completeness, and TDD compliance before handing off to execution.

---

## Per-Skill Health Summary

Skills not listed here are unchanged from the 2026-03-07 audit and remain GREEN.

| Skill | Status | Notes |
|-------|--------|-------|
| `coding/writing-plans` | GREEN (improved) | Plan verification subagent section added |
| `meta/skill-stocktake` | GREEN (fixed) | FLAW-21: save location corrected |
| `meta/session-resume` | GREEN (fixed) | FLAW-22: stale hook tag reference removed |
| `agents/mcp-server` | GREEN (fixed) | FLAW-23: Context7 reference added for FastMCP docs |
| `coding/systematic-debugging` | GREEN (not re-read) | Pressure-tested GREEN in prior audit; no change since |
| `agents/autonomous-loops` | GREEN (fixed) | Session 4: termination condition checklist added — YELLOW gap closed |
| `coding/eval-harness` | GREEN (pressure-tested) | Session 4: actionability HIGH, scope fit HIGH, currency HIGH. Minor: run.py runner not defined (acceptable for pattern-level reference) |
| `coding/database-migrations` | GREEN (pressure-tested) | Session 4: comprehensive coverage, multi-tool, actionable. PostgreSQL-focused and clearly marked. No gaps |
| `meta/writing-skills` | GREEN (fixed) | Session 4: FLAW-17 resolved — split into lean SKILL.md (~140 lines) + detail.md (~300 lines, on-demand) |

### autonomous-loops: GREEN (Session 4 fix)

Termination condition checklist added. The skill now includes: success condition definition, failure/escalation conditions (max iteration ceiling, stuck-state detection), user escalation triggers, and a reference bash snippet enforcing `MAX_ITERATIONS`. The `while true` without guard rule is now an explicit Hard Rule.

### All other 47 skills

Reviewed systematically. All remaining skills are:
- Actionability: High or Medium
- Scope Fit: High (distinct trigger conditions)
- Uniqueness: High (no significant overlaps detected)
- Currency: High (content reflects current tooling)

No retirements or mergers recommended.

---

## New Flaws

### FLAW-21: `skill-stocktake` save location conflict
**Severity:** Low
**Status:** RESOLVED
**Skill:** `meta/skill-stocktake`

**Problem:** Line 199 said `"Save the report in findings/ or logs/"`. The `findings/` directory is reserved by project convention for external repo `.finding.md` files only. Stocktake reports are internal audits and belong in `investigation-report/`.

**Fix applied:** Changed to `"Save the report in investigation-report/ (increment the number prefix) — it's a record of decisions made, not an external repo investigation (findings/ is reserved for those)."`

---

### FLAW-22: `session-resume` relies on unimplemented session-start hook
**Severity:** Low
**Status:** RESOLVED
**Skill:** `meta/session-resume`

**Problem:** Step 1 said "Check if a log was already injected by session-start (it will appear in `<previous-session-context>` tags)." No session-start hook injecting these tags has been implemented. The skill was directing Claude to look for something that doesn't exist, potentially causing confusion at step 1.

**Fix applied:** Removed the hook check. Step 1 now goes directly to scanning `logs/` with `ls -t`. Updated the integration diagram to remove the hook reference.

---

### FLAW-23: `mcp-server` lacks current docs reference for FastMCP
**Severity:** Low
**Status:** RESOLVED
**Skill:** `agents/mcp-server`

**Problem:** FastMCP is an actively evolving library. The skill's code examples were written at a point in time but contain no mechanism to check for API changes. Users implementing from this skill may encounter outdated patterns (e.g., constructor signatures, transport config).

**Fix applied:** Added a Context7 callout before the FastMCP pattern section directing users to fetch current docs via `mcp__context7__resolve-library-id` → `mcp__context7__query-docs` before implementing.

---

## Open Flaws (Cumulative)

| # | Flaw | Severity | Status |
|---|------|----------|--------|
| FLAW-17 | `writing-skills` verbosity — long session-load skill | Low | **Resolved** (Session 4) |
| FLAW-21 | `skill-stocktake` save location (`findings/` → `investigation-report/`) | Low | **Resolved** |
| FLAW-22 | `session-resume` stale hook tag reference | Low | **Resolved** |
| FLAW-23 | `mcp-server` missing Context7 reference for FastMCP | Low | **Resolved** |

All flaws resolved. No open flaws.

---

## Required Tools per Skill

Tools and libraries that must be installed for specific skills to work. Grouped by install method.

### brew (macOS)

| Tool | Install | Required By |
|------|---------|-------------|
| `gh` (GitHub CLI) | `brew install gh` | `git/github-cli`, `git/finishing-a-development-branch`, `coding/ci-cd-pipeline`, `agents/autonomous-loops` |
| `rg` (ripgrep) | `brew install ripgrep` | `coding/dependency-management`, `coding/search-first` |
| `git` 2.5+ (worktrees) | Built-in or `brew install git` | `git/using-git-worktrees`, `git/history-archaeology`, `git/finishing-a-development-branch` |
| `jq` | `brew install jq` | `git/github-cli` (JSON scripting in gh commands) |
| `hyperfine` | `brew install hyperfine` | `coding/performance-profiling` (CLI benchmarking) |

### npm / Node

| Tool | Install | Required By |
|------|---------|-------------|
| Playwright | `npm install -D @playwright/test && npx playwright install` | `coding/e2e-testing` |
| `depcheck` | `npm install -g depcheck` | `coding/dependency-management` |

### pip / Python

| Tool | Install | Required By |
|------|---------|-------------|
| `fastmcp` | `pip install fastmcp` or `uv add fastmcp` | `agents/mcp-server` |
| `py-spy` | `pip install py-spy` | `coding/performance-profiling` (Python CPU profiler) |
| `pip-audit` | `pip install pip-audit` | `coding/security-review`, `coding/dependency-management` |

### cargo / Rust

| Tool | Install | Required By |
|------|---------|-------------|
| `cargo audit` | `cargo install cargo-audit` | `coding/security-review` (Rust projects), `coding/dependency-management` |

### go

| Tool | Install | Required By |
|------|---------|-------------|
| `govulncheck` | `go install golang.org/x/vuln/cmd/govulncheck@latest` | `coding/security-review` (Go projects), `coding/dependency-management` |

### MCP

| Tool | Install | Required By |
|------|---------|-------------|
| Context7 MCP | `claude mcp add context7 npx @context7/mcp@latest` | `coding/search-first` (step 4a), `agents/mcp-server` (FastMCP doc fetch) |

### Built-in / Platform

| Tool | Notes | Required By |
|------|-------|-------------|
| Python 3 | Built-in on macOS; `brew install python` if missing | `agents/mcp-server`, `coding/eval-harness` |
| `git` | Built-in on macOS with Xcode CLI tools | All `git/` category skills |

### Skills with no external tooling requirements

Skills that run on Claude capabilities alone (no install needed):

`coding/api-design`, `coding/brainstorming`, `coding/code-reviewer`, `coding/executing-plans`, `coding/investigating`, `coding/onboarding-to-codebase`, `coding/planning-sessions`, `coding/receiving-code-review`, `coding/refactoring`, `coding/requesting-code-review`, `coding/silent-failure-hunter`, `coding/systematic-debugging`, `coding/test-driven-development`, `coding/ui-ux-design`, `coding/verification-before-completion`, `coding/writing-plans`, `agents/dispatching-parallel-agents`, `agents/iterative-retrieval`, `agents/subagent-driven-development`, `agents/autonomous-loops`, `thinking/decision-making`, `thinking/reasoning`, `thinking/thinking-partner`, `meta/capturing-context`, `meta/claude-md-improver`, `meta/prompt-efficiency`, `meta/prompt-generator`, `meta/sensitive-data-guard`, `meta/session-resume`, `meta/skill-creator`, `meta/skill-stocktake`, `meta/using-superpowers`, `meta/writing-skills`, `qol/documenting`, `qol/drafting`, `qol/explaining`, `qol/researching`, `qol/summarizing`

---

## Recommended Next Actions

All session 4 actions completed. No open items.

| # | Action | Status |
|---|--------|--------|
| 1 | Add termination condition checklist to `autonomous-loops` | **Done** (Session 4) |
| 2 | Pressure-test `eval-harness` | **Done** — GREEN |
| 3 | Resolve FLAW-17 (`writing-skills` verbosity) | **Done** (Session 4) |
| 4 | Pressure-test `database-migrations` | **Done** — GREEN |

System is clean. Next audit trigger: when 5+ new skills are added (catalog hits 56) or a skill misbehaves in production use.
