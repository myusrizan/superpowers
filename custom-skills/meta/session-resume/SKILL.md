---
name: session-resume
description: Use when starting a session and wanting to restore state from a previous session — loads the most recent context log, reconstructs working state, and confirms with the user before resuming
---

# Session Resume

## Overview

Load the previous session's context log and restore working state so work can continue from exactly where it left off.

**Core principle:** The log was written for you. Read it as instructions, not history — then confirm with the user before acting.

---

## When to Use

Use when:
- Starting a new session and the user says "continue where we left off", "resume", "pick up where we were"
- You detect a previous session log exists (injected by session-start hook) and it's relevant to the current task
- The user references work from a previous session that you have no memory of

Do NOT use when:
- Starting fresh with no prior context
- The user explicitly says to start from scratch

---

## The Process

### Step 1: Find the Log

Scan for the most recent log:

```bash
ls -t logs/*.md 2>/dev/null | head -5
```

If multiple logs exist: use the most recent unless the user specifies otherwise.

If no logs exist:
```
No previous session logs found in logs/. Starting fresh.
```

### Step 2: Read and Parse the Log

Read the full log. Extract:

| Section | What to restore |
|---------|----------------|
| **Session Summary** | What was being worked on |
| **What Was Done** | What's complete — don't repeat this |
| **Files Created / Modified** | Current state of the codebase |
| **Key Decisions** | Constraints and choices already made — don't re-litigate |
| **Context for Next Session** | Conventions, assumptions, current state |
| **Unresolved / Next Steps** | Where to start work |

### Step 3: Confirm with the User

Present a brief restoration summary before acting:

```
Restored from: logs/YYYY-MM-DD-HH-MM-topic.md

Last session worked on: [1 sentence]

Completed:
- [item]
- [item]

Ready to continue with:
- [ ] [first unresolved item]
- [ ] [second unresolved item]

Resume from the first unresolved item, or is there something specific you want to tackle?
```

**Wait for confirmation.** Don't start implementing until the user confirms.

### Step 4: Resume

After confirmation:
- Start from where the log's unresolved items indicate
- Apply the key decisions without re-debating them
- Use the file paths and conventions documented in the log

---

## If the Log is Outdated or Wrong

If the log doesn't match the current state of the codebase (files that should exist don't, etc.):

1. Note the discrepancy: "The log says X exists, but I don't see it"
2. Ask the user to clarify before proceeding
3. Don't guess — mismatched context causes compounding errors

---

## Common Failures

| Failure | What it looks like | Fix |
|---------|--------------------|-----|
| **Starting without confirming** | Jumping into implementation before user says "yes" | Always present the restoration summary and wait |
| **Re-doing completed work** | Repeating tasks listed in "What Was Done" | Mark completed items as done, start from Unresolved |
| **Re-litigating decisions** | "Should we have used X instead of Y?" | Key Decisions are settled — apply them, don't re-debate |
| **Ignoring discrepancies** | Proceeding despite mismatch between log and actual state | Surface the mismatch explicitly |

---

## Integration

**Pairs with:** `capturing-context` — this skill loads what that skill saves. `proactive-memory` — check recent observations for the project before or alongside reading the full log.

**Session continuity loop:**
```
Session starts → session-resume reads most recent log from logs/
              → also checks: rg "project: <name>" logs/observations.md | tail -20
session-resume → restores state and confirms → work continues
Session runs  → proactive-memory writes observations at pause points
Session ends  → capturing-context → logs/YYYY-MM-DD-HH-MM.md
```
