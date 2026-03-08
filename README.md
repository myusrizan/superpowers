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

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## What's Inside

52 skills across 6 categories. The skill catalog is auto-generated from frontmatter on every build — run `bash scripts/build-skills.sh` after adding or editing skills.

### coding/ — Software development workflow

| Skill | What it does |
|-------|-------------|
| **api-design** | REST API design: URL structure, HTTP semantics, pagination (offset vs cursor), versioning strategy |
| **brainstorming** | Required gate before implementation — Socratic design refinement, explores alternatives, saves design doc |
| **ci-cd-pipeline** | Pipeline design and debugging: stage ordering, caching, secrets management, deployment strategies (rolling/blue-green/canary) |
| **code-reviewer** | Subagent structured code review: spec compliance first, then code quality |
| **database-migrations** | Schema changes: expand-contract pattern, CONCURRENTLY indexes, batch updates, UPSERT, SKIP LOCKED queues |
| **dependency-management** | Add vs build decisions, pinning strategy, lock file discipline, vulnerability audits |
| **e2e-testing** | Page Object Model, flaky test quarantine, condition-based waits, CI artifact collection |
| **eval-harness** | Eval-driven development: capability vs regression evals, pass@k metrics, code/model/human graders |
| **executing-plans** | Implements written plans in batches with human review checkpoints |
| **investigating** | Systematic codebase/system investigation — produces structured findings report |
| **observability** | Structured logging, metrics (counter/gauge/histogram), distributed tracing, SLO-based alerting |
| **onboarding-to-codebase** | 6-layer reading order for unfamiliar codebases — produces written mental model before any changes |
| **performance-profiling** | Measure → profile → hypothesis → one fix → measure again. Never optimize without profiling. |
| **planning-sessions** | Prioritizes a backlog of candidate features — dependency ordering, value/effort ratio, milestones |
| **receiving-code-review** | Structured process for responding to review feedback with technical rigor |
| **refactoring** | Characterization tests first, one refactoring type at a time, tests after every change, undo on red |
| **requesting-code-review** | Dispatches code-reviewer subagent with full context |
| **search-first** | Research before building — find existing libraries/MCPs/skills before writing a line of code |
| **security-review** | 3-phase OWASP-aligned review: attack surface map → 10 threat categories → CRITICAL/HIGH/MEDIUM/LOW output |
| **silent-failure-hunter** | Hunts empty catch blocks, swallowed exceptions, non-actionable error messages, unjustified fallbacks |
| **systematic-debugging** | 4-phase root cause process: reproduce → pattern analysis → hypothesis testing → fix with test first |
| **test-driven-development** | RED-GREEN-REFACTOR: write failing test, watch fail, write minimal code, watch pass, refactor |
| **ui-ux-design** | Industry-matched UI/UX: analyze context, select style system, apply accessibility/interaction standards, validate against anti-patterns |
| **verification-before-completion** | Evidence before claims — run the command, read the output, then report status |
| **writing-plans** | Detailed implementation plans with exact code, exact commands, expected outputs |

### agents/ — Agent orchestration

| Skill | What it does |
|-------|-------------|
| **autonomous-loops** | 5 patterns for Claude running without user input: sequential pipeline, de-sloppify pass, infinite loop, continuous PR loop, RFC-driven DAG |
| **dispatching-parallel-agents** | Parallel subagent dispatch for independent tasks |
| **iterative-retrieval** | Subagent context-gathering: broad dispatch → score (0–1) → refine → max 3 cycles |
| **mcp-server** | Build custom MCP servers with FastMCP — tool design, input validation, registration with Claude Code/Desktop/Cursor |
| **subagent-driven-development** | Per-task subagent dispatch with 2-stage review (spec compliance + code quality) |

### git/ — Version control

| Skill | What it does |
|-------|-------------|
| **finishing-a-development-branch** | Verify tests → 4 options (merge/PR/keep/discard) → cleanup worktree |
| **github-cli** | Issues, CI runs, releases, search, and repo operations via gh — JSON output, scripting, autonomous PR loops |
| **history-archaeology** | Trace bug origins via git blame, bisect, log -S pickaxe, and show — read history before forming hypotheses |
| **using-git-worktrees** | Isolated worktrees with smart directory selection and safety verification |

### thinking/ — Intellectual engagement

| Skill | What it does |
|-------|-------------|
| **decision-making** | Structured evaluation for high-stakes choices: options → criteria → pre-mortem → score → commit |
| **reasoning** | First principles, pre-mortem, assumption mapping, inversion, devil's advocate |
| **thinking-partner** | 4 modes: Opinion / Ideation / Challenge / Sounding Board |

### qol/ — Output production

| Skill | What it does |
|-------|-------------|
| **documenting** | READMEs, API docs, ADRs, CHANGELOG entries — type-specific structures |
| **drafting** | Messages, emails, Slack posts — point-first, tone-calibrated |
| **explaining** | Audience-calibrated explanations with analogies and layered complexity |
| **researching** | Multi-source synthesis — direct answer first, evidence, caveats, confidence |
| **summarizing** | Bullet / narrative / executive / tldr — format matched to content and need |

### meta/ — Skill system

| Skill | What it does |
|-------|-------------|
| **capturing-context** | Saves session state to `logs/` for next session; also covers context compaction timing |
| **claude-md-improver** | 5-phase CLAUDE.md audit: discover → assess (6 criteria A–F) → report → propose → apply |
| **prompt-efficiency** | 8 patterns for token-efficient prompts — goal first, output constraints, batching, structure over prose |
| **prompt-generator** | Generates reusable system prompts saved to `prompts/` |
| **sensitive-data-guard** | Detects credentials/PII in shared content — mandatory revocation warning before any resolution |
| **session-resume** | Loads most recent context log, reconstructs state, confirms before resuming |
| **skill-creator** | Full skill creation process: intent → draft → test → evaluate → iterate → optimize description |
| **skill-stocktake** | Systematic skill audit: actionability, scope fit, uniqueness, currency → Keep/Improve/Update/Retire/Merge |
| **using-superpowers** | Mandatory session-start skill — discovers available skills before taking any action |
| **writing-skills** | TDD for skill creation: RED (test without skill) → GREEN (write skill) → REFACTOR |

## Philosophy

- **Test-Driven Development** — Write tests first, always
- **Systematic over ad-hoc** — Process over guessing
- **Complexity reduction** — Simplicity as primary goal
- **Evidence over claims** — Verify before declaring success
- **Search before building** — Find existing solutions before writing new code
- **Skills trigger automatically** — The system works without remembering to invoke it

Read more: [Superpowers for Claude Code](https://blog.fsck.com/2025/10/09/superpowers/)

## Adding Custom Skills

Skills live in `custom-skills/` organized by category (`coding/`, `agents/`, `git/`, `thinking/`, `qol/`, `meta/`). After adding or editing a skill:

```bash
bash scripts/build-skills.sh
```

This rebuilds `skills/` from `custom-skills/` and auto-regenerates the skill catalog in `using-superpowers/SKILL.md` from frontmatter.

Each skill is a directory containing `SKILL.md` with YAML frontmatter:

```yaml
---
name: my-skill
description: Use when [specific triggering condition]. Invoke whenever [adjacent condition] — even if the user doesn't explicitly mention [skill name].
---
```

The `description` field is the primary trigger mechanism. Make it specific but include adjacent phrasings — Claude undertriggers by default.

See `custom-skills/meta/writing-skills/SKILL.md` for the complete skill creation guide, or use the `skill-creator` skill to build and test new skills iteratively.

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
