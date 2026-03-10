---
name: md-improver
description: Use when auditing, improving, or updating CLAUDE.md files — to keep project memory aligned with the actual codebase. Invoke when a CLAUDE.md might be stale, incomplete, or generic, or when the user asks to "audit the CLAUDE.md" or "check if CLAUDE.md is up to date".
---

# CLAUDE.md Improver

## Overview

CLAUDE.md is Claude's project memory. It tells Claude how to navigate the codebase, which commands to run, what conventions to follow, and what gotchas to avoid. When it's out of date or too generic, every session starts from a worse baseline.

**Core principle:** CLAUDE.md should contain only project-specific, actionable content. Generic advice ("write clean code") that Claude already knows is noise. Missing project-specific content (actual commands, real gotchas, this project's conventions) is a gap.

---

## Phase 1: Discover

Find all CLAUDE.md variants in the project:

```bash
find . -name "CLAUDE.md" -o -name ".claude.local.md" | sort
```

Common locations:
- `/CLAUDE.md` — project root (main file, committed to repo)
- `/.claude.local.md` — local overrides (personal preferences, in `.gitignore`)
- `/packages/*/CLAUDE.md` — package-specific context in monorepos
- `~/.claude/CLAUDE.md` — global default (applies to all projects)

Read each file fully before assessing.

### Auto-Generate from Codebase (when CLAUDE.md is missing or empty)

If no `CLAUDE.md` exists or it's essentially empty, generate one from the codebase rather than starting from scratch:

**Step 1: Scan the codebase for commands**
```bash
# Package.json scripts
cat package.json | jq '.scripts'
# Makefile targets
grep "^[a-zA-Z].*:" Makefile 2>/dev/null | head -20
# Common script files
ls scripts/ 2>/dev/null
```

**Step 2: Identify the project type and framework**
```bash
cat package.json | jq '{name, description, dependencies, devDependencies}' 2>/dev/null | head -30
ls *.toml *.yaml *.yml 2>/dev/null | head -10
```

**Step 3: Find conventions from existing code**
```bash
# Naming patterns
rg "^(export|class|function)" src/ -l | head -10
# Test framework
rg "describe|test|it\(" --include="*.test.*" -l | head -5
```

**Step 4: Draft CLAUDE.md from findings**

Use only what was found — no invented conventions. Structure:
```markdown
# CLAUDE.md

## Commands
[Only list commands that actually exist in package.json / Makefile / scripts/]

## Architecture
[Only what was discovered from the file structure]

## Conventions
[Only patterns observed in existing code]

## Gotchas
[Only issues actually discovered, not hypothetical ones]
```

**Step 5:** Continue with Phase 2 (Assess) using the generated draft as the starting point.

---

## Phase 2: Assess

Score each file against 6 criteria. Be specific about what's missing or stale — not just a score.

### Criteria (each A–F)

| Criterion | A (excellent) | F (failing) |
|-----------|--------------|-------------|
| **Commands & workflows** | Lists actual runnable commands with exact syntax | No commands, or only "run the tests" |
| **Architecture clarity** | Describes where things live, how data flows, key modules | No architecture context |
| **Non-obvious patterns** | Documents gotchas, conventions that aren't in the code | Only states what's already obvious |
| **Conciseness** | Every sentence earns its place | Bloated with generic advice |
| **Currency** | Commands work, packages referenced exist | Stale commands, removed packages |
| **Actionability** | Reader can copy-paste commands and act | Vague descriptions requiring interpretation |

### Scoring

| Score | Grade |
|-------|-------|
| 90–100 | A |
| 80–89 | B |
| 70–79 | C |
| 60–69 | D |
| 0–59 | F |

---

## Phase 3: Report

Before making any changes, produce a quality report:

```markdown
## CLAUDE.md Audit Report

### /CLAUDE.md — Score: 72/100 (C)

**Commands & workflows: B**
- Has: `npm test`, `npm run build`
- Missing: migration commands, seed command, how to run a single test

**Architecture: D**
- Missing: which folder contains business logic, how auth flow works, what the `lib/` folder is for

**Non-obvious patterns: C**
- Has: "always use transactions for multi-table updates"
- Missing: why `useOptimisticUpdate` hook exists, the quirk with the payment webhook signature

**Conciseness: A**
- Well-scoped, no bloat

**Currency: B**
- `npm run seed` referenced but doesn't exist in package.json anymore

**Actionability: C**
- Commands are present but some lack flag examples

### Key gaps
1. Missing: how to run migrations (`npx prisma migrate dev`)
2. Missing: the payment webhook signature verification quirk (breaks silently in dev if env var wrong)
3. Stale: `npm run seed` → should be `npx prisma db seed`
```

Show the report to the user before proposing changes.

---

## Phase 4: Propose

Suggest targeted, minimal additions. Show exactly what would be added and why.

**What to add:**

- Commands discovered in `package.json`, `Makefile`, shell scripts that aren't in CLAUDE.md
- Architecture facts: where the business logic lives, what the key modules do
- Gotchas discovered during the session: env var requirements, timing dependencies, non-obvious conventions
- Package relationships in monorepos: which package does what, dependency direction

**What NOT to add:**

- Generic advice Claude already knows ("write tests for your code", "handle errors")
- Obvious things ("the main file is `index.ts`")
- Opinions without project-specific grounding
- Anything that would be true for any project

**Format for proposals:**

```markdown
### Proposed additions to /CLAUDE.md

**Add to Commands section:**
```
npx prisma migrate dev    # Run migrations in development
npx prisma db seed        # Seed the database (replaces the removed npm run seed)
npm test -- --grep "auth" # Run only tests matching a pattern
```

**Add to Architecture section:**
`lib/` contains shared utilities. Business logic lives in `services/`. Never import from `services/` into `lib/`.

**Add new Gotchas section:**
- PAYMENT_WEBHOOK_SECRET must be set in `.env.local` — if unset, webhook validation passes silently and all webhooks are accepted (security hole in dev)
```

---

## Phase 5: Apply

Apply user-approved additions with clear diffs. Don't rewrite sections that are fine — only add what's missing or fix what's stale.

After applying, confirm:
- File still reads top-to-bottom coherently
- No duplicate information introduced
- Commands are runnable (verify with shell if possible)

---

## `.claude.local.md` — Personal Preferences

The `.claude.local.md` file is for personal preferences excluded from the repo. Suggest using it for:
- Personal tooling preferences (e.g., "use vim keybindings in edit suggestions")
- Local environment overrides that differ from the team
- Notes only relevant to this developer's machine

Never add personal preferences to the committed `CLAUDE.md`.

---

## Red Flags — CLAUDE.md Is Failing

- Commands listed that don't exist in `package.json` / `Makefile` / scripts
- Architecture section that just says "this is a Node.js project"
- "Write clean, maintainable code" or similar generic advice
- Key workflows missing that Claude has to discover every session (database commands, test flags, deploy process)
- No gotchas section despite the project having known non-obvious quirks

---

## Hard Rules

- **Only add project-specific content.** If it's true for every project, it doesn't belong here.
- **Commands must be runnable.** Verify that commands listed actually exist before adding them.
- **Report before changing.** Never modify CLAUDE.md without first showing the assessment to the user.
- **Minimal diffs.** Add what's missing, fix what's stale, leave the rest alone.
- **Don't rewrite sections that work.** Improving a B to an A is often not worth the risk of introducing new issues.
