# Skill Catalog — All 53 Skills

> Full reference for what you get when you install Superpowers.
> Source: `custom-skills/` directory (each `SKILL.md`)

---

## coding/ — 26 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `api-design` | Designing a REST API | URL structure, HTTP semantics, pagination (offset vs cursor), versioning strategy |
| `brainstorming` | Starting any new feature or change | Mandatory design gate — Socratic refinement, explores alternatives, saves design doc |
| `ci-cd-pipeline` | Building or debugging a pipeline | Stage ordering, caching, secrets management, deployment strategies, `gh run` debugging |
| `code-reviewer` | Reviewing code (dispatched as subagent) | Spec compliance first, then code quality — structured findings report |
| `database-migrations` | Schema changes | Expand-contract pattern, `CONCURRENTLY` indexes, batch updates, `UPSERT`, `SKIP LOCKED` |
| `dependency-management` | Adding libraries or auditing deps | Add vs build decisions, pinning strategy, lock file discipline, vulnerability audits |
| `e2e-testing` | Writing browser/E2E tests | Page Object Model, flaky test quarantine, condition-based waits, CI artifact collection |
| `eval-harness` | Building eval systems for AI | Eval-driven development, capability vs regression evals, `pass@k` metrics, graders |
| `executing-plans` | Running a written plan | Implements plans in batches with human review checkpoints |
| `investigating` | Investigating a codebase or system | Systematic investigation — produces structured findings report |
| `observability` | Adding monitoring/logging | Structured logging, metrics (counter/gauge/histogram), distributed tracing, SLO-based alerting |
| `onboarding-to-codebase` | Starting in an unfamiliar codebase | 6-layer reading order — produces written mental model |
| `performance-profiling` | Fixing performance issues | Measure → profile → hypothesis → one fix → measure again (never optimize without profiling) |
| `planning-sessions` | Prioritizing a backlog | Dependency ordering, value/effort ratio — produces prioritized plan |
| `receiving-code-review` | Responding to review feedback | Structured process: technical rigor, no defensive responses |
| `refactoring` | Refactoring existing code | Characterization tests first, one refactoring type at a time, undo on red |
| `requesting-code-review` | Requesting a code review | Dispatches `code-reviewer` subagent with full context |
| `search-first` | Before building anything new | Search codebase (`rg`), then NPM/PyPI/crates.io, then Context7 docs — before writing code |
| `security-review` | Reviewing security of code/system | 3-phase OWASP-aligned review: attack surface → 10 threat categories → severity output |
| `silent-failure-hunter` | Hunting swallowed errors | Finds empty catch blocks, non-actionable errors, unjustified fallbacks; APPROVED_OVERRIDE concept |
| `systematic-debugging` | Debugging a bug | 4-phase: reproduce → pattern analysis → hypothesis testing → fix with test |
| `test-driven-development` | Writing code with tests | RED-GREEN-REFACTOR: failing test first, minimum code to pass, then refactor |
| `ui-ux-design` | Building UI/UX | Industry-matched design: analyze context, select style system, accessibility, interaction standards |
| `verification-before-completion` | Before declaring a task done | Run the command, read the output, then report status — never claim success without evidence |
| `writing-plans` | Writing an implementation plan | Detailed plans with exact code, exact commands, expected outputs + plan verification subagent |

---

## meta/ — 10 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `capturing-context` | Before context compaction or end of session | Saves session state to `logs/` for next session |
| `claude-md-improver` | Auditing or improving CLAUDE.md | 5-phase audit: discover → assess (6 criteria) → report → propose → apply |
| `proactive-memory` | Mid-session observations to retain | Append-only observation log at `logs/observations.md` with hashtag retrieval via `rg` |
| `prompt-efficiency` | Writing Claude prompts | 8 patterns for token-efficient prompts: goal first, output constraints, batching, structure |
| `prompt-generator` | Generating reusable system prompts | Creates and saves prompts to `prompts/` |
| `sensitive-data-guard` | Sharing content with credentials/PII | Intercepts and warns — mandatory revocation warning before any analysis |
| `session-resume` | Starting a new session | Loads most recent context log, reconstructs state, confirms before resuming |
| `skill-creator` | Creating a new skill | Full creation process: intent → draft → test → evaluate → iterate → optimize |
| `skill-stocktake` | Auditing existing skills | Systematic audit: actionability, scope, uniqueness, currency → Keep/Improve/Update/Retire/Merge |
| `using-superpowers` | Every session start (auto-injected) | Discovers available skills and invokes the right one before taking any action |
| `writing-skills` | Writing skills with quality | TDD for skill creation: RED → GREEN → REFACTOR |

---

## agents/ — 5 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `autonomous-loops` | Running Claude without user input | 5 loop patterns: sequential pipeline, de-sloppify, infinite, continuous PR, RFC-driven DAG; circuit breaker |
| `dispatching-parallel-agents` | Independent parallel subtasks | Parallel subagent dispatch with wave-based dependency ordering |
| `iterative-retrieval` | Gathering context over multiple rounds | Broad dispatch → score (0–1) → refine → max 3 cycles |
| `mcp-server` | Building a custom MCP server | FastMCP-based MCP servers: tool design, input validation, registration with Claude/Cursor |
| `subagent-driven-development` | Large implementation tasks | Per-task subagent dispatch with 2-stage review; 15% orchestrator / 100% subagent context budget |

---

## git/ — 4 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `finishing-a-development-branch` | Completing a branch | Verify tests → 4 options (merge/PR/keep/discard) → cleanup worktree |
| `github-cli` | GitHub operations via CLI | Issues, CI runs, releases, search, and repo operations via `gh`; JSON output, scripting |
| `history-archaeology` | Tracing a bug's origin | `git blame`, `bisect`, `log -S` pickaxe, `show` |
| `using-git-worktrees` | Isolated feature development | Isolated worktrees with smart directory selection and safety verification |

---

## thinking/ — 3 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `decision-making` | High-stakes choices | Structured evaluation: options → criteria → pre-mortem → score → commit |
| `reasoning` | Complex reasoning tasks | First principles, pre-mortem, assumption mapping, inversion, devil's advocate |
| `thinking-partner` | Thought partnership | 4 modes: Opinion / Ideation / Challenge / Sounding Board |

---

## qol/ — 5 Skills

| Skill | Trigger Scenario | What It Does |
|-------|-----------------|--------------|
| `documenting` | Writing documentation | READMEs, API docs, ADRs, CHANGELOG entries — type-specific structures |
| `drafting` | Writing messages or emails | Point-first, tone-calibrated — messages, emails, Slack posts |
| `explaining` | Explaining a concept | Audience-calibrated with analogies and layered complexity |
| `researching` | Researching a topic | Multi-source synthesis: direct answer first, evidence, caveats, confidence |
| `summarizing` | Summarizing content | Bullet / narrative / executive / tldr — format matched to content |
