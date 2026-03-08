---
name: codebase-analysis
description: Use when starting work on an unfamiliar codebase to build a working mental model before making any changes, or when asked to examine a codebase, folder, system, or set of files to produce structured findings with no implementation goal yet. Invoke at the start of any session in a new codebase, or when asked to audit, review, analyze, or produce findings about a system.
---

# Codebase Analysis

Two modes. Read the mode that matches your situation.

```
"I need to understand this codebase before changing it" → Mode A: Onboarding
"I need to produce a findings report, no changes yet"  → Mode B: Investigating
```

---

## Mode A: Onboarding (Build a Working Mental Model)

**Core principle:** Read in the right order. Entry points before implementation. Structure before details.

**Output:** A written mental model summary before any code is changed.

### When to Use

- First time working in a repository
- Returning after a long absence
- Taking over work from another developer
- About to make changes and uncertain where they belong

### Reading Order

Work through each layer. Do not skip ahead.

**Layer 1: Project identity (2 min)**

What does this project do in one sentence?
- `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod`
- `README.md`
- `LICENSE`, `CONTRIBUTING.md`

**Layer 2: Entry points (5 min)**

Where does execution start?
| Project type | Look for |
|-------------|---------|
| Web server | `main.ts`, `app.ts`, `server.ts`, `main.py`, `app.py` |
| CLI tool | `bin/`, `cmd/`, `cli.ts`, `__main__.py` |
| Library | `src/index.ts`, `src/lib.rs`, `__init__.py` — what is exported |
| Serverless | Handler functions, `serverless.yml`, `functions/` |
| Frontend | `src/main.tsx`, `src/App.tsx`, `pages/_app.tsx`, `index.html` |

Read the entry point. Do not follow every import — identify what it sets up and delegates.

**Layer 3: Configuration and environment (3 min)**

- `.env.example`, `config/`, `settings.py`, `config.ts`
- What environment variables are required?
- What external services does it connect to?
- What are the runtime modes?

**Layer 4: Routing / top-level structure (5 min)**

| Project type | Look for |
|-------------|---------|
| REST API | Router files, controller directories, `routes/` |
| Frontend | `pages/`, `routes/`, `App.tsx` route definitions |
| Library | Public API surface (`index.ts` exports) |
| CLI | Command definitions, subcommand structure |

Read the router or top-level structure — not the implementations. Build a map of what exists.

**Layer 5: Key modules (10 min)**

Read the 3–5 files most central to the task you're about to do. For each file: what does it own? What does it depend on? What depends on it?

**Layer 6: Tests (5 min)**

- Where do tests live?
- What testing framework?
- Run the test suite — is it green?

### Parallel Mapping (Large or Brownfield Codebases)

For codebases with 50+ files, dispatch 5 parallel agents:

```
Agent 1 → STACK.md        (languages, frameworks, key dependencies, versions)
Agent 2 → ARCHITECTURE.md (high-level design, module boundaries, data flow)
Agent 3 → CONVENTIONS.md  (naming, file structure, patterns used consistently)
Agent 4 → INTEGRATIONS.md (external services, APIs, databases, config)
Agent 5 → TESTING.md      (test framework, coverage areas, how to run tests)
```

Each agent writes directly to `docs/codebase/`. Controller receives only confirmations.

### Output: Mental Model Summary

Before making any changes, write this summary:

```markdown
## Codebase: [Project Name]

**What it does:** [one sentence]

**Entry point:** [file:line — what happens first]

**Architecture:**
- [Layer/directory] — [what it owns]
- [Layer/directory] — [what it owns]

**External dependencies:** [database, APIs, services]

**Test command:** [exact command]
**Tests green:** yes / no / [N failing]

**Relevant to my task:**
- [file] — [why it matters]

**Unknowns / things to clarify:**
- [question]
```

Save to `docs/codebase-notes.md` or share in session before proceeding.

### Hard Rules

- Do not make any changes before completing Layer 4
- Run the tests before touching anything — document pre-existing failures
- Write the summary — it is not optional

---

## Mode B: Investigating (Produce Structured Findings)

**Core principle:** Read everything before analyzing anything. Conclusions written before full examination are biases, not findings.

### When to Use

- Asked to audit, review, or analyze a system, codebase, folder, or set of files
- Asked for advantages, disadvantages, flaws, gaps, or quality assessment
- No implementation goal exists yet — findings are the end product
- The user wants a map of what's there before deciding what to do

**Do NOT use when:** Specific bug to trace → `diagnosing` · Design decision to make → `feature-workflow` (brainstorm phase) · Information from external sources → `researching`

### Process

**Step 1: Scope the Investigation**

Before reading anything:
- **Target:** What exactly is being examined?
- **Questions to answer:** What should the report tell the user?
- **Depth:** Skim for overview vs. read everything?

If unclear, ask: "Should I examine everything in X, or focus on a specific aspect?"

**Step 2: Read Everything First**

- Don't stop to analyze mid-read
- Don't skip files that look unimportant
- Take notes on observations but make no judgments yet
- No section of the report is written until all reading is complete

**Step 3: Analyze Systematically**

| Dimension | Questions |
|-----------|-----------|
| **Advantages** | What works well? What is well-designed? |
| **Disadvantages** | What is suboptimal but not broken? What is missing? |
| **Flaws** | What is actively broken or causes failures? |
| **Optimizations** | What specific changes would improve the target? |
| **Gaps** | What should exist but doesn't? |
| **Cross-item patterns** | What systemic issues apply to multiple items? |

For each flaw, assign severity: Critical · High · Medium · Low

**Step 4: Write the Report to Files**

```
investigation-report/
  README.md               — executive summary + file index
  01-overview.md          — system-level analysis
  02-per-item-analysis.md — individual item breakdown
  03-critical-flaws.md    — bugs/issues ranked by severity with concrete fixes
  04-optimizations.md     — improvements with effort/impact
  05-gaps.md              — missing elements
```

Each finding must include: specific location (file:line or named component) · what the issue is · why it matters · for flaws: a concrete fix.

**Vague findings are not findings.** "Could be better" is not a finding. "Line 55 references `frontend-design` which does not exist — causes model confusion" is a finding.

**Step 5: Present and Confirm**

- Tell the user where the report is
- Give a 3–5 bullet executive summary
- Ask: "Anything you want me to investigate more deeply?"

### Investigation Outcomes

| Finding type | Next skill |
|--------------|-----------|
| Broken functionality | `diagnosing` |
| Design gaps or new features wanted | `feature-workflow` (brainstorm phase) |
| Clear list of fixes | `feature-workflow` (planning phase) |
| No action needed | Done — report is the deliverable |

### Red Flags — You've Drifted

- You are writing code or editing files
- You proposed a solution before finishing all reads
- Your findings say "good overall" without specific evidence
- You wrote conclusions in chat instead of a report file
- The user asked "what's wrong with X" and you answered from memory without examining X
