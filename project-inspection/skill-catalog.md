# Skill Catalog — All 39 Skills

> Full reference for what you get when you install Superpowers.
> Source: `custom-skills/` directory (each `SKILL.md`)
> Last updated: 2026-03-08 (post-merge consolidation: 53 → 39 skills)

---

## coding/ — 17 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `advanced-testing` | Writing/debugging E2E tests or building AI eval systems | **E2E mode:** Page Object Model, flaky test quarantine, condition-based waits (Playwright/Cypress), CI artifact collection. **Eval mode:** capability vs regression evals, `pass@k` / `pass^k` metrics, code/model/human graders, prompt injection protection |
| `api-design` | Designing or reviewing REST API endpoints | URL structure, HTTP semantics, pagination (offset vs cursor), versioning strategy, auth headers |
| `ci-cd-pipeline` | Building or debugging a CI/CD pipeline | Stage ordering, caching, secrets management, deployment strategies, `gh run` debugging |
| `code-review` | Completing tasks before merging, dispatched as subagent reviewer, or receiving feedback | **As requester:** dispatch reviewer subagent with git SHAs. **As reviewer:** spec compliance first, then code quality with confidence ≥80 scoring. **As recipient:** verify before implementing, technical pushback, no performative agreement |
| `codebase-analysis` | Starting in an unfamiliar codebase or producing a findings report | **Onboarding mode:** 6-layer reading order (identity → entry points → config → routing → key modules → tests), written mental model, parallel mapping for large codebases. **Investigating mode:** read everything first, structured findings report with severity |
| `database-migrations` | Schema changes | Expand-contract pattern, `CONCURRENTLY` indexes, batch updates, `UPSERT`, `SKIP LOCKED` |
| `dependency-management` | Adding libraries or auditing deps | Add vs build decisions, pinning strategy, lock file discipline, vulnerability audits |
| `diagnosing` | Debugging a bug/failure or optimizing performance | **Debug mode:** 4-phase root cause (reproduce → pattern → hypothesis → fix with test). No fixes without root cause. **Profiling mode:** measure baseline → profile → one fix → measure again |
| `feature-workflow` | Starting any new feature, having a spec to plan, or having a plan to execute | **Brainstorm phase:** mandatory design gate, Socratic refinement, 2–3 alternatives, design doc. **Plan phase:** bite-sized tasks with exact code/commands, plan verification subagent. **Execute phase:** batch execution with checkpoints |
| `observability` | Adding logging, metrics, or tracing | Structured logging, metrics (counter/gauge/histogram), distributed tracing, SLO-based alerting |
| `planning-sessions` | Prioritizing a backlog of features or tasks | Dependency ordering, value/effort ratio — produces prioritized plan |
| `refactoring` | Improving structure of working code | Characterization tests first, one refactoring type at a time, undo on red |
| `search-first` | Before building anything new | Search codebase (`rg`) → NPM/PyPI/crates.io → Context7 docs — before writing a single line |
| `security` | Reviewing code before merge or deploy | **Vulnerability review:** attack surface map → OWASP 10 threat categories → severity output. **Silent failure review:** empty catch blocks, swallowed exceptions, unjustified fallbacks, critical path zero-tolerance, `[APPROVED_OVERRIDE]` pattern |
| `test-driven-development` | Writing any feature or bugfix | RED-GREEN-REFACTOR: failing test first, minimum code to pass, then refactor |
| `ui-ux-design` | Building any UI or visual interface | Industry-matched design: analyze context, select style system, accessibility, interaction standards |
| `verification-before-completion` | Before declaring any task done | Run the command, read the output, then report status — never claim success without evidence |

---

## agents/ — 5 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `autonomous-loops` | Designing Claude to run without user input | 5 loop patterns: sequential pipeline, de-sloppify, infinite, continuous PR, RFC-driven DAG; circuit breaker + termination checklist |
| `dispatching-parallel-agents` | 2+ independent tasks that can run in parallel | Parallel subagent dispatch with wave-based dependency ordering |
| `iterative-retrieval` | Subagent needs to gather context progressively | Broad dispatch → score (0–1) → refine → max 3 cycles |
| `mcp-server` | Building a custom MCP server | FastMCP-based MCP servers: tool design, input validation, registration with Claude/Cursor |
| `subagent-driven-development` | Executing a plan with 3+ independent tasks | Per-task subagent dispatch with 2-stage review; ~15% orchestrator / 100% subagent context budget |

---

## git/ — 4 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `finishing-a-development-branch` | Implementation complete, all tests pass | Verify tests → 4 options (merge/PR/keep/discard) → cleanup worktree |
| `github-cli` | GitHub operations via CLI | Issues, CI runs, releases, search, repo operations via `gh`; JSON output, scripting |
| `history-archaeology` | Tracing a bug's origin or understanding why code exists | `git blame`, `bisect`, `log -S` pickaxe, `show` |
| `using-git-worktrees` | Starting feature work needing isolation | Isolated worktrees with smart directory selection and safety verification |

---

## thinking/ — 3 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `decision-making` | High-stakes choices between concrete options | Structured evaluation: options → criteria → pre-mortem → score → commit |
| `reasoning` | Complex problems needing structured thinking tools | First principles, pre-mortem, assumption mapping, inversion, devil's advocate |
| `thinking-partner` | User wants opinions, challenge, or thought partnership | 4 modes: Opinion / Ideation / Challenge / Sounding Board |

---

## qol/ — 5 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `documenting` | Writing technical documentation | READMEs, API docs, ADRs, CHANGELOG entries — type-specific structures |
| `drafting` | Writing messages, emails, or announcements | Point-first, tone-calibrated — messages, emails, Slack posts |
| `explaining` | Explaining a concept to someone | Audience-calibrated with analogies and layered complexity |
| `researching` | Researching a topic or comparing options | Multi-source synthesis: direct answer first, evidence, caveats, confidence |
| `summarizing` | Summarizing long content | Bullet / narrative / executive / tldr — format matched to content |

---

## meta/ — 6 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `claude-md-improver` | Auditing or improving CLAUDE.md | 5-phase audit: discover → assess (6 criteria) → report → propose → apply |
| `prompting` | Writing or generating prompts | **Efficiency mode:** 8 patterns for lean prompts (goal first, constrain output, batch requests, negative constraints). **Generation mode:** produce self-contained reusable prompts saved to `prompts/[category]/[name]/prompt.md` |
| `sensitive-data-guard` | Sharing content that may contain credentials or PII | Intercepts and warns — mandatory revocation warning before any analysis |
| `session-memory` | Mid-session observations, end-of-session save, or session start restore | **Mode A (observe):** append-only tagged observations to `logs/observations.md` with 3-tier `rg` retrieval. **Mode B (save):** full context log on explicit request. **Mode C (restore):** load last log, quick observation check, confirm before resuming |
| `skill-management` | Creating a skill or auditing the skill system | **Creation phase:** capture intent → draft → TDD pressure test → evaluate → iterate → optimize description. **Stocktake phase:** inventory all skills → score 4 criteria (actionability, scope fit, uniqueness, currency) → detect overlaps → report verdicts |
| `using-superpowers` | Every session start (auto-injected by hook) | Discovers available skills and invokes the right one before taking any action |
