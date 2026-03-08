---
name: proactive-memory
description: Use proactively during a session to write searchable observations to a shared log — at natural pause points (after research, after completing a feature, after hitting a blocker, when switching topics). Also use when the user asks to search past observations. Complements capturing-context (which is end-of-session) and session-resume (which loads the last full log).
---

# Proactive Memory

## Overview

A lightweight, searchable observation log that captures what matters *during* a session — without waiting for the user to say "checkpoint". Each observation is a small, tagged, self-contained entry that `rg` can find in seconds across all past sessions.

**Core principle:** Write small, write often, write tagged. A 3-line observation written now is worth more than a full session log written too late or never.

**How it fits with existing skills:**

| Skill | When | Granularity | Trigger |
|-------|------|-------------|---------|
| `proactive-memory` (this) | Mid-session | One observation at a time | Proactive — natural pause points |
| `capturing-context` | End of session | Full session state | User request |
| `session-resume` | Session start | Last full log | User request |
| `MEMORY.md` | Cross-project | Stable facts only | Explicit remember request |

---

## Storage Location

All observations go into a single append-only file:

```
logs/observations.md
```

Create it if it doesn't exist. Never delete or truncate it — always append.

---

## Observation Format

Each observation is a tagged block:

```markdown
<!-- obs -->
date: 2026-03-08T14:30
project: superpowers
type: decision
tags: #auth #jwt #security
---
JWT middleware doesn't validate `exp` on refresh tokens. Fixed in src/auth/middleware.ts:42
by adding explicit expiry check. Rationale: refresh tokens were being accepted indefinitely
after initial issue.
<!-- /obs -->
```

**Fields:**
- `date` — ISO datetime (at least YYYY-MM-DD, add time when available)
- `project` — current repo or project name
- `type` — one of: `decision`, `finding`, `blocker`, `fix`, `pattern`, `question`
- `tags` — 1–4 `#hashtags` for the main concepts (file, module, technology, domain)

**Body:** 1–5 lines. Specific enough to act on without re-reading the full session. Include:
- What was discovered or decided
- Where it lives (file path + line if relevant)
- Why (the rationale, not just the outcome)

---

## When to Write an Observation

Write proactively at these natural pause points — **without being asked**:

| Trigger | Type to use | Example |
|---------|-------------|---------|
| A research phase concludes and implementation is about to start | `finding` | "Discovered that lib X doesn't support Y — switching to Z" |
| A non-obvious decision is made | `decision` | "Chose append-only log over SQLite for zero-dependency portability" |
| A blocker is hit that can't be resolved immediately | `blocker` | "Rate limit on GitHub API at 60 req/hr blocking bulk fetch" |
| A bug is fixed | `fix` | "Fixed null deref in user.ts:88 — missing guard on optional chain" |
| A reusable pattern is identified | `pattern` | "Use `rg --json` + jq for structured search across skill files" |
| Topic switches significantly | `finding` | Summarize current state before moving on |

**Do NOT write an observation for:**
- Trivial file reads with no insight
- Every tool call (too noisy)
- Things already captured in `MEMORY.md`
- Duplicate of an existing observation

---

## Retrieving Past Observations

Use a 3-tier progressive approach — stop at the tier that gives enough context:

### Tier 1: Tag search (cheap — ~50 tokens)

```bash
rg "#auth" logs/observations.md -A 6
```

Scan for matching tags first. If the result set is small and clearly relevant, you're done.

### Tier 2: Type + date filter (medium — scan a subset)

```bash
rg "type: decision" logs/observations.md -A 8 | rg -i "auth|jwt"
```

Filter by observation type and keyword to narrow chronologically.

### Tier 3: Full context (expensive — read specific blocks)

Only when tiers 1–2 don't give enough to act on. Read the full surrounding observation block and, if referenced, open the specific file at the noted line.

**Rule:** Don't dump the entire `observations.md` into context. Search → filter → fetch only what's needed.

---

## Searching Across All Session Logs

When the user asks about past work more broadly (not just observations):

```bash
# Search observations by tag
rg "#payments" logs/observations.md -A 8

# Search full session logs by keyword
rg -l "auth middleware" logs/

# Then read only the matching log files
```

**Tags to establish early in any session** (use consistently so search works):
- Module/feature: `#auth`, `#payments`, `#api`, `#db`
- Domain: `#security`, `#performance`, `#testing`
- Outcome: `#fixed`, `#blocked`, `#decided`, `#deferred`

---

## Privacy

Wrap sensitive content in a `<!-- private -->` block to exclude it from the observation:

```markdown
<!-- obs -->
date: 2026-03-08
project: client-work
type: decision
tags: #api #credentials
---
Switched to token-based auth for the external API.
<!-- private -->API key: sk-... endpoint: https://...<!-- /private -->
Configuration stored in .env, not committed.
<!-- /obs -->
```

The private block is written to the file but the content within it should not be surfaced in retrieval unless the user explicitly requests it.

---

## Hard Rules

- **Append only.** Never delete or modify past observations — the log is an audit trail.
- **Write at pause points, not after every tool call.** One good observation per phase transition beats ten noisy ones.
- **Tags are searchable contracts.** Use consistent tags across sessions — don't invent a new tag when an existing one fits.
- **Body must be actionable.** If you can't act on it without re-reading the full session, the observation is too vague.
- **File paths and line numbers when relevant.** "Fixed auth bug" is useless. "Fixed null deref in src/auth/middleware.ts:88" is findable.
- **Stop retrieval at the tier that answers the question.** Don't escalate to reading full logs if a tag search is sufficient.

---

## Integration

**Pairs with:**
- `capturing-context` — write observations throughout; `capturing-context` synthesizes the full session at the end
- `session-resume` — on session start, run a quick tag search on recent observations before reading the full log
- `MEMORY.md` — stable, cross-project facts go there; ephemeral, project-specific observations go here

**Retrieval at session start (suggested):**
```bash
# Check recent observations for this project before diving in
rg "project: superpowers" logs/observations.md | tail -20
```
