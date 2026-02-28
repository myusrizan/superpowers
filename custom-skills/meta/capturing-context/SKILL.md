---
name: capturing-context
description: Use ONLY when the user explicitly says "extract the context" or "extract context" — captures everything from the current session that the next conversation needs to continue without losing state
---

# Capturing Context

## Overview

Extract the current session's work, decisions, and state into a structured log file so the next conversation can pick up exactly where this one left off.

**Core principle:** Write for the next session, not for yourself. Capture what a fresh instance would need to know — not everything that happened, but everything that matters going forward.

---

## When to Use

**ONLY when the user explicitly says:**
- "extract the context"
- "extract context"
- "save the context"
- "log the context"

**Do NOT trigger automatically.** Do not trigger based on session length, topic complexity, or at the end of a long conversation unless explicitly requested.

---

## The Process

### 1. Identify the log filename

Format: `logs/YYYY-MM-DD-HH-MM-<topic-slug>.md`

- Use the current date and time
- Derive `topic-slug` from the main thing worked on (2–4 words, hyphenated, lowercase)
- Example: `logs/2026-02-28-14-30-qol-skills-setup.md`

### 2. Extract what matters

Scan the full conversation and extract:

| Section | What to capture |
|---------|----------------|
| **What was worked on** | 1–2 sentence summary of the session's purpose |
| **What was done** | Specific actions taken — files created, folders moved, decisions made |
| **Files created / modified** | Exact paths + one-line description of each |
| **Key decisions** | What was decided and why (include the reasoning, not just the outcome) |
| **Context for next session** | What a fresh instance must know to continue — project conventions, current state, assumptions |
| **Unresolved / next steps** | Open threads, things mentioned but not done, what the user likely wants next |

### 3. Write the log file

Use this structure exactly:

```markdown
# Context Log — YYYY-MM-DD HH:MM

## Session Summary
[1–2 sentences: what this session was about and what it accomplished]

## What Was Done
- [specific action — be concrete, not vague]
- [specific action]

## Files Created / Modified
- `path/to/file` — [what it is / what changed]
- `path/to/file` — [what it is / what changed]

## Key Decisions
- **[decision]** — [why: the rationale, trade-off, or preference that drove it]

## Context for Next Session
[What the next conversation needs to know that isn't obvious from the files alone.
Include: naming conventions used, categorization choices, things the user prefers,
constraints discovered, state of in-progress work.]

## Unresolved / Next Steps
- [ ] [specific thing to do or question to resolve]
- [ ] [specific thing to do or question to resolve]
```

### 4. Confirm to the user

After writing the file, tell the user:
- The file path
- A one-line summary of what was captured

---

## What NOT to Include

- Step-by-step conversation transcript
- Obvious things any instance would know (e.g., "Claude Code is an AI assistant")
- Resolved discussions that have no bearing on future work
- Opinions without decisions — if it was discussed but not decided, put it in Unresolved

---

## Red Flags — Context Will Be Useless

- "What was done" is vague ("worked on skills") instead of specific ("created 3 skills in skills/qol/")
- File paths are missing or approximate
- "Key decisions" only lists outcomes without rationale (next session won't know WHY)
- "Context for next session" is empty or generic
- You captured the whole conversation instead of what's forward-looking
- The log is in the wrong folder (must be `logs/` at project root)
