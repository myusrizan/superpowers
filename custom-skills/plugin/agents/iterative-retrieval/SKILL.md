---
name: iterative-retrieval
description: Use when a subagent needs to gather relevant context before starting work — especially when the relevant files are not known upfront and broad initial context would exceed limits
---

# Iterative Retrieval

## Overview

Subagents face a fundamental problem: they can't predict what context they need before they start working. Static approaches fail:
- **Send everything** → exceeds context limits
- **Send nothing** → agent lacks information to do the job
- **Guess upfront** → often wrong, wastes context on irrelevant files

Iterative retrieval solves this with a dynamic loop: dispatch broad, score what came back, identify gaps, refine, repeat.

**Core principle:** Retrieve the minimum sufficient context. Three highly-relevant files are better than twenty mediocre ones.

---

## The Four-Phase Cycle

```
┌─────────────────────────────────────────┐
│  1. DISPATCH                            │
│     Broad initial query                 │
│     Keywords + file patterns            │
├─────────────────────────────────────────┤
│  2. EVALUATE                            │
│     Score each result: 0.0 – 1.0        │
│     Identify what's still missing       │
├─────────────────────────────────────────┤
│  3. REFINE                              │
│     Update search terms from gaps       │
│     Use discovered terminology          │
├─────────────────────────────────────────┤
│  4. LOOP (max 3 cycles)                 │
│     Stop when: enough context gathered  │
│     OR 3 cycles reached                 │
└─────────────────────────────────────────┘
```

---

## The Scoring System

Score each retrieved file on relevance to the task (0.0 to 1.0):

| Score | Meaning |
|-------|---------|
| 0.9 – 1.0 | Directly relevant — core file for the task |
| 0.6 – 0.8 | Related — useful but not central |
| 0.3 – 0.5 | Adjacent — might be relevant, low confidence |
| 0.0 – 0.2 | Not relevant — different domain entirely |

**Continue searching if:** No files scored above 0.7 after cycle 1.
**Stop when:** 3+ files scored 0.8+ — sufficient context gathered.

---

## Worked Example

### Task
"Fix the bug where rate limiting silently drops requests instead of returning 429"

### Cycle 1: Broad dispatch

```
Search terms: "rate limit", "429", "throttle"
File pattern: src/**/*.ts

Results:
- src/middleware/auth.ts — score: 0.2 (auth, not rate limiting)
- src/api/routes.ts     — score: 0.4 (has some middleware config)
- src/config/limits.ts  — score: 0.7 (rate limit config)

Max score: 0.7 — continue
Gap identified: No middleware file found; config found but not the implementation
```

**Key insight from cycle 1:** The codebase uses "throttle" not "rate limit" (discovered in config). Search terms need updating.

### Cycle 2: Refined search

```
Search terms: "throttle", "ThrottleMiddleware", "429"
File pattern: src/middleware/**

Results:
- src/middleware/throttle.ts  — score: 0.9 (core implementation)
- src/middleware/index.ts     — score: 0.7 (registers middlewares)
- src/config/limits.ts        — score: 0.7 (already found, still relevant)

3 files scored 0.7+ — STOP
```

### Result

The agent has the 3 files it needs: the throttle implementation, the middleware registry, and the config. It can now proceed with the actual fix.

**Without iterative retrieval:** The agent would have searched for "rate limit" and missed the actual `throttle.ts` file entirely.

---

## When to Use Iterative Retrieval

Use this pattern when assigning subagents to tasks where:

- The relevant file names aren't obvious from the task description
- The codebase uses different terminology than the task description
- The task touches multiple interconnected modules
- You're working in an unfamiliar codebase

**You don't need it when:**
- You already know exactly which files to read (just read them directly)
- The task is purely generative (no existing code context needed)
- The codebase is small enough to include entirely

---

## Integration with Subagent Prompts

When dispatching a subagent to a complex task:

```
Task(
  subagent_type="general-purpose",
  prompt="""
  Before starting work, gather context using iterative retrieval:

  CYCLE LIMIT: 3
  STOPPING CRITERION: 3+ files scored 0.8 or above

  Cycle 1: Search broadly using obvious keywords from the task
  For each result: score 0.0-1.0, identify what's missing
  Cycle 2+: Refine search using terminology discovered in cycle 1
  Stop when stopping criterion is met

  Once context is gathered, proceed with:
  Task: [ACTUAL TASK DESCRIPTION]
  """
)
```

---

## Terminology Discovery

A key benefit of the cycle approach: cycle 1 often reveals the codebase's actual vocabulary.

Common mismatches:

| What you searched for | What the codebase calls it |
|-----------------------|---------------------------|
| "rate limiting" | "throttling" |
| "authentication" | "identity" |
| "user permissions" | "access control" |
| "database connection" | "data source" |
| "error handling" | "fault tolerance" |

When cycle 1 returns low scores, read the surrounding code to find the actual terminology used, then search for that in cycle 2.

---

## Hard Rules

- **Maximum 3 cycles.** Beyond 3 cycles, you're searching indefinitely. Stop and proceed with what you have, noting what's uncertain.
- **Stop at 3 files scoring 0.8+.** More context doesn't always help. Focused context beats exhaustive context.
- **Update search terms each cycle.** Using the same terms again won't produce new results.
- **Score every result.** The score makes the gap explicit and drives the refinement query.
- **Proceed even with imperfect context.** The goal is sufficient context, not perfect context.
