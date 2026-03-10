---
name: session-memory
description: Use proactively during a session to write searchable observations at natural pause points (after research, decisions, blockers, or topic switches), or when the user says "extract context" / "save progress" / "checkpoint" to save full session state, or when starting a session and wanting to restore state from a previous session.
---

# Session Memory

Three modes that form the session continuity lifecycle. Use the mode that matches your situation.

```
Session starts  → Mode C: Restore   (load last log + recent observations)
Session runs    → Mode A: Observe   (write observations at pause points — proactively)
Session ends    → Mode B: Save      (extract full session state on request)
```

---

## Mode A: Proactive Observation (mid-session)

**When:** At natural pause points during a session — after research concludes, after a decision is made, after hitting a blocker, after fixing a bug, when switching topics. Write **without being asked**.

**Core principle:** Write small, write often, write tagged. A 3-line observation written now is worth more than a full log written too late.

### Storage

All observations go into a single append-only file: `logs/observations.md`

Create it if it doesn't exist. Never delete or truncate — always append.

### Observation Format

```markdown
<!-- obs -->
date: 2026-03-08T14:30
project: superpowers
type: decision
tags: #auth #jwt #security
---
JWT middleware doesn't validate `exp` on refresh tokens. Fixed in src/auth/middleware.ts:42
by adding explicit expiry check. Rationale: refresh tokens were being accepted indefinitely.
<!-- /obs -->
```

**Fields:**
- `date` — ISO datetime (`YYYY-MM-DDTHH:MM`)
- `project` — current repo or project name
- `type` — one of: `decision` · `finding` · `blocker` · `fix` · `pattern` · `question`
- `tags` — 1–4 `#hashtags` (file, module, technology, domain)
- **Body** — 1–5 lines: what was found/decided · where (file:line if relevant) · why (rationale)

### When to Write

| Trigger | Type | Example |
|---------|------|---------|
| Research phase concludes, implementation about to start | `finding` | "Lib X doesn't support Y — switching to Z" |
| Non-obvious decision made | `decision` | "Chose append-only log over SQLite for zero-dependency portability" |
| Blocker hit that can't be resolved immediately | `blocker` | "GitHub API rate-limit at 60 req/hr blocking bulk fetch" |
| Bug fixed | `fix` | "Fixed null deref in user.ts:88 — missing guard on optional chain" |
| Reusable pattern identified | `pattern` | "Use `rg --json` + jq for structured search across skill files" |
| Topic switches significantly | `finding` | Summarize current state before moving on |

**Do NOT write for:** trivial file reads · every tool call · things already in `MEMORY.md` · duplicate of an existing observation.

### Retrieving Past Observations — 3-Tier Search

Stop at the tier that gives enough context:

**Tier 1 — Tag search (~50 tokens):**
```bash
rg "#auth" logs/observations.md -A 6
```

**Tier 2 — Type + keyword filter:**
```bash
rg "type: decision" logs/observations.md -A 8 | rg -i "auth|jwt"
```

**Tier 3 — Full context:** Only when tiers 1–2 don't answer the question. Read only the matching block, not the entire file.

**Rule:** Don't dump all of `observations.md` into context. Search → filter → fetch only what's needed.

### Hard Rules

- **Append only.** Never delete or modify past observations.
- **Write at pause points, not after every tool call.**
- **Tags are searchable contracts.** Use consistent tags across sessions.
- **Body must be actionable.** "Fixed auth bug" is useless. "Fixed null deref in src/auth/middleware.ts:88" is findable.
- **File paths and line numbers when relevant.**

---

## Mode B: Save Session State (end of session)

**When:** User explicitly says "extract the context" · "save context" · "save progress" · "checkpoint" · "take notes for next session."

**Do NOT trigger automatically** based on session length or complexity.

**Core principle:** Write for the next session, not for yourself. Capture what a fresh instance needs to know — not everything that happened, but everything that matters going forward.

### Process

**1. Filename:** `logs/YYYY-MM-DD-HH-MM-<topic-slug>.md`

**2. Extract what matters:**

| Section | What to capture |
|---------|----------------|
| **Session Summary** | 1–2 sentence purpose + accomplishment |
| **What Was Done** | Specific actions — files created, decisions made |
| **Files Created / Modified** | Exact paths + one-line description |
| **Key Decisions** | What was decided AND why (include rationale, not just outcome) |
| **Context for Next Session** | Conventions, current state, assumptions a fresh instance must know |
| **Unresolved / Next Steps** | Open threads, what the user likely wants next |

**3. Ensure `logs/` exists:** `mkdir -p logs`

**4. File structure:**

```markdown
# Context Log — YYYY-MM-DD HH:MM

## Session Summary
[1–2 sentences: what this session was about and what it accomplished]

## What Was Done
- [specific action — concrete, not vague]

## Files Created / Modified
- `path/to/file` — [what it is / what changed]

## Key Decisions
- **[decision]** — [why: the rationale that drove it]

## Context for Next Session
[What the next conversation needs to know that isn't obvious from the files alone.
Naming conventions, categorization choices, user preferences, constraints discovered.]

## Unresolved / Next Steps
- [ ] [specific thing to do or question to resolve]
```

**5. Confirm:** Tell the user the file path and a one-line summary of what was captured.

### Context Compaction (Separate from Logging)

| Action | What it does | When |
|--------|-------------|------|
| Save log (Mode B) | Writes state to `logs/` for future sessions | End of session, on request |
| `/compact` | Reduces in-session token budget | Mid-session, at phase boundaries |

Compact at **task phase boundaries**: after research before implementation · after implementation before review · when switching major topics · when approaching ~50 tool calls.

**Do NOT compact mid-task.** Compacting mid-file-write or mid-debug loses working context.

### What NOT to Include

- Step-by-step conversation transcript
- Obvious things any instance would know
- Resolved discussions with no bearing on future work
- Opinions without decisions (put those in Unresolved)

---

## Mode C: Restore Previous Session (session start)

**When:** User says "continue where we left off" · "resume" · "pick up where we were" · you detect a relevant previous log was injected by the session-start hook.

**Core principle:** The log was written for you. Read it as instructions, not history — then confirm with the user before acting.

### Process

**1. Find the log:**
```bash
ls -t logs/*.md 2>/dev/null | head -5
```
Use the most recent unless the user specifies otherwise.

**2. Quick observation check (before reading the full log):**
```bash
rg "project: <name>" logs/observations.md | tail -20
```

**3. Parse the log** — extract: what's complete (don't repeat) · key decisions (don't re-debate) · conventions · first unresolved item.

**4. Present restoration summary — wait for confirmation:**

```
Restored from: logs/YYYY-MM-DD-HH-MM-topic.md

Last session worked on: [1 sentence]

Completed:
- [item]

Ready to continue with:
- [ ] [first unresolved item]
- [ ] [second unresolved item]

Resume from the first unresolved item, or is there something specific you want to tackle?
```

**Do not start implementing until the user confirms.**

**5. Resume** — start from unresolved items · apply key decisions without re-debating · use documented file paths and conventions.

### If the Log is Outdated or Wrong

1. Note the discrepancy: "The log says X exists, but I don't see it"
2. Ask the user to clarify before proceeding
3. Don't guess — mismatched context causes compounding errors

### Common Failures

| Failure | Fix |
|---------|-----|
| Starting without confirming | Always present restoration summary and wait |
| Re-doing completed work | Mark completed items as done, start from Unresolved |
| Re-litigating decisions | Key Decisions are settled — apply them |
| Ignoring discrepancies | Surface mismatches between log and actual state explicitly |

---

## Mode D: Memory Consolidation (periodic maintenance)

**When:** User says "consolidate memory", "clean up observations", or `observations.md` has grown past ~500 lines and contains stale/duplicate entries.

**Core principle:** An observation log that's too noisy is as useless as no log. Consolidate periodically.

### Process

**1. Read the full log:**
```bash
wc -l logs/observations.md
cat logs/observations.md
```

**2. Group by tag:** Find clusters of related observations (same `#tag`).

**3. Identify:**
- **Duplicates:** Two observations that say the same thing → keep the more specific one
- **Superseded:** An older observation that a newer one overrides (e.g., old fix that was fixed again)
- **Resolved blockers:** Observations of type `blocker` that have since been fixed
- **One-liners that can merge:** 3 tiny observations on the same topic → one richer observation

**4. Write consolidated log:**
```bash
# Back up original
cp logs/observations.md logs/observations.backup.$(date +%Y%m%d).md

# Write consolidated version
# Preserve all observations that are still relevant
# Remove only: clear duplicates, superseded entries, resolved blockers
```

**5. Prepend a consolidation record:**
```markdown
<!-- consolidation: 2026-03-10 — reduced from 82 to 41 entries; removed 12 resolved blockers, 29 duplicates -->
```

### Hard Rules for Consolidation

- **Never delete — only condense.** If unsure whether an observation is superseded, keep it.
- **Backup before editing.** The original is the source of truth until consolidation is verified.
- **Keep the consolidation record.** Future consolidations need to know what was already cleaned.
- **Never consolidate during active work.** Only at session boundaries when the log is stable.
