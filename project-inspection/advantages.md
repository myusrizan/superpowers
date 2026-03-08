# Advantages of Installing Superpowers

> All advantages below are grounded in specific skills and files in this repo.

---

## 1. Systematic Workflows Replace Ad-Hoc Reasoning

Without Superpowers, Claude improvises. With it, Claude follows structured, repeatable processes.

**Examples from the skill files:**

- `coding/diagnosing` — 4-phase root cause analysis (debug mode): reproduce → pattern analysis → hypothesis testing → fix with test. Never jumps straight to "try this fix".
- `coding/test-driven-development` — Enforces RED-GREEN-REFACTOR per task. Claude writes a failing test first, watches it fail, then writes the minimum code to pass.
- `coding/feature-workflow` — Acts as a mandatory design gate before implementation (brainstorm phase). Claude explores alternatives via Socratic refinement before writing a single line of code.

---

## 2. Skills Fire Automatically

You do not need to remember to invoke skills. The `using-superpowers` skill, injected by the `hooks/session-start` hook on every session start, teaches Claude to detect applicable skills from your task description and invoke them before acting.

**Source:** `hooks/session-start`, `custom-skills/meta/using-superpowers/SKILL.md`

---

## 3. Parallel Agent Dispatch for Large Tasks

`agents/dispatching-parallel-agents` and `agents/subagent-driven-development` enable Claude to break large tasks into independent subtasks and run them in parallel as subagents, with wave-based dependency ordering.

The orchestrator uses ~15% of the context budget; subagents each get 100%. This avoids context exhaustion on large tasks.

**Source:** `custom-skills/agents/subagent-driven-development/SKILL.md`, `findings/gsd-get-shit-done.finding.md`

---

## 4. Evidence-First Verification

`coding/verification-before-completion` enforces: run the command, read the output, then report status. Claude is prevented from claiming success without running verification commands and reading the actual output.

**Source:** `custom-skills/coding/verification-before-completion/SKILL.md`

---

## 5. Search Before Building

`coding/search-first` requires Claude to search for existing libraries, MCPs, and skills before writing new code. Uses `rg` for codebase search and Context7 for live library documentation. Prevents reinventing the wheel.

**Source:** `custom-skills/coding/search-first/SKILL.md`

---

## 6. Built-In Security Review

`coding/security` provides two complementary reviews in one skill: a vulnerability review covering OWASP 10 threat categories (injection, auth, XSS, IDOR, config, data exposure, dependencies, logging, rate limiting, business logic), and a silent failure review catching empty catch blocks, swallowed exceptions, and unjustified fallbacks — both before every merge.

`meta/sensitive-data-guard` intercepts credentials or PII in shared content with mandatory revocation warnings before any analysis proceeds.

**Source:** `custom-skills/coding/security/SKILL.md`, `custom-skills/meta/sensitive-data-guard/SKILL.md`

---

## 7. Session Continuity Across Context Compaction

`meta/session-memory` covers the full session lifecycle in one skill: Mode A writes small tagged observations to `logs/observations.md` throughout the session (append-only, `rg`-searchable by `#hashtag`); Mode B saves a full context log on request; Mode C loads the most recent log at session start and confirms before resuming. The hook auto-injects recent logs (≤150 lines).

**Source:** `custom-skills/meta/session-memory/SKILL.md`

---

## 8. Autonomous Loop Patterns

`agents/autonomous-loops` provides 5 ready-made patterns for Claude running without user input:

- Sequential batch pipeline
- De-sloppify (quality improvement pass)
- Infinite monitoring loop
- Continuous PR review loop
- RFC-driven parallel DAG

Each pattern includes a termination condition checklist and circuit breaker pattern to prevent runaway loops.

**Source:** `custom-skills/agents/autonomous-loops/SKILL.md`

---

## 9. CLAUDE.md Auditing

`meta/claude-md-improver` runs a 5-phase audit of your project's CLAUDE.md using 6 criteria: Actionability, Specificity, Currency, Completeness, Conflict detection, and Format correctness. Proposes and applies improvements.

**Source:** `custom-skills/meta/claude-md-improver/SKILL.md`

---

## 10. Extensible — Build Your Own Skills

`meta/skill-management` covers both phases of the skill lifecycle: creation (intent → draft → TDD pressure test with subagent → evaluate → iterate → optimize description) and stocktake (audit all skills for actionability, scope fit, uniqueness, currency). Both phases follow the same TDD philosophy — watch a subagent fail without the skill before writing it.

`scripts/build-skills.sh` rebuilds the catalog automatically from `custom-skills/` frontmatter. Add a new skill folder with a `SKILL.md` and it appears in the catalog on the next build. Three build profiles: `--code`, `--no-code`, or all.

**Source:** `custom-skills/meta/skill-management/SKILL.md`, `scripts/build-skills.sh`

---

## 11. Cross-Platform Support

Works on macOS, Linux, Windows (via `hooks/run-hook.cmd` polyglot wrapper), Cursor, Codex, and OpenCode — not just Claude Code.

**Source:** `docs/README.codex.md`, `docs/README.opencode.md`, `docs/windows/`, `hooks/run-hook.cmd`

---

## 12. Mature Audit History — Known-Good State

The `investigation-report/` folder contains 7 audit reports. All 23 historical flaws are resolved. Skills have since been consolidated from 53 → 39 through 9 merges, reducing cognitive load while preserving all content. The system is in a known-good state with no open issues as of 2026-03-08.

**Source:** `investigation-report/03-critical-flaws.md`, `investigation-report/07-post-expansion-audit.md`
