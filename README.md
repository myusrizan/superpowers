# Superpowers

Superpowers is a complete software development workflow for your coding agents, built on top of a set of composable "skills" and some initial instructions that make sure your agent uses them.

## How it works

It starts from the moment you fire up your coding agent. As soon as it sees that you're building something, it *doesn't* just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do.

Once it's teased a spec out of the conversation, it shows it to you in chunks short enough to actually read and digest.

After you've signed off on the design, your agent puts together an implementation plan that's clear enough for an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing to follow. It emphasizes true red/green TDD, YAGNI (You Aren't Gonna Need It), and DRY.

Next up, once you say "go", it launches a *subagent-driven-development* process, having agents work through each engineering task, inspecting and reviewing their work, and continuing forward. It's not uncommon for Claude to be able to work autonomously for a couple hours at a time without deviating from the plan you put together.

There's a bunch more to it, but that's the core of the system. And because the skills trigger automatically, you don't need to do anything special. Your coding agent just has Superpowers.


## Sponsorship

If Superpowers has helped you do stuff that makes money and you are so inclined, I'd greatly appreciate it if you'd consider [sponsoring my opensource work](https://github.com/sponsors/obra).

Thanks!

- Jesse


## Installation

**Note:** Installation differs by platform. Claude Code or Cursor have built-in plugin marketplaces. Codex and OpenCode require manual setup.


### Claude Code (via Plugin Marketplace)

In Claude Code, register the marketplace first:

```bash
/plugin marketplace add obra/superpowers-marketplace
```

Then install the plugin from this marketplace:

```bash
/plugin install superpowers@superpowers-marketplace
```

### Cursor (via Plugin Marketplace)

In Cursor Agent chat, install from marketplace:

```text
/plugin-add superpowers
```

### Codex

Tell Codex:

```
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md
```

**Detailed docs:** [docs/README.codex.md](docs/README.codex.md)

### OpenCode

Tell OpenCode:

```
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
```

**Detailed docs:** [docs/README.opencode.md](docs/README.opencode.md)

### Install your local fork in another project

To use your locally modified version of Superpowers in another project:

```bash
/plugin install /path/to/superpowers
```

### Verify Installation

Start a new session in your chosen platform and ask for something that should trigger a skill (for example, "help me plan this feature" or "let's debug this issue"). The agent should automatically invoke the relevant superpowers skill.

## The Basic Workflow

1. **feature-workflow** (brainstorm phase) - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **feature-workflow** (plan phase) - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **subagent-driven-development** or **feature-workflow** (execute phase) - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **code-review** - Activates between tasks. Dispatches reviewer subagent, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## What's Inside

**51 skills** split into two delivery types:

| Type | Count | Location | Purpose |
|------|-------|----------|---------|
| **Chat skills** | 15 | `custom-skills/chat/` → `dist/` | Upload to Claude — behavioral, always-on |
| **Plugin skills** | 36 | `custom-skills/plugin/` → `skills/` | Claude Code plugin — task workflows, on-demand |

The skill catalog is auto-generated from frontmatter on every build — run `bash scripts/build-skills.sh` after adding or editing skills.

---

### Chat Skills (15) — upload `dist/*.zip` to Claude

These shape how Claude behaves in every conversation.

#### meta/ — Skill system (6 skills)

| Skill | What it does |
|-------|-------------|
| **md-improver** | 5-phase CLAUDE.md audit: discover → assess (6 criteria A–F) → report → propose → apply; includes auto-generate from codebase |
| **prompting** | Two modes: efficiency (8 patterns for lean prompts) and generation (produce reusable system prompts saved to `prompts/`) |
| **sensitive-data-guard** | Detects credentials/PII in shared content — mandatory revocation warning before any resolution |
| **session-memory** | Four modes: observe mid-session, save at end, restore at start, consolidate (deduplicate and compress stale observations) |
| **skill-management** | Two phases: create/write (pre-existence check, design, 4 validation tests) and stocktake (audit all skills for actionability, scope fit, uniqueness, currency) |
| **using-superpowers** | Mandatory session-start skill — discovers available skills before taking any action |

#### qol/ — Output production (6 skills)

| Skill | What it does |
|-------|-------------|
| **documenting** | READMEs, API docs, ADRs, CHANGELOG entries — type-specific structures; includes collaborative authoring protocol |
| **documents** | Two modes: read/extract PDFs (reports, contracts, financial docs) and create Office files (pptx/docx/xlsx via Python) |
| **drafting** | Messages, emails, Slack posts — point-first, tone-calibrated |
| **explaining** | Audience-calibrated explanations with analogies and layered complexity |
| **researching** | Multi-source synthesis — direct answer first, evidence, caveats, confidence |
| **summarizing** | Bullet / narrative / executive / tldr — format matched to content and need |

#### thinking/ — Intellectual engagement (3 skills)

| Skill | What it does |
|-------|-------------|
| **decision-making** | Structured evaluation for high-stakes choices: options → criteria → pre-mortem → score → commit |
| **reasoning** | First principles, pre-mortem, assumption mapping, inversion, devil's advocate |
| **thinking-partner** | 4 modes: Opinion / Ideation / Challenge / Sounding Board |

---

### Plugin Skills (36) — loaded by Claude Code from `skills/`

These are task-specific workflows invoked on-demand during development.

#### coding/ — Software development workflow (23 skills)

| Skill | What it does |
|-------|-------------|
| **advanced-testing** | Three modes: live interactive browser testing (user flows, happy path + edge cases); automated E2E test code (Playwright POM, flaky test quarantine, condition-based waits); AI eval harness (capability vs regression evals, pass@k metrics, graders) |
| **api-design** | REST API design: URL structure, HTTP semantics, pagination (offset vs cursor), versioning strategy |
| **architecture-patterns** | System architecture: layered, modular monolith, hexagonal, event-driven — pattern selection guide, decision framework, anti-patterns |
| **audit-website** | Full website health audit across performance (Core Web Vitals), accessibility (WCAG AA), SEO, and code quality — graded report with fixes |
| **better-auth** | Auth implementation: password hashing, session cookies, JWT best practices, OAuth 2.0, common vulnerabilities and mitigations |
| **ci-cd-pipeline** | Pipeline design and debugging: stage ordering, caching, secrets management, deployment strategies |
| **code-review** | Three roles: request review (dispatch reviewer subagent), perform review (spec compliance → code quality + excellence criteria), receive review (verify before implementing, technical pushback) |
| **codebase-analysis** | Two modes: onboarding (6-layer reading order, context map, written mental model before any changes) and investigating (read everything first, produce structured findings report) |
| **database-migrations** | Schema changes: expand-contract pattern, CONCURRENTLY indexes, batch updates, UPSERT, SKIP LOCKED queues |
| **dependency-management** | Add vs build decisions, pinning strategy, lock file discipline, vulnerability audits |
| **diagnosing** | Two modes: systematic debugging (4-phase root cause: reproduce → pattern → hypothesis → fix with test) and performance profiling (measure → profile → one fix → measure again) |
| **feature-workflow** | Three phases: brainstorm (design gate before any code), plan (bite-sized tasks with exact code/commands), execute (batch with checkpoints) |
| **observability** | Structured logging, metrics (counter/gauge/histogram), distributed tracing, SLO-based alerting |
| **planning-sessions** | Prioritizes a backlog of candidate features — dependency ordering, value/effort ratio, milestones; includes full adversarial planning mode (assumption mapping, failure analysis, pre-mortem, devil's advocate) |
| **refactoring** | Refactoring plan first, characterization tests, one type at a time, tests after every change, undo on red |
| **search-first** | Research before building — find existing libraries/MCPs/skills via `rg` and Context7 before writing a line of code |
| **security** | Two parts: vulnerability review (OWASP 10 threat categories, attack surface mapping) and silent failure review (empty catch blocks, swallowed exceptions, unjustified fallbacks, critical path zero-tolerance) |
| **supabase-postgres** | Postgres/Supabase patterns: schema design, RLS policies, query optimization, indexing rules, Supabase-specific client and Edge Function patterns |
| **tailwind-design-system** | Tailwind CSS design system: token configuration, CVA variant pattern, `cn()` helper, avoiding class sprawl |
| **test-driven-development** | RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, refactor |
| **typescript-advanced-types** | Advanced TypeScript: generics, conditional types, mapped types, template literals, discriminated unions, utility types |
| **ui-ux-design** | Industry-matched UI/UX (30 industry patterns) + component architecture (atomic design, state handling, composition) + design tokens (typography, color, spacing, z-axis) + anti-generic-AI checklist |
| **verification-before-completion** | Evidence before claims — run the command, read the output, then report status |

#### agents/ — Agent orchestration (7 skills)

| Skill | What it does |
|-------|-------------|
| **autonomous-loops** | 5 patterns for Claude running without user input: sequential pipeline, de-sloppify pass, infinite loop, continuous PR loop, RFC-driven DAG; includes circuit breaker and termination conditions |
| **dispatching-parallel-agents** | Parallel subagent dispatch for independent tasks with wave-based dependency ordering |
| **iterative-retrieval** | Subagent context-gathering: broad dispatch → score (0–1) → refine → max 3 cycles |
| **llm-council** | Multi-perspective reasoning: dispatch advocate, devil's advocate, and neutral analyst passes; synthesize consensus and surface genuine disagreements |
| **mcp-server** | Build MCP servers (Python FastMCP + TypeScript SDK): pre-implementation tool design, patterns, testing with MCP inspector, registration with Claude Code/Desktop/Cursor |
| **subagent-driven-development** | Per-task subagent dispatch with 2-stage review (spec compliance + code quality); ~15% orchestrator / 100% subagent context budget |
| **swarm-planner** | Coordinate large swarms of parallel agents: decompose into atomic work units, wave-based execution, context packages, merge and verify |

#### git/ — Version control (4 skills)

| Skill | What it does |
|-------|-------------|
| **finishing-a-development-branch** | Verify tests → 4 options (merge/PR/keep/discard) → cleanup worktree |
| **github-cli** | Issues, CI runs, releases, search, and repo operations via `gh` — JSON output, scripting, autonomous PR loops |
| **history-archaeology** | Trace bug origins via git blame, bisect, log -S pickaxe, and show — read history before forming hypotheses |
| **using-git-worktrees** | Isolated worktrees with smart directory selection and safety verification |

#### meta/ — Discovery & docs (2 skills)

| Skill | What it does |
|-------|-------------|
| **context7** | Fetch current library documentation via Context7 MCP before implementing — resolve library ID, query docs, apply to implementation |
| **find-skills** | Search skills.sh marketplace for agent skills — evaluate by install count and relevance, inspect before installing or adapting locally |

---

## Philosophy

- **Test-Driven Development** — Write tests first, always
- **Systematic over ad-hoc** — Process over guessing
- **Complexity reduction** — Simplicity as primary goal
- **Evidence over claims** — Verify before declaring success
- **Search before building** — Find existing solutions before writing new code
- **Skills trigger automatically** — The system works without remembering to invoke it

Read more: [Superpowers for Claude Code](https://blog.fsck.com/2025/10/09/superpowers/)

## Adding Custom Skills

Skills live in `custom-skills/` organized by type and category:

```
custom-skills/
  chat/               ← upload to Claude (dist/*.zip)
    meta/
    qol/
    thinking/
  plugin/             ← Claude Code plugin (skills/)
    agents/
    coding/
    git/
    meta/
```

After adding or editing a skill:

```bash
bash scripts/build-skills.sh
```

This rebuilds both `skills/` (plugin) and `dist/` (chat zips), and auto-regenerates the skill catalog in `using-superpowers/SKILL.md` from frontmatter.

Each skill is a directory containing `SKILL.md` with YAML frontmatter:

```yaml
---
name: my-skill
description: Use when [specific triggering condition]. Invoke whenever [adjacent condition] — even if the user doesn't explicitly mention [skill name].
---
```

The `description` field is the primary trigger mechanism. Make it specific but include adjacent phrasings — Claude undertriggers by default.

See `custom-skills/chat/meta/skill-management/SKILL.md` for the complete skill creation guide.

### Build profiles

```bash
bash scripts/build-skills.sh           # build both chat and plugin (default)
bash scripts/build-skills.sh --chat    # rebuild dist/ only (after editing a chat skill)
bash scripts/build-skills.sh --plugin  # rebuild skills/ only (after editing a plugin skill)
```

### Output locations

| Command | Output | Use for |
|---------|--------|---------|
| `--chat` | `dist/*.zip` | Upload individual .zip files to Claude |
| `--plugin` | `skills/` | Claude Code reads this automatically |

## Updating

Skills update automatically when you update the plugin:

```bash
/plugin update superpowers
```

## License

MIT License — see LICENSE file for details

## Support

- **Issues**: https://github.com/obra/superpowers/issues
- **Marketplace**: https://github.com/obra/superpowers-marketplace
