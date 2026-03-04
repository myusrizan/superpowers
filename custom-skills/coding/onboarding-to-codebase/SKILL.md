---
name: onboarding-to-codebase
description: Use when starting work on an unfamiliar codebase, repository, or service — to build a working mental model before making any changes
---

# Onboarding to Codebase

## Overview

Jumping into an unfamiliar codebase without orientation leads to changes made in the wrong place, with wrong assumptions, that break things you didn't know existed.

**Core principle:** Read in the right order. Entry points before implementation. Structure before details.

**Output:** A written mental model summary before any code is changed.

---

## When to Use

- First time working in a repository
- Returning to a codebase after a long absence
- Taking over work from another developer or agent
- About to make changes and uncertain where they belong

---

## Reading Order

Work through each layer. Do not skip ahead.

### Layer 1: Project identity (2 min)

What is this? What does it do?

- `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` — name, description, scripts, dependencies
- `README.md` — purpose, architecture overview, setup instructions
- `LICENSE`, `CONTRIBUTING.md` — constraints on how to work

**Answer before moving on:** What does this project do in one sentence?

### Layer 2: Entry points (5 min)

Where does execution start?

| Project type | Look for |
|-------------|---------|
| Web server | `main.ts`, `app.ts`, `server.ts`, `index.ts`, `main.py`, `app.py` |
| CLI tool | `bin/`, `cmd/`, `cli.ts`, `__main__.py` |
| Library | `src/index.ts`, `src/lib.rs`, `__init__.py` — what is exported |
| Serverless | Handler functions, `serverless.yml`, `functions/` |
| Frontend | `src/main.tsx`, `src/App.tsx`, `pages/_app.tsx` (Next.js), `index.html` |

Read the entry point. Do not follow every import — identify what it sets up and what it delegates to.

**Answer before moving on:** Where does a request/command/event enter and what happens first?

### Layer 3: Configuration and environment (3 min)

What does the project need to run?

- `.env.example`, `config/`, `settings.py`, `config.ts`
- What environment variables are required?
- What external services does it connect to? (database, cache, message queue, APIs)
- What are the runtime modes? (development, test, production differences)

**Answer before moving on:** What would I need to set up to run this locally?

### Layer 4: Routing / top-level structure (5 min)

How is the code organized?

| Project type | Look for |
|-------------|---------|
| REST API | Router files, controller/handler directories, `routes/` |
| Frontend | `pages/`, `routes/`, `App.tsx` route definitions |
| Library | Public API surface (`index.ts` exports) |
| CLI | Command definitions, subcommand structure |

Read the router or top-level structure — not the implementations. Build a map of what exists.

**Answer before moving on:** What are the main areas of functionality? What does each directory own?

### Layer 5: Key modules (10 min)

Read the 3–5 files most central to the task you are about to do.

For each file:
- What does this module own? (Its one responsibility)
- What does it depend on?
- What depends on it?

Do not read everything — read what is relevant to your task.

### Layer 6: Tests (5 min)

What is tested and how?

- Where do tests live? (`tests/`, `__tests__/`, `*.test.ts`, `*.spec.ts`)
- What testing framework? (Jest, pytest, RSpec, Go testing)
- Are there integration tests? E2E tests?
- What is the test command? (`npm test`, `pytest`, `cargo test`)
- Run the test suite — is it green?

**Answer before moving on:** What's tested, what's not, and can I run the tests?

---

## Output: Mental Model Summary

Before making any changes, write a brief summary. This becomes the working context for the session.

```markdown
## Codebase: [Project Name]

**What it does:** [one sentence]

**Entry point:** [file:line — what happens first]

**Architecture:**
- [Layer/directory] — [what it owns]
- [Layer/directory] — [what it owns]
- [Layer/directory] — [what it owns]

**External dependencies:** [database, APIs, services]

**Test command:** [exact command]
**Tests green:** yes / no / [N failing]

**Relevant to my task:**
- [file] — [why it matters]
- [file] — [why it matters]

**Unknowns / things to clarify:**
- [question]
```

Save this to `docs/codebase-notes.md` or share it directly in the session before proceeding.

---

## Hard Rules

- **Do not make any changes before completing Layer 4.** Changes made without understanding the structure land in the wrong place.
- **Run the tests before touching anything.** If they're already failing, document it — don't accidentally take responsibility for pre-existing failures.
- **Write the summary.** It is not optional. It forces clarity and creates a record of your understanding that can be corrected.

---

## Common Failures

| Failure | Consequence |
|---------|------------|
| Jumping straight to the relevant file | Misses dependencies, makes change in wrong layer |
| Skipping config/env layer | Sets up with wrong assumptions, runtime errors on first run |
| Not running tests before making changes | Can't tell if failures are yours or pre-existing |
| Reading implementation before structure | Gets lost in details, no mental map of the whole |
| Skipping the written summary | Understanding evaporates when asked to explain or context resets |
